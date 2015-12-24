警告から見る正しい OCaml コーディング
====================================

OCaml 4.02.1 には 49種類の警告があります。その定義は OCaml コンパイラのソース
`utils/warnings.mli` で見ることができます:

```ocaml
type t =
  | Comment_start                           (*  1 *)
  | Comment_not_end                         (*  2 *)
  | Deprecated of string                    (*  3 *)
  | Fragile_match of string                 (*  4 *)
  | Partial_application                     (*  5 *)
  | Labels_omitted                          (*  6 *)
  | Method_override of string list          (*  7 *)
  | Partial_match of string                 (*  8 *)
  | Non_closed_record_pattern of string     (*  9 *)
  | Statement_type                          (* 10 *)
  | Unused_match                            (* 11 *)
  | Unused_pat                              (* 12 *)
  | Instance_variable_override of string list (* 13 *)
  | Illegal_backslash                       (* 14 *)
  | Implicit_public_methods of string list  (* 15 *)
  | Unerasable_optional_argument            (* 16 *)
  | Undeclared_virtual_method of string     (* 17 *)
  | Not_principal of string                 (* 18 *)
  | Without_principality of string          (* 19 *)
  | Unused_argument                         (* 20 *)
  | Nonreturning_statement                  (* 21 *)
  | Preprocessor of string                  (* 22 *)
  | Useless_record_with                     (* 23 *)
  | Bad_module_name of string               (* 24 *)
  | All_clauses_guarded                     (* 25 *)
  | Unused_var of string                    (* 26 *)
  | Unused_var_strict of string             (* 27 *)
  | Wildcard_arg_to_constant_constr         (* 28 *)
  | Eol_in_string                           (* 29 *)
  | Duplicate_definitions of string * string * string * string (*30 *)
  | Multiple_definition of string * string * string (* 31 *)
  | Unused_value_declaration of string      (* 32 *)
  | Unused_open of string                   (* 33 *)
  | Unused_type_declaration of string       (* 34 *)
  | Unused_for_index of string              (* 35 *)
  | Unused_ancestor of string               (* 36 *)
  | Unused_constructor of string * bool * bool  (* 37 *)
  | Unused_extension of string * bool * bool    (* 38 *)
  | Unused_rec_flag                         (* 39 *)
  | Name_out_of_scope of string * string list * bool (* 40 *)
  | Ambiguous_name of string list * string list *  bool    (* 41 *)
  | Disambiguated_name of string            (* 42 *)
  | Nonoptional_label of string             (* 43 *)
  | Open_shadow_identifier of string * string (* 44 *)
  | Open_shadow_label_constructor of string * string (* 45 *)
  | Bad_env_variable of string * string     (* 46 *)
  | Attribute_payload of string * string    (* 47 *)
  | Eliminated_optional_arguments of string list (* 48 *)
  | No_cmi_file of string                   (* 49 *)
```

この文書はこれらの警告を解説することを通して、
どういった OCaml プログラムがまずいのか、どう書くべきか、を探っていきます。

Warning 1, 2: 掛算記号とコメント
-------------------------------------------------------

演算子を普通の関数のように前置して使う場合には括弧でその演算子を囲います。
例えば、足し算を行う二項演算子 `+` を括弧で囲んで `(+)` と書くと、

```
# 1 + 2;;
- : int = 3
# (+) 1 2;;
- : int = 3
```

ですが、`(*)` は掛算を意味しません。OCaml のコメントは `(*` と `*)` で囲まれた
テキストです。ですから `(*)` はコメントの始まりを意味します。
しかし、二項演算子 `*` を関数として使おうとして `(*)` と書く人が後を絶ちません。
`*` を関数として使いたい場合は `(` と `*` の間にスペースを入れる必要があります。

```
# 2 * 3;;
- : int = 6
# ( * ) 2 3;;
- : int = 6
```

### Warning 1: this is the start of a comment.

