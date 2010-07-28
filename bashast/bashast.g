/**
Copyright 2010 Nathan Eloe

This file is part of libbash.

libbash is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

libbash is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with libbash.  If not, see <http://www.gnu.org/licenses/>.
**/
grammar bashast;
options
{
	backtrack	= true;
	output	= AST;
	language	= Java;
	ASTLabelType	= CommonTree;
}
tokens{
	ARG;
	ARRAY;
	BRACE;
	BRACE_EXP;
	COMMAND_SUB;
	CASE_PATTERN;
	SUBSHELL;
	CURRSHELL;
	COMPOUND_ARITH;
	COMPOUND_COND;
	FOR_INIT;
	FOR_COND;
	FOR_MOD;
	FNAME;
	OFFSET;
	LIST_EXPAND;
	OP;
	PRE_INCR;
	PRE_DECR;
	POST_INCR;
	POST_DECR;
	PROC_SUB;
	VAR_REF;
	NEGATION;
	LIST;
	REPLACE_FIRST;
	REPLACE_ALL;
	STRING;
	COMMAND;
	REPLACE_FIRST;
	REPLACE_LAST;
	FILE_DESCRIPTOR;
	FILE_DESCRIPTOR_MOVE;
	REDIR;
	ARITHMETIC_CONDITION;
	KEYWORD_TEST;
	BUILTIN_TEST;
}

start	:	(flcomment! EOL!)? EOL!* list^;
flcomment
	:	BLANK? '#' commentpart*;
commentpart
	:	nqstr|BLANK|LBRACE|RBRACE|SEMIC|DOUBLE_SEMIC|TICK|LPAREN|RPAREN|LLPAREN|RRPAREN|PIPE|COMMA|SQUOTE|QUOTE|'<'|'>';
list	:	list_level_2 BLANK* (';'|'&'|EOL)? -> ^(LIST list_level_2);
clist
options{greedy=false;}
	:	list_level_2 -> ^(LIST list_level_2);
list_level_1
	:	(function|pipeline) (BLANK!*('&&'^|'||'^)BLANK!* (function|pipeline))*;
list_level_2
	:	list_level_1 ((BLANK!?';'!|BLANK!?'&'^|(BLANK!? EOL!)+)BLANK!? list_level_1)*;
pipeline
	:	var_def+
	|	time?('!' BLANK!*)? BLANK!* command^ (BLANK!* PIPE^ BLANK!* command)*;
time	:	TIME^ BLANK!+ timearg?;
timearg	:	'-p' BLANK!+;
command
	:	EXPORT^ var_def+
	|	compound_comm
	|	simple_command;
simple_command
	:	var_def+ bash_command^ redirect*
	|	bash_command^ redirect*;
bash_command
	:	fname_no_res_word (BLANK+ arg)* -> ^(COMMAND fname_no_res_word arg*);
arg
	:	brace_expansion
	|	var_ref
	|	fname
	|	res_word_str -> ^(STRING res_word_str)
	|	command_sub
	|	var_ref;
redirect:	BLANK!* hsop^ BLANK!* fname
	|	BLANK!* hdop^ BLANK!* fname EOL! heredoc
	|	BLANK* redir_op BLANK* DIGIT MINUS? -> ^(REDIR redir_op DIGIT MINUS?)
	|	BLANK* redir_op BLANK* redir_dest -> ^(REDIR redir_op redir_dest)
	|	BLANK!* proc_sub;

heredoc	:	(fname EOL!)*;
redir_dest
	:	fname //path to a file
	|	file_desc_as_file; //handles file descriptors0
file_desc_as_file
	:	AMP DIGIT -> FILE_DESCRIPTOR[$DIGIT]
	|	AMP DIGIT MINUS -> FILE_DESCRIPTOR_MOVE[$DIGIT];
hsop	:	HERE_STRING_OP;
hdop	:	LSHIFT MINUS -> OP["<<-"]
	|	LSHIFT -> OP["<<"];
