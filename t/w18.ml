(* with -principal *)
type s = { foo: int; bar: unit }
type t = { foo: int }

let f x =
  x.bar;
  x.foo

(* Removal of code produces incompatible type. *)
let f2 x =
  x.foo

let f3 (x:s) =
  x.bar;
  x.foo
    
let f4 (x:s) =
  x.foo
    
