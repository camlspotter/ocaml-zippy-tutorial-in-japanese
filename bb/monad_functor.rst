====================================================================
Monad にしちゃう functor を通して今時の OCaml モジュールプログラミングを俯瞰
====================================================================

これは私用の覚え書き。 
OCaml や ML のモジュールシステム、 value polymorphism、さらには relaxed value polymorphism 
を知っている人にも役に立つかもしれない。

OCaml 3.12.0 位から以降限定の技だ。

既存モジュールの型 'a t が実はモナドだったので、モナドのインターフェースを加えたい、という時が、ままある。
例えば、 'a Lazy.t は、モナドになる。でもモナドの bind とか return が定義されていない。
モナドの便利な関数群もない。それを functor で拡張していこう。
ここで言う functor とは ML のそれである。モジュールを受取りモジュールを返す関数。モナドのそれと勘違いしないこと。

最低限の Monadic interface を作る
=================================

まずモナドとして最低限提供されてなきゃいけない関数群をモジュールとして見て、その型を考える::

  module type S = sig
    type 'a t
    val return : 'a -> 'a t
    val bind : 'a t -> ('a -> 'b t) -> 'b t
  end

この場合は、 return と bind が最低限必要ってことにした。

'a Lazy.t にモナド風味を付け加えるには、::

  module MLazy : S (* 便宜的に Lazy.t の実装を隠してある *) = struct
    type 'a t = 'a Lazy.t
    let return v = Lazy.lazy_from_val v
    let bind x f = f (Lazy.force x)
  end

これでいい。あ、でもこれじゃ MLazy に Lazy の元々の関数が入ってないじゃないか！ まあそれは後で考える。
MLazy の型を明示的に S と書くことで、外部には MLazy.t が Lazy.t と同じことを隠している。
本来、これを書く必要は無いのだが、次の説明に必要なので。

Covariant にしよう
=================================

ちょっとここでひと工夫。 OCaml は (relaxed) value polymorphism があるので、関数適用時の多相性に制限がある::

  let x = MLazy.return []

これは多相値にならない。 '_a list MLazy.t である。
Monadic なプログラミングでは return や bind を多用するので、これは困る。
そこで、 S.t の型パラメタを covariant だということにして、この問題を回避できる。::

  module type S = sig
    type +'a t (* Covariant ですぞ *)
    val return : 'a -> 'a t
    val bind : 'a t -> ('a -> 'b t) -> 'b t
  end

  module MLazy : S (* 便宜的に Lazy.t の実装を隠してある *) = struct
    type 'a t = 'a Lazy.t
    let return v = Lazy.lazy_from_val v
    let bind x f = f (Lazy.force x)
  end

こうしておくと、 relaxed value polymorphism のお蔭で、 return や bind 適用時にも多相性が失われることがない!::

  let x = MLazy.return []

はちゃんと 'a list MLazy.t になる。

