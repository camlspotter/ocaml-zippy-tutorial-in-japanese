# OCaml 開発環境について ~ OCaml コンパイラソース付属ツール

2015年10月での関数型言語 OCaml コンパイラ一式をインストールした際に付属する「公式」ツール群の紹介を行う。多岐に渡るので、一つ一つの詳しい説明は行わない。各ツールの細かい情報はそれぞれのドキュメントを参照して欲しい。

もし知らないツール名があったらちょっと読んでみて欲しい。もしかしたらあなたの問題を解決するツールがあるかもしれないから。(特に caml-types.el)

★は重要度。五点満点。

外部ツールの紹介はまた今度ね。

# OCaml コンパイラ

現時点での公式最新バージョンは 4.02.3。

このところ OCaml のマイナーバージョンの変わるリリースは一年に一度位。
バグフィックスパッチやリリースはより頻繁にある。順調に行けば 2015年末には
4.03.0 が出るのではないか。

## ocaml toplevel ★★★★

OCaml 対話環境。いわゆる REPL(Read-Eval-and-Print Loop)。
入力は型推論の後 bytecode へとコンパイルされ VM により評価される。
Bytecode とはいえコンパイルが入るため、インタープリタとは普通呼ばれない。
(Native code へとコンパイルする ocamlnat という対話環境も存在する。
ただしまだ「非公式」)

ocaml toplevel にはラインエディタ機能はない。行の編集や履歴を呼び出したい場合は、

