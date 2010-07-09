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
	backtrack=true;
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
}

start	:	(flcomment! EOL!)? EOL!* list^;
flcomment
	:	BLANK? '#' commentpart*;
commentpart
	:	nqstr|BLANK|LBRACE|RBRACE|SEMIC|DOUBLE_SEMIC|TICK|LPAREN|RPAREN|LLPAREN|RRPAREN|PIPE|COMMA|SQUOTE|QUOTE|'<'|'>';
list	:	list_level_2 BLANK? (';'|'&'|EOL)? -> ^(LIST list_level_2);
clist	:	list_level_2 -> ^(LIST list_level_2);
list_level_1
	:	(function|pipeline) (BLANK!?('&&'^|'||'^)BLANK!? (function|pipeline))*;
list_level_2
	:	list_level_1 ((BLANK!?';'!|BLANK!?'&'^|(BLANK!? EOL!)+)BLANK!? list_level_1)*;
pipeline
	:	var_def+
	|	time?('!' BLANK!)? BLANK!? command^ (BLANK!?PIPE^ BLANK!? command)*;
time	:	TIME^ BLANK! timearg?;
timearg	:	'-p' BLANK!;
command	:	EXPORT^ var_def+
	|	compound_comm
	|	simple_command;
simple_command
	:	var_def+ bash_command^ redirect*
	|	bash_command^ redirect*;
bash_command
	:	fname (BLANK arg)* -> ^(COMMAND fname arg*);
arg	:	brace_expansion
	|	var_ref
	|	fname
	|	res_word_str -> ^(STRING res_word_str)
	|	command_sub
	|	var_ref;
redirect:	BLANK!?hsop^BLANK!? fname
	|	BLANK!?hdop^BLANK!? fname EOL! heredoc
	|	BLANK!?redir_op^BLANK!? DIGIT MINUS?
	|	BLANK!?redir_op^BLANK!? redir_dest
	|	BLANK!?proc_sub;

heredoc	:	(fname EOL!)*;
redir_dest
	:	fname //path to a file
	|	file_desc_as_file; //handles file descriptors0
file_desc_as_file
	:	a='&'b=DIGIT -> OP[$a.text+$b.text]
	|	a='&'b=DIGIT'-' -> OP[$a.text+$b.text+"-"];
hsop	:	'<''<''<' -> OP["<<<"];
hdop	:	'<''<''-' -> OP["<<-"]
	|	'<''<' -> OP["<<"];
redir_op:	'&''<' -> OP["&<"]
	|	'>''&' -> OP[">&"]
	|	'<''&' -> OP["<&"]
	|	'<''>' -> OP["<>"]
	|	'>''>' -> OP[">>"]
	|	'&''>' -> OP["&>"]
	|	'&''>''>' -> OP ["&>>"]
	|	'<'
	|	'>'
	|	fd=DIGIT op=redir_op -> OP[$fd.text+$op.text];
brace_expansion
	:	pre=fname? brace post=fname? -> ^(BRACE_EXP ($pre)? brace ($post)?);
brace
	:	LBRACE BLANK? braceexp BLANK?RBRACE -> ^(BRACE braceexp);
braceexp:	commasep|range;
range	:	DIGIT DOTDOT^ DIGIT
	|	NAME DOTDOT^ NAME;
bepart	:	fname
	|	brace
	|	var_ref
	|	command_sub;
commasep:	bepart(COMMA! bepart)+;
command_sub
	:	DOLLAR LPAREN BLANK? pipeline BLANK? RPAREN -> ^(COMMAND_SUB pipeline)
	|	TICK BLANK? pipeline BLANK? TICK -> ^(COMMAND_SUB pipeline) ;
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

for_expr:	FOR BLANK NAME (wspace IN BLANK word)? semiel DO wspace* clist semiel DONE -> ^(FOR NAME (word)? clist)
	|	FOR BLANK? LLPAREN EOL? (BLANK? init=arithmetic BLANK?|BLANK)? (SEMIC (BLANK? fcond=arithmetic BLANK?|BLANK)? SEMIC|DOUBLE_SEMIC) (BLANK?mod=arithmetic)? wspace* RRPAREN semiel DO wspace clist semiel DONE
		-> ^(FOR ^(FOR_INIT $init)? ^(FOR_COND $fcond)? ^(FOR_MOD $mod)? clist)
	;