redir_op:	'&''<' -> OP["&<"]
	|	'>''&' -> OP[">&"]
	|	'<''&' -> OP["<&"]
	|	'<''>' -> OP["<>"]
	|	RSHIFT -> OP[">>"]
	|	'&''>' -> OP["&>"]
	|	'&'RSHIFT -> OP ["&>>"]
	|	'<'
	|	'>'
	|	DIGIT redir_op;
brace_expansion
	:	pre=fname? brace post=fname? -> ^(BRACE_EXP ($pre)? brace ($post)?);
brace
	:	LBRACE BLANK* braceexp BLANK?RBRACE -> ^(BRACE braceexp);
braceexp:	commasep|range;
range	:	DIGIT DOTDOT^ DIGIT
	|	NAME DOTDOT^ NAME;
bepart	:	fname
	|	brace
	|	var_ref
	|	command_sub;
commasep:	bepart(COMMA! bepart)+;
command_sub
	:	DOLLAR LPAREN BLANK* pipeline BLANK? RPAREN -> ^(COMMAND_SUB pipeline)
	|	TICK BLANK* pipeline BLANK? TICK -> ^(COMMAND_SUB pipeline) ;
//compound commands
compound_comm
	:	for_expr
	|	sel_expr
	|	if_expr
	|	while_expr
	|	until_expr
	|	case_expr
	|	subshell
	|	currshell
	|	arith_comp
	|	cond_comp;

for_expr:	FOR BLANK+ NAME (wspace IN BLANK+ word)? semiel DO wspace* clist semiel DONE -> ^(FOR NAME (word)? clist)
	|	FOR BLANK* LLPAREN EOL? (BLANK* init=arithmetic BLANK*|BLANK+)? (SEMIC (BLANK? fcond=arithmetic BLANK*|BLANK+)? SEMIC|DOUBLE_SEMIC) (BLANK* mod=arithmetic)? wspace* RRPAREN semiel DO wspace clist semiel DONE
		-> ^(FOR ^(FOR_INIT $init)? ^(FOR_COND $fcond)? ^(FOR_MOD $mod)? clist)
	;
sel_expr:	SELECT BLANK+ NAME (wspace IN BLANK+ word)? semiel DO wspace* clist semiel DONE -> ^(SELECT NAME (word)? clist)
	;
if_expr	:	IF wspace+ ag=clist BLANK* semiel THEN wspace+ iflist=clist BLANK? semiel EOL* (elif_expr)* (ELSE wspace+ else_list=clist BLANK? semiel EOL*)? FI
		-> ^(IF $ag $iflist (elif_expr)* ^($else_list)?)
	;
elif_expr
	:	ELIF BLANK+ ag=clist BLANK* semiel THEN wspace+ iflist=clist BLANK* semiel -> ^(IF["if"] $ag $iflist);
while_expr
	:	WHILE wspace istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(WHILE $istrue $dothis)
	;
until_expr
	:	UNTIL wspace istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(UNTIL $istrue $dothis)
	;
case_expr
	:	CASE^ BLANK!+ word wspace! IN! wspace! (case_stmt wspace!)* last_case? ESAC!;
case_stmt
options{greedy=false;}
	:	wspace* (LPAREN BLANK*)? pattern (BLANK* PIPE BLANK? pattern)* BLANK* RPAREN wspace* clist wspace* DOUBLE_SEMIC
		-> ^(CASE_PATTERN pattern+ clist)
	|	wspace* (LPAREN BLANK*)? pattern (BLANK? PIPE BLANK* pattern)* BLANK* RPAREN wspace* DOUBLE_SEMIC
		-> ^(CASE_PATTERN pattern+)
	;
last_case
options{greedy=false;}
	:	wspace* (LPAREN BLANK*)? pattern (BLANK* PIPE BLANK? pattern)* BLANK* RPAREN wspace* clist? (wspace* DOUBLE_SEMIC|(BLANK* EOL)+)
		-> ^(CASE_PATTERN pattern+ clist?)
	;
