open Printf

let () =
  let x = max_int in
  printf "max_int=%d\n%!" x;
  let s = Marshal.from_string (Marshal.to_string x []) 0 in
  printf "max_int=%d\n%!" s



  
