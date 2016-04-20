# TAPL
Lambda Calculus Implementation in OCaml（程序语言理论项目汇总）

##Overview（文件结构）
###Untyped lambda calculus (self-untyped)
* Extend [arith](http://www.cis.upenn.edu/~bcpierce/tapl/) with arith with untyped lambda calculus
* [Reference](http://www.cis.upenn.edu/~bcpierce/tapl/) 
	* Reference Book: [Type and Programming Languages](https://book.douban.com/subject/1761910/) 
	* arith: implement Chap3-4, untyped
	* untyped: implement Chap5-7, untyped
	* fulluntyped: implement Chap3-4, 5-7, 11, untyped
* Implementation
	* 参考arith
	* 根据untyped和fulluntyped中的内容，加入Chap5-7的定义；实现难点：context、shift、substitution
	* 仅支持INTV，和Chap3-4, 5-7中定义的Term、Evaluation、Shift、和Substitution规则
	* 支持x/：将x加入namecontext
		* x/ 被解析文件<br>
		![x:被解析文件](https://github.com/codedjw/TAPL/blob/master/self-untyped/screenshot/x:被解析文件.png, "x:被解析文件")
		* x/ 解析结果<br>
		![image](https://github.com/codedjw/TAPL/raw/master/self-untyped/screenshot/x:解析结果.png)


##Change Log
###v1.0.1 (2016/04/20 05:00 +08:00)
* 实现self-untyped主体部分，包括Chap3-4, 5-7中的定义的Term、Evaluation、Shift、和Substitution规则

###v1.0.2 (2016/04/20 13:00 +08:00)
* [支持x/：将x加入namecontext](https://github.com/codedjw/TAPL/blob/master/README.md#untyped-lambda-calculus-self-untyped)
