Fantasy World OCaml について
===============================

Language
===========

Lexical structure
---------------------

### UTF-8 自体に決め打ちするのは問題ないが、識別子などに自由に許しはじめるとモジュール Module が module.ml に対応する現在の実装では大文字小文字変換で問題の起る utf-8 はそう簡単にはいかない。

### ISO-8859-1 の文字列のコードが動かなくなるので良く考える必要がある。

### キーワードの問題。無理

### `::` は leopard で解決済

Module language
-------------------

### `mod` の様な infix operator のユーザー定義可能性: leopard の ``` ``div``` でほぼ解決済

### Mixins: pure fantasy

### Hierarchical module name space: stdlib で使われているのと同じモジュール名を使えないのは偶に困るので改善されるべきだが、 name space をやっている人がいるのでそれ待ち

### Stateless module: コンパイラの問題というか… js_of_ocaml とか embeded とか考え無い限りあまり必要を感じない

Language builtins
-----------------------

### UTF-8 encoded string: UTF-8 hell 判ってない人特有の fantasy

### byte と bytestring: 別に自分でモジュール作ればよろしい

### Immutable strings: 4.02 で半分実現される

### Non hard-coded `[]` and `(::)(_, _)` in the syntax: 下で議論

Types and type definitions
---------------------------------

### `type not rec t = t` は Core に既にあるし `type _t = t;; type t = _t;;` で無問題。 

### Constructors as functions: leopard で解決済

### `type t = T of int * bool` と `type t = T of (int * bool)` を一緒にする: 内部表現の都合上、無理。むしろ文法を変えて違いを明確にすべき: `type t = T (int, bool) と type t = T (int * bool)` のように。ただし backward compatible で無くなる

### `let f : 'a -> 'a = fun x -> x + 1` をやめる。 Type constraint と type annotation の違いが判っていない人が言いそうなこと。型変数のスコープなどは綺麗に考える必要があると思われるが簡単な問題ではない

### Views : I hate views. Views are evil.

Expressions and value definitions
---------------------------------------

### `fun x x -> x` を受け付けるべきではない: その通り

### `match e with p -> true | _ -> false` の略記としての `<expr> match? <pattern>` : leopard の pattern guard で大体同機能ある

### `<pattern> as x` を拡張して `<pattern> as <pattern>` に。 And pattern …あまり欲いと思ったことがないし pattern guard でよいのでは

### Inlined let: `let! f arg1 ... argn = ...`: いらん

### `do .. done` の代りに `begin .. end` (必須)にする: 必須なところが余計混乱を招く。不可。閉じるのがいやなら leopard の `do:` がある

### 左から右へ引数を評価する: 引数評価順が何故不定にしてあるのか？理解していないとこう言う事を思い付く。

Pervasives
--------------------------

### List のコンストラクタを `Nil` と `Cons` にして `[]` と `::` は関数呼出にする。利点を感じない。


Build Tools and Runtime
==========================

### OCaml のビルドツールを ocamlbuild にしてドキュメントちゃんとする: ocamlbuild はオワコン。

### Camlp4 がなんとか…: Camlp4 はメンテ不可能。オワコン状態にもっていくしかない。

### MinGW でもコンパイルできるようにする: 頑張ってやってください

### ocamlyacc を Menhir に入れ替える: Menhir 入れればいいだけ

### “runtime context”: やっている人いる

### There is an LLVM backend.: やっている人いる

### ライセンス: fantasy

Libraries
==============

### LablTk, Graphics, Str と Num はコアから無くなるべき: どうも自分が使わない場合の勝手な fantasy がおおい。

### `stdlib` はコンパイルビルド用ライブラリにして Batteries なり JS Core なりもっと簡単にはめこめるようにする: したらいいんじゃん？
