class c = object
  method m = print_endline "hello"
end

class c' = object
  inherit c
  method m = print_endline "bye"   (* <= Warning 7 *) 
end

(* Warning 7: the method m is overridden. *)
