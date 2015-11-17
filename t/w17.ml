(* ?? *)

class virtual ['a] c = object (self)
  method virtual x : 'a
  initializer
    ignore self#x
end

          
