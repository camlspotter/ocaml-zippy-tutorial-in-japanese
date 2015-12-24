module M = struct let x = 1 end

let () =
  let x = 2 in
  print_int x;
  let open M in
  print_int x
