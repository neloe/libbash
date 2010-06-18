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
}

list	:	list_level_2 BLANK!? (';'!|'&'^|EOL!)?;
clist	:	list_level_2;
list_level_1
	:	pipeline (BLANK!?('&&'^|'||'^)BLANK!? pipeline)*;
list_level_2
	:	list_level_1 ((BLANK!?';'!|BLANK!?'&'^|(BLANK!? EOL!)+)BLANK!? list_level_1)*;
pipeline
	:	time?('!' BLANK)? command^ (BLANK!?PIPE^ BLANK!? simple_command)*;
time	:	TIME^ BLANK! timearg?;
timearg	:	'-''p' BLANK -> ARG["-p"];
command	:	var_def+
	|	simple_command
	|	compound_comm;
simple_command
	:	var_def+ bash_command^ redirect*
	|	bash_command^ redirect*;
bash_command
	:	fpath^ (BLANK! fpath)*;
redirect:	BLANK!?HSOP^BLANK!? fpath
	|	BLANK!?HDOP^BLANK!? fpath EOL! heredoc
	|	BLANK!?REDIR_OP^BLANK!? DIGIT MINUS?
	|	BLANK!?REDIR_OP^BLANK!? redir_dest;

heredoc	:	(fpath EOL!)*;
redir_dest
	:	fpath //path to a file
	|	FDASFILE; //handles file descriptors0
brace_expansion
	:	pre=fpath? brace post=fpath? -> ^(BRACE_EXP ($pre)? brace ($post)?);
brace
	:	LBRACE BLANK? braceexp BLANK?RBRACE -> ^(BRACE braceexp);
braceexp:	commasep|range;
range	:	DIGIT DOTDOT^ DIGIT
	|	NAME DOTDOT^ NAME;
bepart	:	fpath|brace;
commasep:	bepart(','! bepart)+;
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
	|	FOR BLANK? LLPAREN EOL? (BLANK? init=arith_expr BLANK?|BLANK)? (SEMIC (BLANK? cond=arith_expr BLANK?|BLANK)? SEMIC|DOUBLE_SEMIC) (BLANK?mod=arith_expr)? wspace* RRPAREN semiel DO wspace clist semiel DONE
		-> ^(FOR ^(FOR_INIT $init)? ^(FOR_COND $cond)? ^(FOR_MOD $mod)? clist)
	;
sel_expr:	SELECT BLANK NAME (wspace IN BLANK word)? semiel DO wspace* clist semiel DONE -> ^(SELECT NAME (word)? clist)
	;
if_expr	:	IF wspace+ arg=clist BLANK? semiel THEN wspace+ iflist=clist BLANK? semiel EOL* (elif_expr)* (ELSE wspace+ else_list=clist BLANK? semiel EOL*)? FI
		-> ^(IF $arg $iflist (elif_expr)* ^($else_list)?)
	;
elif_expr
	:	ELIF BLANK arg=clist BLANK? semiel THEN wspace+ iflist=clist BLANK? semiel -> ^(IF["if"] $arg $iflist);
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
	;
last_case
	:	wspace* (LPAREN BLANK?)? pat+=pattern (BLANK? PIPE BLANK? pat+=pattern)* BLANK? RPAREN wspace* clist (wspace* DOUBLE_SEMIC|(BLANK? EOL)+)
		-> ^(CASE_PATTERN $pat+ clist)
	;
subshell:	LPAREN wspace? clist (BLANK? SEMIC)? (BLANK? EOL)* BLANK? RPAREN -> ^(SUBSHELL clist);
currshell
	:	LBRACE wspace clist semiel RBRACE -> ^(CURRSHELL clist);
arith_comp
	:	LLPAREN wspace? arith_expr wspace? RRPAREN -> ^(COMPOUND_ARITH arith_expr);
cond_comp
	:	LLSQUARE wspace comp_expr wspace RRSQUARE -> ^(COMPOUND_COND comp_expr);
//stubs for compound commands
arith_expr
	:	'arith_stub';
comp_expr
	:	'cond_stub';
//Variables
var_def	:	BLANK!? NAME EQUALS^ value BLANK!?;
value	:	DIGIT
	|	NUMBER
	|	fpath
	|	LPAREN! BLANK!? arr_val RPAREN!;
arr_val	:	(BLANK? arg+=fpath)* -> ^(ARRAY $arg+);
//Array variables
var_ref
	:	DOLLAR! LBRACE! BLANK!? (NAME|arr_var_ref) BLANK!? RBRACE!
	|	DOLLAR!NAME;
arr_var_ref
	:	NAME^ LSQUARE! DIGIT+ RSQUARE!;
//Rules for tokens.
wspace	:	BLANK|EOL;
semiel	:	(';'|EOL) BLANK?;

//definition of word.  this is just going to grow...
word	:	command_sub
	;
pattern	:	command_sub
	|	fname
	|	TIMES;
//A rule for filenames
fname	:	QUOTE qfname QUOTE
	|	nqfname
	|	NAME
	|	DOT
	|	DOTDOT
	|	TILDE
	|	TIMES;
qfname	:	a=fnamepart b=qfname -> FNAME[$a.text+$b.text]
	|	(c=BLANK|c=LBRACE|c=RBRACE) b=qfname -> FNAME[$c.text+$b.text]
	|	fnamepart
	|	BLANK|LBRACE|RBRACE;
nqfname	:	a=fnamepart b=nqfnamep -> FNAME[$a.text+$b.text];
nqfnamep:	a=fnamepart b=nqfnamep -> FNAME[$a.text+$b.text]
	|	fnamepart;
fnamepart
	:	BANG|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|FUNCTION|IF|IN|SELECT|THEN|UNTIL|WHILE
		|TIME|LLSQUARE|RRSQUARE|LSQUARE|RSQUARE|DOTDOT|TILDE
		|DOLLAR|AT|TIMES|MINUS|OTHER|DOT|NAME|NUMBER|DIGIT|EQUALS;
fpath	:	a=path_elm b=fpath -> ARG[$a.text+$b.text]
	|	a=path_elm -> ARG[$a.text];
path_elm:	fname
	|	'/';
//TOkens

COMMENT
    :   BLANK?'#' ~('\n'|'\r')* (EOL|EOF){$channel=HIDDEN;}
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
TIMES	:	'*';
EQUALS	:	'=';
MINUS	:	'-';
//some separators
SEMIC	:	';';
DOUBLE_SEMIC
	:	';;';
PIPE	:	'|';
QUOTE	:	'"';
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
HSOP	:	'<<<';
HDOP	:	'<<''-'?;
REDIR_OP:	DIGIT?('&'?('>''>'?|'<')|'>&'|'<&'|'<>');
FDASFILE:	'&'DIGIT'-'?;
TILDE	:	'~';
//Tokens for strings
NAME	:	(LETTER|'_')(ALPHANUM|'_')*;
OTHER	:	.;