sel_expr:	SELECT BLANK NAME (wspace IN BLANK word)? semiel DO wspace* clist semiel DONE -> ^(SELECT NAME (word)? clist)
	;
if_expr	:	IF wspace+ ag=clist BLANK? semiel THEN wspace+ iflist=clist BLANK? semiel EOL* (elif_expr)* (ELSE wspace+ else_list=clist BLANK? semiel EOL*)? FI
		-> ^(IF $ag $iflist (elif_expr)* ^($else_list)?)
	;
elif_expr
	:	ELIF BLANK ag=clist BLANK? semiel THEN wspace+ iflist=clist BLANK? semiel -> ^(IF["if"] $ag $iflist);
while_expr
	:	WHILE wspace istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(WHILE $istrue $dothis)
	;
until_expr
	:	UNTIL wspace istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(UNTIL $istrue $dothis)
	;
case_expr
	:	CASE^ BLANK! word wspace! IN! wspace! (case_stmt wspace!)* last_case? ESAC!;
case_stmt
	:	wspace* (LPAREN BLANK?)? pat+=pattern (BLANK? PIPE BLANK? pat+=pattern)* BLANK? RPAREN wspace* clist wspace* DOUBLE_SEMIC
		-> ^(CASE_PATTERN $pat+ clist)
	|	wspace* (LPAREN BLANK?)? pat+=pattern (BLANK? PIPE BLANK? pat+=pattern)* BLANK? RPAREN wspace* DOUBLE_SEMIC
		-> ^(CASE_PATTERN $pat+)
	;
last_case
	:	wspace* (LPAREN BLANK?)? pat+=pattern (BLANK? PIPE BLANK? pat+=pattern)* BLANK? RPAREN wspace* clist? (wspace* DOUBLE_SEMIC|(BLANK? EOL)+)
		-> ^(CASE_PATTERN $pat+ clist?)
	;
subshell:	LPAREN wspace? clist (BLANK? SEMIC)? (BLANK? EOL)* BLANK? RPAREN -> ^(SUBSHELL clist);
currshell
	:	LBRACE wspace clist semiel RBRACE -> ^(CURRSHELL clist);
arith_comp
	:	LLPAREN wspace? arithmetic wspace? RRPAREN -> ^(COMPOUND_ARITH arithmetic);
cond_comp
	:	cond_expr -> ^(COMPOUND_COND cond_expr);
//Variables
var_def	:	BLANK? NAME LSQUARE BLANK? index BLANK? RSQUARE EQUALS value BLANK? -> ^(EQUALS ^(NAME  index) value)
	|	BLANK!? NAME EQUALS^ value BLANK!?
	|	BLANK!? LET! NAME EQUALS^ arithmetic BLANK!?;
value	:	DIGIT
	|	NUMBER
	|	var_ref
	|	fname
	|	LPAREN! wspace!? arr_val RPAREN!;
arr_val	:
	|	(ag+=val wspace?)+ -> ^(ARRAY $ag+);
val	:	'['!BLANK!?index BLANK!?']'!EQUALS^ pos_val
	|	pos_val;
pos_val	: command_sub
	|	var_ref
	|	num
	|	fname;
index	:	num
	|	NAME;
//Array variables
var_ref
	:	DOLLAR LBRACE BLANK? var_exp BLANK? RBRACE -> ^(VAR_REF var_exp)
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
	| var_name SLASH PCT ns_str SLASH fname -> ^(REPLACE_LAST var_name ns_str fname)
	|	var_name SLASH ns_str SLASH fname -> ^(REPLACE_FIRST var_name ns_str fname)
	|	var_name SLASH POUND ns_str SLASH? -> ^(REPLACE_FIRST var_name ns_str)
	|	var_name SLASH PCT ns_str SLASH? -> ^(REPLACE_LAST var_name ns_str)
	|	var_name SLASH ns_str SLASH? -> ^(REPLACE_FIRST var_name ns_str)
	|	var_name SLASH SLASH ns_str SLASH fname -> ^(REPLACE_ALL var_name ns_str fname)
	|	var_name SLASH SLASH ns_str SLASH? -> ^(REPLACE_ALL var_name ns_str)
	|	arr_var_ref
	|	var_name;