```ocaml
# (*) 2 3 this is a comment *)
Characters 0-3:
  (*) 2 3 this is a comment *)
  ^^^
Warning 1: this is the start of a comment.
```

OCaml は妙なコメントを発見しました。もしかして掛算したかったのでしょうか。

### Warning 2: this is not the end of a comment.

```
# 2 * 3;;
- : int 6
# ( *) 2 3
Characters 2-4:
  ( *) 2 3;;
    ^^
Warning 2: this is not the end of a comment.
- : int = 6
```

今度は括弧を閉じる方でも警告が出ました。OCaml は掛算だと思っていますが
もしかしたらユーザーはコメントを閉じているつもりなのかもしれません。





Warning 3: 推奨されない値
-------------------------------------------------------

```
# true & false;;
       ^
Warning 3: deprecated: Pervasives.&
Use (&&) instead.
- : bool = false
```

これは後方互換性のために残してはあるが、使用を勧められない関数や値を使ったときに出る警告です。
この `(&)` という関数は `pervasives.mli` ファイルに次のようにアトリビュート付きで
宣言されています:

```
external ( & ) : bool -> bool -> bool = "%sequand"
  [@@ocaml.deprecated "Use (&&) instead."]
(** @deprecated {!Pervasives.( && )} should be used instead. *)
```

この `[@@ocaml.deprecated ...]` というアトリビュートがある値を使うとこの警告が
出るわけですね。この場合は `(&)` ではなく `(&&)` を使うべきとのメッセージが表示されます。

### どうすべきか

着本的に deprecated な関数や値は使わないようにしましょう。通常は何を代りにつかうべきか
警告に表示されているはずです。

このアトリビュートはあなたも使うことができます。後方互換性のために残してはあるが、
ほんとうは使って欲くはない値に付けるとよいでしょう。




Warning 4: パターンマッチが将来の型の拡張に脆弱かもしれない
--------------------------------------------------------

```ocaml
(* トップレベルではコードを提示しにくいので、プログラムファイルにします *)

type t = Foo | Bar

let f = function
  | Foo -> print_string "1"
  | _ -> print_string "other than 1"    (* <= Warning 4 *)

(* Warning 4: this pattern-matching is fragile.
   It will remain exhaustive when constructors are added to type t. *)
```

デフォルトではオンになっていない警告が出て来ました。この警告を見るには、例えば、
`ocamlc -w A x.ml` など全ての警告表示をオンにして下さい。





Warning 5: 奇妙な関数の部分適用を発見した
----------------------------------------

```
let () =
  print_string "hello";
  List.iter print_string;   (* <= Warning 5 *)
  print_string "world"

(* Warning 5: this function application is partial,
   maybe some arguments are missing.
*)
```
  


Warning 6: ラベルを省略して関数適用を行った
------------------------------------------

```
let () =
  let iter' ~f xs = List.iter f xs in
  iter' print_endline ["hello"; "world"]    (* <= Warning 6 *)

(* Warning 6: labels were omitted in the application of this function. *)
```

Warning 7: メソッドのオーバーライドを非明示に行った
-------------------------------------------------

```
class c = object
  method m = print_endline "hello"
end

class c' = object
  inherit c
  method m = print_endline "bye"   (* <= Warning 7 *) 
end

(* Warning 7: the method m is overridden. *)
```


Warning 8: 網羅的でないパターンマッチを使用している
-------------------------------------------------

```
let g = function                    (* <= Warning 8 *)
  | true -> print_endline "hello"

(* Warning 8: this pattern-matching is not exhaustive.
   Here is an example of a value that is not matched:
   false
*)
```
  

Warning 9: レコードのメンバーの一部がパターンに全く出現しない
-------------------------------------------------------

```
type r = { x : int; y : int  }

let h = function
  | {x = 0} -> 0             (* <= Warning 9 *)
  | {x = x; y = y} -> x + y

(* Warning 9: the following labels are not bound in this record pattern:
   y
   Either bind these labels explicitly or add '; _' to the pattern.
*)
```

