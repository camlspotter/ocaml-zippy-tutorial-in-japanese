(*
module MG(A : sig
  type 'a 'm
  val return : 'a -> 'a 'm
  val bind : 'a 'm -> ('a -> 'b 'm) -> 'b 'm
end) = struct
  include A
  let fmap f am = bind am (fun a -> return (f a))
end
*)

module M1(A : sig
  type 'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end) = struct
  include A
  let fmap f am = bind am (fun a -> return (f a))
end

module M2(A : sig
  type ('a, 'm) app
  val return : 'a -> ('a, 'm) app
  val bind : ('a, 'm) app -> ('a -> ('b, 'm) app) -> ('b, 'm) app
end) = struct
  include A
  let fmap f am = bind am (fun a -> return (f a))
end

module Result = struct
  type ('res, 'error) t = 
    | Ok of 'res
    | Error of 'error

  type ('a, 'm) app = 
end
