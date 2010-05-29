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
