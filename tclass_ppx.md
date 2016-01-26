# Type class by ppx, ideas

## Class declaration

A class is declared as module type.

```ocaml
module type Num = sig
  type a
  val (+) : a -> a -> a
  val (-) : a -> a -> a
end
```

Parameters are declared as abstract types like `a`, `b`...
(Probably we should use a special name like `_a`, `_b`.)

Module type can be defined anywhere: it can be defined in a deeply nested module. But remember, the name for example `Num` is very important.

## Instance declaration

An instance is declared as a module.

```ocaml
module Int : Num with type a = int = sig
  type a = int
  let (+) = (+)
  let (-) = (-)
end
```

```ocaml
module Float : Num with type a = float = sig
  type a = int
  let (+) = (+.)
  let (-) = (-.)
end
```

The module types of instances need not to be declared, but
they must be a constrained version of the corresponding type class module type.
The instances can be declared anywhere: it can be defined in a deeply nested modules. Module names are not very important.

## Mixing instances

Instance resolution of overloaded values is to find an appropriate module
which matches with the context. OCaml module space is vast and even not fixed
therefore a clever way to restrict the search space is required.

Also, the instance candidates should be easily composed.

The idea: the instance candidates must be declared as submodules of
a module with the same name of the type class name:

```ocaml
module Num = struct
  module Int = Int
  module Float = Float
end






