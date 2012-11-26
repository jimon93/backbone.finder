EntryView
================================================================================
Entryに対応するViewです。

Options
--------------------------------------------------------------------------------
EntryViewインスタンス作成時に設定することが可能です。
以下のように利用してください。

    entry = new EntryView({
        tmplate : "#entry-tmplate"
        events : {
            "click .hello" : function(e){
                alert( "hello world!" );
            }
        }
    });

また、EntryViewを継承した新しいEntryViewを作ることで、先ほどと同等の設定が可能です。

    NewEntryView = EntryView.extend({
        options : {
            tmplate : "#entry-tmplate"
        }

        events : {
            "click .hello" : "hello"
        }

        "hello" : function(e){
            alert( "hello world!" );
        }
    });

新しく作成したEntryViewは、EntrylistView作成時に指定することで利用可能です。

    entrylist = new EntrylistView({
        'EntryView' : NewEntryView
    });

#### template
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
使用するテンプレートを指定します。
文字列の場合、selectorとして判断します。

テンプレートは _.template を用いて展開されます。
テンプレート記法に関しては UnderScore を参照してください。

デフォルトは `"#entry-view-tmpl"` です。

#### events
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
エントリーに対応するイベントを設定します。

* key : "event名 セレクタ"
* val : 実行される関数
* 例

        envents : {
            // .button がクリックされたら実行
            "click .button" : function(e){ },
            // どこかがダブルクリックされたら実行
            "dbclick" : function(e){ }
        }

関数内の_this_は_view_にbindされています。

テンプレートとは
--------------------------------------------------------------------------------
本ライブラリでは新しいエントリーを作成する際、テンプレートを使っています。
テンプレートはUnderscoreの`template`メソッドを使っています。

* テンプレート用要素を用意します。

    表示されないようにCSSで'display:none'を指定してください。
    もしくは、`type="text/template"`の`script`ならばCSSの調整なしに
    非表示でDOM要素として埋め込めます。

        <script id="template" type="text/template">
        </script>

* テンプレートごとに展開される内容を書き込む。

        <script id="template" type="text/template">
            <dt></dt>
            <dd></dd>
        </script>

* javascript文を埋め込みたい場合は、特別な書き方をする。

    `<% %>`はjavascriptを埋め込むことができます。
    if文などは次のように書きます

        <% if( id % 2 == 0 ){ %> 真 <% }else{ %> 偽 <% } %>

* データの値を参照して埋め込みたい場合は、特別な書き方をする。

    `<%= %>` `<%- %>` はデータを埋め込みます。
    `<%= %>` はデータを生のまま出力します。
    `<%- %>` はデータをHTMLエスケープして出力します。

        <script id="template" type="text/template">
            <dt><%= title %></dt>
            <dd><%= body %></dd>
        </script>

* 出来たテンプレートをEntryView作成時に渡してください。

    このとき Selector でも jQueryオブジェクト どちらでも構いません。

        new EntryView({
            tmplate : "#tmplate"
        });

詳しくは Underscore のリファレンスを参照ください。
Note
--------------------------------------------------------------------------------
EntryView は backbone.View を継承して作られています。

他の仕様などはbackbone.Viewのリファレンスを参照してください。

