/**
Copyright 2010 Nathan Eloe

This file is part of libbash.

libbash is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

libbash is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with libbash.  If not, see <http://www.gnu.org/licenses/>.
**/
grammar bashast_cond;

options
{
	output	= AST;
	language	= Java;
	ASTLabelType	= CommonTree;
}

expr	:	cond_expr;
cond_expr
	:	LDCOND cond RDCOND -> ^(cond)
	|	LCOND cond RCOND -> ^(cond)
	|	TESTCOND cond -> ^(cond);
cond	:	unary_cond
	|	binary_cond;
binary_cond
	:	(arg1=STR bop=BSTROP arg2=STR|arg1=FILENAME bop=BFILEOP arg2=FILENAME|arg1=UINT bop=BIOP arg2=UINT) -> ^($bop $arg1 $arg2)
	|	(arg1=STR bop=BSTROP arg2=STR|arg1=FILENAME bop=BFILEOP arg2=FILENAME|arg1=UINT bop=BIOP arg2=UINT)(op=LOGICOR|op=LOGICAND) cond -> ^($op ^($bop $arg1 $arg2) cond);
unary_cond
	:	(uop=USTROP arg=STR|uop=UFILEOP arg=FILENAME) -> ^($uop $arg)
	|	(uop=USTROP arg=STR|uop=UFILEOP arg=FILENAME) (op=LOGICOR|op=LOGICAND) cond -> ^($op ^($uop $arg) cond);

LOGICOR	:	'||';
LOGICAND:	'&&';
//Conditional Operators
//Naming convention: first character B=binary, fist character U=Unary
BIOP		:	('-eq'|'-ne'|'-lt'|'-le'|'-gt'|'-ge');
UFILEOP		:	('-a'|'-b'|'-c'|'-d'|'-e'|'-f'|'-h'|'-k'|'-p'|'-r'|'-s'|'-t'|'-u'|'-w'|'-x'|'-O'|'-G'|'-L'|'-S'|'-N');
BFILEOP		:	('-nt'|'-ot'|'-ef');
USTROP		:	('-n'|'-z');
BSTROP		:	('=='|'!'?'='|'<'|'>');

UINT	:	DIGIT+;
LDCOND	:	'[[ ';
RDCOND	:	' ]]';
LCOND	:	'[ ';
RCOND	:	' ]';
TESTCOND:	'test';
STR	:	'"'.*'"';
FILENAME:	('.'|'/'|LETTER|DIGIT)+;
fragment
LETTER	:	('a'..'z'|'A'..'Z');
fragment
DIGIT	:	('0'..'9');

WS	:	(' '|'\t')+{ $channel=HIDDEN; };
