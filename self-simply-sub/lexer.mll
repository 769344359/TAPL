(* 
   The lexical analyzer: lexer.ml is generated automatically
   from lexer.mll.
   
   The only modification commonly needed here is adding new keywords to the 
   list of reserved words at the top.  
*)

{
open Support.Error

let reservedWords = [
  (* Keywords *)
  ("if", fun i -> Parser.IF i);
  ("then", fun i -> Parser.THEN i);
  ("else", fun i -> Parser.ELSE i);
  ("true", fun i -> Parser.TRUE i);
  ("false", fun i -> Parser.FALSE i);
  ("succ", fun i -> Parser.SUCC i);
  ("pred", fun i -> Parser.PRED i);
  ("iszero", fun i -> Parser.ISZERO i);
  (* extended with untyped lambda calculus *)
  ("lambda", fun i -> Parser.LAMBDA i);
  (* extended with simply typed lambda calculus *)
  ("Bool", fun i -> Parser.BOOL i);
  ("Nat", fun i -> Parser.NAT i);
  (* Subtyping *)
  ("Top", fun i -> Parser.TTOP i);
  
  (* Symbols *)
  ("_", fun i -> Parser.USCORE i);
  ("'", fun i -> Parser.APOSTROPHE i);
  ("\"", fun i -> Parser.DQUOTE i);
  ("!", fun i -> Parser.BANG i);
  ("#", fun i -> Parser.HASH i);
  ("$", fun i -> Parser.TRIANGLE i);
  ("*", fun i -> Parser.STAR i);
  ("|", fun i -> Parser.VBAR i);
  (".", fun i -> Parser.DOT i);
  (";", fun i -> Parser.SEMI i);
  (",", fun i -> Parser.COMMA i);
  ("/", fun i -> Parser.SLASH i); (* use AT(@) to replace SLASH(/) *)
  (":", fun i -> Parser.COLON i);
  ("::", fun i -> Parser.COLONCOLON i);
  ("=", fun i -> Parser.EQ i);
  ("==", fun i -> Parser.EQEQ i);
  ("[", fun i -> Parser.LSQUARE i); 
  ("<", fun i -> Parser.LT i);
  ("{", fun i -> Parser.LCURLY i); 
  ("(", fun i -> Parser.LPAREN i); 
  ("<-", fun i -> Parser.LEFTARROW i); 
  ("{|", fun i -> Parser.LCURLYBAR i); 
  ("[|", fun i -> Parser.LSQUAREBAR i); 
  ("}", fun i -> Parser.RCURLY i);
  (")", fun i -> Parser.RPAREN i);
  ("]", fun i -> Parser.RSQUARE i);
  (">", fun i -> Parser.GT i);
  ("|}", fun i -> Parser.BARRCURLY i);
  ("|>", fun i -> Parser.BARGT i);
  ("|]", fun i -> Parser.BARRSQUARE i);
  ("@", fun i -> Parser.AT i); (* use AT(@) to replace SLASH(/) *)

  (* Special compound symbols: *)
  (":=", fun i -> Parser.COLONEQ i);
  ("->", fun i -> Parser.ARROW i);
  ("=>", fun i -> Parser.DARROW i);
  ("==>", fun i -> Parser.DDARROW i);
]

(* Support functions *)

type buildfun = info -> Parser.token
(* 创建符号表 *)
let (symbolTable : (string,buildfun) Hashtbl.t) = Hashtbl.create 1024
(* 遍历保留关键字列表，加入symbolTable *)
let _ =
  List.iter (fun (str,f) -> Hashtbl.add symbolTable str f) reservedWords

let createID i str =
  try (Hashtbl.find symbolTable str) i
  with _ ->
    if (String.get str 0) >= 'A' && (String.get str 0) <= 'Z' then
       Parser.UCID {i=i;v=str}
    else 
       Parser.LCID {i=i;v=str}

(* 定义行号、comment层次 *)
let lineno   = ref 1
and depth    = ref 0
and start    = ref 0

and filename = ref ""
and startLex = ref dummyinfo

let create inFile stream =
  if not (Filename.is_implicit inFile) then filename := inFile
  else filename := Filename.concat (Sys.getcwd()) inFile;
  lineno := 1; start := 0; Lexing.from_channel stream

(* Lexing.lexeme_start lexbuf
Return the absolute position in the input text of the beginning of the matched string (i.e. the offset of the first character of the matched string). The first character read from the input text has offset 0. *)
let newline lexbuf = incr lineno; start := (Lexing.lexeme_start lexbuf)

(* Lexing.lexeme_start lexbuf
Return the absolute position in the input text of the beginning of the matched string (i.e. the offset of the first character of the matched string). The first character read from the input text has offset 0. *)
let info lexbuf =
  createInfo (!filename) (!lineno) (Lexing.lexeme_start lexbuf - !start)
(* Lexing.lexeme lexbuf
Return the matched string. *)
let text = Lexing.lexeme

let stringBuffer = ref (String.create 2048)
let stringEnd = ref 0

let resetStr () = stringEnd := 0

let addStr ch =
  let x = !stringEnd in
  let buffer = !stringBuffer
in
  if x = String.length buffer then
    begin
      let newBuffer = String.create (x*2) in
      String.blit buffer 0 newBuffer 0 x;
      String.set newBuffer x ch;
      stringBuffer := newBuffer;
      stringEnd := x+1
    end
  else
    begin
      String.set buffer x ch;
      stringEnd := x+1
    end

let getStr () = String.sub (!stringBuffer) 0 (!stringEnd)

let extractLineno yytext offset =
  int_of_string (String.sub yytext offset (String.length yytext - offset))
}


