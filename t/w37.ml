module X : sig
  type t
end = struct
  type t = None_uses_this_type
end

module Y : sig
  type t
  val i : int
end = struct
  type t = Foo | None_uses_this_constructor

  let i = match Foo with
    | Foo -> 1
    | None_uses_this_constructor -> 2
end