Warning 10: 関数の返り値が `;` によって捨てられている
-------------------------------------------------------------------

```
let f1 fd =
  let buf = Bytes.create 10 in
  Unix.read fd buf 0 10;       (* <= Warning 10 *)
  buf

(* Warning 10: this expression should have type unit. *)
```


Warning 11: 使われる事のない`match`/`function`ケースがある
--------------------------------------------------------------

```
let x11 x = match x with
  | Some true -> 1
  | Some false -> 0
  | None -> 0
  | Some _ -> 2        (* <= Warning 11 *)

(* Warning 11: this match case is unused. *)
```

Warning 12: this sub-pattern is unused.
-----------------------------------------

```
let f = function
  | () | () -> 1
```

Same as 11 but only for sub-patterns of or-patterns.

Warning 13: the instance variable x is overridden.
-------------------------------------------------------

The behaviour changed in ocaml 3.10 (previous behaviour was hiding.)

```
class c = object
  val x = 1
end

class c2 = object
  inherit c
  val x = 2
end
```

Warning 14: illegal backslash escape in string.
-----------------------------------------------------

```
let x = "\x"
```

This is converted to `let x = "\\x"`.

Warning 15: the following private methods were made public implicitly: ...
-----------------------------------------------------------------------------

Unable to produce... yet

Warning 16: this optional argument cannot be erased.
-------------------------------------------------------------

```
let g ~y ?(x=0) = x + y
```

Warning 17: the virtual method x is not declared.
----------------------------------------------------

```
class virtual c = object (self)
  method y = self#x + 1
end
```

Warning 18: .... is not principal.
----------------------------------------

There is a variety of Warning 18s.

```
(* with -principal *)
type s = { foo: int; bar: unit }
type t = { foo: int }

let f (x:s) =
  x.bar;
  x.foo
```

Warning 19: ... without principality.
------------------------------------------

There is a variety of Warning 19s, like 18.

```
type t = x:int -> y:int -> int

let f g =
  ignore (g : t);
  g ~y:1
```

Warning 20: this argument will not be used by the function.
-------------------------------------------------------------

```
let f () =
  let g () = raise Exit in
  g () 1 
```

Warning 21: this statement never returns (or has an unsound type.)
---------------------------------------------------------------------

```
let rec loop () = loop ()

let () = loop (); print_string "exited from the inf loop!"
```

http://stackoverflow.com/questions/34428933/ocaml-what-is-an-unsound-type

Warning 22: Warnings by PPX preprocessor
----------------------------------------------------

```
[@@@ocaml.ppwarning "Hoo Hoo"]
```

Warning 23: all the fields are explicitly listed in this record: the 'with' clause is useless.
------------------------------------------------------------------

```
type t = { x : int }

let f t = { t with x = 2 }
```


Warning 24: bad source file name: XXX is not a valid module name.
-----------------------------------------------------------------------------

"w24 space.ml"


Warning 25: bad style, all clauses in this pattern-matching are guarded.
---------------------------------------------------------------------------

```
let f = function
  | x when x = 1 -> x + 1
  | x when x = 2 -> x + 20
  | x when x = 3 -> x + 300
```

Warning 26: unused variable x. and Warning 27: unused variable x.
---------------------------------------------------------------------

```
let v =
  let f x = 1 in
  let y = 2 in
  3
```

Warning 28: wildcard pattern given as argument to a constant constructor
---------------------------------------------------------------------------

```
let f = function
  | Some _ -> 2
  | None _ -> 1
```

Warning 29: unescaped end-of-line in a string constant (non-portable code)
----------------------------------------------------------------------------

```
let s = "hello
world
"
```

Warning 30: the XXX YYY is defined in both types TTT and UUU.
-------------------------------------------------------------

```
type t = { x : int }
and u = { x : int }
```

Warning 31: files dir1/a.cmo and dir2/a.cmo both define a module named A
--------------------------------------------------------------------------

