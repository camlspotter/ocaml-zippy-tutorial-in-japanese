# return する関数は内部で作った dependency を export できない

```
MyOCamlPPX(name, files) =
  WithOCamlVeryClean()
  MyOCamlGenericProgram($(name), $(files))
  export
  TARGETS[]=$(name).opt $(name).run $(name)$(EXE)
  return $(TARGETS)
```

`MyOCamlGenericProgram(..)` は新しい依存性を付け加えるのだけど `export`
しているのに外に反映されない。 `return` があると駄目らしい。

`value` を使って関数型ぽく書くとよい。

```
MyOCamlPPX(name, files) =
  WithOCamlVeryClean()
  MyOCamlGenericProgram($(name), $(files))
  export
  TARGETS[]=$(name).opt $(name).run $(name)$(EXE)
  value $(TARGETS)
```

しかしこの関数を他の関数内部で呼ぶと export の効果が無くなる。困る。
例えば、次のコードでは `MyOCamlPPX` が作った依存が使われず失われてしまう:

```
MyOCamlFindPackage(ppx_format, $(MyOCamlPPX ppx_format, $(FILES)))
```

別々に書かなければならない。

```
targets=$(MyOCamlPPX ppx_format, $(FILES))
MyOCamlFindPackage(ppx_format, $(targets) $(MyOCamlPackageExtras))
```

こういうのは本当に困る。

# Dependency が足りないように見える

OCaml で `make inconsistent assumptions over implementation Xxx` が出た時。
ターゲットを `omake --show-dependency ターゲット` でビルドしてみて確認するとよい。
足りていないのを確認できる。