(* The main body of the lexical analyzer *)

rule main = parse (* main stage *)
  (* match: ' ' \t \f *)
  [' ' '\009' '\012']+     { main lexbuf }
  (* match: ...\r\n 换行 *)
| [' ' '\009' '\012']*("\r")?"\n" { newline lexbuf; main lexbuf }
  (* 在main stage中出现*/，报错，证明没有/*，因为如果有/*则会进入comment stage *)
| "*/" { error (info lexbuf) "Unmatched end of comment" }
  (* 设置comment depth为1，设置startLex，转为comment stage直至解析结束后，转回main stage *)
| "/*" { depth := 1; startLex := info lexbuf; comment lexbuf; main lexbuf }
  (* 解析line number，match "# 2": 2; "abc\n# 2": error *)
| "# " ['0'-'9']+
    { lineno := extractLineno (text lexbuf) 2 - 1; getFile lexbuf }
  (* 解析line number，match "# line 2": 2 *)
| "# line " ['0'-'9']+
    { lineno := extractLineno (text lexbuf) 7 - 1; getFile lexbuf }
  (* match int *)
| ['0'-'9']+
    { Parser.INTV{i=info lexbuf; v=int_of_string (text lexbuf)} }
  (* match float *)
| ['0'-'9']+ '.' ['0'-'9']+
    { Parser.FLOATV{i=info lexbuf; v=float_of_string (text lexbuf)} }
  (* match 变量名，变量名只能由大小写字母和_开头 *)
| ['A'-'Z' 'a'-'z' '_']
  ['A'-'Z' 'a'-'z' '_' '0'-'9' '\'']*
    { createID (info lexbuf) (text lexbuf) }
  (* match 操作符 *)
| ":=" | "<:" | "<-" | "->" | "=>" | "==>"
| "{|" | "|}" | "<|" | "|>" | "[|" | "|]" | "=="
    { createID (info lexbuf) (text lexbuf) }
  (* match 操作符 *)
| ['~' '%' '\\' '+' '-' '&' '|' ':' '@' '`' '$']+
    { createID (info lexbuf) (text lexbuf) }
  (* match 操作符 *)
| ['*' '#' '/' '!' '?' '^' '(' ')' '{' '}' '[' ']' '<' '>' '.' ';' '_' ','
   '=' '\'']
    { createID (info lexbuf) (text lexbuf) }
  (* match 单引号转移字符，设置startLex，转为string stage解析字符串 *)
| "\"" { resetStr(); startLex := info lexbuf; string lexbuf }
  (* match EOF *)
| eof { Parser.EOF(info lexbuf) }
  (* match others *)
| _  { error (info lexbuf) "Illegal character" }

and comment = parse (* comment stage *)
  (* match /*/*... comment depth ++，转为comment stage *)
  "/*"
    { depth := succ !depth; comment lexbuf }
  (* match /**/... comment depth --；当coment depth > 0，即存在/*/**/...情况，继续转为comment stage解析 *)
| "*/"
    { depth := pred !depth; if !depth > 0 then comment lexbuf }
  (* match EOF in /*... --> error *)
| eof
    { error (!startLex) "Comment not terminated" }
  (* match 除\n外其他字符，继续为comment stage *)
| [^ '\n']
    { comment lexbuf }
  (* match \n，设置newline，继续为comment stage *)
| "\n"
    { newline lexbuf; comment lexbuf }

and getFile = parse (* getFile stage *)
  " "* "\"" { getName lexbuf }

and getName = parse (* getName stage *)
  [^ '"' '\n']+ { filename := (text lexbuf); finishName lexbuf }

and finishName = parse (* finishName stage *)
  '"' [^ '\n']* { main lexbuf }

and string = parse (* string stage *)
  (* 解析空字符串 *)
  '"'  { Parser.STRINGV {i = !startLex; v=getStr()} }
  (* 解析\转义字符，addStr(转为escaped stage)直到解析结束，转为string stage *)
| '\\' { addStr(escaped lexbuf); string lexbuf }
  (* 解析\n，addStr(\n)，设置newline，转为string stage *)
| '\n' { addStr '\n'; newline lexbuf; string lexbuf }
  (* match 双引号转移字符 EOF，单边--> error，字符串中断 *)
| eof  { error (!startLex) "String not terminated" }
  (* match others *)
| _    { addStr (Lexing.lexeme_char lexbuf 0); string lexbuf }

and escaped = parse (* escaped stage *)
  (* match n --> \n *)
  'n'	 { '\n' }
  (* match t --> \t *)
| 't'	 { '\t' }
  (* match \\ --> \\ *)
| '\\'	 { '\\' }
  (* match 空字符串 *)
| '"'    { '\034'  }
  (* match '\'' --> '\'' *)
| '\''	 { '\'' }
  (* match > 255 --> unicode *)
| ['0'-'9']['0'-'9']['0'-'9']
    {
      let x = int_of_string(text lexbuf) in
      if x > 255 then
	error (info lexbuf) "Illegal character constant"
      else
	Char.chr x
    }
  (* match 除以下其它 --> error *)
| [^ '"' '\\' 't' 'n' '\'']
    { error (info lexbuf) "Illegal character constant" }

(*  *)
