# OCaml: Open datatype, GADT, と第一級モジュールの使用例

OCaml4以降入った新しい機能には

* Extensible open datatypes (4.02.0)
* GADT (4.00.0)
* 第一級モジュール (4.00.0)

がありますが、これを全部うまく使ったモジュールがありましたので紹介します:

```
$ git clone https://github.com/ocaml/dune
$ cd dune
$ git checkout 290fffc2f31b1807043ced8015d0d86b5711feb3
$ emacs src/stddune/univ_map.ml src/stddune/univ_map.mli
```

コミットハッシュは読者の方と同じソースを参照するためで、
このコミットでなければ絶対にいけないという意味はないです。

まずは`univ_map.mli`ファイルを見てください。

```ocaml
(** Universal maps *)

(** A universal map is a map that can store values for arbitrary
    keys. It is the the key that conveys the type of the data
    associated to it. *)
type t (** マップの型 *)

module Key : sig
  type 'a t (** キーの型 *)
  val create : name:string -> ('a -> Usexp.t) -> 'a t
end

val empty    : t

val is_empty : t -> bool
val mem      : t -> 'a Key.t -> bool
val add      : t -> 'a Key.t -> 'a -> t
val remove   : t -> 'a Key.t -> t
val find     : t -> 'a Key.t -> 'a option
val find_exn : t -> 'a Key.t -> 'a
val singleton : 'a Key.t -> 'a -> t
```

インターフェースを見ればわかりますが、これはkey-value mapです。
OCamlの標準ライブラリにあるkey-value mapであるMapのインターフェースは次のようになっています:

```ocaml
(* OCaml標準ライブラリの map.mli(一部) *)
module type S = sig
  type key (** キーの型 *)

  type (+'a) t (** マップの型 *)

  val empty: 'a t

  val is_empty	: 'a t -> bool
  val mem		: key -> 'a t -> bool
  val add		: key -> 'a -> 'a t -> 'a t
  val remove	: key -> 'a t -> 'a t
  val find		: key -> 'a t -> 'a
  val find_opt	: key -> 'a t -> 'a option
  val singleton	: key -> 'a -> 'a t
  ...
end
```

引数順が丸っ切り逆になっているのと`find_exn`が`find`、`find`が`find_opt`になっているのを読み替えれば、大体同じ構造になっているのが判ると思います。

大きな違いは型パラメータの位置です:

```ocaml
(* 標準ライブラリの map.mli *)
type key (** キーの型 *)

type (+'a) t (** マップの型 *)

val empty	 : 'a t
val add		 : key -> 'a -> 'a t -> 'a t
val find_opt : key -> 'a t -> 'a option
```

```ocaml
(* Dune の univ_map.mli *)
module Key : sig
  type 'a t (** キーの型 *)
end

val empty    : t
val add      : t -> 'a Key.t -> 'a -> t
val find     : t -> 'a Key.t -> 'a option
```

OCaml標準ライブラリはマップの型に型変数がついています:`'a t`。
一度型が`s t`のように決まると、このmapには型`s`を持つ値しかつっこめません。
これ普通ですね。

ところが`Univ_map`の方はマップの型に型変数がありません:`t`。
その代わり、キーの型に型変数がついています:`'a Key.t`。
これはどういうことか。`Univ_map.t`にはどんな型の値でもつっこめるのです。
まず`Univ_map.t`に型`s`の値を`s Key.t`というキーを使ってつっこんだ後に、
別の型`u`の値を`u Key.t`というキーを使ってつっこめる。

`Univ_map.t`みたいな不思議ななんでもつっこめるmapは普通のMLでは書けません。
実装`univ_map.ml`ではこれを実現するために、

* Extensible open datatypes
* GADT
* 第一級モジュール

を使っているので、これを見ていきたいと思います。

# Extensible open datatype

Extensible open datatypeは簡単にいうと昔からあったOCamlの例外の型`exn`を拡張したものです。

例外の型`exn`は後からどんどん新しい例外コンストラクタを足す事ができます:

```
exception SomeException of int

...

exception AnotherException of float
```

