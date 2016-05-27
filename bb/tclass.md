Type Class Implementation for Dummies
========================================

関数型言語で話題の型クラスの実装方法。Dummies 向け。マトモに理解したい人はは論文を読むこと。

読み方: 型クラス宣言周りのコードは基本 Haskell 風だが、残りは適当に OCaml に切り換える。理由は:

* 変換後の世界は型クラスないのに型クラスある言語で書くと混乱する
* Haskell は let多相が導入されるところが判りにくいのでヘボい
* Haskell のレコードはヘボい
* Haskell はコンスタントリテラルまで多重定義されているので例が面倒臭すぎる
* 辞書アクセスは plus dict とかではなく明示的に dict.plus と書きたい

混乱して読めない人はお帰り。

非常に簡単な型クラスしか扱わない:

* single parameter type class
* type class 宣言時のインスタンスコードの定義はなし。次のようなやつ:

```haskell
class Ord a where
  (>) :: a -> a -> Bool
  (==)  :: a -> a -> Bool
  (>=) x y = x > y || x == y  -- こういうのは単純化のためパス
```

コンパイル
-------------------------------

型クラスのあるものを直接マシンコードにしたりしない。
型クラスのない、型のついたプログラムにコンパイルする。
だからプログラム変換とも言う。

どの型のものをどの型にコンパイルするか
------------------------------------------

まずこれを抑えておく。これが抑えられていると何となくこのコードはこれに変換されるから、
とアタリがつく。

`=>` は `->` に変換する
------------------------------

`C a => t` という型を持つものは `C a -> t` という関数に変換する。

`C a => D a` という依存のある型クラスは `C a -> D a` という関数に変換。

クラス `C a` はレコード型 `C a` へと変換
---------------------------------------------------------

型クラス宣言

```haskell
class Num a where
  plus :: a -> a -> a
  minus :: a -> a -> a
  fst :: a -> b -> a -- b は Num a に出て来ない
```

は以下のような辞書のデータ型宣言に変換する:

```ocaml
(* ocaml *)
type 'a c = {
  plus : 'a -> 'a -> 'a;
  minus : 'a -> 'a -> 'a;
  fst : 'b . 'a -> 'b -> 'a; (* 'b はここで全称化される *)
}
```

ここではレコード型で説明するが、クラスや第一級モジュールでも構わない。
上の `fst` の場合のためにメンバが多相型を持てるレコードっぽいデータ構造であることが必要。

インスタンスは辞書レコードに変換
---------------------------------------------------------

依存のないインスタンス宣言は辞書レコードに変換する。

```haskell
instance Num Int where
  plus =  plus_int
  minus = minus_int
  fst a b = a

instance Num Float where
  plus =  plus_float
  minus = minus_float
  fst a b = plus_float a 1.2
```

は

```ocaml
(* ocaml *)
let dict_num_int = {
  plus = plus_int;
  minus = minus_int;
  fst = (fun a b -> a);
}

(* ocaml *)
let dict_num_float = {
  plus = plus_float;
  minus = minus_float;
  fst = (fun a b -> plus_float a 1.2);
}
```

というコードになる。 `dict_num_int` は他とダブらない `Num Int` から作ったユニークな名前。

依存のあるクラスのインスタンス宣言は依存部の辞書を貰ってレコードを返す関数になる。

```haskell
instance Num a => C a where
  f :: t[a]  -- なんか内部に a が出て来る型
  f = ...
```

```ocaml
(* ocaml *)
let dict_num_a_arrow_c_a dict_num_a = { (* 頑張って Num a => C a からユニークな名前を作る *)
  f = ... (* dict_num_a が使われる *)
}
```

`dict_num_a` の内部での使われ方は後述の Derived overloading と同じ。


辞書のディスパッチ
--------------------------------------------------------

外側の `let` 多相で型が全称化されていない `C t =>` を持つ identifier
には辞書をディスパッチする:

```ocaml
(* ocaml *)
(* plus :: Num a => a -> a -> a *)
plus 1.2 3.4
```

は `plus` の型は `Num float => float -> float -> float` なので、
`Num float` に対応する辞書をディスパッチする。

```ocaml
dict_num_float.plus 1.2 3.4
```

上の `dict_num_float` の定義を見てこのコードがちゃんと `plus_float 1.2 3.4` と同じ結果を返すことをかくにん、よかった<3

辞書作成はネームスペースにある `dict_*` を組合せて作る。
Prolog を動かすような感じ。作ることができなければ型エラー。
作る方法が複数あれば ambiguous なのでやはり型エラー。

Derived overloading
--------------------------------------------------------

外側の `let` 多相により `C a =>` 部が全称化されているような identifier
には具体的辞書をその場で与えることができない。その代り、外側の `let` から
ディスパッチされたものを使う。

外側の `let` 多相側では内部の全称化された `C a =>` を持つ identifier 
の辞書を外部から貰うために、型は `C a =>` を持たなければいけない。
複数あるばあいは `(C a, D b) => ...` とかになる。 

この `C a =>` の導入に対応して、外部からディスパッチされた `C a` に関する
辞書を受け取るためにλ抽象を入れる:

```haskell
-- plus :: Num a => a -> a -> a
let double x = plus x x      -- plus の型 Num a => a -> a -> a の a は let で全称化されている
-- だから double :: Num a => a -> a という型になる
```

```ocaml
(* ocaml *)
let double dict_num_a (* 外から辞書をもらう *) x = dict_num_a.plus (* 外から貰った辞書を使う *) x x
```

最近の Haskell: OutsideIn(X)
----------------------------

この `C a =>` の `a` を全称化する `let`多相でとにかく `C a =>` をくっつけて
λ抽象を入れるという方式は、`let` がネストする場合無駄なディスパッチコードを作ったりするので
このごろの Haskell では `C a =>` の a が全称化できる `let` は明示することになっている。
(他にも理由はあるが本稿では関係ない)

```ocaml
let quad x =
  let double x = plus x x in
  double x x
```

これを真面目にやると

```ocaml
let quad dict_num_a x =
  let (* double : num 'a -> 'a -> 'a *)
      double dict_num_a' x = plus dict_num_a' x x 
  in
  double dict_num_a x x
```

というコードになるが

```ocaml
let quad dict_num_a x =
  let (* double : num '_a -> '_a -> '_a    '_a はここでは全称化されていない意味 *)
      double x = plus dict_num_a' x x 
  in
  double x x
```

このように全称化をサボることで dispatch コードを消せる。これが困る場合は
全称化することを明示する:

```ocaml
let quad x =
  let double : Num 'a => 'a -> 'a  (* ここで辞書ほしいんですよ *)
      double x = plus x x
  in
  print_int (double 1 2);          (* だってここで複数の型で使うので *)
  print_float (double 1.2 2.3);
  double x x
```

このコードはこうなる:

```ocaml
let quad dict_num_a x =
  let double dict_num_a' x = plus dict_num_a' x x
  in
  print_int (double dict_num_int 1 2);
  print_float (double dict_num_float 1.2 2.3);
  double dict_num_a x x
```

おわり
--------------------------------------------------------

こんな感じで基本的なコンパイル自体は難しくはない。

* 最適化は dispatch 部分の partial evaluation を行えばよい。というかしないと凄く遅くなるので、非明示な最適化を嫌う OCaml は長らくこういうのを採用しない。
* Multi dependent なクラス `(C a, D b) => E a b` は `(C a, D b) -> E a b` に変換するだけ
* Multi parameter class になると型推論が undecidable になるのでその辺はそういう論文読む

