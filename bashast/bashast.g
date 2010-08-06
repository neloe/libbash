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
	MATCH_ANY_EXCEPT;
	MATCH_EXACTLY_ONE;
	MATCH_AT_MOST_ONE;
	MATCH_NONE;
	MATCH_ANY;
	MATCH_AT_LEAST_ONE;
	MATCH_PATTERN;
	MATCH_ANY_EXCEPT;
	CHARACTER_CLASS;
	EQUIVALENCE_CLASS;
	COLLATING_SYMBOL;
	SINGLE_QUOTED_STRING;
	DOUBLE_QUOTED_STRING;
}

start	:	(flcomment! EOL!)? EOL!* list^ ;
//Because the comment token doesn't handle the first comment in a file if it's on the first line, have a parser rule for it
flcomment
	:	BLANK? '#' commentpart*;
commentpart
	:	nqstr|BLANK|LBRACE|RBRACE|SEMIC|DOUBLE_SEMIC|TICK|LPAREN|RPAREN|LLPAREN|RRPAREN|PIPE|COMMA|SQUOTE|QUOTE|LT|GT;
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
//The structure of a command in bash
command
	:	EXPORT^ var_def+
	|	compound_command
	|	simple_command;
//Simple bash commands
simple_command
	:	var_def+ bash_command^ redirect*
	|	bash_command^ redirect*;
bash_command
	:	fname_no_res_word (BLANK+ arg)* -> ^(COMMAND fname_no_res_word arg*);
//An argument to a command
arg
	:	brace_expansion
	|	var_ref
	|	fname
	|	res_word_str -> ^(STRING res_word_str)
	|	command_sub
	|	var_ref;
redirect:	BLANK!* here_string_op^ BLANK!* fname
	|	BLANK!* here_doc_op^ BLANK!* fname EOL! heredoc
	|	BLANK* redir_op BLANK* DIGIT MINUS? -> ^(REDIR redir_op DIGIT MINUS?)
	|	BLANK* redir_op BLANK* redir_dest -> ^(REDIR redir_op redir_dest)
	|	BLANK!* proc_sub;
redir_dest
	:	fname //path to a file
	|	file_desc_as_file; //handles file descriptors0
file_desc_as_file
	:	AMP DIGIT -> FILE_DESCRIPTOR[$DIGIT]
	|	AMP DIGIT MINUS -> FILE_DESCRIPTOR_MOVE[$DIGIT];
heredoc	:	(fname EOL!)*;
here_string_op
	:	HERE_STRING_OP;
here_doc_op
	:	LSHIFT MINUS -> OP["<<-"]
	|	LSHIFT -> OP["<<"];
redir_op:	AMP LT -> OP["&<"]
	|	GT AMP -> OP[">&"]
	|	LT AMP -> OP["<&"]
	|	LT GT -> OP["<>"]
	|	RSHIFT -> OP[">>"]
	|	AMP GT -> OP["&>"]
	|	AMP RSHIFT -> OP ["&>>"]
	|	LT
	|	GT
	|	DIGIT redir_op;
brace_expansion
	:	pre=fname? brace post=fname? -> ^(BRACE_EXP ($pre)? brace ($post)?);
brace
	:	LBRACE BLANK* brace_expansion_inside BLANK?RBRACE -> ^(BRACE brace_expansion_inside);
brace_expansion_inside
	:	commasep|range;
range	:	DIGIT DOTDOT^ DIGIT
	|	LETTER DOTDOT^ LETTER;
brace_expansion_part
	:	fname
	|	brace
	|	var_ref
	|	command_sub;
commasep:	brace_expansion_part(COMMA! brace_expansion_part)+;
command_sub
	:	DOLLAR LPAREN BLANK* pipeline BLANK? RPAREN -> ^(COMMAND_SUB pipeline)
	|	TICK BLANK* pipeline BLANK? TICK -> ^(COMMAND_SUB pipeline) ;
//compound commands
compound_command
	:	for_expr
	|	sel_expr
	|	if_expr
	|	while_expr
	|	until_expr
	|	case_expr
	|	subshell
	|	currshell
	|	arith_comparison
	|	cond_comparison;
//Expressions allowed inside a compound command
for_expr:	FOR BLANK+ name (wspace IN BLANK+ word)? semiel DO wspace* clist semiel DONE -> ^(FOR name (word)? clist)
	|	FOR BLANK* LLPAREN EOL? (BLANK* init=arithmetic BLANK*|BLANK+)? (SEMIC (BLANK? fcond=arithmetic BLANK*|BLANK+)? SEMIC|DOUBLE_SEMIC) (BLANK* mod=arithmetic)? wspace* RRPAREN semiel DO wspace clist semiel DONE
		-> ^(FOR ^(FOR_INIT $init)? ^(FOR_COND $fcond)? ^(FOR_MOD $mod)? clist)
	;
