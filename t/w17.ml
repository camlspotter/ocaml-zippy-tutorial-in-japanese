(* Warning 17: the virtual method x is not declared. *)

class virtual c = object (self)
  method y = self#x + 1
end

          
