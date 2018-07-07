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
module type S = sig
  type key (** キーの型 *)

  type (+'a) t (** マップの型 *)

  val empty: 'a t

  val is_empty	: 'a t -> bool
  val mem	: key -> 'a t -> bool
  val add	: key -> 'a -> 'a t -> 'a t
  val remove	: key -> 'a t -> 'a t
  val find	: key -> 'a t -> 'a
  val find_opt	: key -> 'a t -> 'a option
  val singleton	: key -> 'a -> 'a t
  ...
end
```

引数順が丸っ切り逆になっているのと`find_exn`が`find`、`find`が`find_opt`になっているのを読み替えれば、大体同じ構造になっているのが判ると思います。

大きな違いは型パラメータの位置です。
