/* Examples for testing */

true;
if false then true else false; 

if true then false else false;

lambda x. x;
(lambda x. x) (lambda x. x x); 

0; 
succ (pred 0);
iszero (pred (succ (succ 0))); 

(lambda x. if x then true else false) 0;

(lambda x. if x then true else false) true;

(lambda x. if x then true else false) false;

(lambda x. x) 100;