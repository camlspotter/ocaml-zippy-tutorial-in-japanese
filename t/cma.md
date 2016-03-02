# OCaml のリンクと名前空間と .cma ファイルの話



## よく起る問題

`a.ml` というファイル、つまり、`A` というモジュールを作成し、プログラムを
組んでいた。さて、実行ファイルをリンクしようとしたら、

```
Error: Files b.cmo and a.cmo
       make inconsistent assumptions over interface A
```

というエラーが出た。意味がわからない。



## 可能性1: 依存関係ミス

`B` が `A` を使っており、依存関係があるのにも拘わらず、これがビルドシステムに
把握されておらず、`A` の変更されたのに `B` がリコンパイルされていないというケース
がまず考えられる。

これが起っているかどうかを確認する方法としては、まず完全に `make clean` してから
`make b.cmo` などとして `b.cmo` をビルドしてみるとよい。もし `a.cmo` への依存性が
ビルドシステムに把握されていなければ `a.cmo` 無しに `b.cmo` をコンパイルしようとして
ビルドは失敗するはずだ。

これはビルドシステムに依存関係を正しく把握すればよい話で、方法はシステムによって変る。
本稿ではこれは扱わない。



## 可能性2: 二つ以上の同名モジュールが存在する場合

もう一つの可能性、それは `A` という名の異るモジュールが二つ存在し、それが共にリンクされている場合だ。
おお確かにそれは何か都合の悪い事が起きそうですね。しかし問題無い場合もあるんだ。

これはとにかく、 OCaml でモジュールはどうリンクされるのかを理解する。そうすれば全て判る。
そしてどうリンクされるのかってのはそんなに難しくないんだ。


### 複数モジュールのリンク: 並べた順でソースを繋げたのと同じ

OCaml では、複数のモジュールをリンクすると、並べた順番と同じ順番で
各モジュールのソースコードを連結したのと同等のプログラムを生成する。（ほとんど）

例として、 `x/a.ml` と `x/b.ml` は次のようになっているとする:

```
(* x/a.ml *)
let x = 1
```

```
(* x/b.ml *)
let () = print_int A.x
```

これらのモジュールを分割コンパイルしてからリンクして、実行ファイルを作る:

```shell
$ ocamlc -c -I x x/a.ml
$ ocamlc -c -I x x/b.ml
$ ocamlc -o a.out x/a.cmo x/b.cmo   # リンク
```

このコマンドは、次のような一つの OCaml モジュールと(大体)同等なプログラム `a.out` を生成する:

```ocaml
module A = struct
  let x = 1
end

module B = struct
  let () = print_int A.x
end
```

もしリンク順を逆にするとリンクに失敗する:

```shell
$ ocamlc -o a.out x/b.cmo x/a.cmo
File "_none_", line 1:
Error: Error while linking x/b.cmo:
Reference to undefined global `A'
```

これは、このコマンドが生成しようとする(そして、失敗する)プログラムが、次のものと等価だと
考えると理解できる:


```ocaml
module B = struct
  let () = print_int A.x
end

module A = struct
  let x = 1
end
```

`B` の中で `A.x` を使っているのにその前に `A` の定義が無い。
だから OCaml プログラムとしておかしい。同じ理由で、この順序が間違ったリンクも失敗する。


### 複数の同名モジュールはリンクできない

さて、上の `x/a.ml`, `x/b.ml` に加えて、次の `y/a.ml`, `y/b.ml` という
コードがあったとする:  


```
(* y/a.ml *)
let x = "hello"
```

```
(* y/b.ml *)
let () = print_string A.x
```


この `y` 以下のモジュール `A`, `B` と先程の `x` 以下の `A`, `B`。
これらを混ぜてプログラムをリンクできるだろうか。これは出来無い。

いやちょっと待って。

* バイトコードならできる
* ネイティブだとできない

んですよ。困ったね。でも今日、バイトコードだけで済ます人ってそんないないよね。
だからまあ出来無いってことで。

#### ネイティブはできない

いやー、バイトコードでは出来るんだけど、ネイティブではできないんですよこれが。

```
$ ocamlopt -c x/a.ml
$ ocamlopt -I x -c x/b.ml
$ ocamlopt -I y -c y/a.ml
$ ocamlopt -I y -c y/b.ml
$ ocamlopt -o a.out x/a.cmx x/b.cmx y/a.cmx y/b.cmx
File "_none_", line 1:
Error: Files y/a.cmx and x/a.cmx both define a module named A
```

なんでだろう、俺もよく知らないんだけど、出来ないものはできない。


#### バイトコードならできる

ネイティブではできないがバイトコードだとできる。一応、抑えておく。

```
$ ocamlc -c -I x x/a.ml
$ ocamlc -c -I x x/b.ml
$ ocamlc -c -I y y/a.ml
$ ocamlc -c -I y y/b.ml
$ ocamlc -o a.out x/a.cmo x/b.cmo y/a.cmo y/b.cmo   # リンク
File "y/a.cmo", line 1:
Warning 31: files y/a.cmo and x/a.cmo both define a module named A
File "y/b.cmo", line 1:
Warning 31: files y/b.cmo and x/b.cmo both define a module named B
```

警告が出ているが、`a.out` が作成される。これを実行すると

```
$ ./a.out
1hello
```

とちゃんと動作する。これは、なぜか。生成されるプログラムは次の OCaml コードと(大体)同じである:

```ocaml
module A = struct
  let x = 1
