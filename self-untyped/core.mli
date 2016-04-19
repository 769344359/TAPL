(* module Core

   Core typechecking and evaluation functions
*)

open Syntax
open Support.Error

(* extended to untyped lambda calculus *)

val eval : context -> term -> term 
