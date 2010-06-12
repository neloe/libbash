grammar quotedvars_test;
options
{
   output       =   AST;
   language     =   Java;
   ASTLabelType =   CommonTree;
}
tokens
{
	QUOTED_ARG;
	ARG;
}

simple_command
	:	command BLANK! args;
command	:	NAME;
args	:	var -> ^(ARG var)
	|	QUOTES var QUOTES -> ^(QUOTED_ARG var);
var	:	DOLLAR! LBRACE! NAME RBRACE!;

//TOKENS
DOLLAR	:	'$';
LBRACE	:	'{';
RBRACE	:	'}';
NAME	:	(LETTER|'_')(LETTER|DIGIT|'_')*;
fragment
DIGIT	:	'0'..'9';
fragment
LETTER	:	('a'..'z'|'A'..'Z');
BLANK	:	(' '|'\t')+;
QUOTES	:	'"';
