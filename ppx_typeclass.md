# ppx_typeclass

## type class declaration and entry points

```ocaml
module Num = struct
  module type Class = sig
    type a 
    val (+) : a -> a -> a
    val (-) : a -> a -> a
  end
  
  external (+) : ?d:(module Class with type a = 'a) -> 'a -> 'a -> 'a = "%OVERLOADED"
  external (-) : ?d:(module Class with type a = 'a) -> 'a -> 'a -> 'a = "%OVERLOADED"
end
```

## type class instance

```ocaml
module Int = struct
  type a = int
  let (+) = (+)
  let (-) = (-)
end

module Float = struct
  type a = float
  let (+) = (+.)
  let (-) = (-.)
end
```

## Use of overloaded values

```ocaml
Num.(+) 1.2 3.4    (*  =>  Num.(+) ~d:(module Float) 1.2 3.4 *)
```

The compiler got a code `Num.(+) ?d:(None : (module Class with type a = float) option) 1.2 3.4`. The task is to find a type class instance module whose type is `(module Class with type a = float)` or bigger.

## Derived overloading

Simple app cannot derive overloading:

```ocaml
let double x = Num.(+) x x    (* fails. ambiguous *)
```

The compiler got a code `Num.(+) ?d:(None : (module Class with type a = 'a) option) x x`, and failed to find an instance bigger than it.

It requires an explicit dispatching:

```ocaml
(* val double : (module Num.Class with type a = 'a) -> 'a -> 'a *)
let double ?d x = Num.(+) ?d x x
```

The compiler got a code `Num.(+) ?d:(Some d : (module Class with type a = 'a) option) x x`. Since the dispatch argument is not omitted, the compiler needs not to work on it.

## Type class with constraints

```ocaml
module Show = struct
  module type Class = sig
    type a
    val show : a -> string
  end
  
  external show : ?d:(module Class with type a = 'a) -> 'a -> string
end
```

```ocaml
module Int = struct
  type a = int
  let show = string_of_int
end
```

```ocaml
module List(A : Show.Class) = struct
  let a = (module A : Show.Class with type a = 'a)
  type a = A.a list
  let show xs =
    String.concat "" (List.map (Show.show ~d:a) xs)
end
```
