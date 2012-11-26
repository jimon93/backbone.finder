# About
backbone.finder.js は エントリーデータのリストに対して「検索」「ページ送り」の機能を
持ったコレクションと、そのコレクションに対応する「エントリーリスト」「ページナビゲーター」
「もっと見るボタン」を提供します。

# 読み込み
backbone.finder.js は backbone.js ライブラリーを必要とします。
backbone.js は underscore.js, jquery.js, json2.js を必要とします。

利用する場合は以下のようにしてください

    <script type="text/javascript" src="/js/json2.js"></script>
    <script type="text/javascript" src="/js/jquery-1.8.2.js"></script>
    <script type="text/javascript" src="/js/underscore.js "></script>
    <script type="text/javascript" src="/js/backbone.js"></script>
    <script type="text/javascript" src="/js/backbone.finder.js"></script>

# 簡単な使い方
1. Finder を作成します

        var finder = new Finder();

2. Entry用のテンプレートを作ります。

    これはHTML上の何処かに作成しておきます。
    デフォルトではidの値は'entry-view-tmpl'にしておいてください。

        <script id="entry-view-tmpl" type="text/template">
            <dt> <%= title %> </dt>
            <dd> <%= body %> </dd>
        </script>


3. _Entrylist_ を作成します。

    このとき作成した finder  を渡します。
    また、entrylist を実際に表示する DOM 要素や、
    作成するEntryViewのOptionsも指定します。

        var entrylist = new EntrylistView({
            model        : finder,
            el           : $("#finder-entrylist"),  // 適切なセレクタを選んでください
            entryOptions : {
                tagName : "dl"
            }
        });

4. もし必要ならば _navigator_ を作成します。

    これは ページ送り の View です。
    このとき作成した finder を渡します。
    また、navigator を実際に表示する DOM 要素も渡します。

        var navigator = new NavigatorView({
            model : finder,
            el : $("#finder-navigator")
        })

5. もし必要ならば _morepage_ を作成します。

    これは もっと見るボタン の View です。
    このとき作成した finder を渡します。
    また、morepage を実際に表示する DOM 要素も渡します。

        var morepage = new MorePageView({
            model : finder,
            el : $("#finder-morepage")
        })

6. データを読み込みます。

    finderの_load_メソッドを使います。

    読み込む方法は２つあります。

    1. jsonデータがあるURLを渡す

        自動的に読み込んでエントリーデータを構築します

            finder.load("/data.json");

    2. オブジェクトの配列を渡す

        その要素でエントリーデータを構築します

            finder.load([
                {id:1,title:"title1",body:"world 1"},
                {id:2,title:"title2",body:"world 2"},
                {id:3,title:"title3",body:"world 3"}
            ]);

# 簡単な説明
(backbone.jsの説明をやんわり含んでいます)

_finder_ はデータの操作を行いますが、DOMの操作は行いません。

代わりにデータが更新された時、finderに登録された関数を実行します。


_EntrylistView_, _NavigatorView_, _MorePageView_ はDOMの操作を行い実際に要素を表示したり消したり、クリックなどのイベントを設定したりします。

これら_View_はfinderに必要な関数を登録します。

finderがページを切り替えたら登録された関数が実行され、Viewの表示が切り替わります。

# 各要素の説明

* Model
    * [Entry](docs/entry.md)
      _見なくても大丈夫_
    * [Finder](docs/finder.md)
* Collection
    * [Entries](docs/entries.md)
      _見なくても大丈夫_
* View
    * [EntryView](docs/entry-view.md)
      _見なくても大丈夫_
    * [EntrylistView](docs/entrylist-view.md)
    * [NavigatorView](docs/navigator-view.md)
    * [MorePageView](docs/morepage-view.md)

# Q&A

## 検索条件を満たしたエントリーの数を取得したい

    finder.get('filterdEntries').length

## テンプレートとは

本ライブラリでは新しいエントリーを作成する際、テンプレートを使っています。
テンプレートはUnderscoreの`template`メソッドを使っています。


詳しくは Underscore のリファレンスを参照ください。
