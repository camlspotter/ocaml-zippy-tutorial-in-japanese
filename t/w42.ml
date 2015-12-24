module X = struct
  type t = A of int
end

module Y = struct
  type t = A of int
end

open X
open Y

let f x : X.t = A x
  
