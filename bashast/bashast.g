grammar bashast;
options
{
	output	= AST;
	language	= Java;
	ASTLabelType	= pANTLR3_BASE_Tree;
}

list	:	pipeline (LIST_OP pipeline)*LIST_TERM?;
pipeline
	:	('time' ('-p')?)?('!')?simple_command ('|' simple_command)*;
simple_command	:	;

//Terminals
//Special BASH Ops
BLANK	:	(' '|'\t');
METACHAR
	:	('|'|'&'|';'|'('|')'|'<'|'>'|BLANK);
CONTROL_OP
	:	('|''|'?|'&''&'?|';'';'?|'('|')'|'\n');
LIST_OP	:	(';'|'&''&'?|'||');
LIST_TERM
	:	(';'|'&'|'\n'+);
