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
grammar bashast_param;
options
{
	output	= AST;
	language	= Java;
	ASTLabelType	= CommonTree;
}
tokens
{
	OFFSET;
}

//parameter expansion

expr	:	param_exp;
param_exp
	:	param
	|	bracket_param;
bracket_param
	:	LBR name=NAME RBR -> ^($name)
	|	LBR name=NAME WORDOP word=NAME RBR -> ^(WORDOP $name $word)
	|	LBR name=NAME COLON os=UINT (COLON len=UINT)? RBR-> ^(OFFSET $name $os ^($len)?)
	|	LBR EXPT pre=NAME (op='*'|op='@')RBR -> ^(EXPT $pre $op)
	|	LBR EXPT name=NAME LSB (op='*'|op='@') RSB RBR -> ^(EXPT $name LSB $op RSB)
	|	LBR POUND name=NAME RBR -> ^(POUND $name)
	|	LBR name=NAME (op=POUND|op=POUNDPOUND) word=NAME RBR -> ^($op $name $word)
	|	LBR name=NAME (op=PCT|op=PCTPCT) word=NAME RBR -> ^($op $name $word)
	|	LBR name=NAME SLASH pattern=NAME SLASH str=NAME RBR -> ^(SLASH $name $pattern $str);
param	:	'$'NAME -> ^(NAME);
POUND	:	'#';
POUNDPOUND
	:	'##';
PCT	:	'%';
PCTPCT	:	'%%';
SLASH	:	'/';
EXPT	:	'!';
LSB	:	'[';
RSB	:	']';
COLON	:	':';
PSIGN	:	'$';
LBR	:	'${';
RBR	:	'}';
NAME	:	('a'..'z'|'A'..'Z'|'_')+;
WORDOP	:	(':-'|':='|':?'|':+');
UINT	:	DIGIT+;
fragment
DIGIT	:	('0'..'9');
/*(


fragment
DIGIT	:	('0'..'9');*/
