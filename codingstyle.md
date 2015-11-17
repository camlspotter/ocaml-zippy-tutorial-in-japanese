コーディングスタイル
==============================

Record のラベルは差し支えなければ型名と同じにする
===========================================================

場合によるが、ラベル名と型名が同じだと書きやすく覚えやすい。例えば下のコード::

   (* Like "soumu1234" *)
   type employee_id = {
     prefix : string;
     number : int;
   }

   type employee = {
     name   : string;
     salary : int;
     id     : employee_id;
   }

は、次のほうが読みやすい::

   (* Like "soumu1234" *)
   type id = {
     prefix : string;
     number : int;
   }

   type employee = {
     name   : string;
     salary : int;
     id	    : id;
   }

employee_id を id に変えた。逆に、ラベルを employee_id に変えるのは::

   (* Like "soumu1234" *)
   type employee_id = {
     prefix : string;
     number : int;
   }

   type employee = {
     name       : string;
     salary     : int;
     employee_id : employee_id;
   }

…これは、長すぎて良くない。 id というラベルや型名が、
他のデータ型でも使われていてあまりに一般的だというのなら
モジュールを使って名前空間を独立させれば良い(1モジュール1型主義)::

   module Employee = struct

     (* Like "soumu1234" *)
     type id = {
       prefix : string;
       number : int;
     }
  
     type t = {
       name   : string;
       salary : int;
       id     : id;
     }

   end

``bool`` とか抽象的すぎる時は使わない
==========================================================

例えば、関数が bool を返す。でそれが関数操作の成功か失敗かを表しているらしい。
どっちだ？知るかよ！！ true は成功を意味するのか、それともエラー存在を意味するのか
書いているお前にしかわからないし、書いたお前もすぐに忘れる。なんで::

    type result = Success | Failure

にしないのか。

極論するとわけわかんない抽象的な値を返される位なら元から返り値は unit 
にしてエラーは exception で上げてもらうほうがよほどマシかも知れぬ。

わざわざ ``result`` 型を定義するのが面倒なら OCaml には polymorphic variant
があるから ```Success`` や ```Failure`` を返せば良い。 ```Success``
```Failure`` が長いんなら ```Ok`` と ```NG`` でエエやろちょっとは頭使って
他人にやさしいコード書けやヴォケ。

右か左かを表すのに ``bool`` とか使う奴は死ねってことだ。わかるな？
