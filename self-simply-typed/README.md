## Simply Typed Lambda Calculus
---
###定义
* Project 2: extend arith + untyped lambda calculus with types
* Types: Bool, Nat, T->T
* Syntax: add \lambda x:T.t
* First do type checking, and then remove types and evaluate your program by (arith + untyped lambda calculus)
* No let statements.

###执行方法
* 使用make生成可执行文件f
* 测试方法：./f 测试文件（或make test，即执行./f test.f）
* 测试文件：test.f
* 测试文件描述：定义了常见的simply typed arithmetic expression和simply typed lambda calculus
* 注：不再使用@作为bind操作符，比如x@即将x加入context；使用x:Bool （:Type）作为bind操作符，即将x:Bool作为VarBind加入context