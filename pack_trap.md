ocamlc -pack order glitch
===============================

Summary: be careful about the ordering of modules in `ocamlc -pack`, or you may lose type alias in a very strange way.

Related: type error, polymorphic variant, ocaml, pack

Library modules
--------------------------------

Suppose we have the following two `.ml` files.

```ocaml
(* result.ml *)
type ('a, 'error) t = [`Ok of 'a | `Error of 'error]
```

and

```ocaml
(* option.ml *)
let to_result : 'a option -> ('a, [>`None]) Result.t = function
  | Some v -> `Ok v
  | None -> `Error `None
```

Their build for a package `P` is quite straightforward:

```sh
$ ocamlc -for-pack P -c result.ml
$ ocamlc -for-pack P -c option.ml
```

Pack in wrong order
--------------------------------

Pack the object files into `p.cmo`, but in a **wrong order**:

```sh
$ ocamlc -pack -o p.cmo option.cmo result.cmo
```

Strange type error with the package
-------------------------------------

Now the modules are packed as `P`, therefore we can remove the original compiled files:

```sh
$ rm -f result.cm* option.cm*
```

Let's write an application:

```ocaml
(* test.ml *)
open P
  
let f v = match v with
  | Some 1 -> `Error `X
  | _ -> Option.to_result v
```

The compilation:

```sh
$ ocamlc -c test.ml
File "test.ml", line 5, characters 9-27:
Error: This expression has type (int, [> `None ]) Result.t
       but an expression was expected of type [> `Error of [> `X ] ]
```

This is strange. The function `f` must be typed as

```ocaml
val f : 'a option -> [`Error of [> `X | `None] | `Ok of int]
```

Why this happend?
-------------------------------------

Since the objects are packed in the **wrong order**:
	   
```sh
$ ocamlc -pack -o p.cmo option.cmo result.cmo
```

This makes a module `P` which is equivalent with the following code:

```ocaml
(* p.ml *)
module Option = struct
  let to_result : 'a option -> ('a, [>`None]) Result.t = function
    | Some v -> `Ok v
    | None -> `Error `None
end

module Result = struct
  type ('a, 'error) t = [`Ok of 'a | `Error of 'error]
end
```

The packed module is actually not self-contained:
the type `Result.t` in module `Option` is **not** the one defined in module `Result` in `p.ml`,
but is defined in `result.ml` outside of `P`.

Packages are normally installed without `.cmi` files of packed modules, as we have removed `result.cmi` and `option.cmi`.
Therefore, when using the package `P`, OCaml thinks that `Result.t` of the result type of `P.Option.t_result` is abstract.

How to fix this?
-------------------------------------

Simple. Packed modules in the **correct order**.

```sh
$ ocamlc -pack -o p.cmo result.cmo option.cmo 
```

Why this happend? AGAIN.
-------------------------------------

Wait, should OCaml reject such strange packing order?

Actually OCaml rejects strange packing orderings,
but **only when** the order violates value dependencies:

```ocaml
(* result.ml *)
type ('a, 'error) t = [`Ok of 'a | `Error of 'error]
let x = 1
```

```ocaml
(* option.ml *)
let to_result : 'a option -> ('a, [>`None]) Result.t = function
  | Some v -> `Ok v
  | None -> `Error `None
let x = Result.x
```

```sh
$ ocamlc -for-pack P -c result.ml
$ ocamlc -for-pack P -c option.ml
$ ocamlc -pack -o p.cmo option.cmo result.cmo    # wrong
File "_none_", line 1:
Error: Forward reference to Result in file option.cmo
```

But in the original example, `Option` has only type dependency over `Result`,
which seems to be insufficient to prevent the wrong packing.

OMake specific issue
-------------------------------------

Normally OMake is aware of module dependencies and reorder modules properly
at `OCamlPackage` and `OCamlLibrary` functions, but again, it is only when
there are value dependencies between modules.
The above example is not packed correctly in OMake if the module list is reversed.

I don't know whether other build tools automatically reorder the modules of this example...

