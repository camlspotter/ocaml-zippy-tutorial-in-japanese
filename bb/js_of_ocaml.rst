=========================================
ウェブブラウザで関数型言語を使う: js_of_ocaml
=========================================

js_of_ocaml が熱い。 Google の Dart とか、そんな場合じゃない!!

OCaml で書かれたプログラムがなぜか JavaScript に変換され、それがブラウザで動く。
JS で型がついていないオブジェクトでも何となく型をつけて OCaml 側で型安全性にブラウザで動くプログラムを書ける。生産力向上のチャンス!

え？よくわからない？ http://ocsigen.org/js_of_ocaml/manual/ の demo を試してご覧なさい。これが全部 OCaml で書かれている…!

レシピと下準備
==============

- ocaml http://ocaml.inria.fr/
    なきゃぁ話しにならんわな
 
- findlib http://projects.camlcity.org/projects/findlib.html
    真面目に OCaml やるなら入れてるよな!
    
- lwt http://www.ocsigen.org/lwt/
    Light Weight Thread ライブラリ。 協調スレッドですからロックとかいりません。 Monadic に書きます。 Jane Street の Async も同じようなもの。片方わかればもう片方も普通に書ける。

- js_of_ocaml http://ocsigen.org/js_of_ocaml/
    肝心要の js_of_ocaml

これを上から下に順番にインストール。 
Linux なら特に問題ないはず。問題ある？それは残念ですね…

動いてる？
-----------------

js_of_ocaml の examples ディレクトリで make したらブラウザで index.html にアクセス。いくつかデモがあるから動かしてみよう。
動くはず。動かない？それは…

どうやって使う？
=================

じゃあ早速 js_of_ocaml で何か作ってみよう! と言いたいところだが、まずは例題を自分の環境でコンパイルしてみるところから。
examples ディレクトリにある例題の Makefile はソースをビルドした環境を仮定しているので、それを単にコピーするわけにはいかない。
examples/cubes を自分の作業用ディレクトリにコピーして、次のコマンドを実行してみよう::

    # camlp4o を利用した js_of_ocaml の文法拡張を使い、 lwt ライブラリを使用して cubes.ml をコンパイル
    ocamlfind ocamlc -syntax camlp4o -package lwt,js_of_ocaml.syntax -g -c cubes.ml

    # lwt と js_of_ocaml ライブラリを使って、 cubes.cmo とライブラリを cubes.byte にリンク。
    ocamlfind ocamlc -package lwt,js_of_ocaml -linkpkg -o cubes.byte cubes.cmo

    # cubes.byte を js_of_ocaml コンパイラを使用して cubes.js ファイルに変換
    js_of_ocaml cubes.byte 

上手くいけば cubes.js ファイルが出来上がっている。 
index.html をブラウザで開けばなんか妙なデモが始まるはず。始まらない？そ…

この 3つのビルドステップは Makefile に書いておくといい。私は OMake を使っているが極まりすぎているので公開してもあまり意味がないだろう。
まあ、遊ぶだけなら shell スクリプトでも書いておけばいいはず。Shell スクリプトが書けない？…

じゃあ、何か作ってみよう!
============================

例として既存の javascript を使用した例題を js_of_ocaml に少しづつ以降していくことにしよう。 
Google chart とか、うまくいくと便利そうだから、これにしようっと。

まず http://code.google.com/intl/ja/apis/chart/interactive/docs/quick_start.html の例をコピーしてブラウザで動くかどうか確認::

    <html>
      <head>
        <!--Load the AJAX API-->
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript">
        
          // Load the Visualization API and the piechart package.
          google.load('visualization', '1.0', {'packages':['corechart']});
          
          // Set a callback to run when the Google Visualization API is loaded.
          google.setOnLoadCallback(drawChart);
          
          // Callback that creates and populates a data table, 
          // instantiates the pie chart, passes in the data and
          // draws it.
          function drawChart() {
    
          // Create the data table.
          var data = new google.visualization.DataTable();
          data.addColumn('string', 'Topping');
          data.addColumn('number', 'Slices');
          data.addRows([
            ['Mushrooms', 3],
            ['Onions', 1],
            ['Olives', 1], 
            ['Zucchini', 1],
            ['Pepperoni', 2]
          ]);
    
          // Set chart options
          var options = {'title':'How Much Pizza I Ate Last Night',
                         'width':400,
                         'height':300};
    
          // Instantiate and draw our chart, passing in some options.
          var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
          chart.draw(data, options);
        }
        </script>
      </head>
    
      <body>
        <!--Div that will hold the pie chart-->
        <div id="chart_div"></div>
      </body>
    </html>

