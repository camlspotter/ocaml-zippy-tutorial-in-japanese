let (>>=) a b x = a x + b x
let id x = x
let (&) = (@@)
let f x = (|>) x & id >>= id
