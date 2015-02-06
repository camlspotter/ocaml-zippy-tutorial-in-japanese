(* OCaml 4.00.0 辺りの types.mli の読み解き。間違っている可能性がある。
   現在の OCaml のものとは違っている可能性がある。
*)

open Asttypes

(* Type expressions for the core language *)

type type_expr =
  { mutable desc: type_desc;
    mutable level: int;
    mutable id: int }

(* 
   desc:
       型の内容。

   level: 
       型が生成された let polymorphism level。
       Unification によって小さい方にまとめられていく。

       Quantify された型の level は generic_level。
       Generalization の際、型の level が現在の polymorphism current_level より
       大きければ、 generalize される。同じもしくは小さい level を持っている場合、
       generalize されないどころかサブノードの検査も行われない。
       つまり、 generalize する際には、型の level はサブノードの level より
       同じか、大きくなければ正確な generalization は行われないことになる。
       ただし、通常の HM の型アルゴリズムを舐めている際にはそんなことは起こらない。
       新しい型を既存の型から作るとき、既存の型の level は常に current_level
       と同じか小さいはずだ。大きければそれ以前の let polymorphism で
       generalize されて generic_level になっているからである。

       level は通常 0以上の整数だが、型ノードにマークをつけるため、
       負値を使うことがある。 pivot_level, mark_type を参照。当然、
       付けたマークは戻さないと generalization でオカシイことになる。

   id:
       Unification backtrack のために使われる。
       id が違っても同じ型の場合がある
       違う型の場合必ず id は異なるため、 hash として使われる。
       このフィールドの存在のため、 { ty with desc = ... } のような
       ことをしてはいけない。必ず Btype.new*ty* を使って新しい id をもらう
*)

