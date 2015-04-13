# ppx_typeclass

## basic idea

* typable by the vanilla type checker (but requires transformation to execute properly)
* vanilla typing + transformation in ppx, then retype it by the vanilla again

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

Entry points for overloaded values are by `external = "%OVERLOADED`. Their use should be replaced by an instance value:

```ocaml
Num.(+) 1.2 3.4   =>   Float.(+) 1.2. 3.4        (* See the definition Float below *)
```

`Num.(+)` in the above is instantiated to `?d:(module Class with type a = float) -> float -> float -> float`.
Ppx finds `Float` instance module (somehow, see later sectioons) which maches with the type `module Class with type a = float`.
It also sees the value is `%OVERLOADED` external, in this case, the use of the overloaded value is replaced
by an identifier defined in the found instance module: `Float.(+) 1.2 3.4`.

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

Instance modules for `Num` are modules of instance module types of `Num.Class`. For openess of the overloading, those module can be defined anywhere.

## Derived overloading

Simple app cannot derive overloading:

```ocaml
let double x = Num.(+) x x    (* fails. ambiguous *)
```

The compiler got a code `Num.(+) ?d:(None : (module Class with type a = 'a) option) x x`, and failed to find an instance module whose module type maches with `module Class with type a = 'a`.

It requires an explicit dispatching:

```ocaml
(* val double : (module Num.Class with type a = 'a) -> 'a -> 'a *)
let double ?d x = Num.(+) ?d x x
```

Thus, the searching of instance module for `Num.(+)` is derived to one for `double`.
ppx can see this by looking at the `?d` argument of `Num.(+)`. 

The transformation of derived overloaded values are different from the overloaded entry points:

```ocaml
double ?d:(None : (module Num.Class with type a = float) option) 1.2  
=>  double ?d:(Some (module Float : Num.Class with type a = float)) 1.2
```

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
