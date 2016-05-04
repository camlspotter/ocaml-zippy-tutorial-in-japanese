CamlP4 も悲観的入門

.. contents::
    :local:

===============================
この文章は古い
===============================

CamlP4 はもう誰も使いません。 PPX を使ってください。よってこの文章はもうメンテナンスされません。

===============================
CamlP4 も悲観的入門
===============================

必要なもの

* OCaml 普通に書けるけど、そろそろ何かもうちょっと楽に書きたいなぁ、こう書ければ嬉しいなあと思い始めたアナタ。
* 当然 LL(n) とか Parsec とか、原理はともかく、使ったことあるよね!
* OCaml ソースコード
* OCaml コンパイラ一式

この文章は OCaml 4.00.0 辺りを使って書かれている。あなたの使っている OCaml では例がそのまま
動かないかもしれない。

=======================
肝に命じること
=======================

**CamlP4 はオーパーツもしくはロストテクノロジー。** 全部を理解しようとしてソース本体を読み始めると魂を取られ帰ってこれなくなる。真髄は理解できないものとして、便利に使う、使えなさそうならさっさと諦める、という姿勢が重要。

============================================
OCaml の文法拡張フレームワークとしてのP4
============================================

P4 は OCaml の文法を拡張することが出来るだけでなく、独自言語のパーサーやプリティプリンタを記述することもできる。できるが時間の無駄だからやめろ。Lex(OCamlLex/ULex)+Yacc(Menhir) があるじゃないか。

というわけで OCaml の文法を拡張する道具としての P4 についてしか述べない。

===============================================
できないことを知ろう
===============================================

P4 で出来ないこと。夢想しても逆立ちしても出来ないこと。

* Lexer を変更してオレオレリテラル書きたい! => 諦めろ。  えっでも書けるようなドキュメントが => 諦めろ。pa_xxx.cmo を積み重ねる方式の P4 での文法拡張では常にバニラ　Lexer　が使用される
* 型チェックした後の情報から… 　=> 諦めろ。P4 は型付け前、パース段階で AST をいじるフレームワークなので、型付け情報は扱えない。でも… => じゃあ P4 内部で自分で型推論器実装してみればなんとかなるはずなので勝手にやってくれ

=======================================
どう動作するのか
=======================================

* P4 は改造構文を含む OCaml のソースコードをパースルールを使用してパースする
* パースしながら改造構文の無い vanilla OCaml(以下 *バニラ*)のソースコードツリー(以下 *AST*)を生成する
* コードをパース終了した後にも AST を変形させることができる (*Filter*)
* 最終的にバニラコードを出力する

君の仕事は

* P4 が提供するバニラのパースルールを基に
* 文法拡張のためのパースルールを追加し
* 文法拡張部分や Filter のための AST 生成器を書き
* それを P4 ランタイムに登録する

ことになる

=================================================
3.09以前型と 3.10以降系
=================================================

多分あなたが触っている P4 は 3.10以降系。これは OCaml のバージョンを見ればわかる。
これは 3.09以前系と結構中身が違う。困ったことに CamlP4 のチュートリアルは 3.09以前系の物が
インターネットに結構転がっており、これを読みながら 3.10以降系を使ってみて惨めにハマるという
若者が跡を絶たない。何か読む際にははっきりと 3.10以降系と明示されたものを読むこと。

ちなみに、この文章は 3.10以降系の P4 について書かれてある。

=================================================
Original Syntax, Revised Syntax なんと複雑な!
=================================================

P4 にはバニラ OCaml の文法である *Original syntax* とは別に *Revised syntax* という別の OCaml 文法が実装されており、これが P4 のオーパーツ化の始まりとなっている。注意して欲しいのは

**Revised syntax は君の OCaml プログラミングを revise する物ではない**

ということだ。実際のところ Revised syntax は Original syntax と比べて人間の目には冗長に見える。Original syntax を知っている人には違いを覚えるのも大変である。知らない人は Original syntax も覚えなければいけないのでもっと大変である。

Revised syntax が有利になるのは P4 での拡張を *Quotation* (*Quote* 後述) を使って書く場合だけ。
Revised は P4 のための DSL として作られており、枠構造が明確になっており Quote が書きやすい場合がある。

では Revised syntax を習得するべきか。 **否。Revised syntax は無視してよろしい。というか無視しろ。** 
この文法は P4 でしか役に立たないので覚えるのは時間の無駄である。Original syntax では Quote が書けなくなるじゃないですか…という人には、
Quote を使わなくても P4 は書ける、と答えよう。
Revised syntax でうんうん唸るなら、 Original syntax を使って、書けない、書きにくい Quote が現れたらそこはベタに AST コンストラクタを書く(*生書き*)。
もちろん Quote が書けてそちらの方が簡便な場合は Quote を使おう。Revised syntax は何となく読めればよい。それが近道だ。


camlp4, camlp4o, camlp4of, camlp4oof, camlp4orf, camlp4r,  camlp4rf … ナメてんのか!
======================================================================================

Quote の外と中の言語を上記の Syntax のどちらで書くか、そして reflective であるかどうか(言語拡張が Quote 内部にも適用されるべきか)の違いにより、 P4 には 2x2x2 = 8 種類のバリアントが想定される、そのため P4 には沢山のコマンドがある。君が使うべきはまず一つ、::

    camlp4of

である。Quote の外と中両方共 Original syntax で reflective なものだ。 **それ以外は忘れろ。**

