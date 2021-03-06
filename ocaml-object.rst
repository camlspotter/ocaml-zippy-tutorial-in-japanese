# この文章について

全部書いていません

================================
OCaml の object について
================================

私は OCaml の オブジェクトシステムそして普通世間一般の オブジェクトシステムについて理解が足りないと
自覚しているので正直こういう文章を書く自信全く無いのですが…

OCaml のオブジェクトは構造的サブタイピング
==============================================

OCaml の オブジェクト のサブタイピングは structural subtyping というものです。
世間一般の nominal なサブタイピングとは常識が異なるので、まずそこから難しいく映るかもしれません。

Nominal なサブタイピングの世界
----------------------------------------------

Nominal な世界ではオブジェクトはクラスに属します。まあ大雑把に言うと オブジェクトの型はクラス名。
そしてオブジェクトの型(クラス名)はその *名前* で区別(identify)されます。だから nominal と言う。

クラスはオブジェクトの実装を与えると同時にその型を定義します。

クラスは他のクラスを継承でき、サブクラスになります。

オブジェクトのサブタイピングは、それが属するクラスの継承関係がそのまま使われます。
クラスの identification は名前で行われますから、オブジェクトのサブタイピングもクラス名で決まります。

OCaml の Structural なサブタイピングの世界
----------------------------------------------

OCaml の Structural な世界ではオブジェクトはクラスに属しません! 
オブジェクトの型はクラス名ではありません! 
まあ大雑把に言うとオブジェクトの型はそのオブジェクトが持っているメソッドの型の集合です。
そしてオブジェクトの型(メソッドの型集合)はその集合の *構造* で区別されます。だから structural と言う。

クラスはオブジェクトの実装を与えますが、その型を定義するものではありません! 
オブジェクトの型の別名を与えるだけです。オブジェクトの型はあくまでもそのメソッド型集合の構造です。

クラスは他のクラスを継承でき、サブクラスになります。

オブジェクトのサブタイピングはその *構造によってのみ* 決まります。
サブタイピングはオブジェクトを生成するのに使用したクラスの継承関係とは *関係ありません。*


クラス抜きで考える OCaml のオブジェクト
===============================================================

オブジェクト、いやさ、多相レコード
------------------------------------

OCaml のオブジェクトのサブタイピングは nominal つまり属クラス名主義的なものではなく、
structural つまり、その型の構造で決まる、と言う事を繰り返し強調しました。
実際 OCaml のオブジェクトのサブタイピングはそのクラスシステムとは独立したものです。
それはクラスの無いオブジェクト (immediate object) を定義できることからもわかります。::

    object 
      method m = 1 
      method n x = x + 1
    end  
    (* 型は < m : int;   n : int -> int > *)

実際のところクラス抜きのオブジェクトは多相レコードにほかなりません。
多相レコードとは、事前の型宣言のいらない型付きレコードのことです。

多相レコードの多相性の例を見ましょう::

    let get_m o = o#m
    (* 型は get_m : < m : 'a; .. > -> 'a *)

この関数は ``o`` というオブジェクト、いやさ、多相レコードを引数に取りそのメソッド、いやさ、
フィールド ``m`` を取ってきて返す関数です。 ``get_m`` の型の引数部分を見てください。
``< m : 'a; .. >`` という形になっている。これは何でもいいから ``m`` というフィールドを
持つ多相レコード、を意味する型です。実際、::

    # get_m (object method m = "hello" end);;
    - : string = "hello"
    # get_m (object method m = 1  method n x = x + 1 end);;
    - : int = 1

こんな風に ``get_m`` は ``m`` の型が違ってたり、 ``m`` 以外のフィールドが
存在する多相レコードであっても取り扱うことができます。

``get_m`` の引数の型  ``< m : 'a; .. >`` には二つの多相性があります:

* m の型は何でも良い事を示す型変数 ``'a``
* m 以外のフィールドが存在してもよいという事を示す ``..``

実際 ``..`` は型変数のような挙動を示すのですが、ここに深入りすると帰ってこれなくなるので
これくらいにしましょう。

上の例では ``get_m`` が適用されている二つの多相レコードの型は
``< m : string >`` と ``< m : int;  n : int -> int >`` ですが、
これを ``< m : 'a; .. >`` の二つの多相性によって上手く扱っているわけです。

あー、なるほど、これが OCaml の構造的サブタイピングな？と思われますか？

*違います。* 

これは多相レコードの多相型によるもので、サブタイプではないのです。
例えば、 ``< m : 'a; .. >``  の型変数である
``'a`` が ``int`` に具体化(instantiate)され、 ``..`` が ``n : int -> int`` に
具体化されたものが ``< m : int;  n : int -> int >`` になります。 
ちょっと ``..`` の部分が構造に関する多相性で特殊ですが、
これは単に ML の　parametric polymorphism の延長に過ぎません。

まあ上では違いますと言い切りましたが、この ``..`` の多相性は
OCaml のオブジェクトにおける"サブタイプ感"を醸しだすのに重要な要素であることは確かです。

えっじゃあサブタイピングはどこに？
------------------------------------

OCaml におけるオブジェクトのサブタイピングとは上の多相レコードにおける 
parametric polymorphism では抑えられない型の大小を取り扱います。
例えば、::

    object method m = 1 end                         (* < m : int > *)
    object method m = 2  method n x = x + 1 end     (* < m : int;  n : int -> int > *)


手稿で判読可能な部分はここで途切れている…この先は草稿らしい

この二つのオブジェクト、そして、それは型推論されません。常に手で書く必要があります。



クラスの継承関係はオブジェクトのサブタイピングに引き継がれますが、
それはクラス継承関係が宣言されたからというより、サブクラスから生成される オブジェクトの型構造が
親クラスから生成されるオブジェクトの型構造を必ず含む、ような継承しか許されないからです。
