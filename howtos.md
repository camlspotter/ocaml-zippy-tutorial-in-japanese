
カスタム printf の作り方
===================================

Printf 系関数におけるフォーマット文字列の型付けは特殊で、
そのため普通にフォーマット文字列を受け取り内部でそれを使って
``printf`` を呼び出すような関数は一見不可能のように見える::

    (* 引数列が何個か fmt で決まるので書けないよー *)
    let failwithf fmt 引数列 = failwith (Printf.sprintf fmt 引数列)

C のように ... が使えて、かつ varargs とか面倒なことなしに、次のように書ければいいのに、それも無理::

    let failwithf fmt ... = failwith (Printf.sprintf fmt ...)

しかし！ OCaml は関数型言語だった! このような場合、継続スタイルの ``k*printf`` 関数をつかうとよい。 
``k`` は Keizoku の K。嘘です。 Kontinuation の K::

    let failwithf fmt = Printf.ksprintf failwith fmt

``fmt`` の引数による η-expansion は多相性のため、必須。

単に ``string -> t`` な関数に Printf 的なインターフェースをその場その場で持たせるのは
もっと簡単::

    ksprintf f "hello %d" 42

これだけ。よく使うので ``sprintf`` と ``ksprintf`` は、
私はいつもモジュール名 ``Printf`` 無しで使えるようにしている。
k は継続の k なんだけど、そんな事考えずに ``string -> t`` の関数を
よろしく ``format -> ... -> t`` に拡張してくれる高階関数と覚えておくのが良い。






η expansion を簡単に書く
===============================================

η expansion がわからない人はそれが何か、それが何の役に立つか勉強してください。
Value polymorphsim とか eta expansion で検索な。

次のようなコードがあったとして::

    let f = very very long code so long and lots_of lines

Value polymorphism restriction で十分に多相性が出ない場合、η expansion します::

    let f x = very very long code so long and lots_of lines x

でもこれ面倒臭い。仮引数と実引数の距離が離れているととても面倒臭い。
これをより簡単にする方法::

    let f x = x |> very very long code so long and lots_of lines

``(|>)`` は::

    external (|>) : 'a -> ('a -> 'b) -> 'b = "%revapply"

で定義。

ただ、これにも限界があって::

    let f = a >>= b

のような ``|>`` と強さが同じもしくは弱い演算子が存在すると、::

    let f x = x |> a >>= b

は::

    let f x = (x |> a) >>= b

のようにパースされ、上手くいかない。そこで、::

    let f x = (|>) x & a >>= b

って手もある。 ``&`` は ``%apply`` である。(Haskell や F# のように記号を使いたい)を参照。

ちゃんとやりたければ CamlP4 を使って::

    let f = eta .....

が ``let f = fun x -> x |> (.....)`` に展開されるようなマクロを書けば良い。
どうやって書くか？そりゃあんたに任せる。

