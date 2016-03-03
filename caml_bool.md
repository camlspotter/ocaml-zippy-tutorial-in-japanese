# OCaml の真偽値型 `bool`

OCaml の真偽値の型は `bool` その *コンストラクタ* は `true` と `false` である。 `true` と `false` は小文字で始まっているが、変数ではなく、 `Some` や `None` と同じヴァリアントコンストラクタである。よってパターンの中に書ける:

```ocaml
(* true の数を数える *)
function 
  | (true, true) -> 2
  | (true, false) | (false, true) -> 1
  | (false, false) -> 0
```

# `bool` の文字列への出力

`Printf` のフォーマット文字列中で `%b` を使うことで `bool` を出力させることができる:

```
# Printf.sprintf "%b" true;;
- : string = "true"
```
