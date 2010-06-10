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
}
list	:	list_level_2 BLANK!? (';'!|'&'^|EOL!)?;
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
RANGE	:	ALPHANUM DOTDOT ALPHANUM;

COMMENT
    :   BLANK?'#' ~('\n'|'\r')* (EOL|EOF){$channel=HIDDEN;}
    ;
LBRACE	:	'{';
RBRACE	:	'}';
RPAREN	:	')';
LPAREN	:	'(';
TICK	:	'`';
DOLLAR	:	'$';
//reserved words.
RES_WORD:	('!'|'case'|'do'|'done'|'elif'|'else'|'esac'|'fi'|'for'|'function'|'if'|'in'|'select'|'then'|'until'|'while'|'{'|'}'|'time'|'[['|']]');

//Because bash isn't exactly whitespace dependent... need to explicitly handle blanks
BLANK	:	(' '|'\t')+;
EOL	:	('\r'?'\n') ;
//some fragments for creating words...
fragment
ALPHANUM:	(DIGIT|LETTER);
fragment
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
