(* OCaml 引数は右から左へと評価され…ない！すまんな、ほうとうにすまん。 *)
let () = 
  let g = fun ~y ~x -> x + y in
  print_int @@ g ~x:(print_string "hello"; 1)
                 ~y:(print_string "world"; 2)
