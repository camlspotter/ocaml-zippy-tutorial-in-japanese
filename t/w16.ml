let f ?(x=0) ~y = x + y (* Why we do not have Warning 16? *)

let g ~y ?(x=0) = x + y (* Warning 16: this optional argument cannot be erased. *)
