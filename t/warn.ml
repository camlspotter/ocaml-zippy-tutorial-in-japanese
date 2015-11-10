(*) this is a comment *)

( *);;

true & false;;

type t = Foo | Bar;;

let f = function
  | Foo -> print_string "1"
  | _ -> print_string "other than 1"


let _ =
  print_string "hello";
  List.iter print_string;
  print_string "world"
    
let () =
  let iter' ~f xs = List.iter f xs in
  iter' print_endline ["hello"; "world"]

class c = object
  method m = print_endline "hello"
end

class c' = object
  inherit c
  method m = print_endline "bye"
end

let g = function
  | true -> print_endline "hello"

type r = { x : int; y : int  }

let h = function
  | {x = 0} -> 0
  | {x = _} -> 1
      
let f10 fd =
  let buf = Bytes.create 10 in
  Unix.read fd buf 0 10;
  buf

let x11 x = match x with
  | Some true -> 1
  | Some false -> 0
  | None -> 0
  | Some _ -> 2

let w12 = function
  | (Some _ | Some _) -> 1 (* <= Warning 12 *)
  | None -> 0

(* Warning 12: this sub-pattern is unused. *)

class c13 = object
  val mutable x = 1
  method get_x = x
end

class c13'' = object
  val mutable x = 10
  inherit c13           (* <= Warning 13 *)
  method get_x' = x
end

(* Warning 13: the following instance variables are overridden by the class c12 :
  x
   The behaviour changed in ocaml 3.10 (previous behaviour was hiding.)
*)


let regexp = "\([A-Z]+[A-Za-z0-9]+\)\." (* <= Warning 14 *)

(* Warning 14: illegal backslash escape in string. *)

class type ct15 = object method x : int end
          
class c15 : ct15 = object (self)
  method private x = self#x + 1
end
