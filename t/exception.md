例外について
==================================================

例外の効率: OCaml の例外は早い、は本当か
======================================================================

例外による再帰関数からの大域脱出は OCaml ではランタイムのペナルティはほとんどない、
という事になっている。
``try with`` を書いてそれでもコードが読みやすければ使って構わない。
が、実際のところ、どうか。 -g を付けてコンパイルした場合、遅くなる。
さらに、 OCAMLRUNPARAM 環境変数に "b" が入っていると更に遅くなる。

しっかりした OCaml プログラムを開発したい場合はバックトレースは是非欲しい
ところなので、 -g を付けて　OCAMLRUNPARAM 環境変数に "b" を入れてプログラム
を実行することは普通にある。だから、安易に例外を使うとパフォーマンスに影響する:

    let gen_timed get minus f v = 
      let t1 = get () in
      let res = f v  in
      let t2 = get () in
      res, minus t2 t1
    
    let timed f v = gen_timed Unix.gettimeofday (-.) f v
    
    let f1 x = 
      match x with
      | 1 -> 1
      | 2 -> 2
      | 3 -> 3
      | _ -> 0
    
    let f2 x = 
      try 
        match x with
        | 1 -> 1
        | 2 -> 2
        | 3 -> 3
        | _ -> raise Exit
      with
      | Exit -> 0
    
    let loop f () = 
      for i = 0 to 1073741823 do
        ignore (f i)
      done
    
    let () =
      let _, sec = timed (loop f1) () in
      Format.eprintf "%f@." sec;
      let _, sec = timed (loop f2) () in
      Format.eprintf "%f@." sec

例えば上記のプログラムでは、 ocamlopt で -g 無しでコンパイルした場合:

    2.507164
    5.330632

と 2倍くらいなのだが、 -g 付きでコンパイルした場合は:

    2.471575
    21.626229

さらに OCAMLRUNPARAM=b した場合:

    2.478992
    30.855514

ということになり、 12倍近く遅くなる。

実際これをどう受け取るかはコンテキストによるところだ。
このベンチは例外を発生させて受け取る、この処理以外パターンマッチ一回やるだけ
なので、この10倍近い比も最悪の場合の数字であって、実際のコードではこの比は
どんどん小さくなるはずだ。
また、raise して try で受けるとバックトレースの処理 10億回に 
28秒しか掛かっていない、結構早いじゃんと考えることもできる。

例えば、 一連の操作をやっていって、全ての操作が成功したら Some x を
返し、どこかで何かしらエラーが出たら None を返す、というコードの場合、
option モナドをチェーンして書く方法と、エラーが出たら例外で脱出する
という場合の2つの方法があるが、次のコードのように 10回チェーンさせる場合
だと -g と OCAMLRUNPARAM=g を付けても両者はほとんど変わらない。
(ちなみに -g も OCAMLRUNPARAM=g もない場合は例外版が 2倍早くなる):

    let (>>=) v f = match v with
      | None -> None
      | Some v -> f v
    
    let g i = match i mod 2 with
      | 0 -> Some i
      | _ -> None
    
    let f1 i = g i >>= g >>= g >>= g >>= g >>= g >>= g >>= g >>= g >>= g
    
    let f2 i = 
      try 
        match i mod 2 with
        | 0 -> 
            begin match i mod 2 with
            | 0 -> 
                begin match i mod 2 with
                | 0 -> 
                    begin match i mod 2 with
                    | 0 -> 
                        begin match i mod 2 with
                        | 0 -> 
                            begin match i mod 2 with
                            | 0 -> 
                                begin match i mod 2 with
                                | 0 -> 
                                    begin match i mod 2 with
                                    | 0 -> 
                                        begin match i mod 2 with
                                        | 0 -> 
                                            begin match i mod 2 with
                                            | 0 -> Some i
                                            | _ -> raise Exit
                                            end
                                        | _ -> raise Exit
                                        end
                                    | _ -> raise Exit
                                    end
                                | _ -> raise Exit
                                end
                            | _ -> raise Exit
                            end
                        | _ -> raise Exit
                        end
                    | _ -> raise Exit
                    end
                | _ -> raise Exit
                end
            | _ -> raise Exit
            end
        | _ -> raise Exit
      with
      | Exit -> None
    
    let loop f () = 
      for i = 1 to 1073741823 do
        ignore (f i)
      done
    
    let () =
      let _, sec = timed (loop f1) () in
      Format.eprintf "%f@." sec;
      let _, sec = timed (loop f2) () in
      Format.eprintf "%f@." sec