演習問題
------------------

* 100行程度の x.ml という OCaml バニラソースを用意せよ。無ければ書け。
* ``camlp4of x.ml`` を実行して出力を確認せよ。
* ``camlp4 x.ml`` を実行して出力を確認せよ。エラーが出た場合、それは何故か考えよ。
* **[重要]** ``camlp4of x.ml > xx.ml`` を実行し xx.ml を確認せよ。
* **[重要]** ``camlp4of -printer Camlp4OCamlPrinter x.ml > xxx.ml`` を実行し xxx.ml を確認せよ。

解説: P4 は OCaml コンパイラのプリプロセッサとして動作させることが多い。P4 と ocamlc の間でのソースのやり取りはわざわざ人間に読める OCaml コードを出力する意義は無いのでバイナリで行われる。 出力先がターミナル以外の場合、プリンタを明示しないと P4 がバイナリを吐くのはそのためである。

=============================================
もう複雑ではなくなったね!
=============================================

* Original syntax 一本! 
* コマンドは常に camlp4of! 
* Quote で迷ったら生書き!

そう決めたらかなり見通しが良くなったはずだ。次に進もう。

=============================
文法拡張のテンプレート
=============================

真似をしていれば良いのだ
===============================

なぜかは聞かず、このテンプレを使う::

    open Camlp4
    
    module Id : Sig.Id = struct
      let name = "pa_XXX"  (* change *)
      let version = "1.0"  (* change *)
    end
    
    module Make (Syntax : Sig.Camlp4Syntax) = struct
      open Sig
      include Syntax
      open Ast
    
      (* 文法拡張部 *)

    end
    
    let module M = Register.OCamlSyntaxExtension(Id)(Make) in ()

* ``Id`` は拡張の名前とかバージョンとかを書く。ありがたかったことがない
* ``Make`` という functor は OCaml シンタックスパーサーモジュール ``Syntax : Sig.Camlp4Syntax``
  をもらってそのモジュールを基に同じ型( ``Sig.Camlp4Syntax`` )のモジュールを生成して返す。
  この functor を積み重ねる方式により、複数の文法拡張を同時に使用することができる。
  当然、変な変更を積み上げるとまともに使えない文法になるが気にしてはいけない。
* 文法拡張部はここでは触れない
* 最後に ``Register.OCamlSyntaxExtension`` を使ってこの ``Make`` を登録する。結果のモジュール ``M`` に特に使い道はない。

演習問題
------------------