subshell:	LPAREN wspace? clist (BLANK* SEMIC)? (BLANK* EOL)* BLANK* RPAREN -> ^(SUBSHELL clist);
currshell
	:	LBRACE wspace clist semiel RBRACE -> ^(CURRSHELL clist);
arith_comp
	:	LLPAREN wspace? arithmetic wspace? RRPAREN -> ^(COMPOUND_ARITH arithmetic);
cond_comp
	:	cond_expr -> ^(COMPOUND_COND cond_expr);
//Variables
var_def	:	BLANK* NAME LSQUARE BLANK? index BLANK* RSQUARE EQUALS value BLANK* -> ^(EQUALS ^(NAME  index) value)
	|	BLANK!* NAME EQUALS^ value BLANK!*
	|	BLANK!* LET! NAME EQUALS^ arithmetic BLANK!*;
value	:	DIGIT
	|	NUMBER
	|	var_ref
	|	fname
	|	LPAREN! wspace!? arr_val RPAREN!;
arr_val	:
	|	(ag+=val wspace?)+ -> ^(ARRAY $ag+);
val	:	'['!BLANK!*index BLANK!?']'!EQUALS^ pos_val
	|	pos_val;
pos_val	: command_sub
	|	var_ref
	|	num
	|	fname;
index	:	num
	|	NAME;
//Array variables
var_ref
	:	DOLLAR LBRACE BLANK* var_exp BLANK* RBRACE -> ^(VAR_REF var_exp)
	|	DOLLAR NAME -> ^(VAR_REF NAME)
	|	DOLLAR num -> ^(VAR_REF num)
	|	DOLLAR TIMES -> ^(VAR_REF TIMES)
	|	DOLLAR AT -> ^(VAR_REF AT)
	|	DOLLAR POUND -> ^(VAR_REF POUND)
	|	DOLLAR QMARK -> ^(VAR_REF QMARK)
	|	DOLLAR MINUS -> ^(VAR_REF MINUS)
	|	DOLLAR BANG -> ^(VAR_REF BANG)
	|	DOLLAR '_' -> ^(VAR_REF '_');
var_exp	:	var_name WORDOP^ word
	|	var_name COLON os=num (COLON len=num)? -> ^(OFFSET var_name $os ^($len)?)
	|	BANG^ var_name (TIMES|AT)
	|	BANG var_name LSQUARE (op=TIMES|op=AT) RSQUARE -> ^(LIST_EXPAND var_name $op)
	|	POUND^ var_name
	|	var_name (POUND^|POUNDPOUND^) fname
	|	var_name (PCT^|PCTPCT^) fname
	|	var_name SLASH POUND ns_str SLASH fname -> ^(REPLACE_FIRST var_name ns_str fname)
	| 	var_name SLASH PCT ns_str SLASH fname -> ^(REPLACE_LAST var_name ns_str fname)
	|	var_name SLASH SLASH ns_str SLASH fname -> ^(REPLACE_ALL var_name ns_str fname)
	|	var_name SLASH SLASH ns_str SLASH? -> ^(REPLACE_ALL var_name ns_str)
	|	var_name SLASH ns_str SLASH fname -> ^(REPLACE_FIRST var_name ns_str fname)
	|	var_name SLASH POUND ns_str SLASH? -> ^(REPLACE_FIRST var_name ns_str)
	|	var_name SLASH PCT ns_str SLASH? -> ^(REPLACE_LAST var_name ns_str)
	|	var_name SLASH ns_str SLASH? -> ^(REPLACE_FIRST var_name ns_str)
	|	arr_var_ref
	|	var_name;
var_name:	num|NAME|TIMES|AT;
arr_var_ref
	:	NAME^ LSQUARE! DIGIT+ RSQUARE!;
//Conditional Expressions
cond_expr
	:	LLSQUARE wspace cond wspace RRSQUARE -> ^(KEYWORD_TEST cond)
	|	LSQUARE wspace old_cond wspace RSQUARE -> ^(BUILTIN_TEST old_cond)
	|	TEST wspace old_cond -> ^(BUILTIN_TEST old_cond);
