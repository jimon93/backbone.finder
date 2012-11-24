Entry = Backbone.Model.extend { }

Entries = Backbone.Collection.extend {
  model: Entry

  initialize: ->
    _.bindAll( @, 'setUrl' )

  ###
  Entryisのurlを設定します
  このメソッドを使えばメソッドチェーンでfetchなどが可能です
  ###
  setUrl:(url)->
    @url = url
    return @
}

Finder = Backbone.Model.extend {
  defaults: {
    pageNumber      : 1
    pageSize        : 5
    prevQuery       : {}
    predicate       : (query, entry)->
      return false for key, val of query when val isnt entry.get(key)
      return true
  }

  initialize:->
    ###
    イベントの設定
    ###
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
    @on "change:pageNumber", => @trigger "change:page"

  ###
  エントリーデータを読み込みます
  引数
    1.URLもしくはエントリーデータの配列
    2.オプション
  ###
  #DOM要素やjQueryオブジェクトを渡されたら、それで構築するのもやってみたいですね
  load:( url = @get('url'), options = {} )->
    if _.isString url
      @get('allEntries').setUrl( url ).fetch(options).then =>
        @toPage(1)
    else if _.isArray url or _.isObject url
      @get('allEntries').reset( url , options )
      @toPage(1)
    else
      throw new Error "Can not load. Invalid argument."

  ###
  モデル1つに対して述語が真ならばfilterdEntriesに追加します
  ###
  filteringOne:( query = @get('prevQuery'), model, predi = @get('predicate') )->
    if not model?
      model = query
      query = @get('prevQuery')
    @set('prevQuery', query)
    predi = _.bind( predi, @, query )
    filtered = @get('filteredEntries')
    filtered.add(model) if predi model and not filtered.include model
    return @

  ###
  allEntriesに対して検索します
  引数
    1.検索条件
    2.述語関数
  ###
  filtering:( query = @get('prevQuery') , predi = @get('predicate') )->
    predi = _.bind( predi, @, query )
    @set('prevQuery', query)
    @get('filteredEntries').reset @get('allEntries').filter predi
    return @

  ###
  次のページがあるなら真、そうでなければ偽を返す
  ###
  hasNextPage:->
    @get('pageNumber') < @getMaxPageNumber()

  ###
  前のページがあるなら真、そうでなければ偽を返す
  ###
  hasPrevPage:->
    1 < @get('pageNumber')

  ###
  次のページへ移動する
  ###
  nextPage:->
    return @ if !@hasNextPage()
    @toPage( @get('pageNumber') + 1 )

  ###
  前のページへ移動する
  ###
  prevPage:->
    return @ if !@hasPrevPage()
    @toPage( @get('pageNumber') - 1 )

  ###
  現在のページに次のページのEntryを追加します
  ###
  morePage:->
    return @ if !@hasNextPage()
    page = @get('pageNumber') + 1
    @get( 'selectedEntries' ).add @getPageEntries page
    @set( 'pageNumber', page )

  ###
  指定したページへ移動します
  ###
  toPage:(page)->
    page = parseInt pase if _.isString page
    @get( 'selectedEntries' ).reset @getPageEntries page
    @set( 'pageNumber', 0, {silent:true} )
    @set( 'pageNumber', page )

  ###
  ページサイズが無限個になっているならば真、そうでなければ偽を返す
  ページサイズを無限個に設定するには0以下の値を設定してください。
  ###
  pageSizeIsInfinity:( pageSize = @get('pageSize') )->
    not pageSize? or pageSize <=  0

  ###
  最大のページ番号を返します
  ###
  getMaxPageNumber:->
    return 1 if @pageSizeIsInfinity()
    allSize = @get('filteredEntries').length
    Math.ceil allSize / @get('pageSize')

  ###
  指定したページ番号のEntryの配列を返します
  ###
  getPageEntries:(page)->
    pageSize = @get('pageSize')
    return @get('filteredEntries').chain().value() if @pageSizeIsInfinity(pageSize)
    skipSize = (page-1) * pageSize
    return @get('filteredEntries').chain().tail(skipSize).head(pageSize).value()

  ###
  現在のページにEntryを追加します
  ###
  _pageAdd: ( model, collection )->
    selected = @get('selectedEntries')
    selected.add model if selected.length < @get("pageSize")

  ###
  受け取ったイベントを、自分のイベントとして吐き出します
  ###
  _onCollectionEvent: ( event, model, collection, options)->
    @trigger('selected', model, collection, options)   if event is "add"
    @trigger('unselected', model, collection, options) if event is "remove"
    @trigger.apply(@,arguments)
}

EntryView = Backbone.View.extend {
  options : {
    template: "#entry-view-tmpl"
  }

  initialize : ->
    _.bindAll( @, 'render', '_getTemplate' )
    @events = @options.events if @options.events?
    @template = @_getTemplate(@options.template)

  render:->
    @$el.html @template( @model.toJSON() )
    return @

  ###
  テンプレートを取得します
  メモ化していますので、引数が同じ関数を複数回呼ぶ場合、2回目以降はキャッシュされたものが返ります
  ###
  _getTemplate : _.memoize ( tmpl ) ->
    tmpl = $( tmpl ) #if _.isString tmpl
    throw new Error "A template does not exist" if tmpl.length is 0
    _.template tmpl.html()
}

EntrylistView = Backbone.View.extend {
  options : {
    'EntryView' : EntryView

    onAdd : (view)->
      view.$el.stop().css('opacity',1.0).hide().fadeIn()

    entryOptions : {}
  }

  initialize : ->
    _.bindAll( @, "render", "_add", "_getView" )
    @model.on "reset", @render
    @model.on "add", @_add

  render :  ->
    @$el.html '' # remove にしても良いか要確認
    @model.get('selectedEntries').each @_add
    return @

  _add : (entry) ->
    view = @_getView entry
    @$el.append view.render().el
    @options.onAdd view if _.isFunction @options.onAdd

  _getView : _.memoize(
    (model)->
      options = _.extend( {}, {model}, @options.entryOptions )
      new @options.EntryView(options)
    (model)->
      model.id
  )
}

NavigatorView = Backbone.View.extend {
  options : {
    viewCount: 5
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
    @model.on "change:page", @render

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
      @$el.append "<span>#{op.exString}</span>" if 1 < nowPage - op.viewCount
      for i in [1..maxPage]
        if nowPage - op.viewCount <=  i <= nowPage + op.viewCount
          if i == nowPage
            @$el.append "<span>#{i}</span>"
          else
            @$el.append "<a class='page-jump' href='##{i}page' data-to-page='#{i}'>#{i}</a>"
      @$el.append "<span>#{op.exString}</span>" if nowPage + op.viewCount < maxPage
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
    @model.on "change:page", @render
    @render()

  render:->
    if @model.get('pageNumber') < @model.getMaxPageNumber()
      @$el.show()
    else
      @$el.hide()
    return @

  _morePage:(event)->
    @model.morePage()
    return false
}

###
using = ->
  classes = ['Entry','Entries','Finder','EntryView','EntrylistView','NavigatorView','MorePageView']
  this[name] = root[name] for name in classes
###
