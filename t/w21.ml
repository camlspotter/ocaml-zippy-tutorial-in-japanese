let rec loop () = loop ()

let () = loop (); print_string "exited from the inf loop!"