end

module B = struct
  let () = print_int A.x
end

module A = struct
  let x = "hello"
end

module B = struct
  let () = print_string A.x
end
```

一つ目の `B` の中では `A` は一つ目の `A` を参照している。
二つ目の `A` の定義で一つ目の `A` はそれ以降の環境では隠されてしまう(*shadowing* と言う)。
そのため、二つ目の `B` の中では `A` は混乱なく、二つ目の `A` を参照することになる。

ただし、上の連結コードはスタンドアローンのソースコードとしてコンパイルできない:

```
$ ocamlc -c z.ml
File "z.ml", line 9, characters 7-8:
Error: Multiple definition of the module name A.
       Names must be unique in a given structure or signature.
```

これは同一ファイル内に同名モジュールがあるコードが書けるのは混乱の元だろうと、
言語デザインとして制限が入っているのが理由でテクニカルにはこれをコンパイル出来無い問題はない。
同名モジュールをリンクした際に `Warning 31: files y/b.cmo and x/b.cmo both define a module named B` が出るのもこの意図からなんやね。

さて、ここで `x` と `y` の `a.cmo` をリンクする時に入れ替えるとどうなるか。 `x/b.cmo` が `y/a.cmo` を使って、 `y/b.cmo` が `x/a.cmo` を使ってしまうとマズいですね？

```
$ ocamlc -o a.out y/a.cmo x/b.cmo x/a.cmo y/b.cmo   # 入れ替えてある
File "_none_", line 1:
Error: Files x/b.cmo and y/a.cmo
       make inconsistent assumptions over interface A
```

出たこれだ。この `make inconsistent assumptions` ての困るんだよね。
（これを出すためにわざわざバイトコードの例を書いているんだ)

これは、複数モジュールのリンクはソースをその順序で連結したプログラムを生成するんだけど、
なんでも並んべた通りにするわけじゃなくて、もう一つチェックがある。
分割コンパイルの時に依存していたモジュールと同じ signature を持つモジュールに
依存するようにしていないと、だめ。 `.cmo` ファイルにはコンパイル時に依存していた
他のモジュールと自分自身の signature のチェックサムが登録されていて、リンク時にこれをチェックしている。
例えば、

```
$ ocamlobjinfo x/a.cmo
File x/a.cmo
Unit name: A
Interfaces imported:
	0d015a5a2136659b0de431be7f1545be	Pervasives
	ba1be62eb45abd435c75cb59cc46b922	CamlinternalFormatBasics
	79aeac24d43e94b4877fd60e64675cab	A
Uses unsafe features: no
Force link: no

$ ocamlobjinfo x/b.cmo
File x/b.cmo
Unit name: B
Interfaces imported:
	0d015a5a2136659b0de431be7f1545be	Pervasives
	ba1be62eb45abd435c75cb59cc46b922	CamlinternalFormatBasics
	af37e0dbb9a008ad0dd930f3f8c13f9f	B
	79aeac24d43e94b4877fd60e64675cab	A
Uses unsafe features: no
Force link: no
```

だから `x/b.cmo` は `A` というモジュールに依存しているが、正しくリンクできるのだけど、
`A` が `79aeac24d43e94b4877fd60e64675cab` というチェックサムを持っている必要がある。
当然、 `y/a.cmo` のチェックサムは違うですよ:

```
$ ocamlobjinfo y/a.cmo
File y/a.cmo
Unit name: A
Interfaces imported:
	0d015a5a2136659b0de431be7f1545be	Pervasives
	ba1be62eb45abd435c75cb59cc46b922	CamlinternalFormatBasics
	e138e0b3dd67a66fa3b68cff3a4acf92	A       <---- ちがーう
Uses unsafe features: no
Force link: no
```


### `.cma` や `.cmxa` ファイルはまあ単に `.cma` とか `.cmxa` の塊





