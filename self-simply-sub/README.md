## Simply Typed Lambda Calculus with Record and Subtyping
###定义

* Project 3: extend arith + simply typed lambda calculus with records and subtypes
* Types: add {l1:T1,l2:T2,...,ln:Tn}, Top
* Syntax: add {l1=t1,l2=t2,...,ln=tn}
* Use algorithmic subtyping and typing rules, and do not change the typing rule for if-then-else.

###执行方法
* 使用make生成可执行文件f
* 测试方法：

```
./f <test file> (eg: ./f test.f)
make test
```
* 测试文件：test.f
* 测试文件描述：

Module| Test Case && Result
-----|--------------------
<b>Record and Projection</b>|<b>[In]</b> {x=true, y=false}; <br><b>[Out]</b> {x=true, y=false} : {x:Bool, y:Bool}<br><br><b>[In]</b> {x=true, y=false}.x; <br><b>[Out]</b> true : Bool<br><br><b>[In]</b> {succ 1, false}; <br><b>[Out]</b> {2, false} : {Nat, Bool}<br><br><b>[In]</b> {0, false}.1;<br><b>[Out]</b> 0 : Nat<br><br><b>[In]</b> if true then {x=true,y=false,a=false} else {x=false,y=true,a=true};<br><b>[Out]</b> {x=true, y=false, a=false} : {x:Bool, y:Bool, a:Bool}<br>
<b>TA-APP</b>|<b>[In]</b> lambda x:{a:Nat}. x.a;<br><b>[Out]</b> (lambda x:{a:Nat}. x.a) : {a:Nat} -> Nat<br><br><b>[In]</b> (lambda x:{a:Nat}. x.a){b=false, a=1};<br><b>[Out]</b> 1 : Nat<br>
<b>Top</b>|<b>[In]</b> lambda x:{a:Top}. x.a;<br><b>[Out]</b> (lambda x:{a:Top}. x.a) : {a:Top} -> Top<br><br><b>[In]</b> lambda x:Top. x;<br><b>[Out]</b> (lambda x:Top. x) : Top -> Top<br><br><b>[In]</b> (lambda x:Top. x) (lambda x:Top. x);<br><b>[Out]</b> (lambda x:Top. x) : Top<br><br><b>[In]</b> (lambda x:Top->Top. x) (lambda x:Top. x);<br><b>[Out]</b> (lambda x:Top. x) : Top -> Top<br>
<b>More Complex Examples: Subtyping + Record + lambda</b>|<b>[In]</b> lambda r:{x:Top->Top}. r.x r.x;<br><b>[Out]</b> (lambda r:{x:Top->Top}. r.x (r.x)) : {x:Top->Top} -> Top<br><br><b>[In]</b> {x=lambda z:Top.z, y=lambda z:Top.z};<br><b>[Out]</b> {x=lambda z:Top.z, y=lambda z:Top.z} : {x:Top->Top, y:Top->Top}<br><br><b>[In]</b> {x=lambda z:Top.0, y=lambda z:Top.true};<br><b>[Out]</b> {x=lambda z:Top.z, y=lambda z:Top.z} : {x:Top->Top, y:Top->Top}<br><br><b>[In]</b> (lambda r:{x:Top->Top}. r.x r.x) {x=lambda z:Top.z, y=lambda z:Top.z}; <br><b>[Out]</b> (lambda z:Top. z) : Top<br><br><b>[In]</b> (lambda r:{x:Top->Top}. r.x r.x) {x=lambda z:Top.0, y=lambda z:Top.true};<br><b>[Out]</b> 0 : Top<br>

