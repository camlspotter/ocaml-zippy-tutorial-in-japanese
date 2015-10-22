# OCaml 開発環境について

2015年10月での関数型言語 OCaml コンパイラ一式をインストールした際に付属する「公式」ツール群、そしてコミュニティ内で広く使われている「準公式」ツール群の紹介を行う。多岐に渡るので、一つ一つの詳しい説明は行わない。各ツールの細かい情報はそれぞれのドキュメントを参照して欲しい。

もし知らないツール名があったらちょっと読んでみて欲しい。もしかしたらあなたの問題を解決するツールがあるかもしれないから。

★は重要度。五点満点。

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

# ほとんど使用されない公式ツール

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

# ビルド関連

## OMake ★★★★

ビルドツール。

Make や OCamlBuild と同様のビルドツール。

* Makefile のような文法によるビルドルール表記が可能で参入障壁が低い
* Makefile よりも随分マシなセマンティックスな言語。関数による際利用可能なビルドルール記述
* ファイル更新時ではなくファイルのチェックサムによるリビルド。更新されたが変化はなかった自動生成ファイルの不要なコンパイルが行われない
* サブディレクトリでのビルドが楽
* 依存関係を解析して複数コアを使った並列ビルドが簡単
* `-P` スイッチによるファイル変更時の自動リビルド
* OCaml プログラムビルドのための便利な機能がもともと入っているので、OCaml のための複雑な関数記述が不要
* LaTeX や C のルールももうある
* ちゃんとスケールする (Jane Street の 100万行程度の多岐のディレクトリにわたる OCaml プロジェクトでも動く)
* マニュアルに日本語の訳がある (英語: http://omake.metaprl.org/manual/omake.html 日本語: http://omake-japanese.sourceforge.jp/ )

私は OCaml のプログラムは今のところ OMake を使っている。スケール感半端無いので。問題がないわけではない:

* スコープルールが特殊。ビルドのために便利なようになっているらしいが、わかったようなわからないような、である
* 依存関係を完全に抑えなければいけない。さもないと1コアだとコンパイルできるけど複数コアだとビルドに失敗する
* お仕着せの OCaml ビルドルールで満足できなくなると関数を沢山書き始めなければならない。あまり嬉しくない。
* ld as needed と相性が悪く `-P` のビルドが上手くいかない人が ( http://d.hatena.ne.jp/camlspotter/20121002/1349162772 )

それでも小さい OCaml プロジェクトの OMakefile はあっけないほど簡単に書けるので使ってみてほしい。
(まあこれは OCamlBuild にも言えることなんだけどね)

## OCamlMakefile ★★

OCaml のための Makefile マクロ集

OMake や OCamlBuild みたいな新しい物を覚えるのは年を取ってしまってどうも…という人は
OCamlMakefile という OCaml プログラムをビルドする際に便利なマクロが詰まった Makefile
を使うと良い。が、 OCamlMakefile のマクロを覚えるコストと OMake や OCamlBuild の初歩を
学ぶコストはどちらが小さいか。

私は5日程使った記憶がある

## OCamlFind / Findlib ★★★★★

ライブラリパッケージマネージャおよびビルド補助ツール

非常に重要なツール。
OCamlFind はある種のパッケージシステムでもあるわけだけど
パッケージ配布には焦点を置いていないのでビルドシステムに分類した。

OCaml コンパイラはモジュールをまとめてライブラリにするリンカ機能は当然あるが、
その出来たライブラリをどのように管理すべきか、統一的な方法はコンパイラ開発チームは
あまり提唱しなかった。そのため、作ったライブラリは `ocamlc -where` で表示される
OCaml 標準ライブラリがインストールされている場所に直接放り込む、とか、
まあそこに hogehoge ライブラリなら `hogehoge` というディレクトリを掘ってそのこに
放んでり込む、とか、各人が思い思いにインストールしていたのだった。

またライブラリを実際に使用して実行プログラムにリンクする際のコンパイラフラッグの管理
も大変だった。もし hogehoge というライブラリを使いたいとすれば、 `hogehoge.cma`
などが格納されていパスを `-I` で指定する必要があるし、
もし hogehoge が fugafuga に依存していれば当然 fugafuga に必要なコンパイルスイッチ
も一緒にコンパイラに渡してやらなければならない。もちろんこれは丁寧に Makefile を書いて
再利用できるようにしておけば何の問題もないのだが、まあ、面倒だった。

OCamlFind はこの二つの点を次のように解決する:

* ライブラリ(群)をパッケージとして扱い、パッケージ名による管理を可能にする
* パッケージ管理者は各ライブラリの依存関係をパッケージの `META` ファイルに記述
* OCamlFind は OCaml コンパイラのラッパとして動作、使用するライブラリ名を渡すと必要なスイッチをコンパイラに自動的に渡す

例えば、今私がいじっている OCamltter を改造したライブラリをビルドすると
こんなコマンドが発行される:

```shell
$ ocamlfind ocamlc \
    -for-pack Twitter \
    -package cryptokit,str,sexplib,spotlib,tiny_json_conv \
    -syntax camlp4o -package sexplib.syntax,meta_conv.syntax \
    -thread -w A-4-9-27-29-32-33-34-39 -warn-error A-4-9-27-29-32-33-34-39 \
    -g -I ../base -I ../twitter -I . -c \
    api_intf.ml
```
	   
`-package ...` とか `-syntax ...` のオプションは OCamlFind に 
`cryptkit`, `str`, `sexplib`, `spotlib`, `tiny_json_conv`
というパッケージを使うこと、拡張文法として camlp4o を使うこと、
そして文法プラグインとして sexplib.syntax と meta_conv.syntax を使うことを指示している。
それ以外は ocamlc にある普通のオプション。え、これで既に長いって？

上のコマンドから OCamlFind が実際にどのような ocamlc コマンドを発行しているか、
-verbose オプションを付けてると、表示してくれる:

```
$ ocamlfind ocamlc -verbose ... (上と同じ)
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
```
	
ということだ。大量の `-I` フラッグがついている。
さらに、`-package` には `type_conv` や `meta_conv` を指定しなかったが
`sexplib` と `tiny_json_conv` がこれらを必要としていることがそれぞれの META ファイルに
書かれているので、 `type_conv` と `meta_conv` のフラッグが自動的に加わっている。

OCamlFind は OCaml のライブラリを駆使するものはまず使う必須ツールなので、
ちょっとややこしいことをする場合は使ったほうがいい。

ちなみに OCamlFind は Findlib というライブラリの上に作られたツールなので自分自身の OCamlFind パッケージ名は findlib。なのに OPAM パッケージ名は ocamlfind というちょっと変な名付けになってる。

# パッケージシステム

この数年 OCaml界ではパッケージが熱い。

## Oasis ★★★

統一的ビルドインターフェースを提供

OCaml のソフトウェアはビルドシステムが自由に選べる。 configure + Make, OCamlBuild, OMake など。
問題はビルド方法がひとつひとつ違うことだ。ユーザーは一度一度 INSTALL.txt などを読まなければならない。
Oasis はそんな問題を解決する: OCaml で書かれた setup.ml というファイルを使うのだ。
`ocaml setup.ml -configure` で設定、 `ocaml setup.ml -build` でビルド、 `-install`
でインストールすると言った具合。つまり Oasis による `setup.ml` があればビルドシステムが何であろうが
ユーザは ocaml setup.ml からインストール作業ができる。

Oasis では `_oasis` という設定ファイルに色々書くと自動的に `oasis setup` で setup.ml を
作成してくれるのだが、その際、`_oasis` から OCamlBuild のビルドファイルを自動的に作ってくれたり
OCamlFind の META フィアルを作ってくれたりするようだ。
Readme や INSTALL.txt を勝手に作ってくれたり、
ソフトウェアライセンスとかも記述でき、コピーライトファイルを自動的に取ってきたり、
いろいろ機能はあるみたいなんだけど…私には、ちょっとやりたいことが多すぎて手が回ってない感じのツールだな。

私は OMake ユーザーであり、 OMake は Oasis で全くサポートされていないのでビルドファイル生成とかの
恩恵は全く無い。
まあ _oasis ファイルを書いて oasis setup すると OMake を呼んでくれる setup.ml を
作成することはできる…でもそれだけ。参考までに OMake で使うばあいの `_oasis`:

```
OASISFormat: 0.2
Name:        <パッケージ名>
Version:     <バージョン>
Synopsis:    <説明>
Authors:     <作者名>
License:     <ライセンス>
Plugins:      StdFiles (0.2)
BuildType:    Custom (0.2)
InstallType:    Custom (0.2)
XCustomBuild:      sh -c "cp OMakeroot.in OMakeroot; omake PREFIX=$prefix"
XCustomInstall:    sh -c "cp OMakeroot.in OMakeroot; omake PREFIX=$prefix install"
XCustomUninstall:  sh -c "cp OMakeroot.in OMakeroot; omake PREFIX=$prefix uninstall"
XCustomBuildClean: sh -c "cp OMakeroot.in OMakeroot; omake PREFIX=$prefix clean"
BuildTools: omake
```

OMake はサポートされていないので `XCustomなんちゃら` を使う。まあこれで setup.ml から omake が呼べるようになる。
( http://d.hatena.ne.jp/camlspotter/20110603/1307080062 )
Custom なのでビルドの自動設定はできないが… `_oasis` の Library エントリとか妙によくわからないので
書けないなら書けないで…まあ構わないのだ。

Oasis パッケージを管理する Oasis DB というモノも作られかけていたが…コケた。
アップロードがあまりに不親切かつ面倒だったからだ。今はもう OPAM repo だね。

## OPAM ★★★★★

パッケージマネージャとパッケージレポ

Oasis はパッケージとそのビルドに焦点を当てたツールだったが、 OPAM はどちらかというとパッケージとその配布管理
に重きをおいたパッケージマネージャ。 OPAM では Oasis は setup.ml を提供するツールとして普通に共存できる。

OPAM は Oasis と違ってビルドスクリプトの方には手を出さない。そのかわり `opam` ファイルに
ビルドするには、インストールするには、アンインストールには、どんなコマンドを発行するか、を記述する。
コマンドはシェルで解釈されるので `ocaml setup.ml` だろうが configure + make だろうが
`ocamlbuild` だろうが `omake` だろうが何でもかまわない。
これは Oasis がそのあたり便利にしようとしてコケている事への反省だと思う。

さらに、パッケージが別パッケージのどのバージョンに依存しているかも `opam` ファイルに記述するのだが
この際のアルゴリズムとして Debian のパッケージと同じアルゴリズムが使われている、まあ枯れていて強力
ということなのだろう。

例として私が書いている opam ファイルはいつもこんな感じ:

```
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
```
	
Oasis でビルド方法を統一してあるので、 `build` と `remove` ルールはいつも同じ。
依存情報である `depends` と `ocaml-version` を書き換えるくらいしかしない。
というわけでなんだかんだ言って Oasis は使えるところは使えるのである。

この `opam` ファイルに加え、ソフトウェアの説明を記述した　`descr`、ソフトウェアの tarball
をどこに置いたか、そしてそのチェックサムを記録した `url` この三点セットのファイルで一つのパッケージ
情報になる。これを opam-repository のレポに置けば誰もがそこから三点セットをダウンロードして
opam コマンドで OCaml ソフトウェアを簡単にインストールできる。自分で OPAM パッケージ
を作る場合はこの公式レポを fork して変更の pull request を送れば良い。平日なら日本の午前に出せば
夕方には取り込まれる。

(もちろん OPAM もソースを使ったソフトの配布システムなので環境が違うとインストールできないという事は
普通にある…万能なソースベースのパッケージシステムなんかないのだ)

そんなこんなで OCamlFind, Oasis, OPAM の住み分けは(少なくとも私には)こんな感じになってる:

* OCamlFind を OMake で使う。最後は ocamlfind install で META ファイル含めてインストール
* Oasis で OMakefile を呼び出す setup.ml を作る
* ソースと setup.ml をレポに上げてバージョンのブランチなりタグを作る
* ブランチもしくはタグに対応する tarball を url に書いて opam, descr と一緒に OPAM レポに pull request
* アップデートリリースのアナウンスは面倒だからしないw opam update したらそこに見つかるだろうから
 
# コード自動生成

## CamlIDL ★★

(この頃は Ctypes を使ったほうが良い、のかな

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

## Type_conv, Sexplib, Bin_prot ★★★

型定義から便利なコードを自動生成するフレームワーク、とその応用

代数的データ型を使っているとその代数構造を利用したプログラムコードを
沢山手で書く、大変便利なわけだが、その代数構造から決まりきったコードを記述することが
ままある。例えばプリンタとか:

```ocaml
type t = Foo | Bar of int

let show_t = function
  | Foo -> "Foo"
  | Bar n -> "Bar of " ^ string_of_int n

type t' = Poo | Pee of float

let show_t' = function
  | Poo -> "Poo"
  | Pee n -> "Pee of " ^ string_of_float n
```

上の例でもわかるようにコンストラクタ名や型引数の違いはあるが、`show_t` も
`show_t'` も基本的にやってることは同じ。完全にルーチンワークだ。
こういったルーチンワーク(Boiler plate code)は書きたくない、できればコンパイラに
自動生成させたいというのが人の常で、type_conv はこういった型の代数的構造から自然と決まるコード
の自動生成を支援するための CamlP4 フレームワーク。type_conv では type 宣言が拡張されていて
`with <名前>` というのをくっつけることができる:

```ocaml
type t = Foo | Bar of int with show

type t' = Poo | Pee of float with show
```

こう書くと type_conv は `show` という名前で登録されたコード生成モジュールを
呼び出して型定義情報を与える、生成モジュールはやはり P4 で書かれていて例えば
上の `show_t` や `show_t'` を生成する。もちろん生成モジュール
は誰かが書かねばならない。 まあ、 Haskell の deriving をよりプログラマブルに
倒したものと考えれば当たっているだろう。

type_conv でよく使われるコード生成モジュールが sexp と bin_prot。両方共
OCaml の値の一種のプリンタとパーサを提供しているが sexp が S-式の形で、
bin_prot が通信に特化した binary の形で出入力を提供する。
Sexp は 設定ファイルに OCaml の値を直接書き込んだり、読み込んだり、
人がエディタで変更したりできるので、結構便利。
また、型 t を sexp_of_t で S-式に変換した後、`Sexp.pp_hum` で
プリティプリントすることで簡単なデバッグプリントでの OCaml の値のプリントができる。 
(もちろん S式の形でプリントされるので読みにくいかもしれないが、
慣れれば結構読めるものである)

type_conv 以下は Jane Street 謹製なので安心。

問題は自分で生成モジュールを作るのは P4 プログラミングを伴うので結構大変ってこと。
自作が面倒なら sexp の S-式から何とかするのが楽。
Sexplib はかなりちゃんとドキュメントが書かれている。

## OCaml-Deriving ★★★

(ppx-deriving にほぼ置き換わった

OCaml-deriving は type_conv と同じ目的のやはり CamlP4 でのフレームワーク。
こちらは `with hoge` の代わりに `deriving hoge` と書く。js_of_ocaml
で使われている。 Type_conv と OCaml_deriving が共存できるかどうかは、知らない。

OCaml-deriving は show がすでにあるのが嬉しいかな。まあ type_conv でも meta_conv
使って `with conv(ocaml)` すれば同じ事出来るけどね。

## Atdgen ★

Atdgen はこれまた型定義からのコード自動生成ツール。ただし、これは CamlP4 ではなくって
OCaml のコードを読んで、型定義から関数ソースを生成する独立したフィルタプログラム。
そしてターゲットは JSON に特化しているみたいだ。まあ、 CamlP4 書くの大変だもんね…
これは OCaml でウェブ系の仕事しているアメリカ人たちが使っている様子だ。

# プログラミング環境

## Tuareg ★★★★★

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

## Vim 関連

私 Vim 使わないからよくわからないわー。ゴメンナサイ。

* ocaml.vim とか omlet.vim とか聞きますね。どちらがいいんでしょうね。
* ocaml-annot という caml-types.el に相当するもの　(http://blog.probsteide.com/getting-started-with-ocaml-and-vim)
* https://github.com/MarcWeber/vim-addon-ocaml
* OCamlSpotter にも一応、 ocamlspot.vim てものがあるけど、私使わないから…直してみてよ
 
## utop ★★★

OCaml の標準の REPL である ocaml toplevel はラインエディタ機能もついていないという
ミニマル製品なので rlwrap や Emacs の shell モードの中などで実行することで
エディタ力を強化してやる必要がある。まあこれは Unix 的発想で良いと思うんだけど、
この頃の若者はそういう寛容さがないから無理を強いられていると感じるのしら。

utop は ocaml toplevel を強化したもの。ラインエディット、補完とかカラーつけたりカッコ対応表示したり
できる…使ってみると実際カラフルで全然 Caml っぽくないw が…何気に必要ライブラリすごくないかい？

私は REPL 使わない派なので使ったことなかったんだけど、補完はなかなか良さそうだ。
 
# コンパイラテクノロジ寄りの開発強化ツール

まあ、なんというか分類しにくいんですが、コンパイラのかっちょいい機能を使った
カッチョイイ開発ツール達。

## OCamlSpotter ★★

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

## TypeRex ★

(discontinued? Merlin を紹介するべき

Emacs 用の OCaml IDE。

OCamlSpotter と同じような機能にさらに独自ハイライトや
インデント、リファクタリング(変数名を変更すると同じ変数(同じ名前の変数ではなく、同じ定義を指す変数だけ!を変更してくれる)
も搭載されている。うまく動けば超強力らしい。

問題は設計がこりすぎていて、Mac OS X となにか問題があるようで、動かなかったりする。
TypeRex が動かなかったら OCamlSpotter も試してみてくれい。

Spotter も TypeRex も使ってない caml-types.el も使ってないとかいう人は
演習が終わったら OCaml もう使わないほうがいいと思う。 F# とか IDE あるでしょ？

## OCaml API Search ★★★

(discontinued. OCamlScope を紹介するべき

型式や名前から関数や型定義を探し出す Webツール。 @mzp さん作。
http://search.ocaml.jp/

スタンドアローン GUIツールである OCamlBrowser を Web にしたもの。
OCamlBrowser を Tcl/Tk が無いのでインストールしていない人には便利。
ただし、 Stdlib と Extlib しか検索できない。

今や OPAM があるので OPAM パッケージを全て対応とかしたら嬉しいんじゃないだろうか。
そこまで OCamlBrowser/OCaml API Search の検索アルゴリズムがスケールするのか、どうか興味もある。

## cmigrep ★

cmigrep はコンパイラが生成した cmi ファイルを解析して grep 的にパターンに合致する
値や型を探し出すコマンドラインツール。
OCamlBrowser は GUI で面倒、OCaml API Search はサーチスペースが
どうしても固定されてしまう、という時、 cmigrep だとちょっと取っ掛かりが難しいが、
網羅的に調べるのに便利といえるかな。

コンパイラ内部依存なので、使用するには各コンパイラごとにちょっとした修正が必要。
私は自分で 4.00.1 に対応させているけど
( https://bitbucket.org/camlspotter/cmigrep-fork )、
確か誰かが同じ事をして公開しているはずです。

## OCamlClean ★?

これはぜーーんぜん使ったこと無いのだが、 PIC で OCaml を動かすという
OCaPIC project の産物。Dead code elimination を行なって
バイトコードプログラムの挙動は同じままにサイズを減らしてくれる。
(OCaml バイトコードコンパイラは使ってないコードもそのままリンクする。
バイトコードはバイトコードで最適化はほとんど行わないというポリシーなので。)
js_of_ocaml でもデッドコード消去は行われているはずだけれど、
これを事前に使うと嬉しいことがあったり、しない？する？
わかりません。なんで書いといた。

# 強化ライブラリ

この紹介は開発ツールということで、ライブラリは飛ばすつもりなのだが、
強化基本ライブラリに関しては例外。

OCaml の標準ライブラリはとても貧弱。
長らく、各人がそれぞれ自分で育てた強化ライブラリを使って仕事をしてきたが、
さすがにそれではいかんだろうという事で強化された基本ライブラリが幾つか
発表されている。

Dev はもっとユーザを束ねて基本ライブラリ拡充運動を一本化して行うべきだったと思う。
正直この辺で手を抜いていたので OCaml 使えねーというイメージが固定化されてしまったのでは
無いかと思っている… 

## Jane Street Core ★★★★

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

## OCaml Batteries Included ★★★★

OCaml Batteries Included は Python の Batteries Included から名前を
インスパイヤされた強化基本ライブラリ。

私は使ったことがない。理由は Jane Street Core に慣れているから。
なので違いとかもよくわからない。

Core と Batteries の併用は…わからないけどやめておいたほうがいいと思う。
結構機能的に重複があるし、Core は C言語で書かれた部分もあるから競合しているところがあるかもしれない。

## Extlib ★★

Extlib は Batteries Included の基になったより小さい強化基本ライブラリ。
Batteries をリンクするのは大きすぎて困るが OCaml 標準は足りなさすぎる…
という時に使うと良い。

## Containers

# 強化パーサージェネレータ

## Ulex ★★★★

Unicode aware な Lex。ニホンゴガー言うてる人はどうぞ使ってみてください。
私は使ったこと無い。

## Menhir ★★★★★

強化された OCamlYacc。ほとんど OCamlYacc の上位互換で同じ \*.mly が使えるにも
関わらず、エラーメッセージが判りやすいうえに OCamlYacc では受け付けない形の
パースルールも幾つか拾ってくれる、というわけで良いことしか無い。 Yacc 使うなら
ocamlyacc じゃなくて Menhir。約束だ。

# テストフレームワーク

## OUnit ★★★

ユニットテストライブラリ

テストは簡単には assert でやるもんですが、それが沢山になってくると、どのテストが通ったかとかどれが通ってないとか
調べたくなるもの。OUnit はベタな assert を organized な物にするためのライブラリ。

テストの元になってる最小単位は `test_fun`、要は `unit -> unit` でエラーの場合は `Failure` 例外を上げる
関数。これを `(>::)` で名前をつけて `test` にしてやる。複数の `test` を `(>:::)`
でまとめて一つの大きな `test` にしたり、などなど、テストという概念の簡単なコンビネータがある。
最終的に全てのテストを一つの `test` にまとめ上げたら `perform_test` 関数で走らせる。

OUnit は単にテストをまとめ上げるためだけだから、 QuickCheck 的なランダムテスト自動生成とかは、ない。

テストが大量にあってカバレージが気になる人は使うといい。テストが少量とか、100% 通らないと困る、
という人はあえて使わなくてもいいんじゃないか。

## OCaml-QuickCheck ★?

書いてみただけ。試したこと無い…

基本的に Haskell の QuickCheck を持ってきただけなので type class の辞書飛ばしを
マニュアルでやらないといけない。面倒そうだ。
https://github.com/camlunity/ocaml-quickcheck
このフォークが 3.12.x の first class module を使っていて
その辞書飛ばしの部分は少し使いやすいそうだ。
しかし、自動値生成として type_conv なり deriving 使ってないと
大変だと思う。多分そういうの無いよねこれは…

# ドキュメントw

## Cheat Sheets

http://www.ocamlpro.com/blog/2011/06/03/cheatsheets.html

OCaml 関連のカンニングペーパー。文法からコンパイラのスイッチ、 Tuareg まで、
まあ簡単にまとまっていること！ 


# コード検索

## OCamlBrowser ★★

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

