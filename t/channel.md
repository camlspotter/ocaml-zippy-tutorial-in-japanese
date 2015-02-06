Channel に関して
===============================

Channel から `Unix.file_descr` を得る際の注意
-------------------------------------------

`Unix.descr_of_{in,out}_channel` を使うと `{in,out}_channel` から Unix の fd を
得ることができる、ここから `Unix` の関数が使える。が、いくつか注意が必要:

* `{in,out}_channel` が GC されると fd は自動的に閉じられる。channel から fd を取得したら fd の作業が終るまで channel の liveness に注意すること。

`close` する時の注意: `close_{in,out}` か `Unix.close` のどちらかで閉める。両方はいけない。

* `close_{in,out}` で閉じてもよいが、 fd をその後 `Unix.close` してはいけない。Double close で失敗するか、別の所で作った fd を間違って閉じてしまう恐れがある。 fd は内部では整数なので GC とかは気にしなくてもよい。
* `Unix.close` で閉じてもよいが、元の channel をその後 `close_{in,out}` してはいけない。Double close で失敗するか、別の所で作った fd を間違って閉じてしまう恐れがある。 channel は放っておけば中身は GC が回収する。
* close に忘れた場合は channel の GC 時に自動的に close されるが、この方法にはあまり頼るべきではない。



