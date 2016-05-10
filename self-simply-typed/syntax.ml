open Format
open Support.Error
open Support.Pervasive

(* ---------------------------------------------------------------------- *)
(* Datatypes *)

type ty = 
    TyVar of int * int
  | TyNat
  | TyBool
  | TyArrow of ty * ty

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

(* extended with untyped lambda calculus *)
type binding = 
    NameBind (* for printing and parsing *)
  | VarBind of ty (* for type checking *)
  
(* extended with untyped lambda calculus *)
type context = (string * binding) list

type command =
  | Eval of info * term
  (* extended with untyped lambda calculus *)
  | Bind of info * string * binding

(* ---------------------------------------------------------------------- *)
(* Context management *)

let emptycontext = []
let ctxlength ctx = List.length ctx
let addbinding ctx x bind = (x, bind)::ctx
let addname ctx x = addbinding ctx x NameBind
let index2name fi ctx i = 
  try
    let (i_n,_) = List.nth ctx i in
    i_n
  with Failure _ ->
    let msg =
      Printf.sprintf "Variable lookup failure: offset: %d, ctx size: %d" in
    error fi (msg i (List.length ctx))
 
let rec name2index fi ctx x =
  match ctx with
    [] -> error fi ("Identifier " ^ x ^ " is unbound")
  | (y,_)::rest -> 
      if y=x then 0
      else 1+ (name2index fi rest x)

let rec isnamebound ctx x = 
  match ctx with
    [] -> false
  | (y,_)::rest -> 
      if y=x then true
    else isnamebound rest x

(* ---------------------------------------------------------------------- *)
(* Helper Function *)
let rec pickfreshname ctx x = 
  if isnamebound ctx x then pickfreshname ctx (x^"'")
else ((x,NameBind)::ctx), x

(* ---------------------------------------------------------------------- *)
(* shifting and substitution *)
let tymap onvar c tyT = 
  let rec walk c tyT = match tyT with
    TyVar(x,n) -> onvar c x n
  | TyBool -> TyBool
  | TyNat -> TyNat
  | TyArrow(tyT1, tyT2) -> TyArrow(walk c tyT1,walk c tyT2)
  in walk c tyT

let tmmap onvar ontype c t =
  let rec walk c t = match t with (* d-place shift of a term t above cutoff c *)
    TmTrue(fi) as t -> t
  | TmFalse(fi) as t -> t
  | TmIf(fi,t1,t2,t3) -> TmIf(fi,walk c t1,walk c t2,walk c t3)
  | TmZero(fi)      -> TmZero(fi)
  | TmSucc(fi,t1)   -> TmSucc(fi, walk c t1)
  | TmPred(fi,t1)   -> TmPred(fi, walk c t1)
  | TmIsZero(fi,t1) -> TmIsZero(fi, walk c t1)
  (* P79 6.2.1 Rule01 *)
  | TmVar(fi,x,n) -> onvar fi c x n
  (* P79 6.2.1 Rule02 and extended with simply typed lambda calculus *)
  | TmAbs(fi,x,tyT1,t2) -> TmAbs(fi,x,ontype c tyT1,walk (c+1) t2) (* simply typed *)
   (* P79 6.2.1 Rule03 *) 
  | TmApp(fi,t1,t2) -> TmApp(fi, walk c t1, walk c t2)
  in walk c t

(* support x@ / x\ *)
let typeShiftAbove d c tyT =
  tymap
    (fun c x n -> if x>=c then TyVar(x+d,n+d) else TyVar(x,n+d))
    c tyT

let termShiftAbove d c t = 
  tmmap
    (* P79 6.2.1 Rule01 判断 *)
    (fun fi c x n -> if x>=c then TmVar(fi,x+d,n+d) 
                     else TmVar(fi, x, n+d))
    (typeShiftAbove d) (* simply typed lambda calculus *)
    c t

let termShift d t = termShiftAbove d 0 t (* P79 6.2.1 We write 箭头d(t) for 箭头(0,d)(t) *)

let typeShift d tyT = typeShiftAbove d 0 tyT

(* added *)
let bindingshift d bind =
  match bind with
    NameBind -> NameBind
  | VarBind(tyT) -> VarBind(typeShift d tyT)
(*  P80 6.2.4 *)
let termSubst j s t =
  tmmap
    (fun fi c x n -> if x=j+c then termShift c s else TmVar(fi,x,n))
    (* simply typed lambda calculusm *)
    (fun j tyT -> tyT)
    j t

(* P81 E-APPABS *)
let termSubstTop s t = 
  termShift (-1) (termSubst 0 (termShift 1 s) t)

let typeSubst tyS j tyT =
  tymap
    (fun j x n -> if x=j then (typeShift j tyS) else (TyVar(x,n)))
    j tyT

let typeSubstTop tyS tyT = 
  typeShift (-1) (typeSubst (typeShift 1 tyS) 0 tyT)

let rec tytermSubst tyS j t =
  tmmap (fun fi c x n -> TmVar(fi,x,n))
        (fun j tyT -> typeSubst tyS j tyT) j t

let tytermSubstTop tyS t = 
  termShift (-1) (tytermSubst (typeShift 1 tyS) 0 t)

(* context management continued *)
let rec getbinding fi ctx i =
  try
    let (_,bind) = List.nth ctx i in
    bindingshift (i+1) bind
  with Failure _ -> 
    let msg = 
      Printf.sprintf "Variable lookup failure: offset: %d, ctx size: %d" in
    error fi (msg i (List.length ctx))