動くよね？ 

js_of_ocaml 第一歩
=======================

じゃあ、この２つ目の script タグの部分を js_of_ocaml に移していこう! まず、この部分を完全にカットして、 chart.js を読み込むようにする::

    <html>
      <head>
        <!--Load the AJAX API-->
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript" src="chart.js"></script>
      <body>
        <!--Div that will hold the pie chart-->
        <div id="chart_div"></div>
      </body>
    </html>

で、この chart.js の部分を js_of_ocaml を使って chart.ml で記述していきましょう。どうするか？まずは超簡単に::

    open Js
    
    let _ = Unsafe.eval_string "
            
                  // Load the Visualization API and the piechart package.
                  google.load('visualization', '1.0', {'packages':['corechart']});
                  
                  // Set a callback to run when the Google Visualization API is loaded.
                  google.setOnLoadCallback(drawChart);
                  
                  // Callback that creates and populates a data table, 
                  // instantiates the pie chart, passes in the data and
                  // draws it.
                  function drawChart() {
            
                  // Create the data table.
                  var data = new google.visualization.DataTable();
                  data.addColumn('string', 'Topping');
                  data.addColumn('number', 'Slices');
                  data.addRows([
                    ['Mushrooms', 3],
                    ['Onions', 1],
                    ['Olives', 1], 
                    ['Zucchini', 1],
                    ['Pepperoni', 2]
                  ]);
            
                  // Set chart options
                  var options = {'title':'How Much Pizza I Ate Last Night',
                                 'width':400,
                                 'height':300};
            
                  // Instantiate and draw our chart, passing in some options.
                  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
                  chart.draw(data, options);
                }
    "

あれ？ほとんど元の JavaScript ではないか。そう。とりあえず、 Js.Unsafe.eval_string という文字列をそのまま JS として評価する関数があるので、それを使ってみたわけだ。これで、::

    ocamlfind ocamlc -syntax camlp4o -package lwt,js_of_ocaml.syntax -g -c chart.ml
    ocamlfind ocamlc -package lwt,js_of_ocaml -linkpkg -o chart.byte chart.cmo
    js_of_ocaml chart.byte 

を実行する、そんで index.html を読み込む。 Pie chart が出るはず。出ない？…

そら eval するだけだから出るのは当たり前だろう、バカにしているのか？と言ってはいけない。 js_of_ocaml、まず第一歩はこういう eval から始めるのがいいみたい。とりあえずワケわからなくなったら Js.Unsafe.eval_string で様子を見てみる、これ大切。

関数を作って JS に渡してみよう!
====================================

もうすこし複雑なことをしてみよう。 JS の drawChart 関数を OCaml に移す::

    open Js
            
    let drawChart () = Unsafe.eval_string "
                  // Create the data table.
                  var data = new google.visualization.DataTable();
                  data.addColumn('string', 'Topping');
                  data.addColumn('number', 'Slices');
                  data.addRows([
                    ['Mushrooms', 3],
                    ['Onions', 1],
                    ['Olives', 1], 
                    ['Zucchini', 1],
                    ['Pepperoni', 2]
                  ]);
            
                  // Set chart options
                  var options = {'title':'How Much Pizza I Ate Last Night',
                                 'width':400,
                                 'height':300};
            
                  // Instantiate and draw our chart, passing in some options.
                  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
                  chart.draw(data, options);
               "
      
    let _ = Unsafe.eval_string "
                  // Load the Visualization API and the piechart package.
                  google.load('visualization', '1.0', {'packages':['corechart']});
            ";
            Unsafe.meth_call (Unsafe.variable "google") "setOnLoadCallback" [| Unsafe.inject drawChart |]

