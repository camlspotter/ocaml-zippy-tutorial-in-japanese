let f ?(add=1) x = x + add

let twice g x = g (g x)

let () = print_int (twice f 0)