え？ match を 10回もネストさせないと？いやいや、これはただの例だ。
それぞれが例外を投げるような手続き型命令を10回実行する場合に、
try with で包む代わりに一つ一つを Either を返すようにして bind で
チェーンすると流石に遅くなりますよという事である。
そういう事であれば普通に起こりうるだろう。

さてさて、ではどうすればいいのか。私はこうしたいと思っている:

* ライブラリ関数のような誰かがどこかで再帰やループで何度も呼び出すかもしれない
  関数については安易に大域脱出しない。
* アプリケーションコードで、呼び出される回数が読め、かつ十分少ない場合、
  例外で書くと読みやすくなる場合は例外で書く。
* 一関数内部でのローカルに完結した脱出は気にしない

ちなみに、この、例外が遅いので大域脱出に気軽に使えない、
という問題を解決するため、バックトレースを生成しない速度の早い例外
を実験している人もいる: http://caml.inria.fr/mantis/view.php?id=5879 
確かに、「安全な goto」として例外を使いたい場合はそのバックトレースは
別に興味がない。本当に例外的な事が起こった時だけトレースが欲しいわけだから
フローコントロールの道具としての例外と、
非常事態のための例外は分けるべきなのかもしれない。


``raise Exit``, ``raise Not_found`` でコードが読みやすくなるなら使う…
=====================================================================

CR jfuruse: 前エントリとの整合性を考えること

特に例外を使うべきなのは Option モナドや Result(Either)モナドで処理を長ーく ``bind`` (``>>=``) 連結する場合。
クロージャーを多用するので、どうしてもパフォーマンスが落ちる。例外にしたほうがよい。
Option モナドの None には Not_found を使えばいいだろう。
Result のエラーには何か例外を作らなければならないが、例えば、
ローカルモジュールで作ってみよう(ちょっと長くなる):

   let module E = struct exception Error of error in
   let fail e = raise (E.Error e) in
   try `Ok begin
     ... Result モナドの bind チェーンに相当するものを fail を使って書く...
   end with
   | E.Error e -> `Error e

エラーの型を明示しなければならないのは面倒だ。他には:

   let ref error = ref None in
   let fail e = error := Some e; raise Exit in
   try `Ok begin
     ... Result モナドの bind チェーンに相当するものを fail を使って書く...
   end with
   | Exit -> 
       match !error with
       | Some e -> `Error e
       | None -> assert false

とも書けるか。 ``Exit`` が一般的すぎるならやはりローカルに例外を定義すればよい。
まああとはこれをチョイチョイと一般化して高階関数にすれば ``Result.catch`` の出来上がり。
``Option.catch`` ももちろんできますね。

ただしできるだけ例外は発生させるコードの周辺でローカルに処理すること。
さもなくば例外の取りこぼしによるバグに悩まされることになる。

OCaml 例外の静的型検査の研究はあるが採用されていない。

とはいえ例外に頼りすぎるな
==============================================================

要修正: 前エントリとの整合性を考えること

例外に頼った再帰からの脱出を使わずとも同等の再帰関数を書くことは
(初心者には難しいかもしれないが)全く可能である。例外に頼りすぎるのはよくない。:

      let exists p list = 
        try 
          List.iter (fun x -> if p x then raise Exit) list; false 
        with Exit -> true

この手続き感のあるコードと:

      let rec exists p = function
        | [] -> false
        | x::_ when p x -> true
        | _::xs -> exists p xs

この関数型的コードは同じである。どちらが好まれるかは、もちろん後者である。
前者のように書いていても構わないが…
OCaml を書き続けるならどこかで努力をして後者に切り替えるべきである。
