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
	* 根据untyped和fulluntyped中的内容，加入Chap5-7的定义；实现难点：context、shift、substitution (tmmap)
	* 仅支持INTV，和Chap3-4, 5-7中定义的Term、Evaluation、Shift、和Substitution规则
	* 支持x@：将x加入namecontext(use AT(@) to replace SLASH(/))
		* x@ (NameBind) 被解析文件<br>
		![image](https://github.com/codedjw/TAPL/raw/master/self-untyped/screenshot/NameBind被解析文件.png)
		* x@ (NameBind) 解析结果<br>
		![image](https://github.com/codedjw/TAPL/raw/master/self-untyped/screenshot/NameBind解析结果.png)

###Simply Typed lambda calculus (self-simply-typed)
* Definition
	* Project 2: extend arith + untyped lambda calculus with types
	* Types: Bool, Nat, T->T
	* Syntax: add \lambda x:T.t
	* First do type checking, and then remove types and evaluate your program by (arith + untyped lambda calculus)
	* No let statements.
* [Reference](http://www.cis.upenn.edu/~bcpierce/tapl/) 
	* Reference Book: [Type and Programming Languages](https://book.douban.com/subject/1761910/) 
	* simplebool: implement Chap9-10, untyped (Bool, ->)
	* 参考simplebool和fullsimple中的内容，加入Chap8的定义；实现难点：context、shift、substitution、TmAbs (tymap)
	* 不再支持x@；使用x:Bool （:Type）作为bind操作符，即将x:Bool作为VarBind加入context
		* :Type (VarBind) 被解析文件<br>
		![image](https://github.com/codedjw/TAPL/raw/master/self-simply-typed/screenshot/VarBind被解析文件.png)
		* :Type (VarBind) 解析结果<br>
		![image](https://github.com/codedjw/TAPL/raw/master/self-simply-typed/screenshot/VarBind解析结果.png)
	


##Change Log
###v2.0.1 (2016/05/10 17:08 +08:00)
* 删除prbindingty in main.ml (duplicated with prbinding)
* 删除TyBinder in parser.mly 和 TyVarBind in syntax.ml(mli) --> 现阶段不用？？

###v2.0.0 (2016/05/06 12:00 +08:00)
* 实现self-simply-typed主体部分，包括Chap8-10中的定义和规则

###v1.0.2 (2016/04/20 13:00 +08:00)
* [支持x@：将x加入namecontext](https://github.com/codedjw/TAPL/blob/master/README.md#untyped-lambda-calculus-self-untyped)

###v1.0.1 (2016/04/20 05:00 +08:00)
* 实现self-untyped主体部分，包括Chap3-4, 5-7中的定义的Term、Evaluation、Shift、和Substitution规则
