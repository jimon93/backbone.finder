EntrylistView
================================================================================
Entryの集合に対応するViewです。

Options
--------------------------------------------------------------------------------
EntrylistViewインスタンス作成時に設定することが可能です。
以下のように利用してください。

    entrylist = new EntrylistView({
        el : $("#entrylist"),
        entryOptions : { tagName : 'li' }
    });

#### el
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
**必須項目です**。

このViewが対応する要素を指定してください。
要素はDOM要素でもjQueryオブジェクトでも構いません。


#### entryOptions
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EntryViewを作成するときに使われるオプションです。


#### onAdd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EntryViewを表示する際に呼ばれる関数です。

デフォルトでは次のような関数が実行されます。

    function(view){
      view.$el.stop().css('opacity',1.0).hide().fadeIn()
    }


#### EntryView
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Entryに利用するViewを指定します。

デフォルトは`EntryView`です。


Note
--------------------------------------------------------------------------------
EntrylistView は backbone.View を継承して作られています。

他の仕様などはbackbone.Viewのリファレンスを参照してください。


