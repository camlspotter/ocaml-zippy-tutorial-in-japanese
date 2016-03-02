モジュール、ライブラリのリンクについて
==============================================

オブジェクトファイルのリンク順
=================================================

OCaml のオブジェクトファイル(.cmo, .cmx)を並べる順番には意味がある。
順番を間違えると::

    Reference to undefined global Hogehoge

などと言われるので注意。 

a.ml::

    let x = 1

b.ml::

    let y = A.x 

c.ml::

    let z = B.y

というソースがあったとする。 a.ml, b.ml, c.ml の順に分割コンパイルする。これは問題ない::

    $ ocamlc -c a.ml
    $ ocamlc -c b.ml
    $ ocamlc -c c.ml

さて、これをリンクする場合、依存関係の順にリンクしなければいけない::

    $ ocamlc -o a.out a.cmo b.cmo c.cmo 　　　# a.out 実行ファイルへとリンク

これを間違えると Reference to undefined global Hogehoge というエラーが出る::

    $ ocamlc -o a.out b.cmo a.cmo c.cmo
    File "_none_", line 1:
    Error: Error while linking b.cmo:
    Reference to undefined global `A'

OCaml でのモジュール毎の分割コンパイルと、そのリンクは、モジュール群のソースが、
連結されて一つの巨大な OCaml プログラムソースになったものをコンパイルする
作業を分割したもの、と考えると判りやすい。 b.cmo, a.cmo, c.cmo の順番での
リンクは、 b.ml, a.ml, c.ml をこの順番でつなぎあわせたものをコンパイルするのと
同じで、b.ml の部分では a.ml のモジュール A は未定義。だからエラーになる::

    module B = struct
    
        let y = A.x 
    
    end

    module A = struct
    
        let x = 1

    end
    
    module C = struct

        let z = B.y

    end
    
この上記のプログラムがコンパイルエラーになるのと同じである。

これは cma ライブラリを作る際の落とし穴にもなる ocamlc -o lib.cma b.cmo a.cmo とした場合、 lib.cma はエラーもなく作成される。その後、この lib.cma を使って例えば c.cmo とリンクし、実行ファイルを作ろうとすると、そこで初めてエラーとしてレポートされる::

    $ ocamlc -a -o lib.cma b.cmo a.cmo       # lib.cma アーカイブ作成。エラー無し
    $ ocamlc -o a.out lib.cma c.cmo          # a.out 実行ファイルへとリンク(失敗する)
    File "_none_", line 1:
    Error: Error while linking lib.cma(B):
    Reference to undefined global `A'

上記の lib.cma は A というモジュールに依存した B モジュールと、それと独立した A モジュールを含むアーカイブになっている。大変に気持ち悪いがこのようなことができる::

     $ ocamlc -o a.out a.cmo lib.cma c.cmo

この実行ファイルには A というモジュールが二回リンクされている。lib.cma 内部の B が使う A は lib.cma 内の A ではなく、 lib.cma の前に並べた a.cmo になる。同名モジュールが二回出てくることは OCaml のソース上ではあまりにわけが分からないので禁止されているが、リンカ上では OCaml の普通の値が同名の変数に束縛された場合 shadowing されるように先出のモジュールは後出のものに shadowing される。気持ち悪いがそういう挙動である。

このような問題を避けるにはモジュールを依存順に並べてリンクすればよいのだが、Makefile などの場合は手でモジュールリストの順番を調整する必要がある。 OMake などではこの依存関係を自動解析してくれるのでほとんど気にする必要はない…ただしモジュール間に渡る副作用の依存関係が存在していない限りにおいて、である。

-linkall を付けないとリンクしたつもりのモジュールがスコーンと抜けてしまう事がある
===================================================================

``cma`` アーカイブ中のモジュールはリンク時に他から参照されていない場合、リンクされない。
参照されないモジュールもリンクしたい場合は ``-linkall`` を付ける事。

これが全てなのだが、なかなかに、難しい。

a.ml::

    let x = ref [1]

b.ml::

    let () = A.x := [1; 2]

こんなコードを考える。モジュール A に変更可能なデータがあって、後でそれを B から差し替える。
プラグイン的なコードを書く時には便利なやり方なのだけれど、これをライブラリとしてリンクする時には
注意しなければいけない::

    $ ocamlc -c a.ml
    $ ocamlc -c b.ml
    $ ocamlc -a -o lib.cma a.cmo b.cmo

さてこのライブラリ ``lib.cma`` に次のコード ``c.ml`` をリンクする::

    let () = Printf.printf "%d\n" (List.length !A.x)

リンクのコマンドは::

    $ ocamlc -o c.exe lib.cma c.ml

実行すると、 ``2`` ではなく、 ``1`` と出てくる。モジュール B は C から参照
されていないので実行ファイルにはリンクされない。なので ``A.x`` は更新されない。

``main`` が無く、副作用がある言語がこんなリンク方式を取ると、副作用を起こしたいだけの
B の様なモジュールがすっ飛ばされる事になり大変ヤバイのだが…そういう挙動なので仕方がない。

B もちゃんとリンクさせるためには ``-linkall`` を付けること::
     
    $ ocamlc -linkall -o c.exe lib.cma c.ml

もしくは、ライブラリ構築を行って、直接 ``cma`` ライブラリを作るのではなく、
その前にパッケージモジュールを作るというのが今様である::

    $ ocamlc -for-pack Lib a.ml
    $ ocamlc -for-pack Lib b.ml
    $ ocamlc -pack -o lib.cmo a.cmo b.cmo
    $ ocamlc -a -o lib.cma lib.cmo

こうするとモジュール B は Lib.B として埋め込まれる。パッケージモジュール Lib に
一回でも触るコードとリンクされると、 Lib.B は捨てられない::

    let () = Printf.printf "%d\n" (List.length !Lib.A.x)

``Lib.A.x`` という形で ``Lib`` に触っているので、 ``Lib`` 下のモジュールは
全て実行ファイルにリンクされることになる。
