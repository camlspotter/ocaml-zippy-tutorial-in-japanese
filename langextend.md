OCaml を拡張する
=============================

特殊なリテラルを作りたい
=================================

CamlP4 で quotation 使う。 ``<:hoge<自由に書ける>>`` 。
CamlP4 でのレクサ拡張は他の文法拡張と重ねることができないので、うまくいかない。
Quotation は ``<:x<>>`` と最低でも 6 文字必要なので悲しい。
