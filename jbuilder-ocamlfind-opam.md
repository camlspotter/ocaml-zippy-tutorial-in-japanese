# Dune(Jbuilder)がパッケージが無いと言っているパッケージ名とあなたがOPAMでインストールするべきパッケージ名は違う、かもしれない

Dune(Jbuilder)で必要なライブラリが足りないと、Duneは丁寧にそれを指摘してくれます。
たとえば:

```
$ jbuilder build
...
Error: Library "typerep" not found.
Hint: try: jbuilder external-lib-deps --missing @install
...
```

`typerep`パッケージがインストールされていないようです。
`jbuilder external-lib-deps --missing @install`コマンドで
足りないパッケージをリストアップしてみたら？と言われました。やってみましょう:

```
$ jbuilder external-lib-deps --missing @install
Error: The following libraries are missing in the default context:
- bigstring
- calendar
- cohttp-lwt-unix
- cstruct
- curl
- ezjsonm
- hex
- hidapi
- ipaddr.unix
- irmin
- js_of_ocaml
- lablgtk2 (optional)
- mtime.clock.os
- netstring
- nocrypto
- num
- ocplib-endian
- ocplib-endian.bigstring
- ocplib-ocamlres
- ppx_typerep_conv
- rresult
- scrypt-kdf
- sexplib
- tls
- typerep
- uint
- uri
- uutf
Hint: try: opam install bigstring calendar cohttp-lwt-unix cstruct curl ezjsonm hex hidapi ipaddr irmin js_of_ocaml mtime netstring nocrypto num ocplib-endian ocplib-ocamlres ppx_typerep_conv rresult scrypt-kdf sexplib tls typerep uint uri uutf
```

なんだかたくさん足りません。でも丁寧に、足りないパッケージは`opam install ...`コマンドを使ってインストールしてみたら？と言われました。やってみましょう:

```
$ opam install bigstring calendar cohttp-lwt-unix cstruct curl ezjsonm hex hidapi ipaddr irmin js_of_ocaml mtime netstring nocrypto num ocplib-endian ocplib-ocamlres ppx_typerep_conv rresult scrypt-kdf sexplib tls typerep uint uri uutf
[ERROR] No package named curl found.
[ERROR] No package named netstring found.
[ERROR] No package named ocplib-ocamlres found.
```

あれれ、OPAMに、`curl`, `netstring`, `ocplib-ocamlres`なんていうパッケージは知らないと言われました。

Duneがないと言っているのはOCamlFindのパッケージ名です。OPAMがないと言っているのはOPAMのパッケージ名です。この二つは、だいたいの場合は同じですが、**同じである必要はありません**。

ええっ、なんでそんな面倒な、と思われるかもしれませんが、OPAMの1パッケージが複数のOCamlFindパッケージをインストールする事も可能なので、そうなっています。OPAMに知らないと言われたOCamlFindパッケージ名からOPAMのパッケージ名を調べてみましょう:

まず、`ocplib-ocamlres`:
```
$ opam search ocplib-ocamlres
# Packages matching: match(*ocplib-ocamlres*)
# Name       # Installed # Synopsis
ocp-ocamlres --          Manipulation, injection and extraction of embedded reso
```
なるほど、`ocp-ocamlres`というのがあります。これらしい。なんで同じ名前にしてくれないのか...

`curl`はどうでしょうか:
```
$ opam search curl
# Packages matching: match(*curl*)
# Name          # Installed # Synopsis
conf-libcurl    --          Virtual package relying on a libcurl system installa
curly           --          The Dumbest Http Client
dsfo            --          Download (anyhow) and interact (ocaml, utop) with co
ocurl           --          Bindings to libcurl
opam-repository --          opam 2.0 development libraries
```
いくつか出てきました。正解は、`ocurl`です。慣れていないとわからないですよね。

`netstring`はもっとむずかしい:
```
$ opam search netstring
# Packages matching: match(*netstring*)
# Name # Installed # Synopsis
aws    --          AWS client for Amazon Web Services
```
いや、Amazonは関係ありませんね。この場合の正解は`ocamlnet`です。
`opam install netstring`でネット検索するとわかります。

このインストールしたいOCamlFindパッケージ名から、インストールすべきOPAMパッケージ名を引くのがたまに難しい問題はOPAM開発チームも理解しているので、OPAMパッケージディスクリプションにインストールされうるOCamlFindパッケージ名を書き加えるなど、将来改善されると思いますが、それまでは面倒ですがこんな感じでOPAMパッケージ名を推測する必要があります。