* **[重要]** 上のテンプレを camlp4temp.ml に保存し ocamlc でコンパイルせよ。コマンドは ``ocamlc -pp camlp4of -I \`ocamlc -where\`/camlp4 -c camlp4temp.ml``
* **[重要]** 上記コンパイルコマンドを一々打ち込まなくても良いよう、自分の使用しているビルドツールのルールを作成せよ。

===================================
Quotation と Anti-quotation
===================================

さて、テンプレに触れたから早速文法拡張に移りたいところだが…その前に Quotation system を見なければならない。少し落ち着け。Quote system とは OCaml 内部で OCaml の syntax tree (*AST*) を OCaml ソースの形で記述できるようにするための言語内 DSL だと思って良い。AST を簡単にいじるために必須なツールだ。

Quotation
==============

P4 では *Quasi-quotation* (*Quote*) が使える。Quote を使えば、言語 AST の内部表現を書く(生書きとでも呼ぼう)代わりに、より人間様に判りやすい言語ソースをそのまま書くことができる。

例えば、P4 での空リスト ``[]`` 式の内部表現は::

    Ast.ExId (_loc, (Ast.IdUid (_loc, "[]")))

であるが、Quote を使えば::

    <:expr<[]>>

と書くことができる。空リストパターンの内部表現は::

    Ast.PaId (_loc, (Ast.IdUid (_loc, "[]")))

であるが、Quote を使えば::

    <:patt<[]>>

で済む。残念ながら Quote 内部のソースコード片をパースさせるコンテクスト(``expr``, ``patt`` などは)は明示しなければならない。

演習問題
-----------------

* ``let _ = <:expr<[]>>`` というファイルを作り、 camlp4of で出力して、 Quote が内部で何に展開されているか確認せよ。
* ``let _ = <<[]>>`` というファイルを作り、 camlp4of で出力して、出力を確認せよ。結果は役に立つのでメモしておくこと。使える expander のリストが手に入った!


Quote が展開される AST の定義
=================================

さて、Quote が AST 内部表現に展開される例を見たが、そこで出てくる ``Ast.ExId`` やら ``Ast.IdUid`` はどこで定義されているか。どのようなコンストラクタがあるか。もっとも簡単な資料は OCaml ソースコードディレクトリ(*$OCAML と略記*)の ``$OCAML/camlp4/Camlp4/Camlp4Ast.partial.ml`` である。これは Revised syntax で記述されており、なおかつこのファイル自体が P4 が作成される際にコンパイルされるわけではないのだが、もっとも判りやすい。ここに定義された型名は Quote ``<:XXX< ... >>`` のコンテクスト名 ``XXX`` として使用できる。

Revised syntax でのバリアント定義の読み方だが例えば、::

    | StExt of loc and string and ctyp and meta_list string

であれば、Original syntax の ::

    | StExt of loc * string * ctyp * string meta_list

に相当する。読み替えはそれほど難しくはないはずだ。

Camlp4Ast の各コンストラクタは一応コメントされているもののその使用方法はよくわからないことが多い。例えば、::

    and ctyp =
      [ ...
      | TyApp of loc and ctyp and ctyp (* t t *) (* list 'a *)
      ...
 
これはどうやら引数を持つデータ型の適用のためのコンストラクタである（実際そうだ）。コメントも Revised syntax で書かれているので ``list 'a`` とは ``'a list`` のことである。さて、``TyApp`` は二つの ``ctyp`` を取るが、 ``'a list`` の場合どちらが ``'a`` でどちらが ``list`` か。 ``('a, 'b) Hashtbl.t`` の場合は ``('a, 'b)`` をどうエンコードするのか。云々。 ``Camlp4Ast`` には時にドキュメントされていないインバリアントがあり、 Ast として型のあった式を作成しても P4 のバニラ出力時に拒否されてしまうことがある。

どうしたらよいか。 **例を camlp4of で展開して確かめるのが最も良い。** 次の演習をやりなさい。

演習問題
------------------

* ``<:ctyp< 'a list >>``
* ``<:ctyp< ('a, 'b) Hashtbl.t >>``
* ``<:ctyp< int list option >>``
* **[重要]** これらを camlp4of で展開してどのような AST ツリーになるか確認せよ

``_loc`` とは「例の場所」
==========================

Quote 展開例でしばしば見られる自由変数 ``_loc`` は式の場所を指す。この自由変数はもっと外のパターンで Quote を使っている限り、自動的に束縛されることになっているので Quote を使っている限りは気にすることはない。ただし、 Quote を使わず生書きする場合は少し注意する必要がある。

Quote では ``_loc`` を書く必要は無いが、明示的書きたい場合があるその場合は::

    <:patt@myloc<[]>>

の様に書く。 

演習問題
------------------------

* ``<:patt@myloc<[]>>`` の quote 展開を確認せよ


テンプレ内部での Quote
============================

Quote の展開例で見たように、 quote 展開では ``Camlp4Ast.partial.ml`` に記述されたコンストラクタが ``Ast.`` を付けて使用される。(例えば ``Ast.PaId``) これを P4 文法拡張で使用する際には、テンプレの「文法拡張部」で ``Ast`` という名前のモジュールにアクセスできるようになっていなければならない。

実際には functor パラメータ ``Syntax`` に ``Ast`` モジュールがある (すなわち ``Syntax.Ast``)。この ``Syntax.Ast`` を ``Ast`` としてアクセスするためには ``Syntax`` を open するか include する必要がある。実際の P4 文法拡張においては ``Syntax`` モジュールを変更し新しい ``Syntax`` を創りだす場合が多いので ``include Syntax`` を見ることが多い。

演習問題
--------------------

* テンプレコードの「文法拡張部」に ``let _ = <:expr<[]>>`` と書いてコンパイルを試みよ。コンパイルコマンドは前の演習問題でビルドスクリプトに記録してあるはずだ。
* なぜ失敗するか、 camlp4of で quote 展開結果を確認せよ
* 自由変数 ``_loc`` をλ抽象で適当になんとかして再度コンパイルを試みよ

Anti-quotation
====================

*Anti-quotation(Anti-quote)* は Quotation の中に外部の値を導入するための Quote の中の Quote。
書式は ``$ 式 $`` と書く。例えば ``<:expr< $x$ + 1 >>`` と書けば、``x`` に束縛された ``expr`` 型を持つ
AST からそれにさらに 1 を足すという expr AST を作ることができる。例えば、::

    fun _loc ->                  (* Quote 内部で _loc が使われているため *)
      let x = <:expr< 42 >> in
      <:expr< $x$ + 1 >>        

というコードは ``42 + 1`` に相当する AST を生成する。簡単である。

Anti-quotation の ``$XXX: 式$`` 記法
-------------------------------------

さて、``42`` という整数式を埋め込む例を上で見たが、ではこんどは、
この整数を自由に変化させるにはどうするか？関数で ``int`` をもらうべきだ。こうだろうか::

    let make_add_1 _loc x = <:expr< $x$ + 1 >>

うーん、これだと ``x`` の型は整数 ``int`` ではなく式 ``expr`` になってしまう。
``CamlAst`` 以外の型(``int`` や文字列)の値を Anti-quotation で埋め込むにはどうしたらよいのだろう。
もちろん常に生書きすることはできる::

    let make_add_1 _loc x = <:expr< $Ast.ExInt (_loc, string_of_int x)$ + 1 >>    (* x の型は int *)

しかしこれは面倒だ。こんな場合のために P4 には ``$XXX: 式$`` という Anti-quotation 記法がある(これが全然ドキュメントされてないのだ…)。この記法を使うと上の式は次のように書き換えることができる::

    let make_add_1 _loc x = <:expr< $int: string_of_int x$ + 1 >>  (* x を string に変換…。ほんとは int をそのまま埋め込みたいんだけど… *)

``$int: x$`` は ``x`` は ``string`` なんだけどそれをよろしくコンテクストに合う AST に変更しちゃってください、という意味だと思えば良い。もっとかっこよく言うと「ホスト言語(Quote の外側)の値から、埋め込み言語(Quote の内側)の AST への変換子」だ。この変換子は(おそらく)次のものが使用できる::

    <:expr< $x$ >>              (* 普通。x がそのまま使われる *)
    <:expr< $id:x$ >>           (* x : ident を expr にする *)
    <:expr< $lid:x$ >>          (* x : string を IdLid の ident expr にする *)
    <:expr< $uid:x$ >>          (* x : string を IdUid の ident expr にする *)
    <:expr< $str:x$ >>          (* x : string を 文字列 expr にする *)
    <:expr< $int:x$ >>          (* x : string を 整数 int として解釈し、expr にする *)
    <:expr< $int32:x$ >>        (* 略 *)
    <:expr< $int64:x$ >>        (* 略 *)
    <:expr< $nativeint:x$ >>    (* 略 *)
    <:expr< $flo:x$ >>          (* x : string を 浮動小数点 expr にする *)
    <:expr< $chr:x$ >>          (* x : string を 文字 expr にする *)

``$XXX: 式$`` の ``XXX`` 部分は ``Camlp4Ast`` のコンストラクタ名 ``ExXXX`` から来ている。

演習問題
------------------

* **[重要]** 上記例を camlp4of で展開し(ry

パターン中での anti-quotation
--------------------------------

Anti-quotation はパターンの中でも重要。AST 内部の情報を手軽に変数に束縛することができる。
例えば::

    match ast with
    | <:expr< $x$ + 1 >> -> x
    | _ -> ast

は ast を受け取り、もし ``○ + 1`` という形であれば ``+ 1`` を剥ぎとり、それ以外は ast 自身を返す操作を行う。 Anti-quotation で ``x`` に AST が束縛されることに注意。

パターン中でも ``$XXX: パターン$`` という書式が使える。「埋め込み言語のASTから、ホスト言語の値への変換子」だ。::

    match ast with
    | <:expr< $int: x$ + 1 >> -> <:expr< $int: x + 1$ >>
    | _ -> ast

これはもし ast が例えば ``42 + 1`` という形であった場合、 ``43`` にたたみ込む。

パターンマッチでの ``$x$`` と ``$XXX: x$`` の使い分けは時に注意が必要だ。 ``$x$`` ではどんな AST でもマッチしてしまう。もし変数だけマッチさせたければ ``$x$`` ではなく ``$lid: x$`` と書かなければいけない。次の式は意味的に間違い::

    match ast with
    | <:expr< x >>   -> prerr_endline "The variable x!!!"
    | <:expr< $_$ >> -> prerr_endline "A non-x variable" (* 変数どころか全部マッチしちゃう *)
    | _              -> prerr_endline "Something else"

こう書かねばならない::

    match ast with
    | <:expr< x >>        -> prerr_endline "The variable x!!!"
    | <:expr< $lid: _$ >> -> prerr_endline "A non-x variable" (* 変数だけマッチ *)
    | _                   -> prerr_endline "Something else"

なお、 ``$`` は OCaml では普通に使える symbol character なのだが、camlp4of では
``$`` が Anti-quote のために予約されているため $ は使えなくなってしまう。なので ``$`` を OCaml で
使うのは避けよとは言わないが、注意しておくべし。

演習問題
-------------
まだ書いてない。

Original syntax ではうまく書けない Quotation
================================================

なぜ Original と Revised syntax という二つの文法があるのか、
それは Original syntax だと Quotation がうまく書けない場合があるからだ。
次の ``sig ... end`` のためのコンストラクタを見てみよう::

      (* sig sg end *)
    | MtSig of loc and sig_item

さて、これを使って ``sig .. end`` にマッチするパターン ``MtSig(_loc, sg)`` なのだが、
これに相当する Quotation を書こうとすると…書けない。::

    <:module_type< sig $sg$ end >>

は::

    Ast.MtSig (_loc, (Ast.SgSem (_loc, y, (Ast.SgNil _loc))))

に展開される。なんですかこの ``SgNil`` は?!?
Revised syntax ならば::

    value x = <:module_type< sig $sg$ end >>;

は camlp4rf を使えばちゃんと::

    let x = Ast.MtSig (_loc, sg)

に展開されるのに…

ここに Original syntax にこだわると Quotation で難儀する原因がある。
**Original syntax の Quote は、いくつかのリストの形をした AST コンストラクタを最小の形で記述することができないのだ。** 
これは直せるバグで、もしかするとあなたの OCaml では既に直っているかもしれない。
が、困ったことに他にも複数こういう場所がある。

さて、これがすごく問題かというとそうでもない。
パターンと同様、式においても Quotation ``<:module_type<sig $x$ end>>`` は
``SgNil`` のある式に展開されるし、 camlp4of が ``sig .. end`` という OCaml ソースを
読み込んだ時もやはりこの ``SgNil`` が最後にくっついてくるからだ。(多分。希望である。)

これが原因で Original syntax で ``module_type`` の Quote を使ったパターンマッチを書くと
``Ast.MtSig (_, _)`` のケースが押さえることが出来ず non exhaustive になってしまう。
これが気になる場合はデフォルトケースでエラーにするか、Quote を使わず ``MtSig`` のケースを生書きするか、
ともかくちょっとした工夫が必要になる。

例題: 定義された型を抜き出す
=================================

OCaml のインターフェースファイル mli の P4 でのパースツリーの型は ``sig_item`` という
型である。(``Camlp4Ast`` 参照) この型の値を受け取り、 mli 内部で定義されている型の名前の
文字列を全て抜き出したい。 ``sig_item -> string list`` という型を持つ
関数 ``extract_defined_type_names`` を作成する。

これを実直にやるならば単に ``sig_item`` の型の定義を見ながらパターンマッチを
行なって全てのノードを辿る関数を書くだけ。普通にトラバーサルして末尾再帰::

    let extract_defined_type_names sg =
      let rec ext_sig_item st = function
        | SgNil _loc ->
        | ...
        ...
      in
      ext_sig_item [] sg

なのだが、それでは読みづらいし、せっかくなのでパターンに Quote を使ってみよう::

    (* pa_extract_types.ml *)
    open Camlp4
        
    module Id : Sig.Id = struct
      let name = "pa_XXX"  (* change *)
      let version = "1.0"  (* change *)
    end
        
    module Make (Syntax : Sig.Camlp4Syntax) = struct
      open Sig
      include Syntax
      open Ast
        
      let extract_defined_type_names sg = 
        let rec ext_sig_item st = function
          | <:sig_item<                             >> -> st
          | <:sig_item< class $_$                   >> -> st
          | <:sig_item< class type $_$              >> -> st
          | <:sig_item< $sg1$ $sg2$                 >> -> List.fold_left ext_sig_item st [sg1; sg2]
          | <:sig_item< #$_$                        >> -> st
          | <:sig_item< exception $_$               >> -> st
          | <:sig_item< external $_$                >> -> st
          | <:sig_item< include $_$                 >> -> st
          | <:sig_item< module $m$ : $mty$          >> -> ext_module_type st mty
          | <:sig_item< module rec $module_binding$ >> -> ext_module_binding st module_binding
          | <:sig_item< module type $_$ = $_$       >> -> st
          | <:sig_item< open $_$                    >> -> st
          | <:sig_item< type $ctyp$                 >> -> ext_ctyp st ctyp
          | <:sig_item< val $_$                     >> -> st
          | Ast.SgAnt _                                    -> assert false
        and ext_module_type _ _ = assert false    (* 未実装 *)
        and ext_module_binding _ _ = assert false (* 未実装 *)
        and ext_ctyp _ _ = assert false           (* 未実装 *)
        in
        ext_sig_item [] sg
    
    end
        
    let module M = Register.OCamlSyntaxExtension(Id)(Make) in ()

``Camlp4Ast`` を見ながらこんなのを書いてみた。各行が ``sig_item`` の各コンストラクタに対応している。Antiquote のケースは良くわからないので Quote を使わずに ``Ast.SgAnt`` と普通に書いてみた。
ひとつひとつを生書きするよりは読みやすいことがわかるだろう。さてこれを::

    ocamlc -pp camlp4of -I `ocamlc -where`/camlp4 -c .ml pa_extract_types.ml

でコンパイルしてみると::

    File "pa_extract_types.ml", line 21, characters 29-32:
    While expanding quotation "sig_item" in a position of "patt":
      Parse error: ":" expected after [a_LIDENT] (in [sig_item])
    
    File "pa_extract_types.ml", line 1:
    Error: Preprocessor error

へ？なんでっか？  ``<:sig_item< external $_$ >>`` の部分で文句を言われた。 ``external …`` に対応おするデータは::

    | SgExt of loc and string and ctyp and meta_list string

となっている。 ``string``, ``ctyp``, ``meta_list string`` と ``loc`` を除いて3つ引数を取っているが、
これは実際の ``external`` の文法::

    external foobarboo : int -> int = "foobar"  "option"
             <string->   <--ctyp-->   <meta_list string>

に対応している、そしてこれらはどれも省略できない。
``<:sig_item< external $_$ >>`` は ``external`` の後一つしか引数がない。残り2つを忘れていた
ために起こったエラーだ。書き換えよう::

          | <:sig_item< external $_$ : $_$ = $_$ >>            -> st

なるほど。たしかに途中の記号は略してはいけなさそうだ。再コンパイルしよう::

    File "pa_extract_types.ml.ml", line 28, characters 24-27:
    While expanding quotation "sig_item" in a position of "patt":
      Parse error: ":" expected after [a_LIDENT] (in [sig_item])
    
    File "pa_extract_types.ml.ml", line 1:
    Error: Preprocessor error

ありゃ？今度は ``<:sig_item< val $_$ >>`` だ。ああ、これも ``val x : type`` に相当する Quote だからニ引数にしてちゃんと記号を書いてあげよう::

          | <:sig_item< val $_$ : $_$ >>                     -> st

これでどうか？::

    File "pa_extract_types.ml.ml", line 14, characters 30-1080:
    Warning 8: this pattern-matching is not exhaustive.
    Here is an example of a value that is not matched:
    SgDir
      (_, _,
      (ExId (_, _)|ExAcc (_, _, _)|ExAnt (_, _)|ExApp (_, _, _)|ExAre (_, _, _)|
       ....)
    File "pa_extract_types.ml.ml", line 26, characters 19-19:
    Warning 11: this match case is unused.

今度はパターンが完全に埋まっていないですと言われた。 ``SgDir`` だからこの部分だ::

      | <:sig_item< #$_$ >>                        -> st

``SgDir`` は ``loc`` 以外に 2引数を取っているのに 1引数しか書いていなかった。これも 2引数にしなければ。しかし何故今回はエラーではなく警告なのか。これは、directive の文法では第2引数は省略できるからだ。つまり、 ``<:sig_item< #$_$ >>`` は第2引数を省略した正しい構文だが、第2引数があるケースは押さえられない。この場合は、第2引数も明示する::

      | <:sig_item< #$_$ $_$>>                        -> st

さあ、コンパイル…やっと完全なパターンマッチになったようだ。(大抵の場合 P4 のモジュールではここまで完璧なパターンマッチは必要なく、興味のないケースについてはデフォルトケース ``| _ ->`` で全て押さえてしまうのが一般的だが、もし自分の書いた Quote パターンが意図したケースをちゃんと処理してくれない場合、このような分析が必要になる。

さて… ``ext_sig_item`` については実装できたので、のこりの ``ext_*`` 関数を ``assert false`` からちゃんとした実装のものにしよう::

Quotation system まとめ
============================

* **[重要]** Quote や Anti-quote の展開がわからなかったら例題を作って camlp4of で実際にどうなるか確かめよう
* **[重要]** Quote/Anti-quote は syntax sugar。使いづらいと思ったら迷わずすぐに Camlp4Ast のコンストラクタを生書きしよう。
* **[重要]** ``$x$`` と ``$XXX:x$`` は違う。特にパターンでの ``$_$`` と ``$XXX:_$`` の間違いが致命的なので注意しよう

=================================
文法拡張
=================================

やっと肝心の文法拡張について述べることができる。

P4 パーサーの性質
=====================

CamlP4 のパーサーは、LALR(1) スタイルによるバニラOCamlの文法定義( ``$OCAML/parsing/lexer.mll`` と ``$OCAML/parsing/parser.mly`` )とは別に実装された、 LL(?(シラネ)) スタイルのパーサーである。わしはパーサー技術のことはよく知らんから適当なことを今から言うが、CamlP4 が LL という性質の違うパーサ技術を採用しているのは lex/yacc ではダイナミックな変更が難しいからだと思われる。LL は Parsec でみなさんおなじみの通りそのままコードを書けばよろしい。各文法要素をパースする LL の部品に名前をつけておいて、その名前で部品にアクセス、それを消したり、上書きしたり、新しい部品を追加したり…普通の(どちらかというと継承っぽい)プログラミングスタイルが使える。

P4 では LL のパーサーを書くためのストリームパターンマッチのための DSL が用意されている。(この特殊文法も P4 で書かれているとかまあ再帰っぽいのでワクワクするかもしれないが時間の無駄なのでさっさと先に進もう)

拡張を伴わない文法ルールの基礎
=================================

LL ではあるがルール記述は yacc の様なちょっと BNF っぽい書き方ができる DSL が用意されている:

* ``ルール名: [ ケースグループ | ケースグループ | .. ]``
* ``ケースグループ: [ ケース | ケース | .. ]`` もしくは ``"名前" associativity [ ケース | ケース | .. ]`` ( ``名前`` と ``associativity`` (``LEFTA`` など) は省略できる)
* ``ケース: ストリームパターン -> Camlp4Ast を生成する式``
* ストリームパターン内で自分自信を参照する場合は ``SELF`` を使う。(これは継承時の自己参照に必要からだと思われる)

Yacc と異なりケースの実行は上から下へ。なので順番は重要。

わかりますよね？わからない？えっ、パーサーの基礎も知らずに P4 とか無理ですよ？言わなかったけ。
 
改造の基本
==============

テンプレ、もしくは誰かが書いた pa_XXX.ml からはじめる。スクラッチするのはめんどくさい。

文法拡張はテンプレの「文法拡張部」の部分に ``EXTEND Gram ... END`` という枠内で書く。

文法拡張はテンプレの ``Syntax`` という functor 引数内部で既に定義された文法ルールを基に
新しいルールセットを作ることで行う。そのために、

* 文法ルールのケースグループ全体を消してしまう: ``Gram.Entry.clear``
* 文法ルールの中のケースを消してしまう: ``DELETE_RULE Gram 名前: パターン END;`` で消す。パターンはケースを選択するために必要
* ``EXTEND Gram ... END`` を書いてその中に付け加えるルールやケースを書く
    * ``GLOBAL`` 宣言で自分が今からいじりたい既存の文法ルールを列挙せよ! なんで必要なのか、理由は分かんねー。
    * 既存の文法ルールの中のケースの前後に新しいケースを付け加える: 普通に追加分だけのケースをルールに書いておくと、既存のケースの最後にルールが付け加えられる
    * ``文法ルール名: BEFORE "hogehoge" [ ケースグループ ] ;`` などと書いてケースグループを挿入する場所を指定することもできる。指定しなければ一番最後に加えられる。 ``BEFORE`` (すぐ前)の他に ``AFTER`` (すぐ後), ``LEVEL`` (同じところ？) などが使える。


元の文法はどこに定義されていますか
=======================================

わかりました。では、私が変更することになる大本の OCaml 文法はどこで調べたら良いですか？
もっともな疑問であるが…正直これが大変であり、P4 の近寄り難さを演出している

* 基本的な文法はまず Revised syntax のルールとして定義されている(なんてこった!) ``$OCAML/camlp4/Camlp4Parsers/Camlp4OCamlRevisedParser.ml``
* バニラOCaml の文法はこの f#$@ing な Revised syntax の文法拡張として定義されている!! ``$OCAML/camlp4/Camlp4Parsers/Camlp4OCamlParser.ml``
* そしてこいつらは全て Revised syntax で書かれている!! (オーノー)

camlp4rf を使ってやれば Revised syntax で書かれているコードをバニラで読むことは出来るのだが… Quote が全て展開されているのでかなりきつい。まあここは Revised syntax を理解してなくても空気で読むしか無い…

Camlp4OCamlParser.ml を眺めよ!!
====================================

とこき下ろしたが、実のところ Camlp4OCamlParser.ml は最も複雑な P4 文法拡張なので、ルールの削除や追加の例はこのファイルを眺めるのが最適である。 **読むなよ！眺めるだけだ！**

=========================
例題
=========================

君は Scheme か LCF ML 基地外なので ``let rec`` という OCaml 構文を見ていつも引っかかりを覚えていた。何故だ、何故 ``let rec`` と中央に空白があるのだ。 ``letrec`` でなければいけないはずだ... ついに君は CamlP4 拡張を書き始めた。

やるべきこと

* ``letrec`` という文法ルールを入れる! ``let rec`` のコピペでいいはずだ。
* ``let rec`` という文法ルールは潰す! 

ステップ1 ルールを探す
=============================

``let rec`` に関する P4 のルールを探そう。
``Camlp4OCamlParser.ml`` には、見当たらない。
では ``Camlp4OCamlRevisedParser.ml`` か？あった::

    opt_rec:
      [ [ "rec" -> <:rec_flag< rec >>
        | `ANTIQUOT ("rec"|"anti" as n) s -> Ast.ReAnt (mk_anti n s)
        | -> <:rec_flag<>>
      ] ]
    ;

