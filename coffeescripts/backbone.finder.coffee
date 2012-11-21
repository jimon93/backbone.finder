# 名前空間をガリガリ汚染してます!
Entry = Backbone.Model.extend { }

Entries = Backbone.Collection.extend {
  model: Entry

  initialize: ->
    _.bindAll( @, 'setUrl' )

  setUrl:(url)->
    @url = url
    return @
}

Finder = Backbone.Model.extend {
  defaults: {
    pageNumber      : 1
    pageSize        : 5
    prevQuery       : {}
    predicate       : (query, model)->
      return false for key, val of query when val isnt model.get(key)
      return true
  }

  initialize:->
    filtering      = _.bind( @filtering, @, null, null )
    filteringOne   = (model) => @filteringOne model
    initializePage = _.bind( @toPage, @, 1 )
    _.bindAll( @, 'load', 'filteringOne', 'filtering', 'hasNextPage', 'hasPrevPage', 'nextPage', 'prevPage', 'morePage', 'toPage', 'pageSizeIsInfinity', 'getMaxPageNumber', 'getPageEntries', '_onCollectionEvent', '_pageAdd' )

    @set( 'allEntries'      , new Entries ) if not @has('allEntries')
    @set( 'filteredEntries' , new Entries ) if not @has('filteredEntries')
    @set( 'selectedEntries' , new Entries ) if not @has('selectedEntries')

    @get('allEntries').on "reset", filtering
    @get('allEntries').on "add", filteringOne

    @get('filteredEntries').on "add" , @_pageAdd
    @get('filteredEntries').on "reset" , initializePage

    @get('selectedEntries').on 'all' , @_onCollectionEvent

    @on "change:pageSize", initializePage

  load:( url = @get('url'), options = {} )->
    if _.isString url
      @get('allEntries').setUrl( url ).fetch(options)#.then =>
    else if _.isArray url or _.isObject url
      @get('allEntries').reset( url , options )
    else
      throw new Error "Can not load. Invalid argument."
    @set('pageNumber', 0, {silent:true})
    @toPage(1)

  filteringOne:( query = @get('prevQuery'), model, predi = @get('predicate') )->
    if not model?
      model = query
      query = @get('prevQuery')
    @set('prevQuery', query)
    predi = _.bind( predi, @, query )
    filtered = @get('filteredEntries')
    filtered.add(model) if predi model and not filtered.include model
    return @

  filtering:( query = @get('prevQuery') , predi = @get('predicate') )->
    predi = _.bind( predi, @, query )
    @set('prevQuery', query)
    @get('filteredEntries').reset @get('allEntries').filter predi
    return @

  hasNextPage:->
    @get('pageNumber') < @getMaxPageNumber()

  hasPrevPage:->
    1 < @get('pageNumber')

  nextPage:->
    return @ if !@hasNextPage()
    @toPage( @get('pageNumber') + 1 )

  prevPage:->
    return @ if !@hasPrevPage()
    @toPage( @get('pageNumber') - 1 )

  morePage:->
    return @ if !@hasNextPage()
    page = @get('pageNumber') + 1
    @get( 'selectedEntries' ).add @getPageEntries page
    @set( 'pageNumber', page )

  toPage:(page)->
    page = parseInt pase if _.isString page
    @get( 'selectedEntries' ).reset @getPageEntries page
    @set( 'pageNumber', page )
    @trigger( 'pageChanged' )

  pageSizeIsInfinity:( pageSize = @get('pageSize') )->
    not pageSize? or pageSize <=  0

  getMaxPageNumber:->
    return 1 if @pageSizeIsInfinity()
    allSize = @get('filteredEntries').length
    Math.ceil allSize / @get('pageSize')

  getPageEntries:(page)->
    pageSize = @get('pageSize')
    return @get('filteredEntries').chain().value() if @pageSizeIsInfinity(pageSize)
    skipSize = (page-1) * pageSize
    return @get('filteredEntries').chain().tail(skipSize).head(pageSize).value()

  _pageAdd: ( model, collection )->
    selected = @get('selectedEntries')
    selected.add model if selected.length < @get("pageSize")

  _onCollectionEvent: ( event, model, collection, options)->
    @trigger('selected', model, collection, options)   if event is "add"
    @trigger('unselected', model, collection, options) if event is "remove"
    @trigger.apply(@,arguments)
}

