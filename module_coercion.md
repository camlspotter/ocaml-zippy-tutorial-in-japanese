Module coercion について
=============================

Module coercion というのは初めて見ると何のことだかわからない。わしもそうだったので、わかる。
なので簡単にアイデアだけ説明しておく。

OCaml での module のコンパイル
==============================

OCaml では module を tuple と同じブロック構造に変換する:


    $ ocaml -dlambda
	...
	# module M = struct let x = 42 let y = "hello" end;;
    (apply (field 1 (global Toploop!)) "M/1023"
      (let (x/1021 42 y/1022 "hello") (makeblock 0 x/1021 y/1022)))
    module M : sig val x : int val y : string end


`(makeblock 0 x/1021 y/1022)` というのがその部分。 Tuple でも同じ:


    # (fun x y -> (x,y)) (42, "hello");;
    (after //toplevel//(1):0-32
      (apply
        (function x/1021 y/1022
          (funct-body //toplevel//(1):0-18
            (before //toplevel//(1):12-17 (makeblock 0 x/1021 y/1022))))
        [0: 42 "hello"]))
    - : '_a -> (int * string) * '_a = <fun>


`(x,y)` の部分が `(makeblock 0 x/1021 y/1022)` になっている。

なので `sig val x : int val y : string end` のモジュールは `int * string` と
同じブロック構造をしている。

まずこれ重要。

ML のモジュールの型付けは tuple よりも柔軟
======================================

`(int * string)` という型の tuple があったとして、それを `(string * int)` という
型に使えるかというともちろんそんなことはできない。


    # (Obj.magic (42, "hello") : (string * int));;
    Segmentation fault (core dumped)


が、ML のモジュールは？ `sig val x : int val y : string end` という型を持つ
モジュールは `sig val y : string val x : int end` という型にしても良い。


    # module M = struct let x = 42 let y = "hello" end;;
    module M : sig val x : int val y : string end
    # module N = (M : sig val y : string val x : int end);;
    module N : sig val y : string val x : int end


あれ？ Tuple ではクラッシュするのになぜ module ではクラッシュしない？
`sig val x : int val y : string end` の型を持つモジュールは `(int * string)` 
と同じ構造をしているはず、 `sig val y : string val x : int end` の型にすると
`(string * int)` と同じはず。どうして上手く行く？

Module coercion
======================================

もしコンパイラが何も特にしていなかったとすれば、 tuple の例と同じでクラッシュするはずだ。
クラッシュしないということは何か特別なことをしているから。


    $ ocaml -dlambda
	...
    # module M = struct let x = 42 let y = "hello" end;;
    (apply (field 1 (global Toploop!)) "M/1020"
      (let (x/1018 42 y/1019 "hello") (makeblock 0 x/1018 y/1019)))
    module M : sig val x : int val y : string end
	
    # module N = (M : sig val y : string val x : int end);;
    (let (M/1020 (apply (field 0 (global Toploop!)) "M/1020"))
      (apply (field 1 (global Toploop!)) "N/1023"
        (makeblock 0 (field 1 M/1020) (field 0 M/1020))))
    module N : sig val y : string val x : int end


単に `N` は `M` と同じ値ではなく変換が入っている。
`(makeblock 0 (field 1 M/1020) (field 0 M/1020))` の部分。
`M` の 1番目を 0番目に、0番目を 1番目に置いたブロックを作っている。

これが OCaml の Typedtree に出てくる module_coercion。ある sig を持つモジュールの値を
それに互換性のあるか、より一般的な sig へと型を変える時に、後者の sig のレイアウトへと
モジュールブロックの要素を再配置させるための情報です。

基本的に module coercion は新 sig の中に旧 sig 要素のどの位置のモノが順に出てくるか
なので int list の構造になるが、出てくる対象が module だった場合、その module に対する
module coercion も必要になる。また primitive に対しては…忘れた。ソース読めや。


