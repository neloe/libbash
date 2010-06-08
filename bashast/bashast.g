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
	output	= AST;
	language	= Java;
	ASTLabelType	= CommonTree;
}
tokens{
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
}

list	:	list_level_2 BLANK!? (';'!|'&'^|EOL!)?;
clist	:	list_level_2;
list_level_1
	:	pipeline (BLANK!?('&&'^|'||'^)BLANK!? pipeline)*;
list_level_2
	:	list_level_1 (BLANK!?(';'^|'&'^)BLANK!? list_level_1)*;
pipeline
	:	('time'^ BLANK! ('-p'BLANK!)?)?('!' BLANK)?simple_command^ (BLANK!?PIPE^ BLANK!? simple_command)*;
simple_command	:	(VAR_DEF BLANK!)* command^ redirect*;
command	:	FILEPATH^ (BLANK! FILEPATH)*;
redirect:	BLANK!?HSOP^BLANK!? FILEPATH
	|	BLANK!?HDOP^BLANK!? FILEPATH EOL! heredoc
	|	BLANK!?REDIR_OP^BLANK!? DIGIT CLOSE_FD?
	|	BLANK!?REDIR_OP^BLANK!? redir_dest;

heredoc	:	(FILEPATH EOL!)*;
redir_dest
	:	FILEPATH //path to a file
	|	FDASFILE; //handles file descriptors0
brace_expansion
	:	pre=FILEPATH? brace post=FILEPATH? -> ^(BRACE_EXP ($pre)? brace ($post)?);
brace
	:	LBRACE BLANK? braceexp BLANK?RBRACE -> ^(BRACE braceexp);
braceexp:	(commasep|RANGE);
bepart	:	FILEPATH|brace;
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

for_expr:	FOR BLANK name (wspace IN BLANK word)? semiel DO wspace* clist semiel DONE -> ^(FOR name (word)? clist)
	|	FOR BLANK? LLPAREN EOL? (BLANK? init=arith_expr BLANK?|BLANK)? (SEMIC (BLANK? cond=arith_expr BLANK?|BLANK)? SEMIC|DOUBLE_SEMIC) (BLANK?mod=arith_expr)? wspace* RRPAREN semiel DO wspace clist semiel DONE
		-> ^(FOR ^(FOR_INIT $init)? ^(FOR_COND $cond)? ^(FOR_MOD $mod)? clist)
	;
sel_expr:	SELECT BLANK name (wspace IN BLANK word)? semiel DO wspace* clist semiel DONE -> ^(SELECT name (word)? clist)
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
	:	wspace* (LPAREN BLANK?)? pat+=pattern (BLANK? PIPE BLANK? pat+=pattern)* BLANK? RPAREN wspace* clist (wspace* DOUBLE_SEMIC|(BLANK? EOL)*)
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
//Rules for tokens.
wspace	:	BLANK|EOL;
name	:	FILEPATH;
semiel	:	(';'|EOL) BLANK?;

//definition of word.  this is just going to grow...
word	:	command_sub
	;
pattern	:	command_sub
	|	name
	|	TIMES;

//TOkens
RANGE	:	ALPHANUM DOTDOT ALPHANUM;
arr_var_def
	:	ARR_VAR_DEF;
arr_var_ref
	:	DOLLAR! LBRACE! BLANK!? FILEPATH^ (LSQUARE! ((DIGIT)+|TIMES|AT) RSQUARE!)? BLANK!? RBRACE! 
	|	DOLLAR!FILEPATH;

COMMENT
    :   BLANK?'#' ~('\n'|'\r')* (EOL|EOF){$channel=HIDDEN;}
    ;
LBRACE	:	'{';
RBRACE	:	'}';
RPAREN	:	')';
LPAREN	:	'(';
LLPAREN	:	'((';
RRPAREN	:	'))';
LSQUARE	:	'[';
RSQUARE	:	']';
LLSQUARE:	'[[';
RRSQUARE:	']]';
TICK	:	'`';
DOLLAR	:	'$';
TIMES	:	'*';
AT	:	'@';
FOR	:	'for';
SELECT	:	'select';
DO	:	'do';
DONE	:	'done';
IN	:	'in';
IF	:	'if';
FI	:	'fi';
ELSE	:	'else';
THEN	:	'then';
ELIF	:	'elif';
WHILE	:	'while';
UNTIL	:	'until';
CASE	:	'case';
ESAC	:	'esac';
SEMIC	:	';';
DOUBLE_SEMIC
	:	';;';

//reserved words.
RES_WORD:	('!'|'case'|'do'|'done'|'elif'|'else'|'esac'|'fi'|'for'|'function'|'if'|'in'|'select'|'then'|'until'|'while'|'{'|'}'|'time'|'[['|']]');

//Because bash isn't exactly whitespace dependent... need to explicitly handle blanks
BLANK	:	(' '|'\t')+;
EOL	:	('\r'?'\n')+ ;
//some fragments for creating words...
fragment
ALPHANUM:	(DIGIT|LETTER);
DIGIT	:	'0'..'9';
fragment
LETTER	:	('a'..'z'|'A'..'Z');
//Some special redirect tokens
HSOP	:	'<<<';
HDOP	:	'<<''-'?;
REDIR_OP:	DIGIT?('&'?('>''>'?|'<')|'>&'|'<&'|'<>');
CLOSE_FD:	'-';
DOTDOT	:	'..';
fragment
FILENAME:	'"'(ALPHANUM|'.'|'-'|'_')(ALPHANUM|'.'|' '|'-'|'_')*'"'
	|	(ALPHANUM|'.'|'-'|'_')(ALPHANUM|'.'|'-'|'_')*;
FDASFILE:	'&'DIGIT'-'?;
FILEPATH:	'/'?FILENAME('/'FILENAME)*;
VAR_DEF	:	(ALPHANUM)+EQUALS FILENAME;
EQUALS	:	'=';
PIPE	:	'|';
ARR_VAR_DEF
	:	(ALPHANUM)+EQUALS LPAREN (BLANK? FILENAME)* BLANK? RPAREN;
