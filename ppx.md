ocamlc -ppx で遊ぶ
========================

こないだは OCaml 4.02.0 の新機能を概観したので今回はその内の一つ、
ppx を試してみるのだ。日本一の CamlP4 作家と自他共に認める私だが、
どーも CamlP4 は黒轢死となる予定が強まったので、次の動きを見極める
必要があるのだ

4.02.0
========================

ppx で遊ぶには OCaml 4.02.0 が必要なのであるが、 OPAM がある我々には
インストールの手間とかはほとんどない:

    $ opam switch -a | grep 4.02
    --     -- 4.02.0+trunk                latest 4.02 trunk snapshot

ほうほう成程、`4.02.0+trunk` いうのがあるのな:

    $ opam switch 4.02.0+trunk

で待っとれば入れてくれる。はー長生きはするものじゃて。

    $ eval `opam config env`

ほい用意できた。

どうパースされているか
========================

さて、今回は

    (* x.ml *)
    let x = {id|\(^o^)/|id}
    let () = prerr_endline x

というコードを弄ってみよう。これどないなってるんですか？

    $ ocamlc -dparsetree x.ml
    [
      structure_item (x.ml[1,0+0]..[1,0+23])
        Pstr_value Nonrec
        [
          <def>
            pattern (x.ml[1,0+4]..[1,0+5])
              Ppat_var "x" (x.ml[1,0+4]..[1,0+5])
            expression (x.ml[1,0+8]..[1,0+23])
              Pexp_constant Const_string ("\\(^o^)/",Some "id")
        ]
    ]
    ...

はーなるほど、 `Const_string` に `string option` が新しくついたんやね。ほいでちゃんと `\` は `'\\'` になっておる。素晴しい。 `-dparsetree` のプリンタはあいかわらず正しく括弧つけるのサボっておりあかんちんである。

ppx てどう動くのか
========================

じゃまあこの `Const_string ("\\(^o^)/",Some "id")` に手を加えてみたいわけであるが、その前に、 `-ppx` がどう動くのか、判っていないので調べる。

    $ ocamlc -ppx foobar x.ml
    sh: foobar: command not found
    File "x.ml", line 1:
    Error: Error while running external preprocessor
    Command line: foobar '' '/var/folders/5h/2_0729sx3kg863fqlm17mfn80000gn/T/camlppx2bcc71'

ということで、 `-ppx command` と書くと、 `command <infile> <outfile>` てな感じにプログラムが呼び出されて `command` は `<infile>` から `<outfile>` を生成すればよいようだ。

    #!/bin/sh
    # x.sh
    cp $1 $2
    cp $1 /tmp/copy.ml

というのを作って、 `ocamlc -ppx 'sh x.sh' x.ml` て起動すると、 `/tmp/copy.ml` に ppx で指定されるプログラムが受け取るコードを得ることができる。で、見てみた:

    $ cat /tmp/copy.ml 
    Caml1999M016バイナリー.....バイナリー

あーなんかバイナリなので、 `x.ml` をパースした結果を単に `output_value` で書き出しているようである。 `Caml1999` というのはまあ知ってる奴には OCaml コンパイラのソースの `utils/config.ml` にあるマジックキーワードの一つなので、まあそこを参照すると:

    let exec_magic_number = "Caml1999X008"
    ...
    and ast_impl_magic_number = "Caml1999M016"
    and ast_intf_magic_number = "Caml1999N015"
    ...

とあるので、ああ、単に `output_value` したんじゃなくて、その前に、`.ml` 由来か `.mli` 由来を示すヘッダを付けるわけだとわかる。これは `.ml` から来たから `ast_impl_magic_number` で、これを受け取ったプログラムはやはりこのヘッダを付けて別の AST を返せばいいんだろう。

続くバイナリ部分はさすがにコードを読まないとわからない。
コンパイラの `driver/pparse.ml` に該当コードがあり、

    Location.input_name := input_value ic;
    let ast = input_value ic in

とあるので、値が二つあって、一つめはソースファイルの名前、二つめは
どうやら `.ml` なら `Parsetree.structure`、 `.mli` なら `Parsetree.signature` 
の AST が入っている。え？ 4.02.0+trunk のソース？ `opam switch 4.02.0+trunk` している間に `~/.opam/4.02.0+trunk/build/ocaml` から回収せよ。コンパイル終ったら `ocaml` ディレクトリ消えてしまう素敵バグがあるからコピーしとけ。

初めての、何もしないフィルタ
==============================

ほいじゃ、簡単にフィルタを書いてみましょうか:

    (* filter.ml *)
    let infile = Sys.argv.(1)
    let outfile = Sys.argv.(2)
    
    let ic = open_in_bin infile
    let oc = open_out_bin outfile
    
    open Parsetree
    
    let filter f =
      let header = 
        let buf = "Caml1999M016" in
        let len = String.length buf in
        assert (input ic buf 0 len = len);
        buf
      in
      Location.input_name := input_value ic;
      let v = input_value ic in
      close_in ic;
    
      let v = f header v in
    
      output_string oc header;
      output_value oc Location.input_name;
      output_value oc v;
      close_out oc
      
    let () = 
      filter (fun _header v -> v)

適当に書いた。ただ読んで、ただ書くだけ。 `filter` に与える関数を変更すれば何かできる: 

    $ opam install ocamlfind
    $ ocamlfind ocamlc -package compiler-libs.common -linkpkg -o filter filter.ml

    $ ocamlc -ppx ./filter x.ml

で、`x.ml` はまずパースされ、その結果のバイナリ AST が `./filter` に渡され、その結果、今のところ、入力と同じだけど、それがまた OCaml コンパイラに差し戻されて、コンパイル終了となる。

何か文字をいじってみる
==============================

Parsetree を弄るなら Ast_mapper。あれ？ 4.01.0 では class 使っていたけれど、fixed point もらうデカいレコードに変っているね。まあいいや。

    let infile = Sys.argv.(1)
    let outfile = Sys.argv.(2)
    
    open Parsetree
    open Asttypes
    open Ast_mapper
    
    let my_mapper = { default_mapper with
      expr = (fun mapper -> function
        | ( { pexp_desc = Pexp_constant (Const_string (s, Some "id")) } as e) ->
              { e with pexp_desc = Pexp_constant (Const_string (s ^ s, None)) }
        | e -> default_mapper.expr mapper e)
     }
    
    let () = apply ~source:infile ~target:outfile my_mapper

`{id|xxx|id}` という文字列を見付けたら `"xxxxxx"` にするという簡単なものである。ついでに Ast_mapper には上で書いたよなフィルタの実装がもうあった汗。まったくカンタンだ。ああ、まあ super である `default_mapper.expr` 呼ばずに self である `mapper.expr` をデフォルとケースで使うと無限ループするから注意な。

気をとりなおしてフィルタのコンパイル:

    $ ocamlfind ocamlc -package compiler-libs.common -linkpkg -o filter filter.ml
      
このフィルタを使って `x.ml` をコンパイルしてみる

    $ ocamlc  -ppx ./filter x.ml  
    $ ./a.out
    \(^o^)/\(^o^)/

二倍。ほいできた。

4.02.0+trunk の `ocaml` は `-ppx` を無視するので `ocamlc` を使うこと。これはリリースでは直っている。

まとめ
===================================

* -ppx で AST 書き換え。これが標準になるので OCaml でコンパイラでなんたらという若者はおさえておくこと
* Ast_mapper に肝は用意されている
* `ocaml` では動かないので `ocamlc` で予習。 ⇐今は大丈夫

以上
        
