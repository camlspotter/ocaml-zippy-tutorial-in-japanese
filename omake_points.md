# OMake はまりポイント

## スコープ

OMake ではインデントが深くなる毎にローカルスコープができる。

## 名前空間

恐しいことに名前空間が 3 つある: private, this と global。

### global

普通の変数。public とも言う。大体これを使っておけばよいと思う。

初期化していないものはダメ
```
eprintln($(X))   # unbound variable: global.X
```

```
X=1
eprintln($(X))   # 1
X=2
eprintln($(X))   # 2
```

グローバル変数なのに、ローカルスコープでの変更は `export` しないと外に伝わらない
```
X=1
section  # ローカルスコープ
  X=2
  eprintln($(X))  # 2
eprintln($(X))    # 1 !!!
```

```
X=1
section  # ローカルスコープ
  X=2
  eprintln($(X))  # 2
  export          # X の変更が外に反映される
eprintln($(X))    # 2 !!!
```

```
section
  X=2
  eprintln($(X))  # 2
eprintln($(X))    # unbound variable: global.X
```


```
section
  X=2
  eprintln($(X))  # 2
  export
eprintln($(X))    # 2
```

### ルールの export を忘れる

ローカルスコープで宣言したルールも外で有効にしたい場合は(普通したいのだが) `export` としなければいけない。

```
MyOCamlTop(name, files) =
  .DEFAULT: $(OCamlTop $(name), $(files))
  export
```
これは `MyOCamlTop(name, files)` と唱え `omake` すると自動的にカスタムトップレベルを生成する
というルールを作る、が `export` を忘れると効果がなくなる。

# ルール

ルール中で変数を変更しても次行に伝わらない!!

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

これはどういうことか、良く判らないのだが、ルールのボディに書くのはコマンド列であって
式列ではない、ということらしい。

ルール中で変数を変更したい場合は、`section` を使って式列を書く:

```
FP=2
hello.c:
    section
        FP=1
        eprintln($(FP))         # 1 !!!
        echo "hello" > hello.c
```