JS の drawChart 関数をそのまま OCaml の drawChart 関数に写しただけ。相変わらず、中身は eval_string。
この OCaml の drawChart 関数は js_of_ocaml コンパイラでコンパイルしても drawChart という名前にはならない。
だから、drawChart を使う、元の JS の google.setOnLoadCallback(drawChart); メソッド呼び出しはそのまま eval_string することはできない。
Unsafe.meth_call を使う::

            Unsafe.meth_call (Unsafe.variable "google") "setOnLoadCallback" [| Unsafe.inject drawChart |]

- Unsafe.meth_call は JS のメソッド呼び出し。第一引数が JS のオブジェクト、第二がメソッド名、第三が引数配列。
- オブジェクトは JS で google と言う変数に束縛されているので Unsafe.variable "google" として、その変数を使う
- メソッド名は文字列なのでそのまま
- 引数はひとつ、 drawChart 関数を渡すのだけど、そのままでは型が合わないので Unsafe.inject を使う

これで動くはず。動かない？それは残念ですね… と言いたいところだが、

動かなかったら
--------------------

js_of_ocaml で何か上手く行かなかったら、こうするといい

  - アウトプットの js ファイルを良く見る。なんとなく読める。 (というか OCaml のバイトコードからそれなりに人間が読める JS コードを吐ける事に驚く。バイトコードがあればリバースエンジニアリングできるということだからだ! (10年ほど前にはそんな事は出来っこないから、商用コードでもバイトコードで配布すれば安心!というのが常識だった))
  - ブラウザのエラーコンソールを良く見る。なんとなくわかる。

とにかく、急いで全部 OCaml にしない事。一歩々々確かめて、知見はメモするのがいい。この Chart 移植作業中にもいくつかポイントがあった。瑣末だから敢えて書かないけど。

まあ、 Unsafe ですから!!
--------------------------

Unsafe モジュールの関数は超低レベル。とにかく JS と話をするためだけに作られている。型を合わせていない。だから簡単な間違いでも型検査で見つけることができない。そこんとこ宜しく。

文字列と JS literal object
===============================

とりあえず drawChart の eval_string は置いておいて、下の数行をもうちょっと OCaml っぽくしていこう::

    let google = Unsafe.variable "google"
    let _ = 
        (* Load the Visualization API and the piechart package. *)
        Unsafe.meth_call google "load" [| Unsafe.inject (Js.string "visualization"); 
                                          Unsafe.inject (Js.string "1.0");
                                          Unsafe.inject (Unsafe.variable "{'packages':['corechart']}") |];
        Unsafe.meth_call google "setOnLoadCallback" [| Unsafe.inject drawChart |]

ここでの改変ポイントは

- OCaml 文字列は Js.string 関数で JS の文字列オブジェクトに変更。 Unsafe.meth_call に不安全に突っ込むために Unsafe.inject を使用。
- JS literal object {'packages':['corechart']} は今の所良い記述法が無いので Unsafe.variable "文字列" で代用

JS literal object については実は {: packages = [ "corechart" ] :} みたいな書き方ができるようなパッチがつい最近出たみたいだけど、 stable 版には入っていないみたい。とりあえず変数として文字列をぶち込めば、気持ち悪いけど動く。 取り入れられるまで、待ちましょう。

とりあえず、ここんとこ改変して動かしてみよう。

Class type で JS のオブジェクトをエンコード
=========================================

さて、ここから面白くなってくる。 JS に型もクソもないが、JS のオブジェクトの型を何となく OCaml の class type として記述することで、 JS のオブジェクトのインターフェースを OCaml内のクラスとして型安全に使用することが出来る!。 今まで例を引き続き使って、 google オブジェクトのクラス型を考えよう::

    class type g = object
      method load : js_string t -> js_string t -> 'a t -> unit meth
      method setOnLoadCallback : (unit -> unit) -> unit meth
    end
    
とりあえず、 google のメソッドは load と setOnLoadCallback を使っている。このメソッドを持つ class type g を定義している。