* rlwrap : read line wrapper ( http://utopia.knoware.nl/~hlub/rlwrap/#rlwrap )
* emacs の shell mode 内などでの実行
* サードパーティー製の強化 toplevel である utop を使う

などして編集能力を強化するのが普通。utop はこの頃ユーザーも多くなってきたので
使ってみるとよいと思う。

Real World OCaml programmer で toplevel を使うか使わないか…は人により違うようだ。
Toplevel は値のプリンタがあるので、プログラム開発中に toplevel にライブラリをロードして
関数のインタラクティブなテストを行う人はいる。
一方、私は電卓として使うか型システムの挙動を確かめる時以外全く使わない。

## ocamlc bytecode compiler ★★★★

OCaml ソースコードを bytecode へとコンパイルするコンパイラ。
Bytecode プログラムは native code と比べると遅いが、 
ocamldebug を使ったデバッグが可能。

協調スレッドを多用した OCaml プログラムの場合デバッグは ocamldebug を使っても…
という場合が多く、ocamlopt でコンパイルしたコードを gdb でデバッグするのとあまり変わらないような気がする。
ocamlopt を gdb でデバッグするのもこの頃はかなり楽になってきたそうなので、
デバッグを期待した ocamlc によるコンパイルは最後の手段だと思われる。

## ocamlopt native code compiler ★★

OCaml ソースコードを native code (マシン語)へとコンパイルする。 
Native code がサポートされているアーキテクチャで
OCaml コンパイラソースコードディレクトリで make opt すると作成される。
実はほとんど使わない。次の ocamlc.opt, ocamlopt.opt を参照のこと。

## ocamlc.opt ocamlopt.opt ★★★★★

Native code にコンパイルされた bytecode および native code コンパイラ。
Native code コンパイルが可能な環境では通常このコンパイラを使う。

OCaml コンパイラソースコードで make opt の後に make opt.opt を行うと作成される。
通常の ocamlc, ocamlopt は bytecode で実行されるが、 *.opt コンパイラは native に
コンパイルされているため ocamlc, ocamlopt よりコンパイル速度が早い。
(Bytecode 版コンパイラがひどく遅いわけではないが。)

ocamlc, ocamlopt 以外の OCaml のツールにも、.opt の suffix がついた 
native code バージョンが存在する。

## 依存抽出: ocamldep ★★★★★

ocamldep は複数の OCaml プログラムファイル間の依存関係を抽出するツール。
結果は Makefile の依存書式で出力される。通常は、

``` shell
$ ocamldep *.ml *.mli > .depend
```

として依存情報をファイルに書きだし、それを Makefile 等で `include .depend` する。

使い方の例は、 Makefile を使った OCaml ソフトウェアを見れば、
まず使用されているので、それらを参考に。

重要ではあるが、 ocamlbuild や OMake、 OCamlMakefile などを使えば
ocamldep は自動的に呼び出されるのであまり意識することはない。

# OCaml パーサーツール

OCaml では lex-yacc スタイルのパーサ生成器が標準で付属しており、
このパーサによって OCaml の文法自体も定義されている。

## ocamllex ★★★★

**注意**: Multi-byte char を処理する場合は、サードパーティー製ツールの ulex を使うべきである。

Lexical analyser。 Lex のスタイルを踏襲しつつ、
アクション等のコードを OCaml プログラムで記述できる。
そのため、基本的に lexer (字句解析)や正規表現の知識が有用かつ前提。
ocamllex は *.mll というアクション等のコードを OCaml プログラムで記述できる。
.mll の例は OCaml コンパイラソースの parsing/lexer.mll を参考にするといい。

## ocamlyacc ★★★

**注意**: 上位互換で、強力かつエラーメッセージの読みやすい Menhir を使うべきである。

Parser generator。こちらは yacc のスタイルを踏襲し、アクション等のコードを OCaml プログラムで記述できる。
そのため、 yacc (LALR) の知識が必要。例えば shift-reduce, reduce-reduce の知識がなければ使いこなせない。
ocamlyacc は *.mly という拡張子のファイルを受け取り、 parsing rule を解釈し、 *.ml へと変換する。
注意すべき点は、 OCaml コード以外のパートでのコメントは `(* ... *)` ではなく、 `/* ... */` であることくらいか。 *.mly の例は OCaml コンパイラソースの parsing/parser.mly を参考に。
なおその場合は完全に shift-reduce 警告を 0 にしている所を味わうこと。

ocamllex, ocamlyacc は色々と古臭い部分もあり、イライラすることもあるが、
ほとんどアップデートもなく、非常に良く枯れており高速に動作する。
(Lex-yacc も使えずに LL の Parsec があーたらどーたらカッコイイとか構成的に書けるとか
つぶやくのは甘えです。:-P )

ocamlyacc のほぼ上位互換 parser generator として Menhir という外部ツールがある。 
Menhir は ocamlyacc と同じ *.mly ファイルを受け取る上に、エラーメッセージが読みやすいなど良い点が多い。そのため、現在 OCaml で parser generator を使う場合は Menhir を使うことが推奨されている。
(ユーザに Menhir をインストールさせるのが面倒だと思われる場合は、 Menhir の新機能を使わず *.mly を作り、リリース時には ocamlyacc に戻す、ということも可能。)


## マクロ/文法拡張システム: Camlp4 pre-processor and pretty printer ★

Camlp4 (略称P4) は Pre-Processor and Pretty Printer の４つの P から P4 と呼ばれ、
自分でパーサーをスクラッチから記述できるだけでなく、 
OCaml コードでのマクロや文法拡張を実現することもできる強力なツール。

P4 は強力なのだが、非常に複雑なので OCaml 4.01.0 から
PPX rewriter という文法拡張機能の無いプログラム書換えフレームワークが導入された。
現時点で重要なP4拡張で PPX へ移行が可能なものは移行が完了しているので、
P4 を使うという場面は現在非常に限られている。

P4 では OCaml の文法が yacc のような LALR ではなく LL ベースの stream parsing で再定義されており、
このパーサーを使って OCaml プログラムを解釈し、
その結果を OCaml コンパイラに送ることができる
(OCaml 標準の lex-yacc で書かれたパーサーは迂回される)。
使い方は OCaml コンパイラの -pp オプションを見ること。

この P4 の OCaml parsing rule群を **動的** に変更することで、 
OCaml の文法を拡張することができ、単純なマクロから、非常に複雑なメタプログラミングまで
P4 で行うことができる。

文法拡張記述には OCaml の通常の文法 (original syntax) と
OCaml 文法拡張を書く際、 ambiguity が少なくなる改良文法 (revised syntax) の二つの文法を
選ぶことができる。これらの文法を使うかどうかに対応して Camlp4 コマンドも camlp4* から始まる
複数のコマンド群からなる。

CamlP4 は OCaml 3.10 同梱版より完全にリライトされ、細かい部分がかなり変更された。
そのため、「3.10以前系」のチュートリアルドキュメントは「3.10以降系」には細かい点では違いが多すぎて役に立たない。
そして、P4 について日本語/英語で書かれたウェブ上のドキュメントはほとんどが「以前系」についてである。
「以降系」のドキュメントはあまりない。
基本的なアイデアは以前系も以降系も同じなので 古い P4 のドキュメントを読んで 以降系 P4 の基本的な使用方法を理解することは可能であるが、その際には必ず 3.10系 P4 の working example などを参照して細かな違いを把握する必要がある。

3.10以降系 P4 のチュートリアルとしては Jake Donham の
Reading Camlp4 http://ambassadortothecomputers.blogspot.com/search/label/camlp4
は素晴らしい記事であり、推薦する。

以下は 3.10以降系 Camlp4 を開発した人が書いた情報。残念ながら全く不十分

* Camlp4: Major changes : http://nicolaspouillard.fr/camlp4-changes.html
* Using Camlp4: http://brion.inria.fr/gallium/index.php/Using_Camlp4

インターネット上の P4 の情報を調べる際は、必ずそれがいつの時期に書かれたものか、つまり 3.10以前か 3.10以降かを確認すること。

* 拙著の投げやりな入門: https://bitbucket.org/camlspotter/ocaml-zippy-tutorial-in-japanese/src/a8da8ba783d1c66e4e19e77cc72c15446c8e9f57/camlp4.rst?at=default

### コンパイラ同梱の終了

OCaml 4.02.0 より CamlP4 はコンパイラソースへの同梱が中止され、独立したアプリケーション
としてメンテナンスされることとなった。

### Camlp5 との関係

Camlp4 とは別に Camlp5 というツールが存在する。

Camlp5 は 3.10以前系の Camlp4 が引継がれたもので、コードベースとしては 「3.09 までの P4」 および P5 は似ている。 3.10系 P4 はそれらからかなり離れている。 P5 が P4 より数字が多いため、優れているとか、その逆、という関係ではない。
なお、 P5 は Coq theorem prover でよく使用されている。

P4 と P5 が何故ブランチしたか、はさまざまな事情があるがここで語るべきではない。

# リンク支援: ocamlmktop, ocamlmklib ★★

ocamlmktop および ocamlmklib は外部Cライブラリをリンクした toplevel や
ライブラリを作成する際に補助的に使用するツール。

これらのライブラリや toplevel は
OCaml コンパイラ、C コンパイラ、リンカ、アーカイバ を自分で呼び出すことで
作成できるのだが、この煩雑な作業を代行してくれるのが
ocamlmktop と ocamlmklib である。

# プログラムビルドシステム: ocamlbuild ★★★★

プログラムビルドシステム。

ocamlbuild は簡単な OCaml ソースに対しては ソースファイル名を列挙するだけでモジュール間の依存関係解析からコンパイル、リンクに至るまでを自動的に行なってくれる。そのため Makefile のような既存の外部ビルドシステムにおけるビルドの煩雑さから解放される。

複雑なソース、プログラムコードの自動生成や特殊なリンクが必要な場合など、の場合は myocamlbuild.ml という OCaml モジュールで特殊ルールを記述し ocamlbuild に伝える必要がある。このファイルでは ocamlbuild が提供するルール記述用ライブラリを使うことができる。

ocamlbuild にはよいドキュメントがなかったが、最近、良い物が公開された: https://github.com/gasche/manual-ocamlbuild/blob/master/manual.md

難点としては、ルール記述が OCaml という汎用言語で書かねばならないためどう見ても Makefile や OMakefile などのビルドに特化した言語に比べ煩雑に見えてしまうことがある。もちろん OCaml の利点である型安全性やパターンマッチ、高階関数などによってビルドルールを構成的に書くことができるのだが…もう少し文法拡張などして DSL の風味を付け加えるべきではなかろうか。

私は ocamlbuild は使わない。現在のところ OMake を使っている。ocamlbuild は現在 OCaml コンパイラをコンパイルするのに使用されていないので、ソース同梱が中止される可能性が高い。

# ドキュメントシステム: ocamldoc ★★★

OCaml のコードを HTML や LaTeX の形に抽出するためのドキュメントシステム。
`(** ... *)` という特殊なドキュメントコメントを使うことで簡単な整形記法や
コード要素に明示的に結び付けられたドキュメントを簡単に書くことができる。

OCaml の標準ライブラリリファレンスドキュメントも ocamldoc によって
各 *.mli ファイルから自動的に生成されている。
(逆に言えば、ライブラリリファレンスをブラウザでアクセスせずとも *.mli を
読めば同じ情報が手に入る。)

ドキュメントの書きかたは次を参照してほしい: http://caml.inria.fr/pub/docs/manual-ocaml/ocamldoc.html

# エディタ支援

公式ソースコードに付属するエディタ支援は Emacs, XEmacs の物に限られる。
ソースコードからビルドしている場合、 make install ではこれらの elisp ファイルはインストールされない。
導入にはソースディレクトリ/emacs/README を読むこと。

## caml.el ★★★★★

OCaml プログラムのインデントとハイライトを提供する Caml-mode を提供する。
外部ツールである tuareg-mode を好む人(含む私)もいる。

## caml-types.el ★★★★★

任意の部分式の型を表示させることで型エラー解消などの作業を効率的に行うためのツール。

OCaml はその型推論のおかげでプログラム中に型を書く必要がほとんどない。そのため複雑なコードも簡潔に、かつ型安全に書くことができる。反面、型を明示的に書くことでプログラムが読みやすくなることもある。型が書かれていないため読みにくい他人の書いたコードや、型エラーが発生したがどうも何がおかしいのかわからない、といったことが起こり易くもなる。 caml-types.el を使えば OCaml コードの部分式の型を例えば明示されていなくともコンパイルの結果から表示させることができる。 **caml-types.el を使っているかいないかで OCaml プログラマの生産性は数倍変わるので生き死にに関係する。**

OCaml コンパイラ(ocamlc, ocamlopt)に -annot オプションを付けて *.ml, *.mli ファイルをコンパイルすると *.annot というファイルができる。この *.annot ファイルにはソースコード上の場所をキーとして、そこにある式の型などの情報が記録されている。
caml-types.el はこのファイルを走査し、部分式の型を Emacs のメッセージバッファに表示する。

caml-types.el は caml.el と独立しており、 tuareg-mode と一緒に使うこともできる。

VIM ユーザは外部ツール ocaml-annot ( https://github.com/avsm/ocaml-annot ) などを使っているようである。

# ほとんど使用されないツール

## バイトコードデバッガ ocamldebug ★★

私はほとんど使わない。

ocamldebug は OCaml の byte code プログラムのためのデバッガ。
ocamldebug を使うためには各バイトコードオブジェクトファイル *.cmo を 
ocamlc にデバッグフラグ -g を付けてコンパイルする必要がある。

ocamldebug では一旦進めたデバッグステップを巻き戻すことができるという、ちょっと変わった機能がある。とは言え… printf デバッグか、 gdb を使った native code プログラムのデバッグの方が判りやすい場合が多い。どうしてもプログラム挙動がわからない場合、念のために使われることが多い。これは ocamldebug が非力だからというのではなく、やはり静的に型付けされた関数型プログラムではキャストの誤りや NULL エラーが起こることがなく、あまりデバッグを必要としないから、というのが大きい。

私は使わない…協調スレッドなどの実行順が判りにくいライブラリを使う場合デバッガではプログラムの実行を **人間** が追えないからだ。デバッガは追えていているのだが。

## caml-debug.el ★

ocamldebug を Emacs で使うための elisp。
現在実行中のソースコードの場所などを Emacs 中に表示できる。

## バイトコードプロファイラ ocamlprof と ocamlcp ★

ほとんど利用されない。

ocamlprof は byte code プログラムのためのプロファイラ。
ocamlprof を利用するためには各バイトコードオブジェクトファイルは
ocamlcp という ocamlc のラッパを用いてコンパイルされていなければならない。

ocamlcp でコンパイルされた byte code 実行ファイルを実行すると
ocamlprof.dump というファイルが作成される。
これを ocamlprof コマンドを使って関数などの使用回数を抽出、
元のソースファイル内にコメントとして書きだす。

ocamlprof は呼び出された回数しかプロファイルしないのでほとんど利用されない。

OCaml プログラムで真面目にプロファイルを取る場合は、通常
ocamlopt に -p オプションを付けて native code でのプロファイルを取り、
そのアプトプットを gprof で可視化するのが普通である。

# マニアックなツール

ディレクトリ名がついている場合、それはインストールされないツールである。 OCaml をビルドするとその場所に実行ファイルができる。

./expunge
    ライブラリ中のモジュールを外部から見えなくするためのツール。A というモジュールがライブラリにリンクされていれば、このライブラリを使うと外部から A という名前でこのモジュールにアクセスすることができる。 A を expunge すると、それができなくなる。コンパイラ屋さんくらいしか使わないツール。
ocamlobjinfo
    オブジェクトファイルやライブラリ *.cm* ファイルの環境依存情報を見ることができる。OCaml ではオブジェクトファイル間の整合性は md5sum で管理されているので *.cmi の整合性が合わない!と言われ、これはコンパイラおかしいだろう!と感極まった場合に使うと良いかもしれない。
tools/dumpobj
    *.cmo ファイルをダンプして VM opcode を眺めることができる
tools/read_cmt
    OCaml 4.00.0 より -bin-annot オプションにより生成されるバイナリアノテーションファイル *.cmt をダンプしたり、 *.annot ファイルに変換することのできるツール。まあ ocamlspot を使えってこった