EntryView = Backbone.View.extend {
  options : {
    templateSelector : "#entry-view-tmpl"
  }

  initialize : ->
    _.bindAll( @, 'render', 'getTemplate' )
    @events = @options.events if @options.events?
    @template = @getTemplate()

  render:->
    #console.log @$el.html("hey")
    #@setElement( @template( @model.toJSON() ), true )
    @$el.html @template( @model.toJSON() )
    return @

  getTemplate : _.memoize ( tmpl = $(@options.templateSelector) ) ->
    throw new Error "A template does not exist" if tmpl.length is 0
    _.template tmpl.html()
}

EntrylistView = Backbone.View.extend {
  options : {
    entryView : EntryView

    containerSelector : ".entry-container"

    onAdd : (view)->
      view.$el.stop().css('opacity',1.0).hide().fadeIn()
  }

  initialize : ( options = {} )->
    _.bindAll( @, "_reset", "_add", "_getView" )
    @$container = @$( @options.containerSelector )
    @model.on "reset", @_reset
    @model.on "add", @_add

  _reset : (collection) ->
    @$container.html ''
    collection.each @_add

  _add : (model,collection) ->
    view = @_getView model
    @$container.append view.render().el
    @options.onAdd view if _.isFunction @options.onAdd

  _getView : _.memoize(
    (model)->
      new @options.entryView {model}
    (model)->
      model.id
  )
}

NavigatorView = Backbone.View.extend {
  options : {
    viewNumber: 5
    separater: ' | '
    nextString: '次のページ'
    prevString: '前のページ'
    exString:'...'
  }

  events : {
    "click a.nextlink" : '_nextPage'
    "click a.prevlink" : '_prevPage'
    "click a.page-jump": '_toPage'
  }

  initialize:->
    _.bindAll( @, 'render', '_nextPage', '_prevPage', '_toPage' )
    @model.on "pageChanged", @render

  render:->
    op = @options
    nowPage = @model.get('pageNumber')
    maxPage = @model.getMaxPageNumber()
    @$el.html ''
    if maxPage <= 1
      @$el.hide()
    else
      @$el.show()
      @$el.append "<a class='prevlink' href='#prev'>#{op.prevString}</a><span>#{op.separater}</span>" if @model.hasPrevPage()
      @$el.append "<span>#{op.exString}</span>" if 1 < nowPage - op.viewNumber
      for i in [1..maxPage]
        if nowPage - op.viewNumber <=  i <= nowPage + op.viewNumber
          if i == nowPage
            @$el.append "<span>#{i}</span>"
          else
            @$el.append "<a class='page-jump' href='#to-#{i}' data-to-page='#{i}'>#{i}</a>"
      @$el.append "<span>#{op.exString}</span>" if nowPage + op.viewNumber < maxPage
      @$el.append " #{op.separater} <a class='nextlink' href='#next'>#{op.nextString}</a>" if @model.hasNextPage()
    return @

  _nextPage:(event)->
    @model.nextPage()
    return false

  _prevPage:(event)->
    @model.prevPage()
    return false

  _toPage:(event)->
    @model.toPage( $(event.currentTarget).data('to-page') )
    return false
}

MorePageView = Backbone.View.extend {
  events : {
    "click" : '_morePage'
  }

  initialize:->
    _.bindAll( @, 'render', '_morePage' )
    @model.on "pageChanged", @render
    @render()

  render:->
    if @model.get('pageNumber') < @model.getMaxPageNumber()
      @$el.show()
    else
      @$el.hide()

  _morePage:(event)->
    @model.morePage()
    return false
}
