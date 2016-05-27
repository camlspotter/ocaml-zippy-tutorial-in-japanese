packed module の中とオリジナルは違う
======================================

```ocaml
(* x.ml *)
type t = Foo
```

`P` というモジュールにパックする事前提でコンパイルします:

```shell
$ ocamlc -for-pack P x.ml
```

`x.cmo` を `p.cmo` にパック。 `P.X` というモジュールを含む `p.cmo` を作ります:

```shell
$ ocamlc -pack -o p.cmo x.cmo
```

さて、 `X.t` と `P.X.t` は同じようで違うというのが本稿の話:

```ocaml
(* y.ml *)
let ts = [ X.Foo; P.X.Foo ] (* X.t と P.X.t は違うという型エラー *)
```
 
あいやー。

Pack というと

```ocaml
module P : sig
  module X : sig 
    type t = X.t = Foo 
  end
end = struct
  module X = X
end
```

という物を期待していたのですが、どうも

```ocaml
module P : sig
  module X : sig 
    type t = Foo  (* 元の X.t との関係は見えない *)
  end
end = struct
  module X = X
end
```

という扱いみたい。

「一旦 pack したら pack したモジュールを介して使え、直接さわるな」って事でいいんですかね。
