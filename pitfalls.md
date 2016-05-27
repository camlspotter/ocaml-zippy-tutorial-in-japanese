ログは flush を忘れるな
================================================

stderr といえども呼んだだけでは自動的に flush されない関数があるので注意。特に、

* `*_string` は改行が入っていても flush しない! (`*_newline`, `*_endline` は呼んだ瞬間に flush する)
* `Printf.*printf` は `%!` で明示しない限り改行でも flush しない!

Printf デバッグする時はこれに注意してないと「あれー表示されないのに実行されてるー？おかちいな」ということになる

さらに C とリンクする場合。C 側で fflush() しても OCaml の stdout/stderr は flush されない。
これは OCaml 自身が stdout/stderr の独自バッファを持っているからである。独自バッファに溜まっている文字列は
C は関知しないので当然 `fflush()` しても無駄である。

さらに、`Format.*printf` は明示的に flush していなければ `exit` が呼ばれても flush されない。

```ocaml
let () =
  Format.eprintf "hello world"; (* <= 出力されない *)
  exit 0
```

`Format.std_formatter` を使うもの、つまり `Format.printf` だけは何故か
`exit`時に自動 flush されるのだが、、、あまりこれに頼るべきではない。

Physical comparison `(==)`  `(!=)`  で泣く位なら始めから締めだす
==========================================================================

自分が `(=)`, `(<>)` と `(==)`, `(!=)` の違いが判らないとか、同僚が判らない場合は
もうさっさと `(==)` と `(!=)` は潰したほうがいい。Jane Street Core のように::

```ocaml
(* base.ml *)
let phys_equal = (==)
let (==) _ _ = `Consider_using_phys_equal
let (!=) _ _ = `Consider_using_phys_equal
```

`open Base` すると `(==)` と `(!=)` の型は `'a -> 'b -> [> `Consider_using_phys_equal]` になる。
そこで::

```
if "hello" == "hello" then "equal" else "different";;
```

などと書くと型エラーに `Consider_using_phys_equal` と出てくるので、あれ？なんだこれは？とわかる。
本当に physical comparison を使いたい時は `phys_equal "hello" "hello"` と書く。
これを structural comparison `(=)` と間違って使った場合はもちろん救えない。

`open Base` を全 `*.ml` ファイルで強制しなければならないが、
これは grep などで調べれば機械的にチェックできる。
