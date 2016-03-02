module X = struct
  type t = { x : int; y : int }
end

type t = { x : int; z : int }

open X

let r = { y = 1; x = 2 }
