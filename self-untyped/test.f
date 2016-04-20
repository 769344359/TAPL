/* test01.f */

true;
if false then true else false; 

0; 
succ (pred 0);
iszero (pred (succ (succ 0)));

/* Self Defined */
succ (succ 0);
if iszero(succ 0) then (succ 2) else (pred 5);
(pred 0);

/* test02.f */

true;
if false then true else false; 

if true then true else false;

lambda x. x;
(lambda x. x) (lambda x. x x); 

0; 
succ (pred 0);
iszero (pred (succ (succ 0))); 

(lambda x. if x then true else false) 0;

(lambda x. if x then true else false) true;

(lambda x. if x then true else false) false;

(lambda x. x) 100;

/* test03.f */

lambda x.x(lambda x.x);

(lambda x.x(lambda x.x))1;

/* test04.f and part of test05.f */

/*
/* error case (Unbound Identifier) */
if x then false else true;
x;
*/

x@; /* add x to namecontext */
x;

lambda x. x;
(lambda x. x) (lambda x. x x); 

if x then false else x; 

/* part of test05.f */

/*/* recursive comments  */*/

if true then false else true;
if 1 then true else false;

0; 
succ (pred 0);
iszero (pred (succ (succ 0))); 

(lambda x. if x then true else false) 0;
(lambda x. if x then true else false) false;