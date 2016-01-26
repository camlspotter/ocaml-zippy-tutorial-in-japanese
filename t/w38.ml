type t = ..

module X : sig end = struct
  type t += None_uses_this
end
  