cond	:	BANG BLANK binary_cond -> ^(NEGATION binary_cond)
	|	BANG BLANK unary_cond -> ^(NEGATION unary_cond)
	|	binary_cond
	|	unary_cond;
old_cond:	BANG BLANK binary_old_cond -> ^(NEGATION binary_old_cond)
	|	BANG BLANK unary_cond -> ^(NEGATION unary_cond)
	|	binary_old_cond
	|	unary_cond;
binary_old_cond
	:	condpart BLANK!* binary_string_op_old^ BLANK!? condpart(BLANK!* UOP^ BLANK!*cond)?
	|	num BLANK!+ BOP^ BLANK!+ num(BLANK!? UOP^ BLANK!* cond)?;
binary_cond
	:	condpart BLANK!* bstrop^ BLANK!? condpart(BLANK!*(LOGICOR^|LOGICAND^) BLANK!*cond)?
	|	num BLANK!+ BOP^ BLANK!+ num(BLANK!?(LOGICOR^|LOGICAND^) BLANK!* cond)?;
bstrop	:	BOP
	|	EQUALS EQUALS -> OP["=="]
	|	EQUALS
	|	BANG EQUALS -> OP["!="]
	|	'<'
	|	'>';
binary_string_op_old
	:	BOP
	|	EQUALS
	|	BANG EQUALS -> OP["!="]
	|	ESC_LT
	|	ESC_GT;
unary_cond
	:	UOP^ BLANK! condpart;
condpart:	brace_expansion
	|	var_ref
	|	res_word_str -> ^(STRING res_word_str)
	|	num
	|	fname
	|	arithmetic;
//Rules for tokens.
wspace	:	BLANK+|EOL;
semiel	:	(';'|EOL) BLANK*;

//definition of word.  this is just going to grow...
word	:	brace_expansion
	|	command_sub
	|	var_ref
	|	num
	|	fname
	|	arithmetic_expansion
	|	res_word_str -> ^(STRING res_word_str);
pattern	:	command_sub
	|	fname
	|	TIMES;
num
options{k=1;backtrack=false;}
	:	DIGIT|NUMBER;
//A rule for filenames/strings
res_word_str
	:	BANG|CASE|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|FUNCTION|IF|IN|SELECT|THEN|UNTIL|WHILE|TIME;
str_part
	:	ns_str_part
	|	SLASH;
str_part_with_pound
	:	str_part
	|	POUND
	|	POUNDPOUND;
ns_str_part
	:	ns_str_part_no_res
	|	res_word_str;
ns_str_part_no_res
	:	num
	|	NAME|NQSTR|TIMES|PLUS|EQUALS|PCT|PCTPCT|MINUS|LSQUARE|RSQUARE|DOT|DOTDOT|COLON|BOP|UOP|TEST|'_'|LLSQUARE|RRSQUARE|TILDE|INC|DEC|ARITH_ASSIGN|QMARK;
ns_str	:	ns_str_part* -> ^(STRING ns_str_part*);
dq_str_part
	:	BLANK|EOL|AMP|LOGICAND|LOGICOR|'<'|'>'|PIPE|SQUOTE|SEMIC|COMMA|LPAREN|RPAREN|LLPAREN|RRPAREN|DOUBLE_SEMIC|LBRACE|RBRACE|TICK|LEQ|GEQ
	|	str_part_with_pound;
sq_str_part
	:	str_part_with_pound
	|	BLANK|EOL|AMP|LOGICAND|LOGICOR|'<'|'>'|PIPE|QUOTE|SEMIC|COMMA|LPAREN|RPAREN|LLPAREN|RRPAREN|DOUBLE_SEMIC|LBRACE|RBRACE|DOLLAR|TICK|BOP|UOP;
fname	:	nqstr -> ^(STRING nqstr)
	|	dqstr -> ^(STRING dqstr)
	|	QUOTE QUOTE -> ^(STRING)
	|	sqstr -> ^(STRING sqstr)
	|	SQUOTE SQUOTE -> ^(STRING);
