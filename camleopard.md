# What I do not like in OCaml

# Syntax

## Variant constructors should be functions

For example `map Some [1;2;3] = [Some 1; Some 2; Some 3]`.

## Record fields as functions

But I am against having real functions like Haskell. Say, `(.label)`?

## Making a simple closure requires too many chars to type

```
must_fail @@ fun () -> List.hd []
```

We need 14 chars!: ` @@ fun () -> `.

With lazy and `let & = @@`:

```
must_fail & lazy (List.hd [])
```

We need 10 chars: ` & lazy (` and `)`, but still too many and it requires
cursor moves.

## lazy take too many chars

`lazy` always require parens therefore we need 7 chars to make a thing
lazy: `lazy (` and `)`.

## @@ should be 1 character, and usable for non expressions too

Say, `$`, or `&`. And it is good not to be a function but a syntax construct:

```
(* In pattern *)
function
  | Some $ x, y -> ...
  | None -> ...
```

```
(* lazy *)
lazy $ raise Failure
```

## struct and sig sound scarely

They sound just horrible and I had no courage to use them 20 years ago.
Having two keywords for a module and its type is redundant except
paying some respect to the ML module system.

## Indentation rule

Moving cursors to put `begin` and `end` for nested `function`, `match`
and `if` is waste of time.

# Typing (or error reporting)

## ml and mli signature mismatch error should print related locations

```
In module Cf:
Values do not match:
  val concrete :
    Asttypes.override_flag ->
    Parsetree.expression -> Parsetree.class_field_kind
is not included in
  val concrete :
    ?override:bool ->
    Parsetree.expression -> Parsetree.class_field_kind
```
Ok, but where I should fix?

I know it is not easy to do, but I want it.