もちろんモジュール型 S は元の S より条件が厳しくなるので、今から作る functor の取りうるモジュールの幅が狭まるが、
今のところ covariant 以外の 'a t をモナドにしようと思ったことが無いので、まあこれでよかろう。
(もし covariant でない 'a t をモナドにしようとすれば別の S' を定義して以下の functor Make もまた別の Make'
を定義することになる。もちろんその Make'(A) の関数群は relaxed value polymorphism の恩恵は受けることはできないが。)

MLazy の型制限も必要ないから外しておこう::

  module MLazy = struct
    type 'a t = 'a Lazy.t
    let return v = Lazy.lazy_from_val v
    let bind x f = f (Lazy.force x)
  end

強化 functor, Make を作ろう
==================================

S の型を持つ基本モジュールを作るのはプログラマの仕事。そこからいろいろ自動的にモナディックな関数群を創りだす
functor、 Make を定義しよう。まず、強化されたモジュール型から::

  module type T = sig
    include S

    val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
    val map : ('a -> 'b) -> 'a t -> 'b t
    val sequence : 'a t list -> 'a list t
  end

T は S に関数を足したもので、まあ、二つしか足してないが…まあ好きなだけ足せばいい。
Make は S の型を持つ基本モジュール A をもらって型 T に強まったモジュールを返す。
実装::

  module Make (A : S) : T = struct
    include A

    let (>>=) = bind

    let map f t = bind t (fun x -> return (f x))

    let rec sequence = function
      | [] -> return []
      | x::xs ->
          x >>= fun x ->
          sequence xs >>= fun xs ->
          return (x::xs)
  end

(>>=) と sequence の定義はごく普通。 ふむ、出来た。使ってみる::

  module XLazy = Make(MLazy)

  let v = [ MLazy.return []; XLazy.return [] ] (* 型エラー *)

あれ？ 強化前のモナドと強化後のモナド、同じはずなのに、一緒の型を持てないからリストに入れられない…
型システムが MLazy.t と XLazy.t を別の型だと思っているのだ。

なぜか？ module Make (A : S) : T = ... の所で明示的に結果のモジュールの型を T と提示しているが
T.t が A.t と同じであると宣言するのを忘れている! この情報を教えてやらなければいけない::

  module Make (A : S) : T with type 'a t = 'a A.t (* 型の同値を足した *) = struct
    include A

    let (>>=) = bind

    let map f t = bind t (fun x -> return (f x))

    let rec sequence = function
      | [] -> return []
      | x::xs ->
          x >>= fun x ->
          sequence xs >>= fun xs ->
          return (x::xs)
  end

なんと面倒な! 実は、この返り型を書かなければ、型システムがよろしくやってくれる! ::

  module Make (A : S) = struct
    include A

    let (>>=) = bind

    let map f t = bind t (fun x -> return (f x))

    let rec sequence = function
      | [] -> return []
      | x::xs ->
          x >>= fun x ->
          sequence xs >>= fun xs ->
          return (x::xs)
  end

この様に、モジュールを使ったプログラミングではプログラマが情報を必要以上に減らしたモジュール型を書いてしまって
型の同値性が知らず知らずに失われてしまう、ということが、ままある。モジュールを使わない所では型推論の恩恵に
慣れきっている我々には難しいところだ…

基本的には functor の引数の型など必要なモジュール型以外は、とりあえず、書かない、のが吉なようだ。
ただし、ライブラリとして functor の返りモジュールの型情報は合ったほうがよいし(特に .mli)、
そうなると、上の T やT with 'a t = 'a A.t の記法も避けられない。
ここんとこの勘所を身につけるには修行が必要だ。

Binary operator のための特殊名前空間を作る
================================================

さて、 module XLazy = Make(MLazy) で、強化モジュールが出来た。
XLazy.(>>=) をバリバリ使いたいのだが、それには XLazy.(>>=) と一々書くのは面倒だから、
open XLazy を唱えてちゃんと二項演算子として使えるようにしてやろう!
と言いたいところだが、ちょっと待て。 open XLazy すると (>>=) どころか map や sequence も
アクセス可能になる。 map は特に一般的なイディオムだから名前空間を開きすぎだ。
やはり map はあくまでも map ではなく XLazy.map としてアクセスしたい。
そのために open 用のモジュール、 XLazy.Open を定義しよう::

  module Make (A : S) = struct
    include A

    module Open = struct
      let (>>=) = bind
    end

    include Open

    let map f t = bind t (fun x -> return (f x))

    let rec sequence = function
      | [] -> return []
      | x::xs ->
          x >>= fun x ->
          sequence xs >>= fun xs ->
          return (x::xs)
  end

こうすると、 module XLazy = Make(MLazy) とした場合、 (>>=) は XLazy.(>>=) としても、
XLazy.Open.(>>=) としてもアクセスできる。 open XLazy.Open を唱えれば Open の中で定義されている
(>>=) だけがグローバルな名前空間に踊りでてくるという寸法だ。

まあ、型クラスがあればこんな事気にしなくて良いのだが…無いものはしょうがない。

拡張前の元のモジュールと統合: with type 'a t := ... を使う!
=========================================================

Lazy モジュールには、型 'a t の他にいろいろな関数が定義されているが、 MLazy そして強化された XLazy
にもそれらの関数は入っていない。 これは、 XLazy を MLazy ではなく、 Lazy に return と bind を加えたものから
作っても同じ事だ。::

  module MLazy' = struct
    include Lazy
    val return : 'a -> 'a t
    val bind : 'a t -> ('a -> 'b t) -> 'b t
  end

  module XLazy' = Make(MLazy')

XLazy' は Lazy そして MLazy' に存在する関数群が継承されていない。残念だが functor の引数は閉じた型しか
取れないので、いくら functor 引数にリッチなモジュールを与えても、 functor 内部では引数モジュールの型として
宣言したプアーな型しか持っていないのだ。他は、忘れ去られてしまう。

まあ、 Lazy と XLazy を使い分ければ良いのだが…できればこの二つの機能を合わせ持つ 俺Lazy が欲しいところだ。
これならどうだ?::

  module Lazy = struct
    include Lazy
    include XLazy (* うまくいかない! *)
  end

残念だが上手くいかない。 Lazy も XLazy も 'a t を定義している。同じ名前の型定義が二つ以上モジュールには存在できないのだ。
しかしこれは妙な話だ。 'a XLazy.t = 'a Lazy.t という同値関係を型システムは知っているのだから、問題はないはずなのに。
'a XLazy.t が 'a Lazy.t と同じであることを宣言してみよう::

  module Lazy = struct
    include Lazy
    include (XLazy : T with 'a type t = 'a Lazy.t) (* うまくいかない! *)
  end

