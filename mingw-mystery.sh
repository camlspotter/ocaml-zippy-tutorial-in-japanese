#!/bin/sh

X=`ocamlfind query unix`
echo X="$X"
Y="-I $X hello"
echo Y=$Y
ocaml $Y