fname_no_res_word
	:	nqstr_no_res_word -> ^(STRING nqstr_no_res_word)
	|	dqstr -> ^(STRING dqstr)
	|	QUOTE QUOTE -> ^(STRING)
	|	sqstr -> ^(STRING sqstr)
	|	SQUOTE SQUOTE -> ^(STRING);
nqstr_no_res_word
	:	(var_ref|command_sub|arithmetic_expansion|dqstr|sqstr|(str_part str_part_with_pound+)|(ns_str_part_no_res|SLASH))+;
nqstr	:	(var_ref|command_sub|arithmetic_expansion|dqstr|sqstr|(str_part str_part_with_pound*))+;
dqstr	:	QUOTE! (var_ref|command_sub|arithmetic_expansion|dq_str_part)+ QUOTE!;
sqstr	:	SQUOTE!sq_str_part+ SQUOTE!;
//Arithmetic expansion
arithmetic_expansion
	:	DOLLAR! LLPAREN! BLANK!* arithmetic_part BLANK!* RRPAREN!;
arithmetic_part
	:	arithmetics
	|	arithmetic;
arithmetics
	:	arithmetic (BLANK!* COMMA! BLANK!* arithmetic)*;
arithmetic
	:	arithmetic_condition
	|	arithmetic_assignment;
primary	:	num
	|	var_ref
	|	command_sub
	|	NAME -> ^(VAR_REF NAME)
	|	LPAREN! (arithmetics) RPAREN!;
post_inc_dec
	:	NAME BLANK?INC -> ^(POST_INCR NAME)
	|	NAME BLANK?DEC -> ^(POST_DECR NAME);
pre_inc_dec
	:	INC BLANK?NAME -> ^(PRE_INCR NAME)
	|	DEC BLANK?NAME -> ^(PRE_DECR NAME);
unary	:	post_inc_dec
	|	pre_inc_dec
	|	primary
	|	PLUS^ primary
	|	MINUS^ primary;
negation
	:	(BANG^BLANK!?|TILDE^BLANK!?)?unary;
exponential
	:	negation (BLANK!* EXP^ BLANK!* negation)* ;
tdm	:	exponential (BLANK!*(TIMES^|SLASH^|PCT^)BLANK!* exponential)*;
addsub	:	tdm (BLANK!* (PLUS^|MINUS^)BLANK!* tdm)*;
shifts	:	addsub (BLANK!* (LSHIFT^|RSHIFT^) BLANK!* addsub)*;
compare	:	shifts (BLANK!* (LEQ^|GEQ^|'<'^|'>'^)BLANK!* shifts)?;
bitwiseand
	:	compare (BLANK!* AMP^ BLANK!* compare)*;
bitwisexor
	:	bitwiseand (BLANK!* CARET^ BLANK!* bitwiseand)*;
bitwiseor
	:	bitwisexor (BLANK!* PIPE^ BLANK!* bitwisexor)*;
logicand:	bitwiseor (BLANK!* LOGICAND^ BLANK!* bitwiseor)*;
logicor	:	logicand (BLANK!* LOGICOR^ BLANK!* logicand)*;

arithmetic_condition
	:	cnd=logicor QMARK t=logicor COLON f=logicor -> ^(ARITHMETIC_CONDITION $cnd $t $f);
arithmetic_assignment
	:	(NAME BLANK!* (EQUALS^|ARITH_ASSIGN^) BLANK!*)? logicor;
//process substitution
proc_sub:	(dir='<'|dir='>')LPAREN BLANK* clist BLANK* RPAREN -> ^(PROC_SUB $dir clist);
//the biggie: functions
function:	FUNCTION BLANK+ fname (BLANK* parens)? wspace compound_comm redirect* -> ^(FUNCTION fname compound_comm redirect*)
	|	fname BLANK* parens wspace compound_comm redirect* -> ^(FUNCTION["function"] fname compound_comm redirect*);
