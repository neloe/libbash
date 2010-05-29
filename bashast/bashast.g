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
