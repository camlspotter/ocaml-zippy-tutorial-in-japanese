let () =
  print_string "hello";
  List.iter print_string;   (* <= Warning 5 *)
  print_string "world"

(* Warning 5: this function application is partial,
   maybe some arguments are missing.
*)

let iter2 f =
  print_string "iter is partially applied";
  fun xs -> List.iter f xs

let () =
  print_string "hello";
  let _ = iter2 print_string in (* no more warning *)
  print_string "world"