sel_expr:	SELECT BLANK+ name (wspace IN BLANK+ word)? semiel DO wspace* clist semiel DONE -> ^(SELECT name (word)? clist)
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
//the last case can have a slightly different structure than the rest; this accounts for that
last_case
options{greedy=false;}
	:	wspace* (LPAREN BLANK*)? pattern (BLANK* PIPE BLANK? pattern)* BLANK* RPAREN wspace* clist? (wspace* DOUBLE_SEMIC|(BLANK* EOL)+)
		-> ^(CASE_PATTERN pattern+ clist?)
	;
//A grouping of commands executed in a subshell
subshell:	LPAREN wspace? clist (BLANK* SEMIC)? (BLANK* EOL)* BLANK* RPAREN -> ^(SUBSHELL clist);
//A grouping of commands executed in the current shell
currshell
	:	LBRACE wspace clist semiel RBRACE -> ^(CURRSHELL clist);
//comparison using arithmetic
arith_comparison
	:	LLPAREN wspace? arithmetic wspace? RRPAREN -> ^(COMPOUND_ARITH arithmetic);
cond_comparison
	:	cond_expr -> ^(COMPOUND_COND cond_expr);
//Variables
//Defining a variable
var_def	:	BLANK* name LSQUARE BLANK? index BLANK* RSQUARE EQUALS value BLANK* -> ^(EQUALS ^(name  index) value)
	|	BLANK!* name EQUALS^ value BLANK!*
	|	BLANK!* LET! name EQUALS^ arithmetic BLANK!*;
//Possible values of a variable
value	:	num
	|	var_ref
	|	fname
	|	LPAREN! wspace!? arr_val RPAREN!;
//allow the parser to create array variables
arr_val	:
	|	(ag+=val wspace?)+ -> ^(ARRAY $ag+);
val	:	'['!BLANK!*index BLANK!?']'!EQUALS^ pos_val
	|	pos_val;
pos_val	: command_sub
	|	var_ref
	|	num
	|	fname;
//possible indexes for the variable.  Names are used when it acts more like a map/hash than an array
index	:	num
	|	name;
//Referencing a variable (different possible ways/special parameters)
var_ref
	:	DOLLAR LBRACE BLANK* var_exp BLANK* RBRACE -> ^(VAR_REF var_exp)
	|	DOLLAR name -> ^(VAR_REF name)
	|	DOLLAR num -> ^(VAR_REF num)
	|	DOLLAR TIMES -> ^(VAR_REF TIMES)
	|	DOLLAR AT -> ^(VAR_REF AT)
	|	DOLLAR POUND -> ^(VAR_REF POUND)
	|	DOLLAR QMARK -> ^(VAR_REF QMARK)
	|	DOLLAR MINUS -> ^(VAR_REF MINUS)
	|	DOLLAR BANG -> ^(VAR_REF BANG)
	|	DOLLAR '_' -> ^(VAR_REF '_');
//Variable expansions
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
//Allowable variable names in the variable expansion
var_name:	num|name|TIMES|AT;
//Referencing an array variable
arr_var_ref
	:	name^ LSQUARE! DIGIT+ RSQUARE!;
//Conditional Expressions
cond_expr
	:	LSQUARE LSQUARE wspace keyword_cond wspace RSQUARE RSQUARE -> ^(KEYWORD_TEST keyword_cond)
	|	LSQUARE wspace builtin_cond wspace RSQUARE -> ^(BUILTIN_TEST builtin_cond)
	|	TEST wspace builtin_cond-> ^(BUILTIN_TEST builtin_cond);
cond_primary
	:	LPAREN! BLANK!* keyword_cond BLANK!* RPAREN!
	|	keyword_cond_binary
	|	keyword_cond_unary
	|	fname;
keyword_cond_binary
	:	cond_part BLANK!* binary_str_op_keyword^ BLANK!? cond_part;
keyword_cond_unary
	:	UOP^ BLANK!+ cond_part;
builtin_cond_primary
	:	LPAREN! BLANK!* builtin_cond BLANK!* RPAREN!
	|	builtin_cond_binary
	|	builtin_cond_unary
	|	fname;
builtin_cond_binary
	:	cond_part BLANK!* binary_string_op_builtin^ BLANK!? cond_part;
builtin_cond_unary
	:	UOP^ BLANK!+ cond_part;
keyword_cond
	:	(negate_primary|cond_primary) (BLANK!* (LOGICOR^|LOGICAND^) BLANK!* keyword_cond)?;
builtin_cond
	:	(negate_builtin_primary|builtin_cond_primary) (BLANK!* (LOGICOR^|LOGICAND^) BLANK!* builtin_cond)?;
negate_primary
	:	BANG BLANK+ cond_primary -> ^(NEGATION cond_primary);
