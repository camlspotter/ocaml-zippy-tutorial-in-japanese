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

# 引数なしの `export`

引数なしの `export` が外に export する変数やルールをちゃんと理解する事が重要

* 全ての動的スコープの変数の値
* カレントディレクトリ
* Unix環境変数
* 現在の implicit rule や implicit dependencies
* 現在の "phony" ターゲット宣言

特に関数引数の名前が外に漏れ出るのが非常に困る。これが理由で `omake` 使えないと言われても仕方がない:

```
export1(foo) =
  eprintln(foo=$(foo)) # foo=a
  export # argument is exported to the outside!!!

export1(a)
eprintln(foo=$(foo)) # foo=a !!!
```

# 引数ありの `export`

引数がある `export` はその引数を評価後、その引数によって

* 値が空なら引数無し `export` と同じ
* `$(export 変数..)` で作られた環境の場合、その環境
* `.RULE`: implicit rules and implicit dependencies.
* `.PHONY`: the set of “phony” target declarations.
* その他の文字列は変数名として扱いその変数を export する
