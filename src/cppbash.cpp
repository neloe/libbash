/*
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
*/
///
/// \file cppbash.cpp
/// \author Nathan Eloe
/// \brief Implementation of a class for loading/running bash source
///

#include "cppbash.h"

cppbash::cppbash()
{
  init_nulls();
}

cppbash::cppbash(std::string file_name)
{
  init_nulls();
  load_source(file_name);
}

cppbash::~cppbash()
{
  if (parser)
  {
    parser->free(parser);
    parser=NULL;
  }
  if (lexer)
  {
    lexer->free(lexer);
    lexer=NULL;
  }
  if (token_stream)
  {
    token_stream->free(token_stream);
    token_stream=NULL;
  }
  if (input)
  {
    input->close(input);
    input=NULL;
  }
}

bool cppbash::load_source(std::string file_name)
{
  pANTLR3_UINT8 f_name=(pANTLR3_UINT8)file_name.c_str();
  if (input)
  {
    input->close(input);
    input=NULL;
  }
  input = antlr3AsciiFileStreamNew(f_name);;
  if (!input)
  {
    std::cerr << "Unable to open file for opening due to malloc error\n";
    return false;
  }
  if (lexer)
  {
    lexer->free(lexer);
    lexer=NULL;
  }
  lexer = bashastLexerNew(input);
  if (!lexer)
  {
    std::cerr << "Unable to create the lexer due to malloc error\n";
    return false;
  }
  if (token_stream)
  {
    token_stream->free(token_stream);
    token_stream=NULL;
  }
  token_stream = antlr3CommonTokenStreamSourceNew(ANTLR3_SIZE_HINT,\
    TOKENSOURCE(lexer));
  if (!token_stream)
  {
    std::cerr << "Out of memory trying to allocate token stream\n";
    return false;
  }
  if (parser)
  {
    parser->free(parser);
  }
  parser = bashastParserNew(token_stream);
  if (!parser)
  {
    std::cerr << "Out of memory trying to allocate parser\n";
    return false;
  }
  bash_ast = parser->start(parser);
  return true;
}

void cppbash::init_nulls()
{
  parser=NULL;
  lexer=NULL;
  token_stream=NULL;
  input=NULL;
}

void cppbash::eval_subtree(const pANTLR3_BASE_TREE& subtree)
{
  std::string token = (char*) (subtree->toString(subtree)->chars);
  if (token=="LIST")
  {
    list_rule(subtree);
  }
  else if (token=="=")
  {
    var_def_rule(subtree);
  }
}

std::string cppbash::get_string(const pANTLR3_BASE_TREE& subtree)
{
  std::string return_str;
  for (int i=0; i<subtree->getChildCount(subtree); i++)
  {
    return_str+=(std::string)(char*)(((pANTLR3_BASE_TREE)(subtree->getChild(subtree,i)))->toString(((pANTLR3_BASE_TREE)(subtree->getChild(subtree,i))))->chars);
  }
  return return_str;
}

void cppbash::list_rule(const pANTLR3_BASE_TREE& subtree)
{
  for (int i=0; i<subtree->getChildCount(subtree); i++)
  {
    eval_subtree((pANTLR3_BASE_TREE)(subtree->getChild(subtree,i)));
  }
}

void cppbash::var_def_rule (const pANTLR3_BASE_TREE& subtree)
{
    std::string var=(std::string)(char*)(((pANTLR3_BASE_TREE)(subtree->getChild(subtree,0)))->toString(((pANTLR3_BASE_TREE)(subtree->getChild(subtree,0))))->chars);
    std::string val=(std::string)(char*)(((pANTLR3_BASE_TREE)(subtree->getChild(subtree,1)))->toString(((pANTLR3_BASE_TREE)(subtree->getChild(subtree,1))))->chars);
	symbol_table[var]=val;
}

void cppbash::output_st()
{
	auto it=symbol_table.begin();
	for (it; it!=symbol_table.end(); it++)
	{
		std::cout << it->first << "\t" << it->second << "\n";
	}
}
