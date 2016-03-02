class type ct15 = object method x : int end
          
class c15 : ct15 = object 
  method private x = 1
end

class c15' = object 
  method private x = 1
end

class c15'' = object
  inherit c15'
  method! x = 1
end
  
let i15 = new c15
let () = print_int i15#x

class c () = object method virtual m : int method private m = 1 end;;