and type_desc =
    Tvar of string option
        (* 型変数。名前をつけることができる。 名前は print 時に使用される。
           名前が無い場合は print 時に 'a から順に付けられる

           型変数の同異は pointer equality によってなされる。
           同じ名前がついていてもアドレスが異なれば実際には違う型変数であるし、
           プリントアウトの際にも数字の postfix が入る。
        *)
  | Tarrow of label * type_expr * type_expr * commutable
        (* t -> t。 [is_optional label] の際には引数の型は
           必ず option 型になっている。 
           
           commutable について

                   and commutable =
                       Cok
                     | Cunknown
                     | Clink of commutable ref
    
               let f g = g ~x:1 ~y:true in   f (fun ~y:_ ~x:_ -> ());;
    
               は型エラーになるのだが、これは g の Tarrow が Cunknown だから。
               現在の OCaml では外からくる型不明の関数にかんして引数順入れ替えのコンパイルを
               おこなわない、つまり
    
                  let f g = g ~x:1 ~y:true in f (fun ~x ~y -> (fun ~y:_ ~x:_ -> ()) ~y ~x);;
    
               というコードに変換しない。 多分これをやると abstraction が入るので
               一般的には副作用のタイミングがおかしくなってしまう
                
                  let g = fun ~y:_ ~x:_ -> () in
                  let f = g ~x:1 ~y:true in f 
    
               これは前もって順序がわかっており、 Cok なので型エラーにならない。
               順序の入れ替えは g の定義ではなく g の呼び出し側で行われる:

                  let g = fun ~y:_ ~x:_ -> () in
                  let f = g ~y:true ~x:1 in f

               こんな感じだと思われる(仔細未確認)。OCaml は引数の評価順は未定義なので
               問題ないはず 
        *)
  | Ttuple of type_expr list
        (* タプル *)
  | Tconstr of Path.t * type_expr list * abbrev_memo ref
        (* Data type。 

           abbrev_memo はこの型の alias のキャッシュ。

           例えば type 'a t = 'a * 'a で、 int t という型が
           あった時、 int t の Tconstr が int * int と同じであることを覚えておく
           ための情報がここに入る。
           
           Tconstr から
           何か変換を行なって別の Tconstr を作る際には
           前の型とは関係なくなってしまうから abbrev_memo は別の
           新しい空のキャッシュを使わなければならない。

           Head alias の expansion は、
           try_expand_once             <--- なんだろう書きかけだが、覚えていない

        *)
  | Tobject of type_expr * (Path.t * type_expr list) option ref
        (* [Tobject (field_type, nm)]

           [!nm] が [Some ..] の場合はクラス名付きのオブジェクトの型。
               [Some (p, ty :: tyl)] の場合、
               [(tyl) p] という型である

               [ty] は何か？
                   Printer では [ty] は generalize されているかどうかの判定に使われている
                   See [Printtyp.tree_of_typobject]

                   [nm] が新たに [Some] を introduce するケースは、とても見つけにくいが、
                   [Btype.set_name] そしてそれを呼ぶ [Ctype.set_object_name] である。
                   [set_object_name] の [rv] がこの [ty] になる。

                        let set_object_name id rv params ty =

                   この [rv] は常に [Ctype.row_variable ty] であるので、row variable
                   であるらしい。これは OCaml の型にはプリントされないのと合致する。

               [Some (p, [])] というのはありえない状態 :-( だと思われる

           [!nm] が [None] の場合は無名オブジェクト型。 [field_type]
           には [Tfield] や [Tnil] (おそらく [Tlink]も？) 入っている。
           (ここに [Tarrow] とかは入らない *)
        *)

  | Tfield of string * field_kind * type_expr * type_expr
        (* [Tfield (メソッド名, 種, メソッドの型, 残りのメソッド情報)]

           最後の [type_expr] はリストの cons の様な働きをする。
           Ctype.flatten_fields で普通のリストに展開してくれる。
           最後は Tvar や Tunivar だと open なオブジェクト型、
           Tnil だと closed。これは Tobject での [!nm = Some (p, ty :: tyl)]
           の [ty] と row variable であるようである。

           が、なんと Tconstr が来ることがあるようだが
           これは… (Printtyp.tree_of_typfields)
           Tconstr が来ると、プリンタでは Otyp_object の最後が Some false になる。
           そしてこれは < _..> とプリントされるようなので、 non generalized raw var を指すようだ:

             let f x o = o#m + x
             let g = f 1
           
           とすると val g : < x : int; _..> -> int

           と表示されるので、これ以上知りたい場合はこの場合の最後の型を調べるべきである。 
        *)

  | Tnil
      (* メソッドがもう無い、閉じたオブジェクト型であることを示す *)

  | Tlink of type_expr
        (* 高速 unification のためのリンク。 Tlink はある型(普通は変数)
           が別の型と unify されたなれのはてである。 Unify された相手は
           Tlink の中に入っている。
           
           Btype.repr でこのリンク Tlink (と Tfield) をすっ飛ばすことができる
         *)
  | Tsubst of type_expr         (* for copying *)
        (* 型を変更する際、一時的に desc を [Tsubst 新型変数] に置き換えて
           作業する。新型変数の desc に新しい型の desc を代入する。
           再帰的な作業中に Tsubst を見た場合は、これは既に別のところで作業の
           終わった shared node であることがわかるので同じ作業を行わず
           Tsubst の中の結果だけをもらうことになる。

           Tsubst に置き換えた際には後で元にもどさなければいけない。
           これは Btype.save_desc と Btype.cleanup_types を使う。
         *)
  | Tvariant of row_desc
        (* Polymorphic variant の型 *)
  | Tunivar of string option
        (* 'a . t の 'a。 Quantify されると内部の 'a も Tunivar になるようである *)
  | Tpoly of type_expr * type_expr list
        (* 'a . t *)
  | Tpackage of Path.t * Longident.t list * type_expr list
        (* モジュールのパッケージ型。 module_type ではなく Path.t
           が入っているように nominal である

           Longident.t list * type_expr list は with type ... である
        *)
           

and row_desc =
    { row_fields: (label * row_field) list;
      row_more: type_expr;
      row_bound: unit; (* kept for compatibility *)
      row_closed: bool;
      row_fixed: bool;
      row_name: (Path.t * type_expr list) option }

    (* row_fields: フィールド
       row_more: フィールド追加 (他の型を元に row_type を作る)
       row_bound: 意味なし
       row_closed: 閉じているかどうか
          closed = true だと 
             Rpresent のみの場合: [ ... ] 
             他のがある           [< .. ] 
          closed = false だと    [> .. ]
       row_fixed: 型検査終了後は意味なしのはず 
       row_name: 名前付き poly variant type 
    *)
       
and row_field =
    Rpresent of type_expr option
  | Reither of bool * type_expr list * bool * row_field option ref
        (* 1st true denotes a constant constructor *)
        (* 2nd true denotes a tag in a pattern matching, and
           is erased later *)
  | Rabsent

      (* Rpresent 存在する option は引数があるか、ないか。
           `A とか `A of int など

         Reither (b, [ty1;..;tyn], ...)

               [ (function `A -> 1);
                 (function `A x -> x + 1);
                 (function `A x -> int_of_float x + 1)]

           という式を型推論させると、

               ([< `A of & int & float ] -> int) list

           という型が出て来るが、これ。つまり、 `A は無引数かつ int かつ float を取る
           という不思議な型である。ちなみに上記リストから何かを取り出しても関数として使えない。

           [b] が true だと無引数が存在: `A of (*無*) & int & float と of の直後に & が表示される
           [b] が false だと無引数は存在しない: `A of int & float と of の直後に & は表示されない

         Reither の第三、第四引数は型検査後は重要ではない一時的なもののようだ

         Rabsent 存在しない: 型検査後は出てこないはず (Printtyp の対応も適当)
      *)
         
and abbrev_memo =
    Mnil
  | Mcons of private_flag * Path.t * type_expr * type_expr * abbrev_memo
  | Mlink of abbrev_memo ref

    (* 型 alias のキャッシュ。

       Mnil は空。現在の alias 情報はこれ以上ないことを意味する
       Mlink は別のキャッシュを継承する時に使う
       Mcons は
    *)

and field_kind =
    Fvar of field_kind option ref
  | Fpresent
  | Fabsent

  (* Row polymorphism

     Fpresent : 存在する
     Fabsent : 存在してはいけない
     Fvar None : 変数
     Fvar (Some ..) : Unification により代入されてしまった変数
  *)

and commutable =
    Cok
  | Cunknown
  | Clink of commutable ref
