/* Examples for testing */

succ 0;
pred 2;
true;
false;
2;
iszero (succ 0);
lambda x:Bool. x;

if true then 0 else 1;

(lambda x:Bool->Bool. if x false then true else false) 
   (lambda x:Bool. if x then false else true);

y : Bool;
x : Nat;
lambda x:Bool->Nat.x y;

(lambda x:Nat->Bool. if x 0 then succ(succ 0) else pred(succ 0))
	(lambda x:Nat. if iszero x then true else false);

(lambda x:Bool->Bool. if x false then succ(succ 0) else pred(succ 0))
	(lambda x:Bool. if x then true else false);

z:Bool;
if z then true else false;

x : Bool;
(lambda y:Bool->Bool. y x) (lambda x:Bool. x); /* (lambda y:Bool->Bool. y false) (lambda x:Bool. x); */

(lambda x:Bool. if x then true else false) false;

/* error check */
/* iszero (succ true); */ /* argument of succ is not a number */
/*lambda x:Bool->Nat. x x;*/ /* not well-typed */
/*lambda x.x;*/ /* not specify arg type */
/*y@;*/ /* no namebind in simply typed lambda calculus; use (: Type) which means VarBind to replace it */