(* extended with simply typed lambda calculus *)
let getTypeFromContext fi ctx i =
  match getbinding fi ctx i with
    VarBind(tyT) -> tyT
  | _ -> error fi ("getTypeFromContext: Wrong kind of binding for variable " 
        ^ (index2name fi ctx i))

(* ---------------------------------------------------------------------- *)
(* Extracting file info *)

let tmInfo t = match t with
    TmTrue(fi) -> fi
  | TmFalse(fi) -> fi
  | TmIf(fi,_,_,_) -> fi
  | TmZero(fi) -> fi
  | TmSucc(fi,_) -> fi
  | TmPred(fi,_) -> fi
  | TmIsZero(fi,_) -> fi 
  (* extended with untyped lambda calculus 对应term的类型定义 *)
  | TmVar(fi,_,_) -> fi
  | TmAbs(fi,_,_,_) -> fi (* simply typed *)
  | TmApp(fi,_,_) -> fi

(* ---------------------------------------------------------------------- *)
(* Printing *)

(* The printing functions call these utility functions to insert grouping
  information and line-breaking hints for the pretty-printing library:
     obox   Open a "box" whose contents will be indented by two spaces if
            the whole box cannot fit on the current line
     obox0  Same but indent continuation lines to the same column as the
            beginning of the box rather than 2 more columns to the right
     cbox   Close the current box
     break  Insert a breakpoint indicating where the line maybe broken if
            necessary.
  See the documentation for the Format module in the OCaml library for
  more details. 
*)

let obox0() = open_hvbox 0
let obox() = open_hvbox 2
let cbox() = close_box()
let break() = print_break 0 0

let small t = 
  match t with
    TmVar(_,_,_) -> true
  | _ -> false


(* extended with simply typed lambda calculus; print type *)
let rec printty_Type outer ctx tyT = 
  match tyT with
    tyT -> printty_ArrowType outer ctx tyT

and printty_ArrowType outer ctx tyT = 
  match tyT with
    TyArrow(tyT1, tyT2) -> 
      obox0();
      printty_AType false ctx tyT1;
      if outer then pr " ";
      pr "->";
      if outer then print_space() else break();
      (* Bool -> Nat -> Bool ... *)
      printty_ArrowType outer ctx tyT2;
      cbox()
  | tyT -> printty_AType outer ctx tyT

and printty_AType outer ctx tyT = 
  match tyT with
    TyNat -> pr "Nat"
  | TyBool -> pr "Bool"
  | TyVar(x,n) ->
      if ctxlength ctx = n then
        pr (index2name dummyinfo ctx x)
      else
        pr ("[bad index: " ^ (string_of_int x) ^ "/" ^ (string_of_int n)
            ^ " in {"
            ^ (List.fold_left (fun s (x,_) -> s ^ " " ^ x) "" ctx)
            ^ " }]")
  | tyT -> pr "("; printty_Type outer ctx tyT; pr ")"

let printty ctx tyT = printty_Type true ctx tyT

(* 根据AST递归打印 *)
let rec printtm_Term outer ctx t = match t with
    TmIf(fi, t1, t2, t3) ->
       obox0();
       pr "if ";
       printtm_Term false ctx t1;
       print_space();
       pr "then ";
       printtm_Term false ctx t2;
       print_space();
       pr "else ";
       printtm_Term false ctx t3;
       cbox()
  (* 带格式化输出 *)
  (* simply typed *)
  | TmAbs(fi, x, tyT1, t2) ->
      (let (ctx',x') = (pickfreshname ctx x) in
            obox(); pr "lambda "; 
            pr x'; pr ":"; printty_Type false ctx tyT1; pr ".";
            if (small t2) && not outer then break() else print_space();
            printtm_Term outer ctx' t2;
            cbox())
  | t -> printtm_AppTerm outer ctx t

and printtm_AppTerm outer ctx t = match t with
    TmApp(fi, t1, t2) ->
        obox0();
        printtm_AppTerm false ctx t1;
        print_space();
        printtm_ATerm false ctx t2;
        cbox();
  | TmPred(_,t1) ->
       pr "pred "; printtm_ATerm false ctx t1
  | TmIsZero(_,t1) ->
       pr "iszero "; printtm_ATerm false ctx t1
  | t -> printtm_ATerm outer ctx t

and printtm_ATerm outer ctx t = match t with
    TmTrue(_) -> pr "true"
  | TmFalse(_) -> pr "false"
  | TmVar(fi,x,n) ->
       if ctxlength ctx = n then 
          pr (index2name fi ctx x)
       else
          pr ("[bad index: " ^ (string_of_int x) ^ "/" ^ (string_of_int n)
            ^ " in {"
            ^ (List.fold_left (fun s (x,_) -> s ^ " " ^ x) "" ctx)
            ^ " }]")
  | TmZero(fi) ->
       pr "0"
  | TmSucc(_,t1) ->
     let rec f n t = match t with
         TmZero(_) -> pr (string_of_int n)
       | TmSucc(_,s) -> f (n+1) s
       | _ -> (pr "(succ "; printtm_ATerm false ctx t1; pr ")")
     in f 1 t1
  | t -> pr "("; printtm_Term outer ctx t; pr ")"

let printtm ctx t = printtm_Term true ctx t 

let prbinding ctx b = match b with
    NameBind -> ()
  | VarBind(tyT) -> pr ": "; printty ctx tyT