var_name:	num|NAME|TIMES|AT;
arr_var_ref
	:	NAME^ LSQUARE! DIGIT+ RSQUARE!;
//Conditional Expressions
cond_expr
	:	LLSQUARE! wspace! cond wspace! RRSQUARE!
	|	LSQUARE! wspace! cond wspace! RSQUARE!
	|	TEST! wspace! cond;
cond	:	BANG BLANK binary_cond -> ^(NEGATION binary_cond)
	|	BANG BLANK unary_cond -> ^(NEGATION unary_cond)
	|	binary_cond
	|	unary_cond;
binary_cond
	:	condpart BLANK!? bstrop^ BLANK!? condpart(BLANK!?(LOGICOR^|LOGICAND^) BLANK!?cond)?
	|	num BLANK! BOP^ BLANK! num(BLANK!?(LOGICOR^|LOGICAND^) BLANK!?cond)?;
bstrop	:	BOP
	|	EQUALS EQUALS -> OP["=="]
	|	EQUALS
	|	BANG EQUALS -> OP["!="]
	|	'<'
	|	'>';
unary_cond
	:	UOP^ BLANK! condpart;
condpart:	brace_expansion
	|	var_ref
	|	arithmetic
	|	res_word_str -> ^(STRING res_word_str)
	|	fname;
//Rules for tokens.
wspace	:	BLANK|EOL;
semiel	:	(';'|EOL) BLANK?;

//definition of word.  this is just going to grow...
word	:	brace_expansion
	|	command_sub
	|	var_ref
	|	num
	|	fname
	|	res_word_str -> ^(STRING res_word_str);
pattern	:	command_sub
	|	fname
	|	TIMES;
num	:	DIGIT|NUMBER;
//A rule for filenames/strings
res_word_str
	:	BANG|CASE|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|FUNCTION|IF|IN|SELECT|THEN|UNTIL|WHILE|TIME;
str_part:	ns_str_part
	|	SLASH;
ns_str_part:	num
	|	NAME|NQSTR|TIMES|PLUS|EQUALS|PCT|PCTPCT|MINUS|LSQUARE|RSQUARE|DOT|DOTDOT|COLON|BOP|UOP|TEST|'_'|LLSQUARE|RRSQUARE|TILDE|INC|DEC;
ns_str	:	ns_str_agg -> ^(STRING ns_str_agg);
ns_str_agg
	:	nsp=ns_str_part nsap=ns_str_aggp -> STRING[$nsp.text+$nsap.text]
	|	ns_str_part
	|	rw=res_word_str nsap=ns_str_aggp -> STRING[$rw.text+$nsap.text];
ns_str_aggp
	:	nsp=ns_str_part nsap=ns_str_aggp -> STRING[$nsp.text+$nsap.text]
	|	ns_str_part
	|	rw=res_word_str nsap=ns_str_aggp -> STRING[$rw.text+$nsap.text]
	|	res_word_str
	|	(ch=POUND|ch=POUNDPOUND) sap=str_aggp -> STRING[$ch.text+$sap.text]
	|	POUND|POUNDPOUND;
str_agg	:	sp=str_part sap=str_aggp -> STRING[$sp.text+$sap.text]
	|	str_part
	|	rw=res_word_str sap=str_aggp -> STRING[$rw.text+$sap.text];
str_aggp:	sp=str_part sap=str_aggp -> STRING[$sp.text+$sap.text]
	|	str_part
	|	rw=res_word_str sap=str_aggp -> STRING[$rw.text+$sap.text]
	|	res_word_str
	|	(ch=POUND|ch=POUNDPOUND) sap=str_aggp -> STRING[$ch.text+$sap.text]
	|	POUND|POUNDPOUND;
dq_str_agg
	:	dsap=dq_str_aggp dsa=dq_str_agg -> STRING[$dsap.text+$dsa.text]
	|	dq_str_aggp;
