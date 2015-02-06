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

### Warning 1: this is the start of a comment.

```ocaml
# (*) this is a comment *)
Characters 0-3:
  (*) this is a comment *)
  ^^^
Warning 1: this is the start of a comment.
```

演算子を関数として使う場合には括弧でその演算子を囲います。例えば、足し算を行う関数は
二項演算子 `+` を括弧で囲んで `(+)` と書けます:

```
# 1 + 2;;
- : int = 3
# (+) 1 2;;
- : int = 3
```

ですが、`(*)` は掛算を意味しません。OCaml のコメントは `(*` と `*)` で囲まれたテキストです。
ですから `(*)` はコメントの始まりを意味します。しかし、二項演算子 `*` を関数として使おうとして
`(*)` と書く人が後を絶ちません。 `*` を関数として使いたい場合は `(` と `*` の間にスペースを
入れる必要があります。

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

### Warning 2: this is not the end of a comment.

今度は括弧を閉じる方でも警告が出ました。

### どうすべきか

`*` を関数として使いたい場合は `( * )` と書くべきですね。


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


Warning 4: パターンマッチが将来の型の拡張に脆弱かもしれない
--------------------------------------------------------

```
type t = Foo | Bar;;

let f = function
  | Foo -> print_string "1"
  | _ -> print_string "other than 1"

(* Warning 4: this pattern-matching is fragile.
   It will remain exhaustive when constructors are added to type t. *)
```

デフォルトではオンになっていない警告が出て来ました。この警告を見るには、例えば、
`ocamlc -w A x.ml` など全ての警告表示をオンにして下さい。