Warning 32: unused value xxx.
------------------------------

```
module X : sig end = struct
  let x = 1
end
```

Warning 33: unused open Xxx.
--------------------------------

```
module X = struct
  open List
  let () = print_string "none uses things defined in List!"
end
```

Warning 34: unused type xxx.
-------------------------------

```
module X : sig
end = struct
  type t = None_uses_this_type
end
```

Warning 35: unused for-loop index xxx.
---------------------------------------

```
let () =
  for i = 1 to 10 do
    print_endline "Howdy!"
  done
```

Warning 36: unused ancestor variable xxx.
---------------------------------------------

```
class c1 = object end

class c2 = object
  inherit c1 as super
end
```

Warning 37: unused constructor Xxx.
-----------------------------------------

Warning 37: constructor None_uses_this_constructor is never used to build values. (However, this constructor appears in patterns.)
------------------------------------------------------------

```
module X : sig
  type t
end = struct
  type t = None_uses_this_type
end

module Y : sig
  type t
  val i : int
end = struct
  type t = Foo | None_uses_this_constructor

  let i = match Foo with
    | Foo -> 1
    | None_uses_this_constructor -> 2
end
```

Warning 38: unused extension constructor None_uses_this.
----------------------------------------------------------

```
type t = ..

module X : sig end = struct
  type t += None_uses_this
end
```

Warning 39: unused rec flag.
-------------------------------

```
let rec f x = x
```

Warning 40: this record of type Mmm.xxx contains fields that are 
not visible in the current scope: yyy. They will not be selected if the type becomes unknown.
--------------------------------------------------------------

```
module B = struct
  type r = { i : int }
end

let r : B.r = { i = 1 }
```

Warning 41: these field labels belong to several types: Xxx.ttt Yyy.uuu  The first one was selected. Please disambiguate if this is wrong.
-----------------------------------------------------

```
module M = struct
  type t = { x : int }
end
  
module N = struct
  type u = { x : int }
end

open M
open N

let x = { x = 20 }
```

Warning 42: this use of X required disambiguation.
--------------------------------------------------------

```
module X = struct
  type t = A of int
end

module Y = struct
  type t = A of int
end

open X
open Y

let f x : X.t = A x
```

Warning 43: the label x is not optional.
--------------------------------------------

```
let f ~x = x

let z = f ?x:None
```

Warning 44: this open statement shadows the value identifier xxx (which is later used)
-----------------------------------

```
module M = struct let x = 1 end

let () =
  let x = 2 in
  print_int x;
  let open M in
  print_int x
```

Warning 45: this open statement shadows the label x (which is later used)
-------------------------------------

```
module X = struct
  type t = { x : int; y : int }
end

type t = { x : int; z : int }

open X

let r = { y = 1; x = 2 }
```

Warning 46: illegal environment variable OCAMLPARAM : ...
-----------------------------------------------------------------------------

```shell
$ OCAMLPARAM=foobar ocamlc
File "_none_", line 1:
Warning 46: illegal environment variable OCAMLPARAM : missing '=' in foobar
File "_none_", line 1:
Warning 46: illegal environment variable OCAMLPARAM : missing '=' in foobar
```


Warning 47: illegal payload for attribute 'ocaml.warning'. A single string literal is expected
----------------------------------------------

```
let x = 1 [@ocaml.warning 1 ]
```

Warning 48: implicit elimination of optional argument ?add
-------------------------------------------------------------

```
let f ?(add=1) x = x + add

let twice g x = g (g x)

let () = print_int (twice f 0)
```

Warning 49: no cmi file was found in path for module Gyaa
------------------------------------------------------------

```
(* ocamlc -no-alias-deps w49.ml *)
module Gyaa = Gyaa
```

Warning 50: ambiguous documentation comment
--------------------------------------------------

```
let x = 1 (** about x *)
let y = 2 (** about y *)
```

  

