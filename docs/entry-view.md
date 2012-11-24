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

Note
--------------------------------------------------------------------------------
EntryView は backbone.View を継承して作られています。

他の仕様などはbackbone.Viewのリファレンスを参照してください。