メソッドの OCaml でのあるべき型を何となく想像しよう。例えば、 load は string を二つ、その次によくわからない JS object を受け取り、返り値は unit でいいだろう。つまり、 string -> string -> 'a -> unit だ。 'a はとりあえず、よくわかんないから型変数にしておいた。

class type g の load メソッドが、この型を持つと宣言するのだが、そのまま string -> string -> 'a -> unit と書くわけではなく、ちょっとした変換が必要だ。ここんとこちょい面倒で自動で出来そうなものだが、まあ、ルールは簡単だから手でもできる

- JS のオブジェクトの型は 'a Js.t。 'a は phantom type でオブジェクトの中身の型。例えば JS の文字列オブジェクトの型は js_string Js.t になる。 ここでは open Js しているので js_string t になっている。

- リターンの型は別の phantom type 'a meth で修飾する。ここでは、なんとなく想像したリターン型は unit だから unit meth。

- わかんない型もとりあえず 'a t として、何か JS のオブジェクトが来るってことにする。もちろん型安全性は失われるが、どうせ JS だから。

- 引数の型が関数の場合、オブジェクトではないので t で修飾する必要は無い。

というわけで、 method load の型は js_string t -> js_string t -> 'a t -> unit meth になる。

setOnLoadCallback も同様。このメソッドはコールバック関数をもらってそれを登録するから、 OCaml 的には (unit -> unit) -> unit の型を持つ。これを上のルールに従って変換する。 (unit -> unit) -> unit meth。

さて、インターフェースを OCaml の型で宣言できた。 変数 google にはこのインターフェースを持つオブジェクトが入っているはずだから、それを明示しよう::

    let google : g t = Unsafe.variable "google"

google は JS object なので g t って型になる。 t を忘れないように。

js_of_ocaml では c JS.t という型、つまり c というインターフェースを持つ JS object に対し、特殊な糖衣構文を使って型安全にメソッド呼び出しができる::

    let _ = 
        (* Load the Visualization API and the piechart package. *)
        google##load (Js.string "visualization",
                      Js.string "1.0",
                      Unsafe.variable "{'packages':['corechart']}");
        google##setOnLoadCallback (drawChart)
    
ここでのポイントは

- OCaml の普通のメソッド呼出 # と違って、 ## を使う
- JS のメソッドは uncurry form で呼び出す。 class type での宣言は curried であるのだが。
- 一引数、ゼロ引数であっても JS メソッド名の後には () が必須。 google##setOnLoadCallback drawChart とは書けない

当然ながら今度は Unsafe を多用していた時と違って、かなり型安全になっている。例えば setOnLoadCallback に違う型の関数を適用することはできない。

js_of_ocaml ではこんな風に、既存の JS クラスに適当な型を与えて OCaml 側で型安全性を使ったプログラミングが出来る。もし完全に型をエンコードできなければ型変数を使ってとりあえず、その部分だけの型安全性を諦めることも出来る。非常に柔軟かつ簡単に複雑な JS 資産を OCaml 側で利用できる仕組みを持っていると言えるだろう。

例によって、最後の部分をこの class type 宣言、 google の定義、 google の使用のコード片に書き換えて動作を確認しよう。

プロパティと new
============================================

さて、これで元の JS の最後の部分は OCaml に移すことが出来た。 (JS literal object が甘いが、今の所エレガントにはできないのだからまあ、よしとする) こんどは drawChart の eval_string の部分を移植していこう。

ここでの問題は、 new google.visualization.PieChart() に見られる、

- google.visualization というプロパティアクセス
- new

の二つ。

プロパティも class type にエンコード
-------------------------------------------- 

JS object のプロパティも class type にエンコードすることで OCaml 側でアクセスすることが可能だ。 visualization というプロパティを google のクラス型 g に足してみよう：：

    class type g = object
      method load : js_string t -> js_string t -> 'a t -> unit meth
      method setOnLoadCallback : (unit -> unit) -> unit meth
      method visualization : 'a t readonly_prop
    end
    
とりあえず、 google.visualization の型は何かわからないので 'a t という型にしておいた。 google.visualization はメソッドではなく、プロパティなので、 meth の代わりに readonly_prop という phantom type を使う。こう記述しておくと、 google##visualization という OCaml コードで JS の google.visualization にアクセスできる。