negate_builtin_primary
	:	BANG BLANK+ builtin_cond_primary -> ^(NEGATION builtin_cond_primary);
binary_str_op_keyword
	:	BOP
	|	EQUALS EQUALS -> OP["=="]
	|	EQUALS
	|	BANG EQUALS -> OP["!="]
	|	LT
	|	GT;
binary_string_op_builtin
	:	BOP
	|	EQUALS
	|	BANG EQUALS -> OP["!="]
	|	ESC_LT
	|	ESC_GT;
unary_cond
	:	UOP^ BLANK! cond_part;
//Allowable parts of conditions
cond_part:	brace_expansion
	|	var_ref
	|	res_word_str -> ^(STRING res_word_str)
	|	num
	|	fname
	|	arithmetic;
//Rules for whitespace/line endings
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
	:	CASE|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|FUNCTION|IF|IN|SELECT|THEN|UNTIL|WHILE|TIME;
//Any allowable part of a string, including slashes, no pounds
str_part
	:	ns_str_part
	|	SLASH;
//Any allowable part of a string, with pounds
str_part_with_pound
	:	str_part
	|	POUND
	|	POUNDPOUND;
//Parts of strings, no slashes
ns_str_part
	:	ns_str_part_no_res
	|	res_word_str;
//Parts of strings, no slashes, no reserved words
ns_str_part_no_res
	:	num
	|	name|NQSTR|EQUALS|PCT|PCTPCT|MINUS|DOT|DOTDOT|COLON|BOP|UOP|TEST|'_'|TILDE|INC|DEC|ARITH_ASSIGN|ESC_CHAR|CARET;
//strings with no slashes, used in certain variable expansions
ns_str	:	ns_str_part* -> ^(STRING ns_str_part*);
//Allowable parts of double quoted strings
dq_str_part
	:	BLANK|EOL|AMP|LOGICAND|LOGICOR|LT|GT|PIPE|SQUOTE|SEMIC|COMMA|LPAREN|RPAREN|LLPAREN|RRPAREN|DOUBLE_SEMIC|LBRACE|RBRACE|TICK|LEQ|GEQ
	|	str_part_with_pound;
//Allowable parts of single quoted strings
sq_str_part
	:	str_part_with_pound
	|	BLANK|EOL|AMP|LOGICAND|LOGICOR|LT|GT|PIPE|QUOTE|SEMIC|COMMA|LPAREN|RPAREN|LLPAREN|RRPAREN|DOUBLE_SEMIC|LBRACE|RBRACE|DOLLAR|TICK|BOP|UOP;
//Generic strings/filenames.
fname	:	nqstr -> ^(STRING nqstr);
//A string that is NOT a bash reserved word
fname_no_res_word
	:	nqstr_no_res_word -> ^(STRING nqstr_no_res_word);
//No quoted string, no reserved words
nqstr_no_res_word
	:	res_word_str (no_res_word_part|str_part_with_pound)+
	|	no_res_word_part (no_res_word_part|str_part_with_pound)*;
//parts of strings, not including reserved word parts
no_res_word_part
	:	bracket_pattern_match
	|	extended_pattern_match
	|	var_ref
	|	command_sub
	|	arithmetic_expansion
	|	dqstr
	|	sqstr
	|	ns_str_part_no_res
	|	SLASH
	|	pattern_match_trigger;
//non-quoted string rule, allows expansions
nqstr	:	(bracket_pattern_match|extended_pattern_match|var_ref|command_sub|arithmetic_expansion|dqstr|sqstr|(str_part str_part_with_pound*)|pattern_match_trigger|BANG)+;
//double quoted string rule, allows expansions
dqstr	:	QUOTE dqstr_part* QUOTE -> ^(DOUBLE_QUOTED_STRING dqstr_part*);
dqstr_part
	:	bracket_pattern_match
	|	extended_pattern_match
	|	var_ref
	|	command_sub
	|	arithmetic_expansion
	|	dq_str_part
	|	pattern_match_trigger
	|	BANG;
//single quoted string rule, no expansions
sqstr	:	SQUOTE sq_str_part* SQUOTE -> ^(SINGLE_QUOTED_STRING sq_str_part*);
//certain tokens that trigger pattern matching
pattern_match_trigger
	:	LSQUARE
	|	RSQUARE
	|	QMARK
	|	PLUS
	|	TIMES
	|	AT;
//Pattern matching using brackets
bracket_pattern_match
	:	LSQUARE RSQUARE (BANG|CARET) pattern_match* RSQUARE -> ^(MATCH_ANY_EXCEPT RSQUARE pattern_match*)
	|	LSQUARE RSQUARE pattern_match* RSQUARE -> ^(MATCH_PATTERN RSQUARE pattern_match*)
	|	LSQUARE (BANG|CARET) pattern_match+ RSQUARE -> ^(MATCH_ANY_EXCEPT pattern_match+)
	|	LSQUARE pattern_match+ RSQUARE -> ^(MATCH_PATTERN pattern_match+);