これはどうやら ``rec`` という文字列があれば ``<:rec_flag< rec >>`` を返し、それ以外は ``<:rec_flag<>>`` を返すようだ。え？ ``ANTIQUOT``? 知るか。残念だがここは変える所ではないらしい。 ``opt_rec`` を使っているルールを探そう...今度は ``Camlp4OCamlParser.ml`` にあった。(``Camlp4OCamlRevisedParser.ml`` にある ``opt_rec`` を使うルールは ``Camlp4OCamlParser.ml`` で ``DELETE_RULE`` により抹消されているので気にする必要はない)::

    str_item:
      [ "top"
          [ "let"; r = opt_rec; bi = binding; "in"; x = expr ->
              <:str_item< let $rec:r$ $bi$ in $x$ >>
          | "let"; r = opt_rec; bi = binding ->
              match bi with
              [ <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
              | _ -> <:str_item< value $rec:r$ $bi$ >> ]
          | ...

    expr: LEVEL "top"
      [ [ "let"; r = opt_rec; bi = binding; "in";
          x = expr LEVEL ";" ->
            <:expr< let $rec:r$ $bi$ in $x$ >>
        | ...

ステップ2 ルールを消す
===============================

では、まずこの汚らわしい ``let rec`` ルールを消そう。消すのには ``DELETE_RULE`` 。 ``Camlp4OCamlParser.ml`` の例を参考にして...::

    DELETE_RULE Gram str_item: "let"; opt_rec; binding; "in"; expr END;
    DELETE_RULE Gram str_item: "let"; opt_rec; binding END;
    DELETE_RULE Gram expr: "let"; opt_rec; binding; "in"; expr END;

ステップ3 **[重要]** テストテストテスト
=============================================

と君は書いてみた。君は基地外ではあるが慎重でもあるので、この時点でテンプレートにこの三行を書き込みテストするのを忘れない::

    open Camlp4
    
    module Id : Sig.Id = struct
      let name = "pa_letrec"
      let version = "1.0"
    end
    
    module Make (Syntax : Sig.Camlp4Syntax) = struct
      open Sig
      include Syntax
      open Ast
    
      DELETE_RULE Gram str_item: "let"; opt_rec; binding; "in"; expr END;
      DELETE_RULE Gram str_item: "let"; opt_rec; binding END;
      DELETE_RULE Gram expr: "let"; opt_rec; binding; "in"; expr END;

    end
    
    let module M = Register.OCamlSyntaxExtension(Id)(Make) in ()

コンパイルしてみる::

    ocamlc -pp camlp4of -I `ocamlc -where`/camlp4 -c pa_letrec.ml

では実際に使ってみよう::

    $ ocaml
            OCaml version 4.00.0
    
    # #load "dynlink.cma";;
    # #load "camlp4of.cma";;
        Camlp4 Parsing version 4.00.0
    
    # #load "pa_letrec.cmo";;
    Fatal error: exception Not_found

あれ？あれれれ？ナンデ？P4ナンデ？

まあ極まった私から言わせてもらうと、 ``DELETE_RULE`` する際にマッチするルールが無かったんだろう。よく見てみると最後のルール間違っている::

    DELETE_RULE Gram expr: "let"; opt_rec; binding; "in"; expr LEVEL ";" END;

と、 LEVEL についても書かないといけないのだ。うーん、トリッキー。これで実行すると::

    # #load "pa_letrec.cmo";;
    # let rec f x = f x;;
    Characters 0-3:
    let rec f x = f x;;
    ^^^
    Error: Parse error: *"module" or "open" expected after "let" (in [str_item])*

こうなる。なんとエラーメッセージを見なさい。 ``let`` の後は ``module`` か ``open`` しか来ないと言っている。 ``rec`` なんかは絶対来ないのだ！素晴らしい！(というか普通の ``let x = 1`` とかも消してしまったのだが。)

ステップ4 ルールを追加する
===============================

さて、仕事は半分終わった。残りは letrec だ。これは消したルールを基に作れる。まず拡張し終わって出来たパースルール群がどうなるか考えよう::

    str_item:
      [ "top"
          [ "let"; bi = binding; "in"; x = expr ->
              <:str_item< let $bi$ in $x$ >>
          | "letrec"; bi = binding; "in"; x = expr ->
              <:str_item< let rec $bi$ in $x$ >>
          | "let"; bi = binding ->
              match bi with
              [ <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
              | _ -> <:str_item< let $bi$ >> ]
          | "letrec"; bi = binding ->
              match bi with
              [ <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
              | _ -> <:str_item< let rec $bi$ >> ]
          | ...

    expr: LEVEL "top"
      [ [ "let"; bi = binding; "in";
          x = expr LEVEL ";" ->
            <:expr< let $bi$ in $x$ >>
        | "letrec"; bi = binding; "in";
          x = expr LEVEL ";" ->
            <:expr< let rec $bi$ in $x$ >>
        ...

こんな感じになるはずだ。
オリジナルのルールをそれぞれ二つにわけ、 ``let`` と ``letrec`` にし、バニラ側で非再帰、再帰の ``let`` に置き換えてやる。
元ソースでは Revised syntax だったがこちらは Original に書き換えてある。Quote の中身ではバニラ OCaml を書かねばならないから let rec と書かざるを得ないが…ぐぐぅ。そこは革命のためだ我慢せよ。

さてこれを拡張ルールとして書くには

* str_item と expr をいじることを GLOBAL で宣言する
* let(非再帰)と と letrec のケースを追加する。追加するレベルを LEVEL で明記する。

せねばならない。こう書く::

    GLOBAL: str_item expr;

    str_item: LEVEL "top"
      [   [ "let"; bi = binding; "in"; x = expr ->
              <:str_item< let $bi$ in $x$ >>
          | "letrec"; bi = binding; "in"; x = expr ->
              <:str_item< let rec $bi$ in $x$ >>
          | "let"; bi = binding ->
              match bi with
              [ <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
              | _ -> <:str_item< let $bi$ >> ]
          | "letrec"; bi = binding ->
              match bi with
              [ <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
              | _ -> <:str_item< let rec $bi$ >> ]
       ];

    expr: LEVEL "top"
      [ [ "let"; bi = binding; "in";
          x = expr LEVEL ";" ->
            <:expr< let $bi$ in $x$ >>
        | "letrec"; bi = binding; "in";
          x = expr LEVEL ";" ->
            <:expr< let rec $bi$ in $x$ >> ]
      ];
        
おおっと、match の部分がまだ Revised だった::

    str_item: LEVEL "top"
      [   [ 
          ...
          | "let"; bi = binding ->
              begin match bi with
              | <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
              | _ -> <:str_item< let $bi$ >> 
              end
          | "letrec"; bi = binding ->
              begin match bi with
              | <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
              | _ -> <:str_item< let rec $bi$ >> 
              end
          ]
       ...

これで良いはずだ! ``begin match .. with .. end`` に注意だ! これが出来たら、 ``EXTEND Gram .. END`` の中に入れてコンパイルしよう::

    open Camlp4
    
    module Id : Sig.Id = struct
      let name = "pa_letrec"
      let version = "1.0"
    end
    
    module Make (Syntax : Sig.Camlp4Syntax) = struct
      open Sig
      include Syntax
      open Ast
    
      DELETE_RULE Gram str_item: "let"; opt_rec; binding; "in"; expr END;
      DELETE_RULE Gram str_item: "let"; opt_rec; binding END;
      DELETE_RULE Gram expr: "let"; opt_rec; binding; "in"; expr END;

      EXTEND Gram
        str_item: LEVEL "top"
          [   [ "let"; bi = binding; "in"; x = expr ->
                  <:str_item< let $bi$ in $x$ >>
              | "letrec"; bi = binding; "in"; x = expr ->
                  <:str_item< let rec $bi$ in $x$ >>
              | "let"; bi = binding ->
                  begin match bi with
                  | <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
                  | _ -> <:str_item< let $bi$ >> 
                  end
              | "letrec"; bi = binding ->
                  begin match bi with
                  | <:binding< _ = $e$ >> -> <:str_item< $exp:e$ >>
                  | _ -> <:str_item< let rec $bi$ >> 
                  end
              ]
           ];
    
        expr: LEVEL "top"
          [ [ "let"; bi = binding; "in";
              x = expr LEVEL ";" ->
                <:expr< let $bi$ in $x$ >>
            | "letrec"; bi = binding; "in";
              x = expr LEVEL ";" ->
                <:expr< let rec $bi$ in $x$ >> 
            ]
          ];
      END
    end
    
    let module M = Register.OCamlSyntaxExtension(Id)(Make) in ()

コンパイルとテストはこうなる::

    ocamlc -pp camlp4of -I `ocamlc -where`/camlp4 -c pa_letrec.ml
    $ ocaml
            OCaml version 4.00.0
    
    # #load "dynlink.cma";;
    # #load "camlp4of.cma";;
        Camlp4 Parsing version 4.00.0
    
    # #load "pa_letrec.cmo";;
    # let x = 1;;
    val x : int = 1
    # let rec f x = f x;;
    Characters 0-3:
      let rec f x = f x;;
      ^^^
    Error: Parse error: "module" or "open" or [binding] expected after "let" (in [str_item])
    # letrec f x = f x;;
    val f : 'a -> 'b = <fun>
    # 

あひゃひゃひゃひゃ！革命は成った!!

演習問題
------------------

* **[重要]** 君も上の letrec を試して国際 Scheme 戦線に参加しなさい。LCF ML 懐古趣味でも可能

===================
まだ書いてない
===================

* 新しい Quote を作る
* Filter
* Findlib
