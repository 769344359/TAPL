(* module Syntax: syntax trees and associated support functions *)

open Support.Pervasive
open Support.Error

(* Data type definitions *)
type ty = 
    TyVar of int * int
  | TyNat
  | TyBool
  | TyArrow of ty * ty
  (* Subtyping *)
  | TyTop
  | TyRecord of (string * ty) list


type term =
    TmTrue of info
  | TmFalse of info
  | TmIf of info * term * term * term
  | TmZero of info
  | TmSucc of info * term
  | TmPred of info * term
  | TmIsZero of info * term
  (* extended with untyped lambda calculus *)
  | TmVar of info * int * int
  | TmAbs of info * string * ty * term (* simply typed *)
  | TmApp of info * term * term
  (* Record in Subtyping *)
  | TmRecord of info * (string * term) list
  | TmProj of info * term * string

(* extended with simply typed lambda calculus *)
type binding = 
    NameBind (* no typing assumptions; for printing and parsing *)
  | VarBind of ty (* typing assumptions; for type checking *)
  
type command =
  | Eval of info * term
  (* extended with untyped lambda calculus *)
  | Bind of info * string * binding


type context
(* Printing : (* extended with untyped lambda calculus *) *)
(*val printtm: term -> unit*)
val printtm: context -> term -> unit
(*val printtm_ATerm: bool -> term -> unit*)
val printtm_ATerm: bool -> context -> term -> unit
val printty: context -> ty -> unit

(* Misc *)
val tmInfo: term -> info

(* extended with untyped lambda calculus are as follows *)

(* shifting and substitution *)
val termShift: int -> term -> term
val termSubstTop: term -> term -> term
(* extended with simply typed lambda calculus *)
val typeShift : int -> ty -> ty
val typeSubstTop: ty -> ty -> ty
val tytermSubstTop: ty -> term -> term

(* contexts *)
(* extended with untyped lambda calculus *)
val emptycontext : context (* params: context; returns void *)
val ctxlength : context -> int (* params: context; returns int *)
val addbinding : context -> string -> binding -> context (* params: context, string, binding; returns context *)
val addname: context -> string -> context (* params: context, string; returns context *)
val index2name : info -> context -> int -> string (* params: info, context, int; returns string *)
val getbinding : info -> context -> int -> binding (* params: info, context, int; returns binding *)
val name2index : info -> context -> string -> int (* params: info, context, string; returns int *)
val isnamebound : context -> string -> bool (* params: context, string; returns bool *)
val prbinding : context -> binding -> unit (* params: context, binding; returns unit *)
(* extended with simply typed lambda calculus *)
(* defined in P114 *)
val getTypeFromContext : info -> context -> int -> ty