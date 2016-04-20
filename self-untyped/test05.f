/* Examples for testing; some from fulluntyped */

/*/* recursive comments  */*/

if true then false else true;
if 1 then true else false;

/*
/* error case (Unbound Identifier) */
if x then false else true;
x;
*/

x@; /* add x to namecontext */
x;

if x then false else x; 

lambda x. x;
(lambda x. x) (lambda x. x x); 

0; 
succ (pred 0);
iszero (pred (succ (succ 0))); 

(lambda x. if x then true else false) 0;
(lambda x. if x then true else false) false;