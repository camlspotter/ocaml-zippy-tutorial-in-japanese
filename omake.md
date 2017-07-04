# OMake に関するメモ

# もっとも大事なこと

## Dynamic scoping

```
X=1
GETX() =
  return $(X)
X=2
eprintln($(GETX)) # 2
```

## 代入がない

```
X=1
F() =
  eprintln($(X)) # 1
  X=2  # Xに1を代入するわけではない
  eprintln($(X)) # 2
F()
eprintln($(X)) # 1
```

これは次のOCamlプログラムとだいたい同じ:
```
let x = 1 in (* let x = ref 1 ではない *)
let f () = 
  print_int x;
  let x = 2 in (* x := 2 ではない *)
  print_int x
in
f ();
print_int x
```

## でも関数から外の環境をいじりたい

変数代入もなくI/Oとdynamic scoping以外は純粋関数型っぽいが、
ビルドルールを書いているとスコープの外の変数の値を変化させたい事が多い。
`export`を使うとこれができる

```
X=1
SETX()=
  export X # X の値を上のスコープに伝える
  X=2
SETX()
eprintln($(X)) # 2
```

OCamlでは「だいたい」こうなる:
```
let x = 1
let setx () =
  let x = 2 in
  x
in
let x = setx () in 
print_int x
```
「だいたい」というのは`SETX`自体が関数なので関数の返り値と`export`で出す値の
両方があるともうちょっと違った翻訳になるから。

`export`も外側のスコープにある変数への代入ではなく、外側のスコープでの変数定義なので、
存在していない変数束縛でも作ることができる:

```
MAKEY()=
  export Y
  Y = 3
MAKEY()
eprintln($(Y)) # 3
```

# ルールと関数は違う!そして`section`について

いや、当たり前ですけど。たまにルール内で関数みたいなコードを書いておかしいなあとなるので。

```
hello.c:
    FP=1
    eprintln($(FP))         # unbound variable: global.FP
    echo "hello" > hello.c
```

```
FP=2
hello.c:
    FP=1
    eprintln($(FP))         # 2 !!!
    echo "hello" > hello.c
```

ルールのボディはコマンド列であって式列ではないのですね。
ルール中で変数を変更したい場合は、`section` を使って式列を書きましょう:

```
FP=2
hello.c:
    section
        FP=1
        eprintln($(FP))         # 1 !!!
        echo "hello" > hello.c
```

## 関数の呼び出し


# 次に大事なこと

## `export` いろいろ

Reference manual の "Exporting the environment" はよく読む必要がある。まず読んだ上で。

### 引数なし `export` は気をつける

引数なし `export` は割といろんなものを勝手に外に出してくれるので便利そうだが、
実は予期しないものも出してしまうので使わないほうが良いと思う:

```
f(a,b) = 
  x = $(add $(a), $(b))
  export
```
例えば、上の関数は`x`に`a`と`b`の和をセットするつもりだが、`a`と`b`も外側に出してしまう。
`if`の中とかの無引数`export`は問題ないが、関数bodyのトップでの`export`は、
一時変数まで外に出してしまうので、してはいけないと思われる。
一時変数にすべて`private`変数を使えば大丈夫だが、いちいち`private`書くの面倒くさい。

### 引数なし `export` を封印するにはどうしたらよいですか

Reference manual の "Exporting the environment" をよく読んで。

* `export .RULE` で implicit rule と implicit dependencies を外に出せます
* `export .PHONY` で phony target を外に出せます

Rule, dependency や phony target の`export`も変数の`export`と同じで、上のスコープにある
同名のものをshadowするはず。

### 前置 `export` のほうがよさげ

`if`でスコープを作るのでいちいち`export`しなければならない、面倒なと思う人は:

```
updateX(b)=
  if $(b)
    X=2
    export
  else
    X=3
    export
  export X
updateX(true)
eprintln($(X)) # 2
```

`export` を前置すると捗ります:

```
updateX(b)=
  export X
  if $(b)
    X=2
  else
    X=3
updateX(true)
eprintln($(X)) # 2
```

## `return` を使うと `export` が無効になる

`return`は関数内から外に一気に脱出して値を返しますが、その際、内部での`export`宣言は無視されます。

```
X=1
F(y)=
  export X
  X=2
  return $(y)
Z=$(F 1)
eprintln(Z=$(Z) X=$(X)) # Z=1 X=1 !!!
```

`return`がどうしても必要なければ `value`がおすすめ

```
X=1
F(y)=
  export X
  X=2
  value $(y)
Z=$(F 1)
eprintln(Z=$(Z) X=$(X)) # Z=1 X=2 !!!
```



## Implicit rule

Implicit rule は `%.ext` みたいなワイルドカードを使ったルール。よくあるのは:

```
%.ext1: %.ext2
    ...
```

こんなのも書ける:
```
%a: %b
    cp $< $@
```

でもディレクトリ名を左辺には書けない
```
x/%a: %b  # rejected
    cp $< $@
```

右辺には書けます
```
%a: x/%b
    cp $< $@
```

## Dependency が足りないように見える

OCaml で `make inconsistent assumptions over implementation Xxx` が出た時。
ターゲットを `omake --show-dependency ターゲット` でビルドしてみて確認するとよい。
足りていないのを確認できる。


# 豆知識

## `CREATE_SUBDIRS`

Reference manual の "Temporary directories" に `CREATE_SUBDIRS` という秘密の変数について
さくっと書いてある。 `.SUBDIRS: <dirs>` で `dirs` が無い場合、 `CREATE_SUBDIRS=true` だと
勝手に掘ってくれるとある。ひどい。



