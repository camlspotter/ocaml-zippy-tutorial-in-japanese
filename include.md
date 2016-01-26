呪文 include module type of struct include X end
===============================================================

(mli と sig の関係を判っている人向け用)

モジュールを拡張することってよくある:

```ocaml
module Base : sig
  type t = Foo
end = struct
  type t = Foo
end

module Ext = struct
  include Base
  let f Foo = ()
end
```

問題は、拡張したモジュールのインターフェース(mli)書くのが面倒臭いってこと。

上の `Ext` は `ocamlc -c -i` によれば、こんな sig 持っている:

```ocaml
module Ext : sig 
  type t = Base.t = Foo 
  val f : t -> unit 
end
```

さて基本モジュールの sig が大きい場合、これを手で書くのは大層辛いのだが、
こう書くことができる:

```ocaml
module Ext : sig
  include module type of struct include Base end
  val f : t -> unit 
end
```

何の事かちょっと判らないが、実際これは `ocamlc -c -i` してやると A と同じ
結果が出て来るのである。

これが、

```ocaml
module Ext : sig
  include module type of Base
  val f : t -> unit 
end
```

ではいけない。これは

```ocaml
module Ext : sig 
  type t = Foo        (* Ext.t と Base.t との関係は隠蔽されてしまった *)
  val f : t -> unit 
end
```

になる。 `Base.t` と `Ext.t` は別の型と看做されるので `Base` と `Ext` を混用することができなくなる。

なぜこうなるか
========================================

こうなっているらしい。

```ocaml
module Base = struct
  type t = Foo
end

module Copy = Base

module Included = struct include Base end
```

こいつらはこんな感じの sig を持つ:


```ocaml
module Base : sig
  type t = Foo
end

module Copy = Base

module Included : sig
  type t = Base.t = Foo
end
```

`Copy` の型 `module Copy = Base` は 4.02.x から入ったもので、 `Copy` は `Base` の
エイリアスですよ、ということを表す。まあこれはエイリアスを多用するこのごろのライブラリの為の最適化で、
内容的には `Included` の sig と同じで `type t = Base.t = Foo` を持っていると思ってよい。

さて、`Base` を include することで拡張した `Ext` の型を `module type of X` で
表現しようとすると結果どうなるか、次のコードでわかる:

```ocaml
module Ext = struct
  include Base
  let f Foo = ()
end

module ExtBase     : module type of Base = Ext
module ExtCopy     : module type of Copy = Ext
module ExtIncluded : module type of Included = Ext
```

これを `ocamlc -c -i` してやると:

```ocaml
module Ext : sig 
  type t = Base.t = Foo 
  val f : t -> unit 
end

module ExtBase : sig 
  type t = Foo      (* Ext.t と Base.t との関係は隠蔽されてしまった *)
end

module ExtCopy : sig 
  type t = Base.t = Foo 
end

module ExtIncluded : sig 
  type t = Base.t = Foo 
end
```

ごらんのとおり `module type of Base` で制限すると `ExtBase.t` は `Base.t` との
関連性を失う。`Copy` と `Included` では関連性は保たれたままある。

たいそう気持悪いのだがこれが `module type of X` の仕様である。 `module type of X`
は `X` の sig をそのまま持って来る。 `module type of Base` であれば `type t = Foo`
が `Base` の sig であるので、それが入ってくる。この際 `t` が `Base.t` であったとかは
自動的に入らない。`Included` および `Copy` はその sig に `t` が実は `Base.t` と
同じである事が `type t = Base.t = ..` と情報として含まれているので `module type of Included` や
`module type of Copy` にも受け継がれる、ということになる。

`module type of Base` が `Base` とは関係が無い sig になるというのはどうも私は気持ち悪いが、
そのような sig が作りたくなる場合もあると思われるので理解できる。

一方 `Base` と関連性を保ったままの `Base`互換の sig は
`module type of struct include Base end` というお経のようなコードを書かなくてはいけない
のが辛い。覚えられない。やはり一時的に隠し機能としてあった `(module Base)` とか書けないですかね。
