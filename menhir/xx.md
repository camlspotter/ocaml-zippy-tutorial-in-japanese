YACC の shift/reduce, reduce/reduce conflict の解消はパーサーの教科書もしくはネット情報に沢山書かれているのでまず。まず、YACC の基本動作原理とともにそれなりに理解してください。たとえば http://guppy.eng.kagawa-u.ac.jp/2006/ProgLang/bison-1.2.8/bison-ja_8.html など。

どの教科書にもありますが、すごく大雑把には

* ルールが大雑把過ぎるのが原因であることが多いので、ジェネレータが conflict で迷わないようになるまでルールを書き下す。
* トークンの優先順位と結合方向を指定することで適用可能なルールの数を減らす
* reduce/reduce は解消したほうがよい
* shift/reduce の場合は shift 優先なので、それで満足ならほっておく (ただしあなたの YACC 経験値は上がりません)

ことで解消します。私は詳しくないのでパーサーに詳しい方は修正してください。

### OCaml 特有の事情

OCaml では、 OCamlYacc は古いのでもう使わない Menhir を使う。
そして、 `menhir --explain` を使ってどこに conflict があるかちゃんと理解する、くらいでしょうか。

### Menhir のレポートの読み方

次の例を使って `<basename>.conflicts` の読み方を説明します。 Bison などのドキュメントで出て来る reduce/reduce の例に少し足したものです:

    %token WORD
    %token START
    
    %start <int> statement
    
    %%
    
    statement:
      | START sequence { $2 }
      ;
    
    sequence:
      | /* empty */ { 0 }
      | maybeword { $1 }
      | sequence WORD { $1 + $2 }
      ;
    
    maybeword:
      | /* empty */ { 0 }
      | WORD { 1 }
      ;
    
    %%

上のコードを `menhir --explain x.mly` とすると次のような `x.conflicts` ファイルが出来ます。`.conflicts` ファイルは `** Conflict (...) in state XXX.` というラインから始まる conflict の説明の集合からなっています。レポートを読んでいて、 `** Conflict (..)` が出てきた時は別の conflict の説明に移っていることに注意すると読み易い:

    ** Conflict (shift/reduce/reduce) in state 1.
    ** Tokens involved: WORD #
    ** The following explanations concentrate on token WORD.
    ** This state is reached from statement after reading:
    
    START 

WORD に対する処理回りで conflict が起っています。これは statement からはじめて START を読み込んだ後、発生します。shift/reduce と reduce/reduce が同時に起っているようですね。
    
    ** The derivations that appear below have the following common factor:
    ** (The question mark symbol (?) represents the spot where the derivations begin to differ.)
    
    statement 
    START sequence 
          (?)

Conflict を起している複数の解釈方法は statement を START sequence だと解釈する所までは共通ですが、そこから先、 sequence をどう解釈するか、の所で発生しています。以下はそれぞれの解釈がどうなっているかの説明です
    
    ** In state 1, looking ahead at WORD, reducing production
    ** maybeword -> 
    ** is permitted because of the following sub-derivation:
    
    sequence WORD // lookahead token appears
    maybeword // lookahead token is inherited
    . 

先読みトークン WORD がある時に、WORD を含めて sequence WORD というルールが選択可能。下から読むと、 (空) -> maybeword -> sequence と構成でき、さらに先読みトークンの WORD と併せて sequence WORD -> sequence となる。 `.` はパーサが見ているところはここ、というマークです。
    
    ** In state 1, looking ahead at WORD, shifting is permitted
    ** because of the following sub-derivation:
    
    maybeword 
    . WORD 

先読みトークン WORD がある時に、下からこの先読みトークンを含めて、 WORD -> maybeword -> sequence という構成が可能。 . WORD は今パーサが居るところが . で WORD は先読みトークンです。
    
    ** In state 1, looking ahead at WORD, reducing production
    ** sequence -> 
    ** is permitted because of the following sub-derivation:
    
    sequence WORD // lookahead token appears
    . 

先読みトークン WORD がある時に、WORD を含めて sequence WORD というルールが選択可能。下から読むと、 (空) -> sequence と構成でき、さらに先読みトークンの WORD と併せて sequence WORD -> sequence となる。

さて、conflict の解消はとにかく受理可能セットを(それが正しいと仮定して)そのまま保ったまま、
このように複数のルールの選択可能性をルールを変更したり優先順位を加えたりして狭めていく、
ということなのですが、とにかくこうしろ、という機械的な方法はありません。
(あればそもそもパーサジェネレータが勝手に解消してくれるはずです。)
もうこれは conflict レポートをよく読んで原因理由を理解するのが一番かと思います。
