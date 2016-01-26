let from_Some = function                    (* <= Warning 8 *)
  | Some v -> v

(* Warning 8: this pattern-matching is not exhaustive.
   Here is an example of a value that is not matched:
   None
*)

