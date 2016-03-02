type t = x:int -> y:int -> int

let f g =
  ignore (g : t);
  g ~y:1


