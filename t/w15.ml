class type ct15 = object method x : int end
          
class c15 : ct15 = object 
  method private x = 1
end

let i15 = new c15