もし JS object o のプロパティ p が変更可能な場合、 readonly_prop の代わりに普通の prop を使う。その場合は、 o##p でプロパティを読み出すだけでなく、 o##p <- e でプロパティの上書きが可能だ。

クラスコンストラクタ は constr でエンコード
------------------------------------------

上では visualization はとりあえず 'a t という型だと想定したが、 new google.visualization.PieChart(...) という使われ方をしているから、

- PieChart にアクセスできる
- PieChart は HTML の要素を取って new できる

事が判る。今度はこの visualization を OCaml の class type にエンコードしよう::

    class type v = object
      method _PieChart : (Dom_html.element t -> 'a t) constr readonly_prop
    end

- PieChart は大文字から始まる。 OCaml では大文字から始まるメソッドは定義できないので _ を前に付ける。 _PieChart。
- PieChart は read only prop
- PieChart はオブジェクトではなく新しいオブジェクトを new できるコンストラクタ。なので constr phantom type でそれを明示。
- new google.visualization.PieChart(e) は HTML の element を取る。その型は Dom_html.element t。 そして作られるオブジェクトは…例によって良く判らないので 'a t にしておく

v を用意したので、 google.visualizaiton の型は v t と書くことが出来る。 class type g を修正::

    class type g = object
      method load : js_string t -> js_string t -> 'a t -> unit meth
      method setOnLoadCallback : (unit -> unit) -> unit meth
      method visualization : v t readonly_prop
    end

これで、準備完了。 new google.visualization.PieChart(e) は OCaml では次のように書くことが出来る::

    jsnew (google##visualization##_PieChart) (e)

- PieChart へのアクセスは ## を使う
- JS object の new は OCaml の new ではなく、 jsnew を使う
- jsnew の引数にはカッコが必須。 (constructor に ## が入っている場合もカッコがいる

どんどん変えていこう
=================================

さて、ここらで一度動くコードが提示できると嬉しいのだけど…残念ながら、一気にやっていかないといけない。 (eval_string 内で変数にバインドしてもその後使えないので…)

- new google.visualization.PieChart(...) の結果は 'a t では寂しい。結果の chart は draw というメソッドを持っているので、 chart という class type を定義。 draw メソッドを宣言

- PieChart と同様に、 DataTable を constr readonly_prop として class type v に定義

- new google.visualization.DataTable() の結果は addColumn と addRows というメソッドを持っているので、それも class type に定義

これを全部やったのが次::

    open Js
            
    class type dataTable = object
      method addColumn : js_string t -> js_string t-> unit meth
      method addRows : 'a t -> unit meth
    end
    
    class type chart = object
      method draw : dataTable t -> 'a t -> unit meth
    end
    
    class type v = object
      method _DataTable : dataTable t constr readonly_prop
      method _PieChart : (Dom_html.element t -> chart t) constr readonly_prop
    end
    
    class type g = object
      method load : js_string t -> js_string t -> 'a t -> unit meth
      method setOnLoadCallback : (unit -> unit) -> unit meth
      method visualization : v t readonly_prop
    end
      
    let google : g t = Unsafe.variable "google"
    
    let drawChart () = 
      let data = jsnew (google##visualization##_DataTable) () in
      data##addColumn (Js.string "string", Js.string "Topping");
      data##addColumn (Js.string "number", Js.string "Slices");
      data##addRows ( Unsafe.eval_string "[
                    ['Mushrooms', 3],
                    ['Onions', 1],
                    ['Olives', 1], 
                    ['Zucchini', 1],
                    ['Pepperoni', 2]
                  ]" );
      let options = Unsafe.variable "{'title':'How Much Pizza I Ate Last Night',
                                     'width':400,
                                     'height':300}" 
      in
      let div = Unsafe.eval_string "document.getElementById('chart_div')" in
      let chart = jsnew (google##visualization##_PieChart) (div) in
      chart##draw(data, options)
    
    let _ = 
        (* Load the Visualization API and the piechart package. *)
        google##load (Js.string "visualization",
                      Js.string "1.0",
                      Unsafe.variable "{'packages':['corechart']}");
        google##setOnLoadCallback (drawChart)

注意点は…

- addRows の第一引数と draw の第二引数の型は、まあ、とりあえず放っとく。 Unsafe.eval_string したものを渡すので
- options は例によって JS literal object なので Unsafe.variable "文字列" で代用

まだちょっと Unsafe な部分はあるが、大部分が OCaml の型安全な世界に移ってきた。

仕上げ
=================================

残りの Unsafe や取りあえずの method 型宣言内の型変数を減らそう。 (JS literal object は置く。)

- addRows の第一引数の型は JS object の配列の配列なので、 'a t js_array t js_array t。 ('a の部分は…難しい)
- OCaml で記述したピザデータから JS 文字列の配列の配列を作るためのコード
- HTML の chart_div という id を持ったエレメントを探すため Dom_html モジュールを使用

最終的にはこんなコードになる::

    open Js
            
    class type dataTable = object
      method addColumn : js_string t -> js_string t-> unit meth
      method addRows : 'a t js_array t js_array t -> unit meth (* 引数の型を明確化 *)
    end
    
    class type chart = object
      method draw : dataTable t -> 'a t -> unit meth
    end
    
    class type v = object
      method _DataTable : dataTable t constr readonly_prop
      method _PieChart : (Dom_html.element t -> chart t) constr readonly_prop
    end
    
    class type g = object
      method load : js_string t -> js_string t -> 'a t -> unit meth
      method setOnLoadCallback : (unit -> unit) -> unit meth
      method visualization : v t readonly_prop
    end
      
    let google : g t = Unsafe.variable "google"
    
    let drawChart () = 
      let data = jsnew (google##visualization##_DataTable) () in
      data##addColumn (Js.string "string", Js.string "Topping");
      data##addColumn (Js.string "number", Js.string "Slices");
      (* 食べたピザデータを OCaml の (string * int) list で表現 *)
      let rows = [ ("Mushrooms", 3); 
                   ("Onions", 1);
                   ("Olives", 1); 
                   ("Zucchini", 1);
                   ("Pepperoni", 2) ]
      in
      (* JS のオブジェクトへ変換 *)
      let rowsJS = 
        Js.array (Array.of_list (List.map (fun (name,q) -> 
          Js.array [| Js.string name; 
                    (* No phantom for top type? *)
                      Obj.magic q |])  rows))
      in
      data##addRows(rowsJS);
      let options = Unsafe.variable "{'title':'How Much Pizza I Ate Last Night',
                                     'width':400,
                                     'height':300}" 
      in
      (* Dom アクセスで chart_div という名前のエレメントを取得。無ければ、残念です… *)
      let div = match Opt.to_option (Dom_html.window##document##getElementById (Js.string "chart_div")) with
        | None -> assert false
        | Some div -> div
      in
      let chart = jsnew (google##visualization##_PieChart) (div) in
      chart##draw(data, options)
    
    let _ = 
        (* Load the Visualization API and the piechart package. *)
        google##load (Js.string "visualization",
                      Js.string "1.0",
                      Unsafe.variable "{'packages':['corechart']}");
        google##setOnLoadCallback (drawChart)

残った Unsafe は、ごくわずか。

- google オブジェクトは g t という型を持つよー。これはしょうがない
- JS literal object の部分。これは多分すぐにエレガントに書けるようになる。 Wktk して待て!

まとめ
=================================

js_of_ocaml を導入すれば、既存の JS 資産を利用した HTML ページを、簡単な eval_string を使ったものから始めて、最終的にほとんどのコードを OCaml に移植する事が出来る。これを Google の Chart API を使った例を通して見てみた。実際カンタン!

JS のオブジェクトのインターフェースは、いくつかのルールを覚えれば、簡単に OCaml の class type として宣言し、 OCaml 内で静的型安全に使用することができる。とはいえ、ガッチムチに硬いわけでもなく、完全な静的型安全性が得にくい場合は、その部分だけの安全性を捨て、 JS 側の動的型検査にまかせることができる。すごく柔軟だ!!

