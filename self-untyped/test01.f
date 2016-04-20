/* Examples for testing */

true;
if false then true else false; 

0; 
succ (pred 0);
iszero (pred (succ (succ 0)));

/* Self Defined */
succ (succ 0);
if iszero(succ 0) then (succ 2) else (pred 5);
(pred 0);
