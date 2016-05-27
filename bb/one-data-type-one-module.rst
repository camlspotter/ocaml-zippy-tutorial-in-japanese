========================================
[OCaml] 1モジュール1データ型主義
========================================

OCaml の「1モジュール1データ型スタイル」。このプログラミングスタイルは21世紀に入ってからモジュールを多用する OCaml コミュニティで流行りだしたもので私も採用しています。源流は SML 方面にあると聞きましたが…私自信は確認していません。要出典です。

「1モジュール1データ型スタイル」の意味するところは簡単です:

* データ型一つ一つにモジュールを一つ一つ作る。
* モジュール名は型の意味する名前をつける。人なら Person。
* モジュール内で定義するデータ型は常に t という抽象的な名前にする。
* t を主対象とする操作はモジュール内で定義する。

ただし、全ての OCaml プログラムはこのように書かれるべし、というものでもありません。
例えば、 OCaml のコンパイラのソースコードはこのスタイルでは全く書かれていません。

「1モジュール1データ型スタイル」の利点は:

* モジュール名に型名が既に入っているので関数名に型名を書かなくて済む
* 様々なデータ型で似たような機能の関数、コンストラクタ名、レコードフィールド名に対し名前付けを統一化できる: Process.to_string, Person.to_string, Process.kill, Person.kill など
* module system を使った名前空間操作が可能になる module P = Person, open Person など
* モジュールが自然と Functor に適用しやすい形になる


例: 社員と製品に見る「1モジュール1データ型スタイル」
========================================================

暇なんで社員でも管理してみましょう::

    type employee = { 
      employee_name : string; 
      age         : int; 
      salary      : int;
      employee_id   : int 
    }

    let employee_to_string t = Printf.sprintf "name=%s age=%d salary=%d id=%d" t.employee_name t.age t.salary t.employee_id

    let john = { employee_name = "John"; age = 42; salary = 5000; employee_id = 5963 }

普通にはこんな感じになります。name, id ではなく employee_name, employee_id になっているのは他の id を持つ製品レコードと名前が被るからですね::

    type product = { 
      product_name : string; 
      price        : int;
      product_id   : int 
    }

    let product_to_string t = Printf.sprintf "name=%s price=%d id=%d" t.product_name t.price t.product_id

    let cheese = { product_name = "cheese"; price = 10; product_id = 4989 }

さて、ここで問題は

* 一々 employee employee, product product 書くの面倒くさい
* 統一感がない。salary も employee_salary、 price も product_price にすべき

確かに、これでは r.employee_name, r.product_id, employee_to_string, product_to_string と書くことになります。OCaml のレコードは単相ですし、値は overloading が無いので名前を被せることができないのですね。 

このコード、「1モジュール1データ型スタイル」で書きかえると次のようになります。::

    module Employee = struct

      type t = { 
        name   : string; 
        age    : int; 
        salary : int;
        id     : int 
      }
  
      let to_string t = Printf.sprintf "name=%s age=%d salary=%d id=%d" t.name t.age t.salary t.id
      let john = { name = "John"; age = 42; salary = 5000; id = 5963 }


    end

    module Product = struct

      type t = { 
        name  : string; 
        price : int;
        id    : int 
      }
  
      let to_string t = Printf.sprintf "name=%s price=%d id=%d" t.name t.price t.id

      let cheese = { name = "cheese"; price = 10; id = 4989 }

    end

綺麗になりました。employee_name や product_id が name や id に。関数は employee_to_string と price_to_string が共に to_string に。これらのモジュールの外では r.Employee.name とか r.Product.id、Employee.to_string や Product.to_string と書いてそれぞれ呼び出すことになります。 

ん？それでは r.employee_name, r.product_id, employee_to_string, product_to_string と何も変わらんではないか。いやいや。このスタイルの利点は名前空間をモジュールでコントロールしてプログラムを短く書けることにあります。 

* open で名前空間を開き、モジュール名記述を省略する。ローカルコンテクストでのみ開くこともできる
* module alias (別名) でモジュールの短縮名を定義し、open しないまでもキーストロークを減らすことができる

まず open: open Employee すれば Employee. は必要なくなりますし、 open Product とすれば Product. と書くこともなくなります。素晴らしい::

    open Employee  (* 以降、 r.name, r.id, to_string は Employee.t の操作の事になる *)  
    
いや待て、そもそも employee と product は同じモジュールで定義されている、つまり混ぜて使う事を想定されている。open Employee か open Product は同時には使えないではないか。うむ、たしかに。open を二つ並べると、後の open の名前の方が優先されます。前の open の効力は無くなる。しかしそういう場合は local open を使えばよい。名前空間の操作がローカルに調整できます。::

    let fire e = 
      let open Employee in (* fire 関数中のみ、Employee を書かなくてよくなる *)
      ...
    ;;