parens	:	LPAREN BLANK* RPAREN;
//TOkens

COMMENT
    :  (BLANK|EOL) '#' ~('\n'|'\r')* {$channel=HIDDEN;}
    ;
//Bash "reserved words"
BANG	:	'!';
CASE	:	'case';
DO	:	'do';
DONE	:	'done';
ELIF	:	'elif';
ELSE	:	'else';
ESAC	:	'esac';
FI	:	'fi';
FOR	:	'for';
FUNCTION:	'function';
IF	:	'if';
IN	:	'in';
SELECT	:	'select';
THEN	:	'then';
UNTIL	:	'until';
WHILE	:	'while';
LBRACE	:	'{';
RBRACE	:	'}';
TIME	:	'time';
LLSQUARE:	'[[';
RRSQUARE:	']]';

//Other special useful symbols
RPAREN	:	')';
LPAREN	:	'(';
LLPAREN	:	'((';
RRPAREN	:	'))';
LSQUARE	:	'[';
RSQUARE	:	']';
TICK	:	'`';
DOLLAR	:	'$';
AT	:	'@';
DOT	:	'.';
DOTDOT	:	'..';
//Arith ops
LET	:	'let';
TIMES	:	'*';
EQUALS	:	'=';
MINUS	:	'-';
PLUS	:	'+';
INC	:	'++';
DEC	:	'--';
EXP	:	'**';
AMP	:	'&';
LEQ	:	'<=';
GEQ	:	'>=';
CARET	:	'^';
LT	:	'<';
GT	:	'>';
LSHIFT	:	'<<';
RSHIFT	:	'>>';
ARITH_ASSIGN
	:	(TIMES|SLASH|PCT|PLUS|MINUS|LSHIFT|RSHIFT|AMP|CARET|PIPE) EQUALS;
//some separators
SEMIC	:	';';
DOUBLE_SEMIC
	:	';;';
PIPE	:	'|';
QUOTE	:	'"';
SQUOTE	:	'\'';
COMMA	:	',';
//Because bash isn't exactly whitespace dependent... need to explicitly handle blanks
BLANK	:	(' '|'\t')+;
EOL	:	('\r'?'\n')+ ;
//some fragments for creating words...
DIGIT	:	'0'..'9';
NUMBER	:	DIGIT DIGIT+;
fragment
LETTER	:	('a'..'z'|'A'..'Z');
fragment
ALPHANUM:	(DIGIT|LETTER);
//Some special redirect operators
TILDE	:	'~';
HERE_STRING_OP
	:	'<<<';
//Tokens for parameter expansion
POUND	:	'#';
POUNDPOUND
	:	'##';
PCT	:	'%';
PCTPCT	:	'%%';
SLASH	:	'/';
WORDOP	:	(':-'|':='|':?'|':+');
COLON	:	':';
QMARK	:	'?';
//Operators for conditional statements
TEST	:	'test';
LOGICAND
	:	'&&';
LOGICOR	:	'||';
BOP	:	MINUS LETTER LETTER;
UOP	:	MINUS LETTER;
//Some builtins
EXPORT	:	'export';
//Tokens for strings
CONTINUE_LINE
	:	('\\' EOL)+{$channel=HIDDEN;};
ESC_RPAREN
	:	'\\' RPAREN;
ESC_LPAREN
	:	'\\' LPAREN;
ESC_LT	:	'\\''<';
ESC_GT	:	'\\''>';
NAME	:	(LETTER|'_')(ALPHANUM|'_')*;
NQSTR	:	~('\n'|'\r'|' '|'\t'|'\\'|QMARK|COLON|AT|SEMIC|POUND|SLASH|BANG|TIMES|COMMA|PIPE|AMP|MINUS|PLUS|PCT|EQUALS|LSQUARE|RSQUARE|RPAREN|LPAREN|RBRACE|LBRACE|DOLLAR|TICK|COMMA|DOT|'<'|'>'|SQUOTE|QUOTE)+;
