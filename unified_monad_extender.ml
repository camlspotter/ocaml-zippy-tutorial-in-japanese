(* Start from a typical Monad interface *)
module type Monad = sig
  type 'a m
  val return : 'a -> 'a m
  val bind : 'a m -> ('a -> 'b m) -> 'b m
end
  
(* From the minimum requirements, we extend the monad module.
   Here as a small example, let's add [fmap]. 
*)

(* The extended interface *)
module type Extend = sig
  type 'a m
  val fmap : ('a -> 'b) -> 'a m -> 'b m
end

(* And implementation of [fmap], using the primitives. Quite normal. *)  
module Extend(M : Monad) : Extend with type 'a m := 'a M.m = struct
  open M
  let fmap f m = bind m (fun a -> return (f a))
end
  
(* Implementation of option and its monad, using the above tools.
   Very normal.
*)
module Option = struct
  type 'a t = 'a option

  module Monad = struct
    type 'a m = 'a t
    let return x = Some x
    let bind m f = match m with
      | None -> None
      | Some a -> f a
  end

  include Monad
  include Extend(Monad)
end

(* Now think about the monad of [result] (Either in Haskell).
   Since [result] has two type parameters, [('a, 'error) result],
   we cannot use the module type [Monad]. Instead, we have to define
   the following [Monad2] with 2 parameters:
*)
module type Monad2 = sig
  type ('a, 'x) m
  val return : 'a -> ('a, 'x) m
  val bind : ('a, 'x) m -> ('a -> ('b, 'x) m) -> ('b, 'x) m
end
  
(* We here need to define [Extend2] for [Monad2].
   This is the problem: we have to write the same function definition
   for [fmap]:
*)
module Extend2(M : Monad2) : sig
  open M
  val fmap : ('a -> 'b) -> ('a, 'x) m -> ('b, 'x) m
end = struct
  include M
  let fmap f m = bind m (fun a -> return (f a))
end
  
(* Implementation of result monad, using [Extend2] *)
module Result = struct
  type ('a, 'err) t = Ok of 'a | Error of 'err

  module Monad = struct
    type ('a, 'err) m = ('a, 'err) t
    let return x = Ok x
    let bind m f = match m with
      | Error e -> Error e
      | Ok a -> f a
  end

  include Monad
  include Extend2(Monad)
end

(* Is it possible to unify these [Extend] and [Extend2]?
   Actually it is possible. Use [Extend2] for the option monad:
*)
module Option' = struct
  type 'a t = 'a option

  module Monad = struct
    type ('a, _ (* this parameter is dummy *)) m = 'a t
    let return x = Some x
    let bind m f = match m with
      | None -> None
      | Some a -> f a
  end

  include Monad
  include (Extend2(Monad) : Extend with type 'a m := 'a t)
    (* This module type constraint is not required but 
       it helps to get a clearner signature. *)
end
