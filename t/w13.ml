class c = object
  val x = 1
  method x = x
end

class c' = object
  inherit c
  val x = 2          (* <= Warning 13 *)
  method y = x
end

module Fixed = struct
  class c = object
    val x = 1
    method x = x
  end
  
  class c' = object
    inherit c
    val! x = 2          (* no more Warning 13 *)
    method y = x
  end
end
  
