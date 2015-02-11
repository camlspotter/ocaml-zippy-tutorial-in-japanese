静的型付き関数型言語と Y combinator 
===========================================

OCaml や Haskell のような静的型付き関数型言語で不動点演算子 Y が「書ける」か、という話。

* そのままではどちらでも書けない
* 工夫するとどちらでも「書ける」

Haskell の場合
-----------------

次は Haskell での典型的な不動点演算子の実装:

```haskell
-- fix :: (a -> a) -> a   (型は推論される事を強調するためコメント)
fix f = f (fix f)
```

`fix` は再帰を使っており、これは Y ではない。
Y は再帰を使わない不動点演算子の実装の代表的なもので、Haskell Curry (人名)が発見したものだ。
Haskell (プログラミング言語名)風に書くと、

```
y = \f -> (\x -> f (x x)) (\x -> f (x x))
```

であるが、 Haskell ではこれは型がつかない。
単純型付きλ計算では自分自身を引数に受け取る関数の型、という**再帰型**が
表現できないので型がつかないのである。

Haskell では再帰型がない(と思われる)ので
Y を「書く」ためには、 recursive type を再帰データ型を使ってエミュレートしてやる必要がある。
OCaml の型風に書くと、
```
('a -> 'a as 'a)
```
と
```
('a -> 'a as 'a) -> ('a -> 'a as 'a)     (上を一度展開したもの)
```
の間を行き来するために手動で roll/unroll を書かねばならない。

```
data Roll a = Roll { unroll :: Roll a -> a }

-- y :: (a -> a) -> a
y = \f -> (\x -> f (unroll x x)) (Roll (\x -> f (unroll x x)))
```

OCaml の場合
-----------------

OCaml での fix の定義は次のとおり:

```ocaml
(* val fix : (('a -> 'b) -> 'a -> 'b) -> 'a -> 'b
       (型は推論される事を強調するためコメント) *)
let rec fix f x = f (fix f) x
```

Haskell の `fix` と違って引数 `x` が新たに加わっているのは
strict な言語では、この関数抽象がないと `fix f` の演算が止まらなくなってしまうからである。
ちなみに、`e` を `fun x -> e x` にするのを eta expansion という。
ちゃんと動くか確認:

```
let make_fact f = f (fun self -> function 0 -> 1 | n -> n * self (n-1))

let fact_fix = make_fact fix
let () = assert (fact_fix 10 = 3628800)
```

ここでなぜ eta expansion が必要か理解しておかないと、この先の理解が不可能になる:

```
let fact0 = fun self -> function 0 -> 1 | n -> n * self (n-1)

let rec fix f x = f (fix f) x

let fact_fix = fix fact0

(*
fact_fix 10 => fact0 (fix fact0) 10       -- fix fact0 の展開にはもう一つ引数が必要
            => 10 * (fix fact0) 9
            => 10 * (fact0 (fix fact0) 9)
            => ...
            => 10 * 9 * ... * 1 * 1
*)

let rec fix' f = f (fix' f)

let fact_fix' = fix' fact0

(*
fact_fix' 10 => fact0 (fix' fact0) 10     -- fix' fact0 の展開が可能なのでしてしまう
             => fact0 (fact0 (fix' fact0)) 10
             => fact0 (fact0 (fact0 (fix' fact0))) 10
             => 帰ってこない
*)
```

### Z combinator

同様に、OCaml では Y はそのままでは実行すると `x x` の所を評価しつづけて
止まらない。それを防ぐために `x x` を `fun v -> x x v` に eta expansion して
実行を「遅延」させる:

```
(* これはそのままでは型がつかない *)
let z_type_error = fun f -> (fun x -> f (fun v -> x x v)) (fun x -> f (fun v -> x x v))
```

これは Y ではなく、Z と呼ばれる。

だが、 Haskell と同様、OCaml も**通常は**再帰型を使うことはできないので、
さらに再帰データ型を使った手動の roll/unroll のような鼻薬が必要になる

```
type 'a roll = { unroll : 'a roll -> 'a }
let unroll x = x.unroll
let roll x = { unroll= x }

let z = fun f -> (fun x -> f (fun v -> unroll x x v)) (roll (fun x -> f (fun v -> unroll x x v)))

(* かくにん *)
let fact_z = make_fact z
let () = assert (fact_z 10 = 3628800)
```

### Rectypes

実は、 OCaml には -rectypes オプションがあり、再帰型を使うことができる。
このオプションを使うと

```
('a -> 'a as 'a)
```
と
```
('a -> 'a as 'a) -> ('a -> 'a as 'a)     (上を一度展開したもの)
```
の行き来ができてしまう。
roll/unroll が必要なくなる。
-rectypes はすごい、が、問題もあるので通常使用はお勧めできない。

```
(* ocamlc -rectypes でコンパイルすること *)
let z_rectypes = fun f -> (fun x -> f (fun v -> x x v)) (fun x -> f (fun v -> x x v))

(* かくにん *)
let fact_z_rectypes = make_fact z_rectypes
let () = assert (fact_z_rectypes 10 = 3628800)
```

### Y in OCaml

-rectypes オプションを使うと当然 Y もそのまま書くことができる、、、
が当然無限ループする。

```
let broken_y = fun f -> (fun x -> f (x x)) (fun x -> f (x x))

(* Stack overflow してしまう
let fact_broken_y = make_fact broken_y
let () = assert (fact_z 10 = 3628800)
*)
```

無限ループの原因は x x の評価が止まらない事なので、Z でそうしたように、ここに
遅延評価を導入すると、 Y に似た物が書ける。

```
let y = fun f -> (fun x -> f (lazy (x x))) (fun x -> f (lazy (x x)))

let fact_y = y (fun self -> function 0 -> 1 | n -> n * Lazy.force self (n-1))

let () = assert (fact_y 10 = 3628800)
```
