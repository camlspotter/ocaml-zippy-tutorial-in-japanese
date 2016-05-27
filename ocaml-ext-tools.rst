=============================================================
OCaml 開発環境について ~ コンパイラに付属しない非公式ツールたち
=============================================================

2012年12月での関数型言語 OCaml コンパイラ一式には入っていない
内部もしくは外部開発されたのツール群の紹介を行う。
例によって多岐に渡るので、一つ一つの詳しい説明は行わない。
各ツールの細かい情報はそれぞれのドキュメントを参照して欲しい。
リンクは貼るの面倒だからググって。

もし知らないツール名があったらちょっと読んでみて欲しい。
もしかしたらあなたの問題を解決するツールがあるかもしれないから。
ライブラリとツールの中間のようなコード生成系も取り上げた。
あくまでも基本的に私が触ったことのある物しか紹介しないから、
そっけなかったりするのはあまり触ってないということ。
なんでこれはなんで取り上げてないの？と思ったら、それは使ったことないから。ごめんね。
不満があったら自分で紹介記事書いてください夜露死苦!

★は重要度。五点満点。

コンパイラ同梱のツールの紹介はもうした。
http://d.hatena.ne.jp/camlspotter/20121204/1354588576

@tmaeda さんも既に似たようなのを更に詳しく書いてた…
http://tmaeda.s45.xrea.com/td/20121028.html

ビルド関連
================================

OMake ★★★★
--------------------------------

ビルドツール。

Make や OCamlBuild と同様のビルドツール。

