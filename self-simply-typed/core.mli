(* module Core

   Core typechecking and evaluation functions
*)

open Syntax
open Support.Error

(* extended to untyped lambda calculus *)

val eval : context -> term -> term 

(* extended with simply typed lambda calculus *)

val typeof : context -> term -> ty
