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
grammar bashast_arith;
options
{
	output	= AST;
	language	= Java;
	ASTLabelType	= CommonTree;
}

tokens
{
	EXPR;
	ARITH_EXPR;
	PRIMARY;
	POST_INC_DEC;
	PRE_INC_DEC;
	UNARY;
	NEGATION;
	EXPONENT;
	TIMES_DIV_MOD;
	ADD_SUB;
	BITSHIFT;
	COMPARE;
	BITWISE_AND;
	BITWISE_OR;
	BITWISE_XOR;
	LOGIC_AND;
	LOGIC_OR;
}
//start rule
expr	:	arith_expr -> ^(EXPR arith_expr);
//stubs to be implemented later
//param	:	'asdf';
var	:	NAME;
//end stubs
arith_expr
	:	logicor -> ^(ARITH_EXPR logicor);
primary	:	UINT -> ^(PRIMARY UINT)
	|	LPAREN arith_expr RPAREN 	-> ^(PRIMARY LPAREN arith_expr RPAREN);
post_inc_dec
	:	var(op=INC|op=DEC)	 -> ^(POST_INC_DEC var $op);
pre_inc_dec
	:	(op=INC|op=DEC)var 	-> ^(PRE_INC_DEC $op var);
unary	:	primary 	-> ^(UNARY primary)
	|	PLUS primary	-> ^(UNARY PLUS primary)
	|	MINUS primary	-> ^(UNARY MINUS primary)
	|	post_inc_dec	-> ^(UNARY post_inc_dec)
	|	pre_inc_dec	-> ^(UNARY pre_inc_dec);
negation:	NEGATE?unary	-> ^(NEGATION unary);
exp	:	negation (EXP negation)* 	-> ^(EXPONENT negation (EXP negation)*);
tdm	:	exp (ltmdexpr)*	-> ^(TIMES_DIV_MOD exp ltmdexpr*);
ltmdexpr:	(TIMES|DIV|MOD) exp;
addsub	:	tdm (laddsubexpr)*		-> ^(ADD_SUB tdm laddsubexpr*);
laddsubexpr
	:	(PLUS|MINUS) tdm;
shifts	:	addsub (lshiftexpr)*	-> ^(BITSHIFT addsub lshiftexpr*);
lshiftexpr
	:	(LBSHIFT|RBSHIFT) addsub;
compare	:	shifts ((op=LEQ|op=GEQ|op='<'|op='>')shifts)?	-> ^(COMPARE shifts ($op shifts)*);
bitand	:	compare (BITAND compare)*	-> ^(BITWISE_AND compare (BITAND compare)*);
bitxor	:	bitand (BITXOR bitand)*		-> ^(BITWISE_XOR bitand (BITXOR bitand)*);
bitor	:	bitxor (BITOR bitxor)*		-> ^(BITWISE_OR bitxor (BITOR bitxor)*);
logicand:	bitor (LOGICAND bitor)*		-> ^(LOGIC_AND bitor (LOGICAND bitor)*);
logicor	:	logicand (LOGICOR logicand)*	-> ^(LOGIC_OR logicand (LOGICOR logicand)*);

UINT	:	('0'..'9')+;
NAME	:	(('a'..'z')|('A'..'Z'))+;
RPAREN	:	')';
LPAREN	:	'(';
INC	:	'++';
DEC	:	'--';
PLUS	:	'+';
MINUS	:	'-';
NEGATE	:	('!'|'~');
EXP	:	'**';
TIMES	:	'*';
DIV	:	'/';
MOD	:	'%';
LBSHIFT	:	'<<';
RBSHIFT	:	'>>';
LEQ	:	'<=';
GEQ	:	'>=';
NEQ	:	'<>';
BITAND	:	'&';
BITXOR	:	'^';
BITOR	:	'|';
LOGICAND:	'&&';
LOGICOR	:	'||';
WS	:	(' '|'\t')+{ $channel=HIDDEN; };
