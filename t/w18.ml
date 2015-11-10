(* ocamlc -c -i -w A -principal w18.ml *)
class c = object method id : 'a. 'a -> 'a = fun x -> x end;;
type u = c option;;
let just = function None -> failwith "just" | Some x -> x;;
let f x = let l = [Some x; (None : u)] in (just(List.hd l))#id;;
let g x =
  let none = (fun y -> ignore [y;(None:u)]; y) None in
  let x = List.hd [Some x; none] in (just x)#id;;
let h x =
  let none = let y = None in ignore [y;(None:u)]; y in 
  let x = List.hd [Some x; none] in (just x)#id;;