//allowable patterns with bracket pattern matching
pattern_match
	:	pattern_class_match
	|	str_part str_part_with_pound*;
//special class patterns to match: [:alpha:] etc
pattern_class_match
	:	LSQUARE COLON NAME COLON RSQUARE -> ^(CHARACTER_CLASS NAME)
	|	LSQUARE EQUALS pattern_char EQUALS RSQUARE -> ^(EQUIVALENCE_CLASS pattern_char)
	|	LSQUARE DOT NAME DOT RSQUARE -> ^(COLLATING_SYMBOL NAME);
//Characters allowed in matching equivalence classes
pattern_char
	:	LETTER|DIGIT|NQCHAR_NO_ALPHANUM|QMARK|COLON|AT|SEMIC|POUND|SLASH|BANG|TIMES|COMMA|PIPE|AMP|MINUS|PLUS|PCT|EQUALS|LSQUARE|RSQUARE|RPAREN|LPAREN|RBRACE|LBRACE|DOLLAR|TICK|DOT|LT|GT|SQUOTE|QUOTE;
//extended pattern matching
extended_pattern_match
	:	QMARK LPAREN fname (PIPE fname)* RPAREN -> ^(MATCH_AT_MOST_ONE fname+)
	|	TIMES LPAREN fname (PIPE fname)* RPAREN -> ^(MATCH_ANY fname+)
	|	PLUS LPAREN fname (PIPE fname)* RPAREN -> ^(MATCH_AT_LEAST_ONE fname+)
	|	AT LPAREN fname (PIPE fname)* RPAREN -> ^(MATCH_EXACTLY_ONE fname+)
	|	BANG LPAREN fname (PIPE fname)* RPAREN -> ^(MATCH_NONE fname+);
//Arithmetic expansion
arithmetic_expansion
	:	DOLLAR! LLPAREN! BLANK!* arithmetic_part BLANK!* RRPAREN!;
arithmetic_part
	:	arithmetics
	|	arithmetic;
//The comma operator for arithmetic expansions
arithmetics
	:	arithmetic (BLANK!* COMMA! BLANK!* arithmetic)*;
arithmetic
	:	arithmetic_condition
	|	arithmetic_assignment;
//The base of the arithmetic operator.  Used for order of operations
primary	:	num
	|	var_ref
	|	command_sub
	|	name -> ^(VAR_REF name)
	|	LPAREN! (arithmetics) RPAREN!;
post_inc_dec
	:	name BLANK?INC -> ^(POST_INCR name)
	|	name BLANK?DEC -> ^(POST_DECR name);
pre_inc_dec
	:	INC BLANK?name -> ^(PRE_INCR name)
	|	DEC BLANK?name -> ^(PRE_DECR name);
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
compare	:	shifts (BLANK!* (LEQ^|GEQ^|LT^|GT^)BLANK!* shifts)?;
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
	:	(name BLANK!* (EQUALS^|ARITH_ASSIGN^) BLANK!*)? logicor;
//process substitution
proc_sub:	(dir=LT|dir=GT)LPAREN BLANK* clist BLANK* RPAREN -> ^(PROC_SUB $dir clist);
//the biggie: functions
function:	FUNCTION BLANK+ fname (BLANK* parens)? wspace compound_command redirect* -> ^(FUNCTION fname compound_command redirect*)
	|	fname BLANK* parens wspace compound_command redirect* -> ^(FUNCTION["function"] fname compound_command redirect*);
parens	:	LPAREN BLANK* RPAREN;
name	:	NAME
	|	LETTER
	|	'_';

//****************
// TOKENS/LEXER RULES
//****************

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
//Handle ANSI C escaped characters: escaped octal, escaped hex, escaped ctrl+ chars, then all others
ESC_CHAR:	'\\' (('0'..'7')('0'..'7')('0'..'7')?|'x'('0'..'9'|'a'..'f'|'A'..'F')('0'..'9'|'a'..'f'|'A'..'F')?|'c'.|.);
NAME	:	(LETTER|'_')(ALPHANUM|'_')+;
NQCHAR_NO_ALPHANUM
	:	~('\n'|'\r'|' '|'\t'|'\\'|CARET|QMARK|COLON|AT|SEMIC|POUND|SLASH|BANG|TIMES|COMMA|PIPE|AMP|MINUS|PLUS|PCT|EQUALS|LSQUARE|RSQUARE|RPAREN|LPAREN|RBRACE|LBRACE|DOLLAR|TICK|DOT|LT|GT|SQUOTE|QUOTE|'a'..'z'|'A'..'Z'|'0'..'9')+;
NQSTR	:	(NQCHAR_NO_ALPHANUM|ALPHANUM)+;
