# この文章について

この文書はかなり古い。今は OCaml でパッケージと言えば OPAM の時代だ。

==========================================
OCaml のパッケージシステム OASIS を使ってみた
==========================================

今日も OCaml ライブラリのソースをダウンロードするところから始めている皆さん、こんにちは。

はっきり言って、面倒ですよね。一度ダウンロード、コンパイルに成功したら、それのソースツリーを置いておけばそれまでなんですが、
他のマシンでコンパイルしたくなったりしますよね。
私はブチ切れて OMake で指定 URL からダウンロードして apt-get+configure+make+install までオンデマンドでやっちゃうシステムを組みました。
マシンが変わっても ``omake`` 一発で全部やってくれるのが気持ちいいです。 (https://bitbucket.org/camlspotter/omy/overview)

それでもやっぱり、ライブラリがバージョンアップしたら、また始めからソース取ってきて確認、は変わりません。

そうなるとやっぱり、 OCaml にも、 Haskell の Cabal みたいなパッケージシステムが欲しい所ですよね。
GODI (http://godi.camlcity.org/godi/index.html) とかもあるんですが、 GODI のパッケージは GODI にしか使えない。また、良くも悪くも GODI の為のパッケージングしか提供しません。

他のパッケージシステム(例えば Debian とかのバイナリパッケージ)にも使えるメタデータを提供できる枠組みが欲しいよね、
あとどうせパッケージの詳細書くのだったら、そこからビルドスクリプト(Makefile とか)も生成できる方がいいよね、
ということで、 OCamlForge の人たちが OASIS http://oasis.forge.ocamlcore.org/ というのを作っています。
OCaml のビッグユーザである Jane Street も賛同しているので、これはメインストリームになりますから必見ですよ!
まあ、まさに今皆でバグ出ししている最中なのでまだホットすぎるけど。

   しかしこの OASIS いうのが一般名詞過ぎて検索しづらいのよね… ocaml oasis 位で検索しないとどもならん

さて、その OASIS なんですが、今のところターゲットビルドシステムとして OCamlBuild を考えてる。普通の Makefile とか、私の好きな OMakefile は

   OMake (todo)

とか書かれていて、その時点で試す気が沸かなかったのですが、実は OMake な人でも(もちろん、ほかのビルドシステムでも)それなりに書けることが解ったので
ちょっと触ってみることにしました。


そもそも OASIS て何よ
=========================================

まあぶっちゃけ Cabal のパクリですわ。(だから多分、 Cabal と同じような依存地獄が出てきますよｗ 一応、 Cabal ユーザにどこがムカツク？ってサーベイしてたけど。)

_oasis
    ソフトウェアパッケージの名前、作者、バージョン、ライセンス、依存する他のパッケージ名、ビルドするターゲットモジュール等をつらつらと書きこむ
setup.ml 
    ``_oasis`` を ``oasis`` コマンドで変換すると ``setup.ml`` というファイルができる。このファイルを使ってパッケージをビルドしたりインストールしたりする
myocamlbuild.ml
    ``_oasis`` を ``oasis`` コマンドで変換すると OCamlBuild 用のビルドファイルが出来る。 ``setup.ml`` は実はこれを使う。(OCamlBuild じゃない人は作る必要なし
INSTALL.txt, AUTHOR.txt
    ``_oasis`` に必要パッケージとか、作者名とか書いといてくれたら勝手に作ってくれるんだ。英語書かなくてもいい!!

あなたが ``_oasis`` とソースコードを書けば、 ``oasis`` コマンドが ``myocamlbuild.ml`` (Makefile みたいなものね) と ``setup.ml`` (configure と make みたいなコマンドインターフェース) を作ってくれる、その上、_oasis は共通フォーマットだから、(将来)それをアップしとくだけでパッケージサイト(Oasis DB)に登録されたりするわけで、もうとっても Cabal チック。パッケージに興味のある人はダウンロードして、 ``ocaml setup.ml -configure`` ``-build`` ``-install`` で完了。めでたしめでたし! という感じで、パッケージ書く人も使う人も嬉しい、ことになっています。

    でも、俺の環境じゃコンパイルできねえお前何とかしろっていうスパムももれなくついてきそうだね！
    まあ、パッチ送ってくるならともかく、デフォでガン無視だよね！

OCamlBuild 以外でも OASIS が使える
===================================

さて、そんな OASIS なんだけど、今のところビルドシステムは OCamlBuild しか対応してない。んで、私は OCamlBuild 使わないんです。多分日本一 OMake 使ってますんでー。

    OCamlBuild、簡単なことするんだったら、いいらしいですよ、ホント。試してみて下さいよ。

        私はね、OCamlBuild との出会いが良くなかった。
        OCamlBuild は開発時から OCaml に付属する CamlP4 や OCamlDoc をビルドできるように開発されたんだけど 、
        両方共結構大きいアプリケーションだから、その myocamlbuild も当時世界一複雑だった。
        それを、まず例として見てしまった、ウゲェ無理ですよ！でやめちゃったんです。
        まあ、 hello world すっ飛ばしてコンパイラの実装を見てしまったような感じですね。

    もう一度言うけど簡単なとこから始めるといいらしいよ。
    OMake も極まってくると一見さんさようならデスカラネ。

でも実は実は！別に OCamlBuild じゃなくっても OASIS 使えるんです！知らなかったんです！
今のところ、_oasis から OMakefile の雛形を作れないってだけで、自分ですでに OMakefile とか、
普通の Makefile 書いてる場合は問題ないのでした。(ちゃんと目立つとこにそう書いといて欲しいです…) 
なんで、 私の(ビルドシステム的に)極まったライブラリ達を OASIS化してみようじゃあ、あーりませんか。

OASIS をインストールするよ!
===================================

なんでパッケージシステムを使うのに、パッケージからじゃなくてソースからビルドしなきゃいけないんですか、ぷんぷくりーん、
なので、バイナリを使うことにしました。
https://forge.ocamlcore.org/frs/?group_id=54&release_id=343#oasis-0-2-0-title-content
Linux のバイナリは…なんか GUI のインストーラが立ち上がったぞw Ubuntu だと libpcre.so.0 のリンクが問題があるようです。 ``ln -s libpcre.so.3 libpcre.so.0`` して ``LD_LIBRARY_PATH`` でおｋ。 ( https://forge.ocamlcore.org/tracker/?func=detail&aid=784&group_id=54&atid=291 ) 

OASIS をとりあえず使ってみるよ
=========================
QuickStart 読めや: http://oasis.forge.ocamlcore.org/quickstart.html

やる気
-----
とりあえず、新しいプロジェクトを始めよう! という意気込みを持つ(ふりをする。練習なので

QuickStart
----------
新しいディレクトリ掘って ``oasis quickstart`` でもれなくアンケートに答えよう!
変な答を入れるとまた始めからやりなおしなので、体力が必要だ! ( https://forge.ocamlcore.org/tracker/?group_id=54&atid=291&func=detail&aid=797 )
例えばモジュール名は大文字で始めないと門前払い!

適当に答えてたら MyGreatLibrary の為の ``_oasis`` ができた! 見てみよう::

    OASISFormat: 0.2
    Name:        MyGreatLibrary
    Version:     42.0.0
    Synopsis:    My great library
    Authors:     My name is great!
    License:     LGPL-2.0 with OCaml linking exception
    
    Library my_great_library
      Path:            lib            # . はやめた方がいいよ
      BuildTools:      ocamlbuild     # ocamlbuild 用スクリプトを生成してくれる
      Modules:         Great          # 大文字で始める。 lib/great.ml を書くこと
      InternalModules: GreatInternal  # 指定しなくてもよい

この時点での注意は上にコメントで書いといた。 

特に、 Path: はトップディレクトリ ``.`` でも、いいんだけど、やめといた方がいい。
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

既に自分で書いたパッケージを OASIS 化する時、特に。
後述の ``ocaml setup.ml -ほげほげ`` する時に、トップディレクトリもサーチパスに入っているので ``stream.ml`` とか
OCaml 標準ライブラリと同じ名前のファイルがあると爆発するんだ。

ソースをでっち上げる
-----------------

次にやることは、ソースを書くこと。 ``lib/great.ml`` に君の極まったライブラリを書いてください。今回は ``touch lib/great.ml`` で許しといたるわ。

oasis setup そして、設定、ビルドしてインストール!
--------------------------------------------------

``oasis setup`` で ``_oasis`` からビルドに必要な ``myocamlbuild.ml``, ``setup.ml`` をなんとなく自動生成してくれるよ。

OCaml トップレベルと ``setup.ml`` を使ってビルドしてみよう!::

    $ ocaml setup.ml -configure
    ... 
    $ ocaml setup.ml -build
    I: Running command '.../bin/ocamlbuild lib/great.cma lib/great.cmxa lib/great.a -tag debug'
    .../bin/ocamlopt.opt ... myocamlbuild.ml ... -o myocamlbuild
    ocamlfind ocamldep -modules lib/great.ml > lib/great.ml.depends
    ocamlfind ocamlc -c -g -I lib -o lib/great.cmo lib/great.ml
    ocamlfind ocamlc -a lib/great.cmo -o lib/great.cma
    ocamlfind ocamlopt -c -g -I lib -o lib/great.cmx lib/great.ml
    ocamlfind ocamlopt -a lib/great.cmx -o lib/great.cmxa

あ、なんか出来た…(もちろん空だけど） あとは ``ocaml setup.ml -install`` でインストールしたり、 ``-uninstall`` でアンインストールしたりできる。まったくカンタンだ。

あとは、 ``_oasis`` や ``setup.ml``, ``myocamlbuild.ml`` 他、生成されたファイルを github か bitbucket に突っ込んだら一丁上がり! 
君も OCaml デベロッパだ! おっと、 ``lib/great.ml`` も忘れないようにな!

既存ライブラリを OASIS でパッケージ化してみる
=======================================

さて、ここまで読むと、なんだか OASIS って勝手に ``myocamlbuild.ml`` 作ってくれるのはいいけど、それで決め打ち見たいだし、
「俺の極まった ``myocamlbuild.ml`` を上書きするんじゃねぇー」
とか、
「俺は OMake 信者だから OCamlBuild は死んでも使わねー」
という人が出てきます。で、 OASIS 使えねー、というとそうでもないんですね！
今度はそれを見ていきましょう!

まず、トップディレクトリから .ml/.mli をサブディレクトリに移動 
-----------------------------------------------------

上でも書きましたけど、 ``ocaml setup.ml`` との相性が悪い場合があるので、トップにソースを置かないことです。
当然、ビルドのための Makefile (OMakefile も同様、以下省略) はトップからサブを呼び出すようにします。

_oasis をでっち上げる
--------------------

``oasis quickstart`` で適当に答えられるところだけ答えて ``_oasis`` を作ってしまいましょう。
例えば、上の MyGreatLibrary みたいなので構いません。

_oasis を変更しよう
--------------------

``_oasis`` を変更して、自動ビルドスクリプト生成をオフ、そしてビルドコマンドを指定します。結論から言うと OMake だとこんなファイルをつくる::

    OASISFormat: 0.2
    Name:        MyGreatLibrary          # 多分スペース無しで、小文字の方がよいかも。
    Version:     42.0.0
    Synopsis:    My great library        # ここはかっこいい名前を自由に書ける
    Authors:     My name is great!
    License:     LGPL-2.0 with OCaml linking exception
    Plugins:      StdFiles (0.2)         # INSTALL.txt や README.txt を自動で作ってくれる。
    BuildType:    Custom (0.2)           # ocaml setup.ml -build の時に XCustomBuild を使うおまじない
    InstallType:    Custom (0.2)         # ocaml setup.ml -install の時に XCustomInstall を使うおまじない
    XCustomBuild: omake                  # ビルドの時はこのコマンドをつかうぜ
    XCustomInstall: omake install        # インストールの時はこのコマンドをつかうぜ
    XCustomUninstall: omake uninstall    # アンインストールの時はこのコマンドをつかうぜ
    BuildTools: omake                    # omake コマンドが無いとコンパイルできないよ！
    
    Library my_great_library
      Path:          lib
      FindlibName:   my_great_lib        # findlib で my_great_lib っていう名前にするよ
      BuildDepends:  unix                # unix という findlib package が必要なんだ!
      Modules:       Great,              # モジュール名はカンマで区切るんだ
                     Greater,
                     EvenGreater,
                     Greatest

要するに、キモは、 ``BuildType``, ``InstallType`` を ``Custom (0.2)`` に指定して、 
``XCustomHogehoge`` にそれぞれのコマンドを書けばいいだけなんだね!
``ocaml setup.ml -hogehoge`` は単に ``XCustomHogehoge`` のコマンドを実行するラッパになります。
ていうか、それだけの事なんだ… OMake(todo) とか書かンといて欲しいわ…

もちろん、 BuildType を Custom にすると ``oasis setup`` しても ``myocamlbuild.ml`` は生成されなくなる。

    ``BuildType`` や ``InstallType`` 、そして ``ConfType`` を ``Custom (2.0)`` に指定し忘れていると
    現時点では ``XCustomHogeHoge`` を書いてもガン無視する素敵バグがあるので注意だ!!

後は、 ``ocaml setup.ml -hogehoge`` をテストしてちゃんとビルドやインストールできるか確認しよう。

パッケージ化した！ で、どうすんのん？ *将来* OASIS DB で公開しよう
============================================================

*今じゃないぞ!*

ソフトウェアを OASIS でちゃんとパッケージ化すると、 ``_oasis`` に依存情報が書きこまれているはず。
例えば、上の例では、 ``BuildTools: omake`` とか、 ``BuildDepends: unix`` とか書いてありますね。
例えばここにバージョン情報も書けるようです。例えば ``BuildDepends: oUnit (>= 1.0.3)`` とかね。
findlib がバージョン 1.0.3 以上の oUnit を見つけないと ``ocaml setup.ml`` が失敗しちゃうわけです。

OASIS では、この ``_oasis`` に記述された提供バージョンと、依存バージョンを使って、ああ、このパッケージには
このパッケージが必要だな、とか、考えるわけですね。

   いやー、もうこの辺りで OASIS が Ports や Cabal より、上手くいくはずが無いような気がしますが…
   まあこれは、ソースパッケージの宿命ですよね。
   まあ、パッチ送ってくるならともかく、デフォでガン無視だよね！

様々なパッケージの様々なバージョンを管理しよう、という、パッケージレポジトリ (CPAN とか Hackage に対応するもの)が OASIS DB です。
（ http://oasis.ocamlcore.org/ ただいま準備中。人柱は http://oasis.ocamlcore.org/dev/home )

あるパッケージのあるバージョンが欲しい、そういう時は OASIS DB を検索しますし、
また、パッケージを作成して、それが検索されるようにするには OASIS DB に登録することになります。

残念ながら、 OASIS DB は OASIS に輪をかけて絶賛テスト中の状態です、
だから、おおっ、よさげ、 OASIS を使うよー、というカジュアル OCaml ユーザーは、あいや、暫く！あいや、暫く！、です。

OASIS DB で公開する方法(今日現在)
-------------------------------

まず、 OASIS DB にパッケージを登録してみましょう。これは超ムズイ、というか、今のところ間違って変なものを登録すると、
やり直せない、というドキドキ仕様です。私も spotlib-1.0.0 を変に登録してしまいました。消せません。メールして直してもらいました。
でも多分少しでも多く皆がアップロードして盛り上げていったほうがいいと思うので、簡単にハマリポイントを説明しますね。

基本的にこっから先は地雷原です。
何かあったらすぐ思考停止して https://forge.ocamlcore.org/tracker/?atid=294&group_id=54&func=browse にレポートするのが良いみたいですね。

2011/06/06: 一週間かそこらで、投稿パッケージの _oasis ファイル変更が可能になるそうです。これで間違った依存情報を上げてしまっても後から修正することができますね。

OCamlForge のアカウントを作る
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

えっ、持ってないの？
この際です。作りましょう: https://forge.ocamlcore.org/account/register.php

Tarball を作る
~~~~~~~~~~~~~~~~~~~~

OASIS DB には "tarball" でソフトを提出せよ、とあるんですが、これが曲者で、どんな tarball か、まぁあああああたく、記載がないのです。

    記載してクレロンってメール送っといたから何か改善されるかもしれないね
 
以下は私が推測した今日現在(2011/06/05)の条件です。

``xxx.tar.gz`` の形であること
    例えば、上の例で言うと、 ``MyGreatLibrary-1.0.0.tar.gz`` でしょうか。(パッケージ名、バージョン名を持つ必要はありません)
Tarball の中身がトップディレクトリ一つで、 ``xxx/_oasis`` を持っていること
     ``MyGreatLibrary-1.0.0/_oasis``,  ``MyGreatLibrary-1.0.0/lib/great.ml`` ってことですね。(ディレクトリ名がパッケージ名、バージョン名を持つ必要はありません)
.tar.gz であること
     .tar.bz や .tbz は無理です。 .tgz はどうでしょうね。試してません。
 
Tarball をどこかに置く
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

これも謎なんですが、 OASIS DB 自体に tarball をコピーして取っておいてくれるのに、他の所からも同じ tarball を入手できるように
しなきゃいけません。 bitbucket や github とかそういうのに何かそういう機能ありますよね？そこに置きましょう。

Upload しる!
~~~~~~~~~~~~~~~~~~~~~

Tarball の準備ができたら、アップします。

まず、 http://oasis.ocamlcore.org/dev/home の Upload というリンクを押す
    Upload page に移動します。今日現在、あまりに素っ気無い作りに脱力すること請け合いです
Tar ball にローカルに存在する tar.gz ファイルを指定
    今のところ tar.bz ダメです。 tar.gz です。  
Public link に同じ Tar ball を http でダウンロードできる URL を入れる
    じゃあなんで、ローカル tarball を指定せなイカンのか判りません。
    ここで私は意味がわからなかったので、 tarball ではなくドキュメントの URL を入れてしまい、放置プレイ中です。
Upload を押す
    何か問題があると、全く愛想のないエラーメッセージで上手くいかなかったことがわかります。
    何がどううまくいかなかったかは判りません (>_<)
サマリを確認して、確定する
    やり直しできません。漢気を感じさせる作りですね! (>_<)

さて、無事に upload が済むと、 http://oasis.ocamlcore.org/dev/browse にあなたのパッケージがリストされているはず。

OASIS DB からパッケージを落としてきてインストールする
============================================================

OASIS DB からパッケージを落としてきて宜しくやるには、 ODB ってパッケージャを使います: http://oasis.ocamlcore.org/dev/odb/
``odb.ml`` てファイルを ``ocaml odb.ml`` って立ち上げるといい。 密かに curl が必要です。

あるパッケージと、依存パッケージをガガっとインストールするには ``ocaml odb.ml --repo unstable <パッケージ名>`` とするようです。
``--repo unstable`` はパッケージレポジトリの種類を選んでいます。将来的には OASIS DB の人が頑張って、これは stable、
これは testing ってやってくれるみたいです。ホンマかいな。とりあえずは遊びですので、一番数のある unstable ですね。
たとえば csv パッケージをインストールしてみました::

   # ocaml odb.ml --repo unstable csv
   Getting URI: http://oasis.ocamlcore.org/dev/odb/unstable/pkg/info/csv
   Getting URI: http://oasis.ocamlcore.org/dev/odb/unstable/pkg/info/ocamlbuild
   ...
   Package ocamlbuild dependency satisfied: true
   ocamlfind: Package `csv' not found
   Package csv dependency satisfied: false
     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
   100 64377  100 64377    0     0   8718      0  0:00:07  0:00:07 --:--:-- 10090
   csv-1.2.2/
   csv-1.2.2/INSTALL.txt
   ...
   I: Running command '.../bin/ocamlc.opt -config > '/var/tmp/oasis-b142a0.txt''
   I: Running command '.../bin/ocamlfind query -format %v findlib > '/var/tmp/oasis-94ff1d.txt''
   
   Configuration: 
   
   ocamldoc: ...................................... .../bin/ocamldoc
   OCamlbuild additional flags: ................... 
   Compile with ocaml profile flag on.: ........... false
   ...
   
   I: Running command '.../bin/ocamlbuild src/csv.cma src/csv.cmxa src/csv.a examples//example.native -tag debug'
   ...
   I: Installing findlib library 'csv'
   I: Running command '.../bin/ocamlfind install csv src/META $HOME/.odb/install-csv/csv-1.2.2/_build/src/csv.cmi ...
   Installed $HOME/.odb/lib/csv/csv.mli
   Installed $HOME/.odb/lib/csv/csv.cma
   Installed $HOME/.odb/lib/csv/csv.cmxa
   Installed $HOME/.odb/lib/csv/csv.a
   Installed $HOME/.odb/lib/csv/csv.cmi
   Installed $HOME/.odb/lib/csv/META
   ocamlfind: Package `csv' not found
   Package csv dependency satisfied: false
   Problem with installed package: csv
   Installed package is not available to the system
   Make sure $HOME/.odb/bin is in your PATH
   and $HOME/.odb/lib is in your OCAMLPATH

ふーむナルホド。 csv パッケージを取ってきて、(途中の微妙なエラーメッセージは気になりますが)ビルドして、デフォルトでは ``$HOME/.odb`` にインストールするのですね。
うーん、 Cabal そっくりだね。ホントに Cabal と同じ問題がありそうダネ…
最後の二行にあるように、 PATH と OCAMLPATH を設定してあげればあとは良いみたいです。
基本的な機能は動いているみたいですね!!

まとめ: みんな _oasis 書こう
============================================================

そんなこんなで OASIS 体験してみました。親指シフトより簡単です。
見てきたように、別に OCamlBuild 使わないとダメということもありません。
OCaml でプログラムを書いてる皆さんはとりあえずゆっくりと _oasis を書き始めてみたらいいんじゃないかな？

で、余裕があれば OASIS DB に登録してみてくださいね!!