* Makefile のような文法によるビルドルール表記が可能で参入障壁が低い
* Makefile よりも随分マシなセマンティックスな言語。関数による際利用可能なビルドルール記述
* ファイル更新時ではなくファイルのチェックサムによるリビルド。更新されたが変化はなかった自動生成ファイルの不要なコンパイルが行われない
* サブディレクトリでのビルドが楽
* 依存関係を解析して複数コアを使った並列ビルドが簡単
* ``-P`` スイッチによるファイル変更時の自動リビルド
* OCaml プログラムビルドのための便利な機能がもともと入っているので、OCaml のための複雑な関数記述が不要
* LaTeX や C のルールももうある
* ちゃんとスケールする (Jane Street の 100万行程度の多岐のディレクトリにわたる OCaml プロジェクトでも動く)
* マニュアルに日本語の訳がある (英語: http://omake.metaprl.org/manual/omake.html 日本語: http://omake-japanese.sourceforge.jp/ )

私は OCaml のプログラムは今のところ OMake を使っている。スケール感半端無いので。問題がないわけではない:

* スコープルールが特殊。ビルドのために便利なようになっているらしいが、わかったようなわからないような、である
* 依存関係を完全に抑えなければいけない。さもないと1コアだとコンパイルできるけど複数コアだとビルドに失敗する
* お仕着せの OCaml ビルドルールで満足できなくなると関数を沢山書き始めなければならない。あまり嬉しくない。
* ld as needed と相性が悪く ``-P`` のビルドが上手くいかない人が ( http://d.hatena.ne.jp/camlspotter/20121002/1349162772 )

それでも小さい OCaml プロジェクトの OMakefile はあっけないほど簡単に書けるので使ってみてほしい。
(まあこれは OCamlBuild にも言えることなんだけどね)

OCamlMakefile ★★
------------------------------

OCaml のための Makefile マクロ集

OMake や OCamlBuild みたいな新しい物を覚えるのは年を取ってしまってどうも…という人は
OCamlMakefile という OCaml プログラムをビルドする際に便利なマクロが詰まった Makefile
を使うと良い。が、 OCamlMakefile のマクロを覚えるコストと OMake や OCamlBuild の初歩を
学ぶコストはどちらが小さいか。

私は5日程使った記憶がある

OCamlFind / Findlib ★★★★★
---------------------------------

ライブラリパッケージマネージャおよびビルド補助ツール

非常に重要なツール。
OCamlFind はある種のパッケージシステムでもあるわけだけど
パッケージ配布には焦点を置いていないのでビルドシステムに分類した。

OCaml コンパイラはモジュールをまとめてライブラリにするリンカ機能は当然あるが、
その出来たライブラリをどのように管理すべきか、統一的な方法はコンパイラ開発チームは
あまり提唱しなかった。そのため、作ったライブラリは ``ocamlc -where`` で表示される
OCaml 標準ライブラリがインストールされている場所に直接放り込む、とか、
まあそこに hogehoge ライブラリなら ``hogehoge`` というディレクトリを掘ってそのこに
放んでり込む、とか、各人が思い思いにインストールしていたのだった。

またライブラリを実際に使用して実行プログラムにリンクする際のコンパイラフラッグの管理
も大変だった。もし hogehoge というライブラリを使いたいとすれば、 ``hogehoge.cma``
などが格納されていパスを ``-I`` で指定する必要があるし、
もし hogehoge が fugafuga に依存していれば当然 fugafuga に必要なコンパイルスイッチ
も一緒にコンパイラに渡してやらなければならない。もちろんこれは丁寧に Makefile を書いて
再利用できるようにしておけば何の問題もないのだが、まあ、面倒だった。

OCamlFind はこの二つの点を次のように解決する:

* ライブラリ(群)をパッケージとして扱い、パッケージ名による管理を可能にする
* パッケージ管理者は各ライブラリの依存関係をパッケージの ``META`` ファイルに記述
* OCamlFind は OCaml コンパイラのラッパとして動作、使用するライブラリ名を渡すと必要なスイッチをコンパイラに自動的に渡す

例えば、今私がいじっている OCamltter を改造したライブラリをビルドすると
こんなコマンドが発行される::

    ocamlfind ocamlc \
       -for-pack Twitter \
       -package cryptokit,str,sexplib,spotlib,tiny_json_conv \
       -syntax camlp4o -package sexplib.syntax,meta_conv.syntax \
       -thread -w A-4-9-27-29-32-33-34-39 -warn-error A-4-9-27-29-32-33-34-39 \
       -g -I ../base -I ../twitter -I . -c \
       api_intf.ml

``-package ...`` とか ``-syntax ...`` のオプションは OCamlFind に 
cryptkit, str ,sexplib, spotlib, tiny_json_conv
というパッケージを使うこと、拡張文法として camlp4o を使うこと、
そして文法プラグインとして sexplib.syntax と meta_conv.syntax を使うことを指示している。
それ以外は ocamlc にある普通のオプション。え、これで既に長いって？

上のコマンドから OCamlFind が実際にどのような ocamlc コマンドを発行しているか、
-verbose オプションを付けてると、表示してくれる::

    ocamlfind ocamlc -verbose ... (上と同じ)
    + ocamlc.opt -verbose -for-pack Twitter -w A-4-9-27-29-32-33-34-39 -warn-error A-4-9-27-29-32-33-34-39 -g \
          -I ../base -I ../twitter -I . -c -thread -I /my_home/.opam/system/lib/num \
          -I /my_home/.opam/system/lib/cryptokit -I /my_home/.opam/system/lib/spotlib \
          -I /my_home/.opam/system/lib/tiny_json -I /my_home/.opam/system/lib/tiny_json_conv \
          -I /my_home/.share/prefix//lib/ocaml/camlp4 -I /my_home/.opam/system/lib/type_conv \
          -I /my_home/.opam/system/lib/sexplib -I /my_home/.opam/system/lib/meta_conv \
          -pp "camlp4 '-I' '/my_home/.share/prefix//lib/ocaml/camlp4' '-I' '/my_home/.opam/system/lib/type_conv' \
                      '-I' '/my_home/.share/prefix//lib/ocaml' '-I' '/my_home/.share/prefix//lib/ocaml' \
                      '-I' '/my_home/.share/prefix//lib/ocaml' '-I' '/my_home/.opam/system/lib/num' \
                      '-I' '/my_home/.opam/system/lib/sexplib' '-I' '/my_home/.opam/system/lib/sexplib' \
                      '-I' '/my_home/.opam/system/lib/meta_conv' '-I' '/my_home/.opam/system/lib/meta_conv' \
                      '-parser' 'o' '-parser' 'op' '-printer' 'p' 'pa_type_conv.cma' \
                      'unix.cma' 'bigarray.cma' 'nums.cma' 'sexplib.cma' \
                      'pa_sexp_conv.cma' 'meta_conv.cmo' 'pa_meta_conv.cma' " \
          api_intf.ml
    ....

ということだ。大量の ``-I`` フラッグがついている。
さらに、``-package`` には type_conv や meta_conv を指定しなかったが
sexplib と tiny_json_conv がこれらを必要としていることがそれぞれの META ファイルに
書かれているので、 type_conv と meta_conv のフラッグが自動的に加わっている。

OCamlFind は OCaml のライブラリを駆使するものはまず使う必須ツールなので、
ちょっとややこしいことをする場合は使ったほうがいい。

ちなみに OCamlFind は Findlib というライブラリの上に作られたツールなので自分自身の OCamlFind パッケージ名は findlib。なのに OPAM パッケージ名は ocamlfind というちょっと変な名付けになってる。

OCamlFind, 便利なんだけど、さらに camlp4 のラッピングをしてコード展開を楽にしてくれるととても嬉しいのだが、
そんな機能はないのだなあ。 P4 の結果を調べるときには、いちいちコマンドを手打ちしなければならない。

パッケージシステム
========================

この数年 OCaml界ではパッケージが熱い。

Oasis ★★★
-------------------------

統一的ビルドインターフェースを提供

OCaml のソフトウェアはビルドシステムが自由に選べる。 configure + Make, OCamlBuild, OMake など。
問題はビルド方法がひとつひとつ違うことだ。ユーザーは一度一度 INSTALL.txt などを読まなければならない。
Oasis はそんな問題を解決する: OCaml で書かれた setup.ml というファイルを使うのだ。
``ocaml setup.ml -configure`` で設定、 ``ocaml setup.ml -build`` でビルド、 ``-install`` 
でインストールすると言った具合。つまり Oasis による ``setup.ml`` があればビルドシステムが何であろうが
ユーザは ocaml setup.ml からインストール作業ができる。

Oasis では ``_oasis`` という設定ファイルに色々書くと自動的に ``oasis setup`` で setup.ml を
作成してくれるのだが、その際、``_oasis`` から OCamlBuild のビルドファイルを自動的に作ってくれたり
OCamlFind の META フィアルを作ってくれたりするようだ。
Readme や INSTALL.txt を勝手に作ってくれたり、
ソフトウェアライセンスとかも記述でき、コピーライトファイルを自動的に取ってきたり、
いろいろ機能はあるみたいなんだけど…私には、ちょっとやりたいことが多すぎて手が回ってない感じのツールだな。

私は OMake ユーザーであり、 OMake は Oasis で全くサポートされていないのでビルドファイル生成とかの
恩恵は全く無い。
まあ _oasis ファイルを書いて oasis setup すると OMake を呼んでくれる setup.ml を
作成することはできる…でもそれだけ。参考までに OMake で使うばあいの ``_oasis``:: 

    OASISFormat: 0.2
    Name:        spotlib
    Version:     2.1.0
    Synopsis:    Useful functions for OCaml programming used by @camlspotter
    Authors:     Jun FURUSE
    License:     LGPL-2.0 with OCaml linking exception
    Plugins:      StdFiles (0.2)
    BuildType:    Custom (0.2)
    InstallType:    Custom (0.2)
    XCustomBuild: yes no | omake --install; PREFIX=$prefix omake
    XCustomInstall: PREFIX=$prefix omake install
    XCustomUninstall: PREFIX=$prefix omake uninstall
    BuildTools: omake

OMake はサポートされていないので ``XCustomなんちゃら`` を使う。まあこれで setup.ml から omake が呼べるようになる。
( http://d.hatena.ne.jp/camlspotter/20110603/1307080062 )
Custom なのでビルドの自動設定はできないが… ``_oasis`` の Library エントリとか妙によくわからないので
書けないなら書けないで…まあ構わないのだ。

Oasis パッケージを管理する Oasis DB というモノも作られかけていたが…コケた。
アップロードがあまりに不親切かつ面倒だったからだ。今はもう OPAM repo だね。

OPAM ★★★★★
-------------------------

パッケージマネージャとパッケージレポ

Oasis はパッケージとそのビルドに焦点を当てたツールだったが、 OPAM はどちらかというとパッケージとその配布管理
に重きをおいたパッケージマネージャ。 OPAM では Oasis は setup.ml を提供するツールとして普通に共存できる。

OPAM は Oasis と違ってビルドスクリプトの方には手を出さない。そのかわり ``opam`` ファイルに
ビルドするには、インストールするには、アンインストールには、どんなコマンドを発行するか、を記述する。
コマンドはシェルで解釈されるので ``ocaml setup.ml`` だろうが configure + make だろうが
``ocamlbuild`` だろうが ``omake`` だろうが何でもかまわない。
これは Oasis がそのあたり便利にしようとしてコケている事への反省だと思う。

さらに、パッケージが別パッケージのどのバージョンに依存しているかも ``opam`` ファイルに記述するのだが
この際のアルゴリズムとして Debian のパッケージと同じアルゴリズムが使われている、まあ枯れていて強力
ということなのだろう。

例として私が書いている opam ファイルはいつもこんな感じ::

    opam-version: "1"
    maintainer: "hoge.hoge@gmail.com"
    build: [
      ["ocaml" "setup.ml" "-configure" "--prefix" "%{prefix}%"]
      ["ocaml" "setup.ml" "-build"]
      ["ocaml" "setup.ml" "-install"]
    ]
    remove: [
      ["ocaml" "setup.ml" "-uninstall"]
    ]
    depends: [ "ocamlfind" "spotlib" {>="2.1.0"} "omake" "orakuda"]
    ocaml-version: [>= "4.00.0"]

Oasis でビルド方法を統一してあるので、 ``build`` と ``remove`` ルールはいつも同じ。
依存情報である ``depends`` と ``ocaml-version`` を書き換えるくらいしかしない。
というわけでなんだかんだ言って Oasis は使えるところは使えるのである。

この ``opam`` ファイルに加え、ソフトウェアの説明を記述した　``descr``、ソフトウェアの tarball
をどこに置いたか、そしてそのチェックサムを記録した ``url`` この三点セットのファイルで一つのパッケージ
情報になる。これを opam-repository のレポに置けば誰もがそこから三点セットをダウンロードして
opam コマンドで OCaml ソフトウェアを簡単にインストールできる。自分で OPAM パッケージ
を作る場合はこの公式レポを fork して変更の pull request を送れば良い。平日なら日本の午前に出せば
夕方には取り込まれる。

(もちろん OPAM もソースを使ったソフトの配布システムなので環境が違うとインストールできないという事は
普通にある…万能なソースベースのパッケージシステムなんかないのだ)

そんなこんなで OCamlFind, Oasis, OPAM の住み分けは(少なくとも私には)こんな感じになってる::

* OCamlFind を OMake で使う。最後は ocamlfind install で META ファイル含めてインストール
* Oasis で OMakefile を呼び出す setup.ml を作る
* ソースと setup.ml をレポに上げてバージョンのブランチなりタグを作る
* ブランチもしくはタグに対応する tarball を url に書いて opam, descr と一緒に OPAM レポに pull request
* アップデートリリースのアナウンスは面倒だからしないw opam update したらそこに見つかるだろうから
 
GODI ★?
--------------------

これまたパッケージシステム。 

OCamlFind の人が書いた OCaml パッケージシステムのはしり。 
私はほとんど使ってないし使っていたのも随分前のことで、いろいろとストレスを感じた記憶がある。
パッケージにあるソフトを改造しにくかったような…今は改善されているのではないか…とも思うが、
Oasis や OPAM との比較は私にはできません。誰か教えてください。

コード自動生成
==============

CamlIDL ★★
------------------

OCaml と C の間を取り持つ FFI(Foreign Function Interface) の自動生成ツール

OCaml は C や他言語との橋渡しに C を使う。C関数を OCaml の関数として使うことができるのだが、
そのままでは普通は使用できない。C関数を OCamlの GC やメモリモデルに沿った形で呼び出す
ラッパ関数(スタブ)から間接的に呼び出す必要がある。
そのスタブの型安全性は全く保証されていない。正しい記述方法は
http://caml.inria.fr/pub/docs/manual-ocaml-4.00/manual033.html
に記載されているとおりだが、ちょっと間違うとすぐにプログラムがクラッシュする。
それも GC に関連する問題だと大変だ、間違った関数を呼んでもそこではクラッシュしない…
しばらくたって GC が走ると…ボン！だ。スタブのデバッグは大変だ。

CamlIDL は MIDL という C のヘッダにアノテーションを記述することで
C関数を OCaml から呼び出すためのスタブを自動生成するツール。
一応 OCaml のモジュールを COM コンポネントにする機能も付いているが、こっちは知らない。

アノテーションが正確である限り CamlIDL は正しいスタブを作ってくれる。
むろん、アノテーションを間違うとどうしようもないが、それでも手でスタブを書くよりは
手間は省けるし安全かもしれない。簡単な型の C関数ならかなり楽にスタブを作ってくれる。

が、そのアノテーションが抑えられないような物を書こうとすると工夫が必要になる。
例えば polymorphic variant を使ったサブタイプを入れたいなど…
そういう場合は IDL ファイルに前処理をしたり
生成された OCaml コードに後処理をしたり、まあいろいろとやれないこともない。
が、まず CamlIDL のチュートリアルから。

まあスタブが10個くらいですむなら私は手で書く。ちゃんと OCaml ランタイムのことがわかっていれば
手書きでもそう間違いはおこらないはずだ。スタブが100個とかになると CamlIDL や
自分で頑張ってコード生成器を書くか (LablGtk2 など) 工夫してやることになる。

Type_conv, Sexplib, Bin_prot ★★★
-------------------------------------

型定義から便利なコードを自動生成するフレームワーク、とその応用

代数的データ型を使っているとその代数構造を利用したプログラムコードを
沢山手で書く、大変便利なわけだが、その代数構造から決まりきったコードを記述することが
ままある。例えばプリンタとか::

    type t = Foo | Bar of int

    let show_t = function
      | Foo -> "Foo"
      | Bar n -> "Bar of " ^ string_of_int n

    type t' = Poo | Pee of float

    let show_t' = function
      | Poo -> "Poo"
      | Pee n -> "Pee of " ^ string_of_float n

上の例でもわかるようにコンストラクタ名や型引数の違いはあるが、``show_t`` も
``show_t'`` も基本的にやってることは同じ。完全にルーチンワークだ。
こういったルーチンワーク(Boiler plate code)は書きたくない、できればコンパイラに
自動生成させたいというのが人の常で、type_conv はこういった型の代数的構造から自然と決まるコード
の自動生成を支援するための CamlP4 フレームワーク。type_conv では type 宣言が拡張されていて
``with <名前>`` というのをくっつけることができる::

    type t = Foo | Bar of int with show

    type t' = Poo | Pee of float with show

こう書くと type_conv は ``show`` という名前で登録されたコード生成モジュールを
呼び出して型定義情報を与える、生成モジュールはやはり P4 で書かれていて例えば
上の ``show_t`` や ``show_t'`` を生成する。もちろん生成モジュール
は誰かが書かねばならない。 まあ、 Haskell の deriving をよりプログラマブルに
倒したものと考えれば当たっているだろう。

type_conv でよく使われるコード生成モジュールが sexp と bin_prot。両方共
OCaml の値の一種のプリンタとパーサを提供しているが sexp が S-式の形で、
bin_prot が通信に特化した binary の形で出入力を提供する。
Sexp は 設定ファイルに OCaml の値を直接書き込んだり、読み込んだり、
人がエディタで変更したりできるので、結構便利。
また、型 t を sexp_of_t で S-式に変換した後、``Sexp.pp_hum`` で
プリティプリントすることで簡単なデバッグプリントでの OCaml の値のプリントができる。 
(もちろん S-式の形でプリントされるので読みにくいかもしれないが、
慣れれば結構読めるものである)

type_conv 以下は Jane Street 謹製なので安心。

問題は自分で生成モジュールを作るのは P4 プログラミングを伴うので結構大変ってこと。
自作が面倒なら sexp の S-式から何とかするのが楽。
Sexplib はかなりちゃんとドキュメントが書かれている。

OCaml-Deriving ★★★
--------------------------

OCaml-deriving は type_conv と同じ目的のやはり CamlP4 でのフレームワーク。
こちらは ``with hoge`` の代わりに ``deriving hoge`` と書く。js_of_ocaml
で使われている。 Type_conv と OCaml_deriving が共存できるかどうかは、知らない。

OCaml-deriving は show がすでにあるのが嬉しいかな。まあ type_conv でも meta_conv
使って ``with conv(ocaml)`` すれば同じ事出来るけどね。

Atdgen ★
-------------------

Atdgen はこれまた型定義からのコード自動生成ツール。ただし、これは CamlP4 ではなくって
OCaml のコードを読んで、型定義から関数ソースを生成する独立したフィルタプログラム。
そしてターゲットは JSON に特化しているみたいだ。まあ、 CamlP4 書くの大変だもんね…
これは OCaml でウェブ系の仕事しているアメリカ人たちが使っている様子だ。

プログラミング環境
===============================

Tuareg ★★★★★
---------------------

Emacs の OCaml コードインデンタとハイライタ。

OCaml コンパイラ付属の OCaml-mode でええやんという人もいるが Tuareg が好きという人もいる。
どちらがいいのかは、正直よくわからない。特に私は toplevel でコード片を eval したりしない人なので…
Jane Street が Tuareg を使っていて、特に Monad の bind 関係でインデントを整備していたので
そのあたり、もしかしたら Tuareg のほうが使い勝手が良いこともあるかもしれない。
OCaml-mode も Tuareg もインデントは完璧ではないので気に入らなければ、提案されるインデントは
無視して手で調整する。 C とか Java みたいな硬いインデントポリシーはないのでそこら辺は臨機応変にしよう。

繰り返しになるけれども、 Tuareg を使っていても caml-types.el や camldebug.el は普通に使えます。

後述する Cheat Sheet によれば、Tuareg ってなんかすごくキーショートカットがある、
多分1/10も使ってないわ私…

Vim 関連
-----------------

私 Vim 使わないからよくわからないわー。ゴメンナサイ。

* ocaml.vim とか omlet.vim とか聞きますね。どちらがいいんでしょうね。
* ocaml-annot という caml-types.el に相当するもの　(http://blog.probsteide.com/getting-started-with-ocaml-and-vim)
* https://github.com/MarcWeber/vim-addon-ocaml
* OCamlSpotter にも一応、 ocamlspot.vim てものがあるけど、私使わないから…直してみてよ
 
utop ★★★
--------------

OCaml の標準の REPL である ocaml toplevel はラインエディタ機能もついていないという
ミニマル製品なので rlwrap や Emacs の shell モードの中などで実行することで
エディタ力を強化してやる必要がある。まあこれは Unix 的発想で良いと思うんだけど、
この頃の若者はそういう寛容さがないから無理を強いられていると感じるのしら。

utop は ocaml toplevel を強化したもの。ラインエディット、補完とかカラーつけたりカッコ対応表示したり
できる…使ってみると実際カラフルで全然 Caml っぽくないw が…何気に必要ライブラリすごくないかい？

私は REPL 使わない派なので使ったことなかったんだけど、補完はなかなか良さそうだ。
 
コンパイラテクノロジ寄りの開発強化ツール
============================================

まあ、なんというか分類しにくいんですが、コンパイラのかっちょいい機能を使った
カッチョイイ開発ツール達。

OCamlSpotter ★★★★
-------------------------

名前の定義を探しだすコード解析ツール

人が書いた OCaml コードで、この変数の定義はどこか？とか、この型の定義はどこに？
とか検索するのは結構骨が折れる。 grep や tags では polymorphism や let shadowning がある
OCaml ではいくつも候補が出てきてしまい、そういう際にはどれが正しい定義かよくわからなくなってくる。

しかし人間にはわからなくてもコンパイラは全てを知っている。OCamlSpotter はコンパイラがソースを
コンパイルした際の結果である cmt ファイルを解析し、ソースコードに現れる名前が、どこで定義されたものかを
解析表示することで、コードを読む際の手間を大幅に短縮するツール。Emacs や Vim からも呼び出すことが
でき、簡単なキーでカーソルにある名前の定義へとジャンプすることができる。

OCamlSpotter を利用するにはソースコードを -bin-annot というオプションでコンパイルし、 cmt ファイル
を生成する必要がある。そしてもちろんこの cmt ファイルとソースファイルは消さずに残して置かなければならない。
ライブラリがインストールされる場合には cmt ファイルも共にインストールする必要がある。

これは私が書いたツールなのだが、私の生計は OCaml プログラミングではなくなった今、あまり以前のように
ガンガンとメンテする暇がないのが残念。とりあえず最新の OCaml コンパイラでとりあえず動くものは公開しているが
バグもある(なかなか直らない)。バグは bitbucket の issues 
( http://bitbucket.org/camlspotter/ocamlspot )に報告してくれれば直す気も出るし、
パッチはもっと歓迎。

TypeRex ★★★★
------------------------

Emacs 用の OCaml IDE。

OCamlSpotter と同じような機能にさらに独自ハイライトや
インデント、リファクタリング(変数名を変更すると同じ変数(同じ名前の変数ではなく、同じ定義を指す変数だけ!を変更してくれる)
も搭載されている。うまく動けば超強力らしい。

問題は設計がこりすぎていて、Mac OS X となにか問題があるようで、動かなかったりする。
TypeRex が動かなかったら OCamlSpotter も試してみてくれい。

Spotter も TypeRex も使ってない caml-types.el も使ってないとかいう人は
演習が終わったら OCaml もう使わないほうがいいと思う。 F# とか IDE あるでしょ？

OCaml API Search ★★★
-----------------------------

型式や名前から関数や型定義を探し出す Webツール。 @mzp さん作。
http://search.ocaml.jp/

スタンドアローン GUIツールである OCamlBrowser を Web にしたもの。
OCamlBrowser を Tcl/Tk が無いのでインストールしていない人には便利。
ただし、 Stdlib と Extlib しか検索できない。

今や OPAM があるので OPAM パッケージを全て対応とかしたら嬉しいんじゃないだろうか。
そこまで OCamlBrowser/OCaml API Search の検索アルゴリズムがスケールするのか、どうか興味もある。

cmigrep ★
---------------------

cmigrep はコンパイラが生成した cmi ファイルを解析して grep 的にパターンに合致する
値や型を探し出すコマンドラインツール。
OCamlBrowser は GUI で面倒、OCaml API Search はサーチスペースが
どうしても固定されてしまう、という時、 cmigrep だとちょっと取っ掛かりが難しいが、
網羅的に調べるのに便利といえるかな。

コンパイラ内部依存なので、使用するには各コンパイラごとにちょっとした修正が必要。
私は自分で 4.00.1 に対応させているけど
( https://bitbucket.org/camlspotter/cmigrep-fork )、
確か誰かが同じ事をして公開しているはずです。

OCamlClean ★?
---------------------

これはぜーーんぜん使ったこと無いのだが、 PIC で OCaml を動かすという
OCaPIC project の産物。Dead code elimination を行なって
バイトコードプログラムの挙動は同じままにサイズを減らしてくれる。
(OCaml バイトコードコンパイラは使ってないコードもそのままリンクする。
バイトコードはバイトコードで最適化はほとんど行わないというポリシーなので。)
js_of_ocaml でもデッドコード消去は行われているはずだけれど、
これを事前に使うと嬉しいことがあったり、しない？する？
わかりません。なんで書いといた。

強化ライブラリ
==============================

この紹介は開発ツールということで、ライブラリは飛ばすつもりなのだが、
強化基本ライブラリに関しては例外。

OCaml の標準ライブラリはとても貧弱。
長らく、各人がそれぞれ自分で育てた強化ライブラリを使って仕事をしてきたが、
さすがにそれではいかんだろうという事で強化された基本ライブラリが幾つか
発表されている。

Dev はもっとユーザを束ねて基本ライブラリ拡充運動を一本化して行うべきだったと思う。
正直この辺で手を抜いていたので OCaml 使えねーというイメージが固定化されてしまったのでは
無いかと思っている… 

Jane Street Core ★★★★
---------------------------

OCaml を使って高頻度金融取引をしている Jane Street Capital が自分達で
使用するプログラムを開発するにあたって作った強化基本ライブラリ。
OCaml の標準ライブラリに無かったデータ構造が、あ！ Core にはある！
これも！これも！という嬉しさがよい。
多分従業員がこれに費やした時間をお金に換算すると億円単位は行ってると思うので
間違いなく品質は良い。

Jane Street 内での仕様を第一に考えて作ってあるので、少し癖があるところもある。
例えば、関数の引数で混乱を避けるためにラベル付き引数がふんだんに使用されており、
人によっては過剰かと思うかもしれないし、至るところ Sexplib による S-式エンコーダ
が張り巡らされていて一部それを使うことを強制されているところもある。
また、ライブラリ全体は巨大な core.cmo というファイルにパッケージされるのだが、
これをプログラムにリンクすると当然実行ファイルも巨大なものになる。
(この問題は OCaml コンパイラの問題として認識されていて、多分近い将来解決されると思う)

私は… Jane Street で働いているときは当然使っていたけど、
私が公開しているソフトはライブラリが多く、 Core に依存性を持たせると
使ってくれる人がいなくなるだろうと思い意識的に避けている。そのかわり、
Core で得た経験を基に自分用の小さい基本ライブラリを作っている。

他人にリンクされることのないアプリケーションレベルのプログラム開発なら手を出す
価値は十分にある。

OCaml Batteries Included ★★★★
-----------------------------------

OCaml Batteries Included は Python の Batteries Included から名前を
インスパイヤされた強化基本ライブラリ。

私は使ったことがない。理由は Jane Street Core に慣れているから。
なので違いとかもよくわからない。

Core と Batteries の併用は…わからないけどやめておいたほうがいいと思う。
結構機能的に重複があるし、Core は C言語で書かれた部分もあるから競合しているところがあるかもしれない。

Extlib ★★
-----------------------------------

Extlib は Batteries Included の基になったより小さい強化基本ライブラリ。
Batteries をリンクするのは大きすぎて困るが OCaml 標準は足りなさすぎる…
という時に使うと良い。

強化パーサージェネレータ
========================

Ulex ★★★★
------------------

Unicode aware な Lex。ニホンゴガー言うてる人はどうぞ使ってみてください。
私は使ったこと無い。

Menhir ★★★★★
-------------------

強化された OCamlYacc。ほとんど OCamlYacc の上位互換で同じ \*.mly が使えるにも
関わらず、エラーメッセージが判りやすいうえに OCamlYacc では受け付けない形の
パースルールも幾つか拾ってくれる、というわけで良いことしか無い。 Yacc 使うなら
ocamlyacc じゃなくて Menhir。約束だ。

テストフレームワーク
========================

OUnit ★★★
-------------

ユニットテストライブラリ

テストは簡単には assert でやるもんですが、それが沢山になってくると、どのテストが通ったかとかどれが通ってないとか
調べたくなるもの。OUnit はベタな assert を organized な物にするためのライブラリ。

テストの元になってる最小単位は ``test_fun``、要は ``unit -> unit`` でエラーの場合は ``Failure`` 例外を上げる
関数。これを ``(>::)`` で名前をつけて ``test`` にしてやる。複数の ``test`` を ``(>:::)``
でまとめて一つの大きな ``test`` にしたり、などなど、テストという概念の簡単なコンビネータがある。
最終的に全てのテストを一つの ``test`` にまとめ上げたら ``perform_test`` 関数で走らせる。

OUnit は単にテストをまとめ上げるためだけだから、 QuickCheck 的なランダムテスト自動生成とかは、ない。

テストが大量にあってカバレージが気になる人は使うといい。テストが少量とか、100% 通らないと困る、
という人はあえて使わなくてもいいんじゃないか。

OCaml-QuickCheck ★?
--------------------

書いてみただけ。試したこと無い…

基本的に Haskell の QuickCheck を持ってきただけなので type class の辞書飛ばしを
マニュアルでやらないといけない。面倒そうだ。
https://github.com/camlunity/ocaml-quickcheck
このフォークが 3.12.x の first class module を使っていて
その辞書飛ばしの部分は少し使いやすいそうだ。
しかし、自動値生成として type_conv なり deriving 使ってないと
大変だと思う。多分そういうの無いよねこれは…

ドキュメントw
======================

Cheat Sheets
-----------------------
http://www.ocamlpro.com/blog/2011/06/03/cheatsheets.html

OCaml 関連のカンニングペーパー。文法からコンパイラのスイッチ、 Tuareg まで、
まあ簡単にまとまっていること！ 


# コード検索

OCamlBrowser ★★
-----------------------

型式や名前から関数や型定義を探し出す GUIツール。

例えば ('a \* 'b) list を扱う関数って何がありますかねぇと思ったら
('a \* 'b) list と入れて Type で検索するとそれらしい型を持つ関数が
ずらっと表示される。
length って名前の関数はどんな型に定義されているのか知りたければ
length と入れて Name で検索。そんな感じ。

OCaml のスタンドアローン Hoogle と言えば Haskell の人には判りやすいだろうが
Hoogle より歴史は古い。
今は懐かしき Tcl/Tk を使用しているので入っていない環境も多いだろう。

これのWeb 版とも言える OCaml API Search (http://search.ocaml.jp )を使う
という手もあるが、ocamlbrowser はスタンドアローンなのでローカルに
インストールされたライブラリも探すことができる点は便利。

私は…使わないなー。どんな型に関する関数がどのモジュールで定義されているか
だいたい頭に入っているから対応する \*.mli ファイルをエディタで開いて
使うべき関数名や型コンストラクタを確認するくらいですんでしまう。

OCamlBrowser が依存している LablTk ライブラリは次バージョンから OCaml システム一式からは
外されて独立したライブラリとなる。そのため OCamlBrowser も次バージョンからは「付属ツール」
とは言えなくなる。

