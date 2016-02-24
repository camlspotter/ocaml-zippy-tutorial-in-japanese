# OCaml の NaN の扱いについて

OCaml では NaN は `nan` と書きます:

```ocaml
# nan;;
- : float = nan
```

`nan` の型は `float` です。`float` は内部では C言語でいう `double`、つまり倍精度の浮動少数点数で表現されます。
OCaml では単精度は標準には無いので、倍精度が `float` で問題ありません。
`nan` は `Pervasives` で倍精度のビットパターンとして定義されています:

```ocaml
let nan =
  float_of_bits 0x7F_F0_00_00_00_00_00_01L
```

# `nan` の比較について

OCaml の `float` 演算は内部では単に C言語での `double` として計算するので、
浮動少数点数の国際規格 IEEE 754 で定められた仕様に従うようになっています。
(これを担保するのは OCaml ではなく、使用している Cコンパイラですけれども。)
これは `nan` の挙動も含みます。ですので、非常に奇妙ですが、

```
# nan = nan;;
- : bool = false
# nan < nan;;
- : bool = false
# nan <= nan;;
- : bool = false
# nan < 1.0;;
- : bool = false
# nan > 1.0;;
- : bool = false
```

となります。これは OCaml のバグではありません。

ところが、 `compare` は違う動きをします:

```
# compare nan nan;;
- : int = 0
# compare nan 1.0;;
- : int = -1
# compare 1.0 nan;;
- : int = 1
```

`compare a b` は `a` と `b` が「等しい」時、 `0` を返すので、`compare` は `nan` は `nan` 自身と等しいと思っています。
また `nan` は `1.0` などの普通の数字と比べると小さいことになっています。
これは上述の比較演算子 `=` の結果と矛盾しますが、バグではありません。意図された仕様です。

`float` をキーにしたコンテナデータを考えてください。例えば、連想リスト`(float * t) list`、
`float` がキーのハッシュテーブル `(float,t) Hashtbl.t`、`Set.Make` を使った `float` の集合などです。

これらのコンテナが正しく動くためには、`float` の全ての要素に等値性や順序が定義されていることが必要になります。
`nan`も例外ではありません。IEEE 754 が定める比較を使ってしまうと、上手く動きません。例えば、連想リストの
キー探索が `(=)` で定義されているとすると、`List.assoc nan [(nan, "hello")]` は `"hello"` を見付けられません。
事実、`List.assoc` のキー比較の実装は `(=)` ではなく `compare` を使っています。

# `float` そして `nan` のポインタ比較について

OCaml では `float` は "boxed" データです。つまり、`float` のデータを新しく作る場合、メモリ領域を新たに割り当て、
倍精度のデータをそこに格納するのです。OCaml ではこの領域へのポインタを `float` の値として使います。誰もメモリ領域を
参照しなくなった場合、領域はGCされます。

OCaml では boxed データをポインタ比較するための `(==)` という演算子があります。否定は `(!=)` です:

```ocaml
# let pi = 3.141592;;
val pi : float = 3.141592
# pi == pi;;
- : bool = true
# pi != pi;;
- : bool = false
```

まあこれはわかりますね。でも次はどうでしょうか:

```ocaml
# 3.141592 == 3.141592;;
- : bool = false
```

同じ数字ですが、ポインタ比較の結果は `false` です。これは OCaml は同じ数字でも別のメモリ領域にデータを割り当てるため、
同じ数字でもポインタとしては別の領域を指しているからです。
(((コンパイラが同じ数字を統合して `let x = 3.141592 in x == x` に式を書き換えるべきかもしれませんが、
OCaml はそういう洒落た最適化はしない主義の言語です。実際 OCaml には CSE(Common Sub-expression Elimination)はありません。
(将来 `string` には入る可能性がありますけど))))

`nan` も例外ではありません。`nan` を自分自身とポインタ比較すると `true` を返します:

```ocaml
# nan == nan;;
- : bool = true
```

でももし何かの計算で別の NaN を作り出したばあいは…

```ocaml
# let zero_per_zero = 0.0 /. 0.0;;
val zero_per_zero : float = nan
# zero_per_zero == nan;;
- : bool = false
```

元の `nan` とはメモリ領域が異ります。繰り返しになりますが、`zero_per_zero` が NaN なのかどうか確かめるには `(=)` は使えません:

```ocaml
# zero_per_zero = nan;;
- : bool = false
```

`compare` を使うか、`Pervasives` に定義されいている `classify_float` を使います:

```ocaml
# compare zero_per_zero nan;;
- : int = 0
# classify_float zero_per_zero;;
- : fpclass = FP_nan
```

# 最後に、大事なこと

ポインタ比較演算子 `(==)` と `(!=)` を構造比較である `(=)` とその否定 `(<>)` と間違わないようにしてください。

非boxed データ、例えば `int` では構造比較とポインタ比較の結果は同じです:

```ocaml
# 42 = 42;;
- : bool = true
# 42 <> 42;;
- : bool = false
# 42 == 42;;
- : bool = true
# 42 != 42;;
- : bool = false
```

OCaml を使い始めると、まずほとんどの人が行う比較が `int` の比較だと思います。そして他の言語に慣れた人だと
`(==)` や `(!=)` を使ってしう事がおおいのです。これは `int` では正しいのですが、やめましょう！！

`float` での比較でも見たように、boxed データでは構造比較とポインタ比較とは動作が全く異なります。
Unboxed データでポインタ比較 `(==)` や `(!=)` を使ってしまっていると、boxed データで本当は構造比較
したいにもかかわらず間違ってポインタ比較を使ってしまうことが多いのです。これはコンパイラが「おかしいよ？」と
指摘してくれませんから、なかなか見つけるのがやっかいなバグになりえます。

これを避けるための、私や Jane Street のお勧めは、次の定義。`(==)` や `(!=)` を間違って使わないように
封印してしまいます:

```
let phys_equal = (==)
let (==) _ _ = `Consider_using_phys_equal
let (!=) _ _ = `Consider_using_phys_equal
```
