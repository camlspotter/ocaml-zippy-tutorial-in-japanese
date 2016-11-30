exception Error

type token = 
  | WORD
  | START


val statement: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (int)