module M = struct
  type t = { x : int }
end
  
module N = struct
  type u = { x : int }
end

open M
open N

let x = { x = 20 }
    
