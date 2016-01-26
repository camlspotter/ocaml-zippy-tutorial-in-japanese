=============================
OCaml C interface の注意事項
=============================

一言で言うと、「マニュアル http://caml.inria.fr/pub/docs/manual-ocaml/manual033.html の通りにやれ、それ以外のことをするな」に尽きます。

C interface がバグっている場合起こること
=========================================

OCaml の GC タイミングにより、プログラムの全く関係ない所で
プログラムがクラッシュします。これは解析、テストが大変に難しい。

対処療法として OCaml のテストプログラムから C関数を何百万回も呼び出し、その都度
GC を強制的に掛ければ問題の早期発見ができる、かも、しれませんが、
されないこともあるわけです。そもそも何百万回も呼び出すには
コストがかかりすぎる場合もある。

ですから兎に角バクを入れない、つまりマニュアルに沿って書く、
ことが必要になります。


落とし穴集
===================

兎に角マニュアル 19.5 を完全理解しないうちは OCaml-C interface を書いてはダメ。

Simple interface
----------------

* Simple interface で使える関数は 19.4.4 の Simple interface にある

* Rule 2   Local variables of type value must be declared with one of the CAMLlocal macros. Arrays of values are declared with CAMLlocalN. These macros must be used at the beginning of the function, **not in a nested block**. 配列の初期化などでついローカルブロックを使ってから ``CAMLlocaln`` を宣言したくなるが、してはいけない。

* Simple interface で確保した ``value`` に対して ``Field(b, n) = v`` と書いてはいけない。 ``Store_field(b, n, v)`` と書く。

Low-level interface
-----------------------

* Low-level interface で使える関数は 19.4.4 の Low-level interface にある

* Low-level function で確保した ``value`` は、次の allocation が起こる前に必ず正しい値でフィールドが埋まっていなければならない。例えば、 ``caml_alloc_small`` した場合次の allocation が起こる前にフィールドを初期化せねばならない。 一方、Simple interface の ``caml_alloc`` はフィールドは 0 クリアされているので問題ない。

* Low-level function で確保した ``value`` のフィールド初期化は ``Field(b, n) = v`` で行う。 ``Store_field(b, n, v)`` を使ってはいけない。既に初期化されているフィールドを変更する場合には ``caml_modify(&Field(b, n), v)`` を使う。

CAMLparam と CAMLlocal
----------------------------

``CAMLparam`` と ``CAMLlocal`` で受け取った/作った ``value`` は
simple でも low-level でもアクセスしてよいが、一度どちらかで始めたら
混ぜてはいけない。
 
えっ難しい…
-------------------------------

じゃあ、 simple interface だけ使う。

* ``caml_alloc_small``, ``caml_alloc_shr`` は使わない
* ``Field(b, n) = v`` と ``caml_modify(&Field(b,n), v)`` は使わない。 ``Store_field(b, n, v)`` を使う。
