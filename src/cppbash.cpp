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

#include <cppbash.h>

cppbash::cppbash()
{
  init_nulls();
  init_builtins();
}

cppbash::cppbash(std::string file_name)
{
  init_nulls();
  init_builtins();
  load_source(file_name);
}

cppbash::~cppbash()
{
  if (parsr)
  {
    parsr->free(parsr);
    parsr=NULL;
  }
  if (lexr)
  {
    lexr->free(lexr);
    lexr=NULL;
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
  if (lexr)
  {
    lexr->free(lexr);
    lexr=NULL;
  }
  lexr = bashastLexerNew(input);
  if (!lexr)
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
    TOKENSOURCE(lexr));
  if (!token_stream)
  {
    std::cerr << "Out of memory trying to allocate token stream\n";
    return false;
  }
  if (parsr)
  {
    parsr->free(parsr);
  }
  parsr = bashastParserNew(token_stream);
  if (!parsr)
  {
    std::cerr << "Out of memory trying to allocate parser\n";
    return false;
  }
  bash_ast = parsr->start(parsr);
  return true;
}

void cppbash::init_nulls()
{
  parsr=NULL;
  lexr=NULL;
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
  else if (token=="COMMAND")
  {
    command_rule(subtree);
  }
}

std::string cppbash::get_string(const pANTLR3_BASE_TREE& subtree)
{
  std::string return_str;
  for (int i=0; i<subtree->getChildCount(subtree); i++)
  {
    return_str+=(std::string)(char*)\
    (((pANTLR3_BASE_TREE)(subtree->getChild(subtree,i)))\
    ->toString(\
    ((pANTLR3_BASE_TREE)(subtree->getChild(subtree,i)))\
    )->chars);
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

void cppbash::command_rule(const pANTLR3_BASE_TREE& subtree)
{
  int comm=0;
  std::string cmd;
  vector<std::string> bash_args;
  while ((std::string)(char*)(((pANTLR3_BASE_TREE)(subtree->getChild(subtree,comm)))->toString((pANTLR3_BASE_TREE)(subtree->getChild(subtree,comm)))->chars)!="STRING")
  {
    ++comm;
  }
  cmd=get_string((pANTLR3_BASE_TREE)(subtree->getChild(subtree,comm)));
  for (int i=comm+1; i<subtree->getChildCount(subtree); i++)
  {
    bash_args.push_back(get_string((pANTLR3_BASE_TREE)(subtree->getChild(subtree,i))));
  }
  if (registered_builtins.is_registered(cmd))
  {
    registered_builtins.exec_builtin(cmd, bash_args);
  }
  else
  {
    std::cout << "COMMAND FOUND: " << cmd << " ";
    for (int i=0; i<bash_args.size(); i++)
    {
      std::cout << bash_args[i] << " ";
    }
    std::cout << std::endl;
  }
}

void cppbash::register_builtin(std::string trigger, cppbash_builtin &fcn)
{
  registered_builtins.register_builtin(trigger, &fcn);
}

void cppbash::init_builtins()
{
  //create an object for each builtin
  echo_builtin my_echo;
  register_builtin("echo", my_echo);
}