これも上手くいかない。無理なのか、と思いきや、こんなのが使える::

  module Lazy = struct
    include Lazy
    include (XLazy : T with type 'a t := 'a Lazy.t) (* たった一文字加えただけなのに! *)
  end

一体何が？ これは次の例を見れば、わかる、かもしれない::

  module type S = sig
    type t
    type s = Foo of t
  end

  module type S' = S with type t = int

  module type S'' = S with type t := int

上のソースを ocamlc -c -i でコンパイルすると次のような解釈になっているのがわかる::

  module type S = sig type t type s = Foo of t end

  module type S' = sig type t = int type s = Foo of t end (* t = int という同値関係が導入されている *)

  module type S'' = sig type s = Foo of int end (* t が無くなって int に置き換わっている! *)

with type ... = と with type ... := の違いがわかるだろうか。 := では「代入」された元の型は結果のモジュール型から
消え去り、右辺の型に置き換わってしまっている。これを使って、 T with type 'a t := 'a Lazy.t と書けば、
XLazy のモジュール型を型 t の定義の無いものへと制限することが出来る。そして、 Lazy と (XLazy  : T with type 'a t := 'a Lazy.t)
には危険な t の定義対はもはや存在しない!

この := を Make に移してみよう::

  module Make (A : S) : T with type 'a t := 'a A.t (* t を置換する! *) = struct
    include A

    module Open = struct
      let (>>=) = bind
    end

    include Open

    let map f t = bind t (fun x -> return (f x))

    let rec sequence = function
      | [] -> return []
      | x::xs ->
          x >>= fun x ->
          sequence xs >>= fun xs ->
          return (x::xs)
  end

こうすれば、 Make(Lazy) には最早 t の型定義は存在しない。だから、::

  module MLazy = struct
    type 'a t = 'a Lazy.t
    let return v = Lazy.lazy_from_val v
    let bind x f = f (Lazy.force x)
  end

  module XLazy = Make(MLazy)

  module Lazy = struct
    include Lazy
    include XLazy
  end

で上手く書ける!

結果を Monad モジュールにまとめよう
====================================

今までの結果を Monad モジュールにまとめよう::

  (* 最低限の monadic module type *)
  module type S = sig
    type +'a t (* covariant *)
    val return : 'a -> 'a t
    val bind : 'a t -> ('a -> 'b t) -> 'b t
  end

  (* 強化された monadic module type *)
  module type T = sig
    include S

    module Open : sig
      val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
    end
    val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
    val map : ('a -> 'b) -> 'a t -> 'b t
    val sequence : 'a t list -> 'a list t
  end

  (* 最低限から強化版を創りだす functor *)
  module Make(A : S) : T with type 'a t := 'a A.t = struct
    include A

    module Open = struct
      let (>>=) = bind
    end

    include Open

    let map f t = bind t (fun x -> return (f x))

    let rec sequence = function
      | [] -> return []
      | x::xs ->
          x >>= fun x ->
          sequence xs >>= fun xs ->
          return (x::xs)
  end

実際に私が使っている monad.ml はこんな感じ。 https://bitbucket.org/camlspotter/spotlib/src/c97d21e10999/lib/monad.ml

- より多くのモナド操作関数
- 2 つの型パラメータのモナド用 functor (OCaml には kind inference が無い…無念!)

Oreore モジュールで強化版モジュール群を管理
=========================================================

さて、これでモナドのインターフェースを持たないモジュールを

- 最低限のモナディックインターフェースを与える (MLazy)
- それを functor で強化してやる ( module XLazy = Make(MLazy) )
- 元のモジュールと統合する ( include Lazy, include XLazy )

の三ステップでモナドインターフェースを与えることができた。

例えば、 oreore.ml に::

  (* oreore.ml *)

  ...

  module Lazy = struct
    include Lazy
    include XLazy
  end

と書いておけば、 open Oreore と唱えれば、
さっきまでヒヨワだったハズの Lazy がモナディックな Lazy として立ち上がってくるわけだ。
Oreore モジュールにはこうやって自分で強化したモジュールをどんどん足していけばいい。

Lazy の中で Lazy を include しているのが気持ち悪い、という人は、::

  module Stdlib = struct
    module Lazy = Lazy
  end

  module Lazy = struct
    include Stdlib.Lazy
    include XLazy
  end
  
とでもして、明示的に include されてる Lazy はオリジナルの stdlib 由来だと判るようにすればいいだろう。
私はそこまでしてもあまりしょうがないかな、と思っている。

oreore.mli を完結に書く
=========================================================

最後に oreore.mli を書いておこう。上の例だと強化 Lazy の signature を書くことになる。