dq_str_aggp
	:	str_agg
	|	res_word_str
	|	BLANK|EOL|AMP|LOGICAND|LOGICOR|'<'|'>'|PIPE|SQUOTE|SEMIC|COMMA|LPAREN|RPAREN|LLPAREN|RRPAREN|DOUBLE_SEMIC|LBRACE|RBRACE|TICK;
sq_str_agg
	:	ssap=sq_str_aggp ssa=sq_str_agg -> STRING[$ssap.text+$ssa.text]
	|	sq_str_aggp;
sq_str_aggp
	:	str_agg
	|	res_word_str
	|	BLANK|EOL|AMP|LOGICAND|LOGICOR|'<'|'>'|PIPE|QUOTE|SEMIC|COMMA|LPAREN|RPAREN|LLPAREN|RRPAREN|DOUBLE_SEMIC|LBRACE|RBRACE|DOLLAR|TICK;
fname	:	nqstr -> ^(STRING nqstr)
	|	QUOTE dqstr QUOTE -> ^(STRING dqstr)
	|	QUOTE QUOTE -> ^(STRING)
	|	SQUOTE sqstr SQUOTE -> ^(STRING sqstr)
	|	SQUOTE SQUOTE -> ^(STRING);
nqstr	:	(var_ref|command_sub|str_agg)+;
dqstr	:	(var_ref|command_sub|dq_str_agg)+;
sqstr	:	sq_str_agg;
//Arithmetic expansion
arithmetic
	:	logicor;
primary	:	num
	|	var_ref
	|	command_sub
	|	LPAREN! arithmetic RPAREN!;
post_inc_dec
	:	NAME BLANK?INC -> ^(POST_INCR NAME)
	|	NAME BLANK?DEC -> ^(POST_DECR NAME);
pre_inc_dec
	:	INC BLANK?NAME -> ^(PRE_INCR NAME)
	|	DEC BLANK?NAME -> ^(PRE_DECR NAME);
unary	:	primary
	|	PLUS^ primary
	|	MINUS^ primary
	|	post_inc_dec
	|	pre_inc_dec;
negation
	:	(BANG^BLANK!?|TILDE^BLANK!?)?unary;
exp	:	negation (BLANK!? EXP^ BLANK!? negation)* ;
tdm	:	exp (BLANK!?(TIMES^|SLASH^|PCT^)BLANK!? exp)*;
addsub	:	tdm (BLANK!? (PLUS^|MINUS^)BLANK!? tdm)*;
shifts	:	addsub (BLANK!? (shiftop^) BLANK!? addsub)*;
shiftop	:	'<''<' -> OP["<<"]
	|	'>''>' -> OP[">>"];
compare	:	shifts (BLANK!? (LEQ^|GEQ^|'<'^|'>'^)BLANK!? shifts)?;
bitand	:	compare (BLANK!? AMP^ BLANK!? compare)*;
bitxor	:	bitand (BLANK!? CARET^ BLANK!? bitand)*;
bitor	:	bitxor (BLANK!? PIPE^ BLANK!? bitxor)*;
logicand:	bitor (BLANK!? LOGICAND^ BLANK!? bitor)*;
logicor	:	logicand (BLANK!? LOGICOR^ BLANK!? logicand)*;
//process substitution
proc_sub:	(dir='<'|dir='>')LPAREN BLANK? clist BLANK? RPAREN -> ^(PROC_SUB $dir clist);
//the biggie: functions
function:	FUNCTION BLANK fname (BLANK? parens)? wspace compound_comm redirect* -> ^(FUNCTION fname compound_comm redirect*)
	|	fname BLANK? parens wspace compound_comm redirect* -> ^(FUNCTION["function"] fname compound_comm redirect*);
parens	:	LPAREN BLANK? RPAREN;
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
NAME	:	(LETTER|'_')(ALPHANUM|'_')*;
NQSTR	:	~('\n'|'\r'|' '|'\t'|COLON|AT|SEMIC|POUND|SLASH|BANG|TIMES|COMMA|PIPE|AMP|MINUS|PLUS|PCT|EQUALS|LSQUARE|RSQUARE|RPAREN|LPAREN|RBRACE|LBRACE|DOLLAR|TICK|COMMA|DOT|'<'|'>'|SQUOTE|QUOTE)+;
