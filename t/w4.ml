type t = Foo | Bar

let f = function
  | Foo -> print_string "Foo"
  | _ -> print_string "other than Bar"    (* <= Warning 4 *)

(* Warning 4: this pattern-matching is fragile.
   It will remain exhaustive when constructors are added to type t. *)