一番カンタンなのは、オリジナルの Lazy からコピペする方法。でも、ダサい。というかコピペ死すべし。
コピペでは、オリジナルの Lazy に関数が足された場合、 Oreore.Lazy の signature 方が追随できない。

それより完結なのは module type of Lazy を使う方法。こんな感じだ::

  (* oreore.mli *)
  module Lazy : sig
    include module type of Lazy
    (* Inherits the original Lazy module *)

    include Monad.T with type 'a t := 'a Lazy.t
    (* Adding monadic interface *)
  end

これを見れば Lazy はオリジナルの Lazy と Monadic インターフェースの両方持ってるのね、とわかる。

実はこんなにすっきり行くのは Lazy.t が type 'a t = 'a lazy_t というエイリアスだから。
Variant や record 型が含まれている場合は厄介だ。::

  (* oreore.mli *)
  module Unix : sig (* 実は良くない *)
    include module type of Unix
    (* Inherits the original Unix module *)

    val usleep : float -> unit
    (** better sleep *)
  end

これは Unix モジュールに usleep を足してみたものの signature (良くない)。 usleep の実装は、まあ適当に interval_timer を
使えば OCaml だけで書けるので実装は省略。

実はこれが良くない。オリジナルの Unix 中の variant や record 型と強化 Unix の型が別モノと認識されるのだ。
強化 Unix だけ使っていれば問題はないが…もし第三者のライブラリがオリジナルの Unix を使っていて、そこから得られる
値、例えば型 open_flag の値を強化 Unix で使おうとすると…使えない。

なんで？これは次の例でわかる::

  $ ocaml unix.cma

  # module U : module type of Unix = Unix;;

  module U : sig
    ...

    type open_flag =
        O_RDONLY
      | O_WRONLY
      | O_RDWR
      | O_NONBLOCK
      | O_APPEND
      | O_CREAT
      | O_TRUNC
      | O_EXCL
      | O_NOCTTY
      | O_DSYNC
      | O_SYNC
      | O_RSYNC

    ...
  end

え？ open_flag ちゃんとあるじゃん？ でも、これは Unix.open_flag じゃなくて U.open_flag。両者には何の関係もない!
Unix.O_RDONLY = U.O_RDONLY は型エラーになる！ これは、例えば::

  module A = struct type t = Foo end 
  module B = struct type t = Foo end 

と書いたときに A.t と B.t は定義の字面は同じだけど違う型なのと同じ理由だ。(同じだったら困る!)
この B.t が A.t と実は同じ、と言いたければその事をちゃんと示してやらねばならない::

  module A = struct type t = Foo end 
  module B = struct type t = A.t = Foo end  (* 同値関係を明示 *)

これと同じ事を(U や)強化Unix に対してもしてやれば、オリジナル Unix との interoperability を実現できる::

  (* oreore.mli *)
  module Unix : sig
    include module type of Unix with type open_flag = Unix.open_flag
    (* Inherits the original Unix module *)

    val usleep : float -> unit
    (** better sleep *)
  end
   
あー、これで完成！ いや、 Unix には他にも沢山型があるのだ。それについても同値性を宣言しなければ…ならない! ::

  (* oreore.mli *)
  module Unix : sig
    include module type of Unix 
    with type error		= Unix.error
    and  type process_status	= Unix.process_status
    and  wait_flag		= Unix.wait_flag
    and  open_flag		= Unix.open_flag
    and  seek_command		= Unix.seek_command
    and  file_kind		= Unix.file_kind
    and  stats			= Unix.stats
    and  ...
    (* Inherits the original Unix module *)

    val usleep : float -> unit
    (** better sleep *)
  end

これは…めんどくさい!! 残念ながら今のところ、この with type の長い列がついたモノと同等の signature を
簡単に得る記法は存在しない。

この場合は、敢えて、 強化 Unix の signature を書かない、つまり、 oreore.mli を書かないのも選択の一つだ。
.mli の無いライブラリモジュールなんて! いやしかし、 .ml は至極カンタンに書ける。ならば .mli は必要ない! ::

  (* xunix.ml *)
  let usleep sec = ...

  (* xunix.mli *)
  val usleep : float -> unit
  (** better sleep *)
 
  (* oreore.ml *)
  module Unix = struct
    include Unix
    (* Inherits the original Unix module *)

    include Xunix
    (* Inherits my extended XUnix *)
  end

ここでは Unix に付け加える関数 usleep を xunix.ml に定義、そのドキュメントを xunix.mli に書いて、
oreore.ml でそれを include している。 oreore.mli は無い。 oreore.mli が無いからドキュメントが…
心配する必要は無い。 oreore.ml はシンプルだ。 Unix はオリジナルの Unix と強化 Xunix から出来ている。
オリジナル Unix も Xunix もちゃんとドキュメント化された .mli が用意されているからそれを参照すればよい。