これと同じくextensible open datatypeはコンストラクタを後付けできます。
まず`type t = ..`という構文で新しいextensible open datatypeを宣言します:

```
type t = ..
```

宣言後は必要に応じて新しいコンストラクタを`type t += ...`という宣言で足していく事ができます:

```
type t += SomeConstructor of int

...

type t += AnotherConstructor of float
```

Extensible open datatypeが`exn`と違って、型パラメータを取れることもできます:

```
type 'a t = ..

type 'a t += C of int * 'a
```

Extensible open datatypeは例外の型`exn`の純粋な拡張なので、
逆に`exn`はOCaml 4.02.0から、extensible open datatypeの一例になっています。
`exn`は次のようなに定義されたextensible open datatypeとかわりませんし:

```
type exn = ..
```

`exception E of t` は

```
type exn += E of t
```

の糖衣構文になっています。

## Extensible open typeの内部表現

普通のヴァリアントは内部表現に使われるタグの上限の関係からコンストラクタの数に上限があります。
例えば、引数を持つコンストラクタは最大で246個しか持てません:

```
(* Error: Too many non-constant constructors
       -- maximum is 246 non-constant constructors
*)
type t = (* 256個の引数付きコンストラクタ *)
  | C0 of int
  | C1 of int
  ...
  | C255 of int
```

これに対し、例外やextensible open datatypeのコンストラクタは異なる内部表現を使っているのでこの制限がありません。色んなライブラリをリンクしていって、あるところで総例外数が246を超えたからコンパイルが失敗してもらっては困りますからね。

このいくらでもコンストラクタを付け加えられるという性質Univ_mapには重要です。

## GADT





```ocaml
module Eq = struct
  type ('a, 'b) t = T : ('a, 'a) t

  let cast (type a) (type b) (T : (a, b) t) (x : a) : b = x
end

module Key = struct
  module Witness = struct
    type 'a t = ..
  end

  module type T = sig
    type t
    type 'a Witness.t += T : t Witness.t
    val id : int
    val name : string
    val sexp_of_t : t -> Usexp.t
  end

  type 'a t = (module T with type t = 'a)

  let next = ref 0

  let create (type a) ~name sexp_of_t =
    let n = !next in
    next := n + 1;
    let module M = struct
      type t = a
      type 'a Witness.t += T : t Witness.t
      let id = n
      let sexp_of_t = sexp_of_t
      let name = name
    end in
    (module M : T with type t = a)

  let id (type a) (module M : T with type t = a) = M.id

  let eq (type a) (type b)
        (module A : T with type t = a)
        (module B : T with type t = b) : (a, b) Eq.t =
    match A.T with
    | B.T -> Eq.T
    | _ -> assert false
end

module Binding = struct
  type t = T : 'a Key.t * 'a -> t
end

type t = Binding.t Int.Map.t

let empty = Int.Map.empty
let is_empty = Int.Map.is_empty

let add (type a) t (key : a Key.t) x =
  let (module M) = key in
  let data = Binding.T (key, x) in
  Int.Map.add t M.id data

let mem t key = Int.Map.mem t (Key.id key)

let remove t key = Int.Map.remove t (Key.id key)

let find t key =
  match Int.Map.find t (Key.id key) with
  | None -> None
  | Some (Binding.T (key', v)) ->
    let eq = Key.eq key' key in
    Some (Eq.cast eq v)

let find_exn t key =
  match Int.Map.find t (Key.id key) with
  | None -> failwith "Univ_map.find_exn"
  | Some (Binding.T (key', v)) ->
    let eq = Key.eq key' key in
    Eq.cast eq v

let singleton key v = Int.Map.singleton (Key.id key) (Binding.T (key, v))

let superpose = Int.Map.superpose

let sexp_of_t (t : t) =
  let open Usexp in
  List (
    Int.Map.to_list t
    |> List.map ~f:(fun (_, (Binding.T (key, v))) ->
      let (module K) = key in
      List
        [ atom_or_quoted_string K.name
        ; K.sexp_of_t v
        ]))
```