いやそれでももしある関数が Employee.t も Product.t も同時に使う場合は？確かにこの場合は難しい。両方 open すると混乱しますからお勧めしません。どちらかを開けてもうひとつはモジュール名を書くか…または、module alias を使って少しでもタイプ数を減らすこともできます。::

    module E = Employee
    module P = Product

    let add_sales_record employee prods =
      ... employee.E.id ... 
      ... List.fold_left (fun st p -> p.P.price + st) 
      ...

Module alias もローカルに宣言できます::

    let add_sales_record employee prods =
      let module E = Employee in
      let module P = Product in
      ... employee.E.id ... 
      ... List.fold_left (fun st p -> p.P.price + st) 
      ...

他の方法はありますか？
========================================================

OCaml には overloading も無いし、レコードは単相だから、どうしても名前が被る場合は明示的に区別してあげなきゃいけません。面倒ですか？まあオブジェクト使う方法もありますけど::

    class employee name age salary id = object
        method name   = name
        method age    = age
        method salary = salary
        method id     = id

        method to_string = Printf.sprintf "name=%s age=%d salary=%d id=%d" name age salary id
    end

    let john = new employee "John" 42 5000 5963

    class product name price id = object
        method name  = name
        method price = price
        method id    = id

        method to_string t = Printf.sprintf "name=%s price=%d id=%d" name price id
    end

    let cheese = new product "cheese" 10 4989

こう書けば x#id は x が employee でも product でも使えます。それどころか id というメソッドがあるオブジェクトに対し全て使えます。Structural subtyping 素晴らしいですね。では、このオブジェクトによる名前の被せ方、お勧めかというとあまりお勧めしません。まず既にタイプ数多すぎますよね…まあ、CamlP4 を使えば field の部分は減らせそうですが…型も複雑になります。上の様な簡単な例ならまだ良いのですが、複雑なことを行うとどこかで破綻する。これらの名前の問題を解決したいためだけに class を導入するのはどうかと思います。(どう破綻するのか…は、書くと長くなるので勘弁してください) この例では単相レコードを多相レコードであるオブジェクトに移す例でした。バリアントの場合は多相バリアントにすることで同じようにコンストラクタ名を被せることが可能です。この場合はクラスと異なり破綻しにくいですが、やはり structural subtyping で型が読みにくくなります。多相レコードとしてのオブジェクトや多相バリアントを導入するか、どうか。絶対にするなとは言いませんが、よくよく導入して得られる overloading の利点に対し、不利な点が上回らないか、検討することが肝要です。

Haskell なら？ Type-class ですか？確かに type-class 強力ですし、 to_string に関しては Show a を作るべきですけど、 Nameable a とか WithID a とかいうクラスこういう時わざわざ作りますか？普通は作らないですね。レコードフィールドやコンストラクタ名を被せる場合、あまり流行ってはいないですが、上で説明した方法と同様の効果を狙って import (qualified).. as .. 前提でモジュールを設計するのではないでしょうか。


t という名前で functor に突っ込みやすくなる
========================================================

「1モジュール1データ型スタイル」のもう一つのポイントは、型名を t にする、です。
型の意味するところは既にモジュール名に語らせていますから、型名は無味乾燥などんな名前で良いのです。
ではなぜどんな名前でもよくなく、t か。これは ML functor を使う上での慣習との相性です。

Set.Make や Hashtbl.Make に代表される ML functor は モジュールを受け取りモジュールを返す関数(のようなもの)。ML module system における強力なプログラム再利用装置です。

* 普段は { Employee.name = "John"; age = 42; salary = 0 } とか Person.to_string と書くが、もし他のモジュールとのバッティングがなければ open Person すれば Person と一々書く必要がなくなる。また、例えば kill_person にすべきか person_kill にすべきかという永遠の問ともおさらばすることができる。とにかくデータ名をモジュールに担当させ、その内部からはデータ名をことごとく省けばよろしい。
* 共通の同じ型名や関数名が種々のモジュールに使われることになり functor に放り込みやすくなる。例えば::

    module type Printable = sig 
      type t
      val to_string : t -> string
    end

    module F(A : Printable) = struct ... end

こんな感じに定義しておけば上記 Person や他の t と to_string : t -> string を持つモジュールは Printable インターフェースを持つことになり、functor F に放り込むことができる

このスタイルにも不利、というか難しい点はないわけでななく、データモジュール内にデータモジュールを入れ子で作ってしまった場合 t の名前がかぶるので別名を用意しなければならない、とか、再帰データに関するデータモジュールは一度再帰型を普通に定義してからデータモジュールを複数つくるか、それとも再帰モジュールで一気に作るか、とかあるのだが、試してみれば自ずとわかるのでまあやってみ。
