Higher kinded datatype
=============================

`'a 'b` <=> `('a, 'b) app`

module Monad(A : sig
  type 'a 'm
  val return : 'a -> 'a 'm
  val bind : 'a 'm -> ('a -> 'b 'm) -> 'b 'm
end) = struct
  include A
  let fmap f am = bind am (fun a -> return (f a))
end

module Monad(A : sig
  type ('a, 'm) app
  val return 'a -> ('a, 'm) app
  val bind : ('a, 'm) app -> ('a -> ('b, 'm) app) -> ('b, 'm) app
end) = struct
  include A
  let fmap f am = bind am (fun a -> return (f a))
end
