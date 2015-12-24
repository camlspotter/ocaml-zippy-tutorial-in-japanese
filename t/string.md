文字、文字列
===============================================

文字のコード表記 `\nnn` は 10進
==================================================

文字、および文字列中で文字をその文字コードで指定する場合は `\nnn` を
使います。この `nnn` はその文字コードの三桁の十進数。ですから
`\000` から `\255` までです。

決して8進数 (`\000` から `\377`) ではないので注意してください。

文字列は `'\0'` では止まらない
==================================================

上にもあるとおり、 NULL文字は `'\0'` ではなく `'\000'` と書きます。
これは OCaml では文字列の終端を意味しません。

```ocaml
# print_string "hello\000world";;
```

``` output
hello^@world- : unit = ()
```

このように、`hello` だけでなく `\000world` も端末に出力されます。
C 言語の NULL ストップに慣れている人は注意が必要です。

OCaml での文字列の長さとは常にアロケートされた長さ。
この長さは値の内部表現ヘッダに書いてあるのでなので *O(1)* で取っ来ることができます。C 言語の `strlen` のように `'\0'` を探して旅に出ることはありません。

標準ライブラリの `input` や `Unix` の `read` 関数など既に確保された
バッファ領域に入力を書き込む関数は、関数の戻り値の示す長さの文字列を
バッファに書き込みますが、書き込むだけで終端処理はされません。
実際に読み込まれたデータ長がバッファの長さより短い場合にはその後ろに
ゴミが残ることになります。

```ocaml
# let s = String.create 10 in input stdin s 0 10; s;;
hello
```

```output
- : string = "hello\n\000\000\000\000"     <-- 入力された改行を含む6文字以降は元のまま
```