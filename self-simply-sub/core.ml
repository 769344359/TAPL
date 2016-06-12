open Format
open Syntax
open Support.Error
open Support.Pervasive

(* ------------------------   EVALUATION  ------------------------ *)

exception NoRuleApplies

let rec isnumericval ctx t = match t with
    TmZero(_) -> true
  | TmSucc(_,t1) -> isnumericval ctx t1
  | _ -> false

let rec isval ctx t = match t with
    TmTrue(_)  -> true
  | TmFalse(_) -> true
  | t when isnumericval ctx t  -> true
  | TmAbs(_,_,_,_) -> true (* simply typed *)
  (* Record *)
  | TmRecord(_,fields) -> List.for_all (fun (l,ti) -> isval ctx ti) fields
  | _ -> false

(* merged version of P87 7.3 (untyped lambda calculus) and P47 4.2 (untyped arith) *)
let rec eval1 ctx t = match t with
    TmIf(_,TmTrue(_),t2,t3) ->
      t2
  | TmIf(_,TmFalse(_),t2,t3) ->
      t3
  | TmIf(fi,t1,t2,t3) ->
      let t1' = eval1 ctx t1 in
      TmIf(fi, t1', t2, t3)
  | TmSucc(fi,t1) ->
      let t1' = eval1 ctx t1 in
      TmSucc(fi, t1')
  | TmPred(_,TmZero(_)) ->
      TmZero(dummyinfo)
  | TmPred(_,TmSucc(_,nv1)) when (isnumericval ctx nv1) ->
      nv1
  | TmPred(fi,t1) ->
      let t1' = eval1 ctx t1 in
      TmPred(fi, t1')
  | TmIsZero(_,TmZero(_)) ->
      TmTrue(dummyinfo)
  | TmIsZero(_,TmSucc(_,nv1)) when (isnumericval ctx nv1) ->
      TmFalse(dummyinfo)
  | TmIsZero(fi,t1) ->
      let t1' = eval1 ctx t1 in
      TmIsZero(fi, t1')
  (* belta reduction: E-APPABS P72 *)
  (* simply typed *)
  | TmApp(fi, TmAbs(_,x,tyT11,t12), v2) when isval ctx v2 ->
      termSubstTop v2 t12
  (* P72 E-APP2 *)
  | TmApp(fi, v1, t2) when isval ctx v1 -> 
      let t2' = eval1 ctx t2 in 
      TmApp(fi, v1, t2')
  (* P72 E-APP1 *)
  | TmApp(fi, t1, t2) ->
      let t1' = eval1 ctx t1 in 
      TmApp(fi, t1', t2)
  | TmRecord(fi, fields) ->
      let rec evalafield l = match l with
        [] -> raise NoRuleApplies
      (* E-RCD *)
      | (l,vi)::rest when isval ctx vi ->
        let rest' = evalafield rest in 
        (l,vi)::rest'
      (* E-RCD *)
      | (l,ti)::rest ->
        let ti' = eval1 ctx ti in 
        (l,ti')::rest
      in let fields' = evalafield fields in
      TmRecord(fi, fields')
  (* E-PROJRCD *)
  | TmProj(fi, (TmRecord(_, fields) as v1), l) when isval ctx v1 ->
      (try List.assoc l fields
       with Not_found -> raise NoRuleApplies)
  (* E-PROJ *)
  | TmProj(fi, t1, l) ->
      let t1' = eval1 ctx t1 in
      TmProj(fi, t1', l)
  | _ -> 
      raise NoRuleApplies

let rec eval ctx t =
  try let t' = eval1 ctx t
      in eval ctx t'
  with NoRuleApplies -> t

(* ------------------------ SUBTYPING --------------------------------------- *)

(* P222 *)
let rec subtype ctx tyS tyT = 
  (=) tyS tyT ||
  match (tyS, tyT) with
    (TyRecord(fS), TyRecord(fT)) -> 
      List.for_all
        (fun (li, tyTi) -> 
          try let tySi = List.assoc li fS in 
              subtype ctx tySi tyTi
          with Not_found -> false)
      fT
  | (_, TyTop) -> true
  | (TyArrow(tyS1, tyS2), TyArrow(tyT1, tyT2)) -> 
    (subtype ctx tyT1 tyS1) && (subtype ctx tyS2 tyT2)
  | (_, _) -> false

(* ------------------------ TYPING --------------------------------------- *)

(* extended with simply typed lambda calculus *)
(* implement inversion lemma 9.3.1 *)
let rec typeof ctx t = 
  match t with
    TmRecord(fi, fields) ->
      let fieldtys = 
        List.map (fun (li,ti) -> (li, typeof ctx ti)) fields in
      TyRecord(fieldtys)
  | TmProj(fi, t1, l) ->
    (match (typeof ctx t1) with
      TyRecord(fieldtys) -> 
        (try List.assoc l fieldtys
         with Not_found -> error fi ("label "^l^" not found"))
    | _ -> error fi "expected record type")
  | TmVar(fi, i, _) -> getTypeFromContext fi ctx i (* because of nameless *)
  | TmAbs(fi, x, tyT1, t2) ->
      let ctx' = addbinding ctx x (VarBind(tyT1)) in 
      let tyT2 = typeof ctx' t2 in 
      TyArrow(tyT1, tyT2)
  | TmApp(fi, t1, t2) -> 
      let tyT1 = typeof ctx t1 in 
      let tyT2 = typeof ctx t2 in 
      (
        match tyT1 with
        | TyArrow(tyT11, tyT12) ->
            (* TA-APP in P217 *) 
            if subtype ctx tyT2 tyT11 then tyT12
            else error fi "paramter type mismatch"
        | _ -> error fi "arrow type expected"
      )
  | TmTrue(fi) -> TyBool
  | TmFalse(fi) -> TyBool
  | TmIf(fi,t1,t2,t3) ->
      if (=) (typeof ctx t1) TyBool then 
        let tyT2 = typeof ctx t2 in 
        if (=) (typeof ctx t3) tyT2 then tyT2
        else error fi "branches of conditional have different types"
      else error fi "guard of conditional not a booolean"
  (* this part below is for TyNat *)
  (* implementation of LEMMA 8.2.2 INVERSION OF THE TYPING RELATION *)
  | TmZero(fi) -> TyNat
  | TmSucc(fi, t1) -> 
      if (=) (typeof ctx t1) TyNat then TyNat
      else error fi "argument of succ is not a number"
  | TmPred(fi, t1) ->
      if (=) (typeof ctx t1) TyNat then TyNat
      else error fi "argument of pred is not a number"
  | TmIsZero(fi, t1) -> 
      if (=) (typeof ctx t1) TyNat then TyBool
      else error fi "argument of iszero is not a number" 