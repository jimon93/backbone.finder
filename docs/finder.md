Finder
================================================================================

Attributes
--------------------------------------------------------------------------------
#### はじめに
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
AttributesはFinderがもつ属性です。
設定項目と言い換えても良いかもしれません。

getメソッドでAttributesの取得が、
setメソッドでAttributesの設定が出来ます。

FinderはAttributesをインスタンス作成時に指定が可能です。
次のようにしてください。

    new Finder({
        pageSize :10,
        predicate : function(){ return true; }
    });


#### pageSize
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
１ページに含むエントリーの数です。

0以下の値を設定すると無限個数のエントリーを表示します。

初期値は５です。


#### predicate
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
検索時に用いる述語関数です。

関数は次の仕様を満たすものとします。

* 引数
    1.  検索条件のオブジェクト
    2.  検索対象となるEntryのオブジェクト
* 返り値
    * 検索条件を満たしているなら真、
      そうでなければ偽を返す

デフォルトでは
queryの全てのkeyとentryが保持するエントリーのkeyが同一のものが同じ値ならば真になります。
次のコードはCoffeeScript書かれた実際のデフォルト関数です。

    (query, entry)->
          return false for key, val of query when val isnt entry.get(key)
          return true


#### pageNumber
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
現在のページ番号です。

書き換え非推奨です。
ページを変える場合は`nextPage` `prevPage` `toPage` などを使ってください。


#### prevQuery
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
１つ前の検索条件です。

書き換え非推奨です。


#### allEntries
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loadしたEntryを保持するEntriesです。

初期設定不可です。


#### filteredEntries
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
検索条件を満たしたEntryを保持するEntriesです。

初期設定不可です。


#### selectedEntries
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
現在のページで表示されているEntryを保持するEntriesです

初期設定不可です。


Methods
--------------------------------------------------------------------------------
#### get
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
attributeの値を取得します。

* 引数
    1. 取得したいattributeの項目名
* 返り値
    * 指定したattributeの値

例えば現在のページ番号を取得したい場合、次のようにします。

    finder.get('pageNumber');

#### set
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
attributeの値を変更します。

* 引数
    1. 設定するattributeの項目名
    2. 設定する新しい値
* 返り値
    * 自身のFinderオブジェクト

例えば現在の１ページあたりの表示サイズを変更したい場合、次のようにします。

    finder.get('pageSize', 10);


#### load
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
エントリーデータを読み込んで構築します。

このメソッドはFinderを１ページ目に変えます。

* URLから読み込む
    * 引数
        1. JSONデータのあるURL文字列
    * 返り値
        * 自身のFinderオブジェクト
    * 例

            finder.load("/data.json");

* エントリーデータの配列から読み込む
    * 引数
        1. エントリーデータの配列
    * 返り値
        * 自身のFinderオブジェクト
    * 例

            finder.load([
                {id:1,title:"title1",body:"world 1"},
                {id:2,title:"title2",body:"world 2"},
                {id:3,title:"title3",body:"world 3"}
            ]);


#### on
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
イベントを追加します。

登録されたイベントは対応したkeyがtriggerされた(これを発火といいます)時、実行されます。

詳しいイベントに関してはこのページの**Event**の項目を参照してください。

* 引数
    1. 対応するイベントの文字列
    2. 登録したい関数
* 返り値
    * 自身のFinderオブジェクト

    finder.on('reset',function(){ alert('reset!'); });

    //finderが自分でresetされたなと思ったら、resetをtriggerします。
    finder.trigger('reset')
    //すると、先程登録した関数が実行され、alertが表示されます。


#### filtering
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
検索を行います。

検索を行うと filteredEntriesを更新します。

filteredEntriesが更新されると１ページ目のselectedEntriesを構築します。
'reset'と'change:page'が発火します。

* 引数
    1.  検索条件のオブジェクト.
        省略した場合、前回の検索条件を使います。
    2.  検索方法の述語関数.
        仕様要求はattributeの predicate と同じです。
        省略した場合、attributeのpredicateを用います。
* 返り値
    * 自身のFinderオブジェクト


#### hasNextPage
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 引数
    * なし
* 返り値
    * 次のページが存在するなら真を返します。
    そうでなければ偽を返します。


#### hasPrevPage
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 引数
    * なし
* 返り値
    * 前のページが存在するなら真を返します。
    そうでなければ偽を返します。


#### nextPage
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
次のページのselectedEntriesを構築します。
'change:page'が発火します。

* 引数
    * なし
* 返り値
    * 自身のFinderオブジェクト


#### prevPage
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
前のページのselectedEntriesを構築します。
'change:page'が発火します。

* 引数
    * なし
* 返り値
    * 自身のFinderオブジェクト


#### toPage
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
指定したページのselectedEntriesを構築します。
'change:page'が発火します。

* 引数
    1. 遷移したいページ番号
* 返り値
    * 自身のFinderオブジェクト


#### morePage
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
現在のselectedEntriesに次のページに含まれるEntryを追加します。

* 引数
    * なし
* 返り値
    * 自身のFinderオブジェクト


#### getMaxPageNumber
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 引数
    * なし
* 返り値
    * 現在のページ数.


Event
--------------------------------------------------------------------------------
**これだけ知ってればなんとかなるイベント**

* reset
    + FinderはselectedEntriesが(再)構築された時 _reset_ を発火します。
    + どんなメソッドで発火する？
        - load
        - filtering
        - nextPage
        - prevPage
        - toPage
    + 登録した関数はどんな引数をもらうの？
        1. selectedEntries
        2. Option
        (よくわからん)

* add
    + FinderはselectedEntriesにEntryが追加された時 _add_ を発火します。
    + どんなメソッドで発火する？
        - morePage
    + 登録した関数はどんな引数をもらうの？
        1. 追加されたentry
        2. selectedEntries
        3. Option
        (よくわからん)

* change:page
    + Finderはページが切り替わった時 _change:page_ を発火します。
    + finder自身のpageNumberの属性が正しく設定された後に発火しますので、
    finderのpageNumberを使う場合はresetではなくこちらをお使いください。


**知らなくてもいい話**

FinderはselectedEntriesが発火するイベントを全て発火しています。


Note
--------------------------------------------------------------------------------
Finderは backbone.Model を継承して作られています。

他のメソッドなどはbackbone.Modelのリファレンスを参照してください。
triggerメソッドなどはそこにあります。
