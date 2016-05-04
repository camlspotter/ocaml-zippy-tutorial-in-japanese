# この文章について

書きかけです…

==============================
splitAt を OCaml で
==============================

Haskell の関数::

  splitAt :: Int -> [a] -> ([a], [a])

を OCaml での遅延リストに翻訳することを考える。ちなみに::

  type 'a t = 'a desc Lazy.t

  and 'a desc = 
    | Null
    | Cons of 'a * 'a t

  let (!!) = Lazy.force

まずどう翻訳したいのか考える
=======================================

Haskell の ``[a]`` を単に ``'a t`` に変えればいいだけではないか？
という単純な考えは一般的に良くない。ちゃんと立ち止まって考える。

``splitAt n xs`` は ``xs`` の prefix ``n``個分と、それ以外の postfix 
を返す。だから、 prefix は常に有限長になる。有限長であって無限長に
ならないのであれば、そもそも ``'a t`` を使わず ``'a list`` ではないのか、
と考えるべきだ。つまり、::

   val split_at : int -> 'a t -> 'a list * 'a t

と考える。そうすると、単に ``[a]`` を ``'a t`` に変えた関数::

   val split_at' : int -> 'a t -> 'a t * 'a t

と型が違う。型が違うと意味が違うはずだ。そう考えると、
``split_at`` と ``split_at'`` がどう動くべき関数であるか
それなりに演繹できる。

まず無限入力にも停止するミニマルなものを書く
============================================================

はじめから欲張って ``split_at'`` を書こうとすると大抵何か
間違いを犯す。まず取り敢えず、どのような ``'a t`` にも結果を返す
(force すると止まらない ``undefined`` かも知れないが)ことを保証する物を
実装しよう。つまり、この場合、 ``split_at`` になる::

  let rec split_at n t =
    if n = 0 then [], t
    else match t with
    | lazy Null -> [], t
    | lazy (Cons (x,t)) -> 
        let xs, t' = split_at (n-1) t in
  	x::xs, t' 

``Lazy.force`` や上述の ``!!`` ではなくパターン部で ``lazy`` を
使って force した上でマッチしていることに注意。 ``Lazy.force`` や ``!!``
を使って書いても良い。

しかしそんな事より、この関数が末尾再帰になっていない事が問題。
ある程度大きい ``n`` を入れるとスタックを食いつぶしてしまう。
こう書くべき::

  let split_at n t = 
    let rec aux rev n t =
      if n = 0 then rev, t
      else match t with
      | lazy Null -> rev, t
      | lazy (Cons (x,t)) -> aux (x::rev) (n-1) t
    in
    let rev, postfix = aux [] n t in
    List.rev rev, postfix

これで出来上がり。``split_at n t`` は ``t`` の ``n`` 個の prefix 
をそこまでの lazy cons を force した上で普通のリストにして返す。
呼び出し時に Lazy cons が force されるのは ``split_at`` の型
に明示されている。Prefix は force されているのでリーク
(プログラマがもういらないはずなのに、と期待していても GC されないようなデータ)
もしない。うん、よろしい。

そして一番重要なことだが、ストリームが無限でも ``split_at`` は停止する。
停止性のみを満たす物を書くのは、これは Haskell の遅延評価を鍵とする関数を
eager evaluation の言語に移す時の最低基準だからだ。そして最低基準であるから、
正しい関数も書きやすい。

それから、できるだけ評価が遅延される物を書く
============================================================

さて、 ``split_at`` を書けたら、次にやることはより遅延が効いた関数を
書くことだ。 ``split_at n xs`` は prefix の cons を force してしまう。
``n`` がいくつで有っても結果にアクセスしない限りできるだけ ``xs`` の
cons が force されないような物を書こう。 ``split_at'`` だ。

事前に ``split_at`` を書いていることで、 ``split_at'`` は次のような
関数でないのは明らかだ::

  let split_at'_bad n t = 
    let prefix, postfix = split_at n t in
    t_of_list prefix, postfix

これでは単に ``split_at`` の結果の prefix 有限リストをストリームに
変えただけだ。確かに型は目指すものと同じだが、``split_at'_bad n t``
を呼び出した時点で先頭の ``n`` 個の cons が force されるのは
``split_at`` と変わらない。

そんなアホな事はしない！？そうだろうか。
気をつけていても型は遅延しているが実際は遅延していない、そういう物を書いてしまうことはある。

分解する時、は lazy で wrap する
---------------------------------------------

Haskell でのなんとなく lazy になる環境に慣れていたり、
不注意で OCaml の普通の list の split_at の様にプログラムを書き出すと
こんなコードになる::

  let rec split_at'_bad2 n t =
    if n = 0 then lazy Null, t
    else match t with
    | lazy Null -> lazy Null, t
    | lazy (Cons (x,t)) -> 
        let pref, post = split_at'_bad2 (n-1) t in
        lazy (Cons (x,pref)), post

これはダメ。何故ダメか。これはちゃんと考えて欲しい。ポイントは二つ::

* 関数に ``t`` を渡すと即座に lazy pattern で force されてしまう。
* ``split_at'_bad2`` がそのまますぐに再帰呼び出しされているので、
  ``split_at'_bad2 n t`` は　即座に ``n``回再帰してしまう。

この二つから、この関数は型こそ目標のものと同じだがやっていることは
結局上の「そんなアホな事はしない！？」と全く同じ。型を合わせただけ、だ。

遅延データを force したら必ずそのコードを lazy で囲もう。つまり、::

  let rec split_at'_bad3 n t =
    if n = 0 then lazy Null, t
    else 
      lazy (match t with
        | lazy Null -> lazy Null, t
        | lazy (Cons (x,t)) -> 
            let pref, post = split_at'_bad3 (n-1) t in
            lazy (Cons (x,pref)), post)

こうなる。 ``split_at'_bad3`` の再帰呼び出しも lazy の中にあるので
上記の２つ目の問題、すぐに再帰呼び出しが行われる問題も解決できている。
しかし、これは型が合っていない。 lazy で wrap してしまったからだ。

Lazy.t を単に !! で外すのはまず間違い
---------------------------------------------

ここで初めて型合わせをやることになる。とはいえ、次のような型合わせは間違い::

  let rec split_at'_bad3 n t =
    if n = 0 then lazy Null, t
    else 
      !!( lazy (match t with
        | lazy Null -> lazy Null, t
        | lazy (Cons (x,t)) -> 
            let pref, post = split_at'_bad3 (n-1) t in
            lazy (Cons (x,pref)), post))

lazy で wrap したのを ``!!`` (force) ですぐさま元に戻している、
これじゃあ意味がない。 ``!!(lazy e)`` は ``e`` と同じだから。
ここで我々が欲しい型は確かに ``('a t * 'a t) Lazy.t -> 'a t * 'a t``
なのだが、一番外側の Lazy.t は force や再帰が勝手に進まないために
導入したものだから外してはいけない。ではどこを外すのか。その内側、つまり::

  ('a t * 'a t) Lazy.t = ('a desc Lazy.t * 'a desc Lazy.t) Lazy.t

の tuple 要素についている ``Lazy.t`` を外すことになる。

  let detuple tpl = fst !!tpl
