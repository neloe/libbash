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
/// \file cppbash.h
/// \author Nathan Eloe
/// \brief Declaration of a class for loading and running bash source
///

#ifndef CPPBASH_H
#define CPPBASH_H

#include "bashast.h"
#include <iostream>
#include <string>
#include <map>

///
/// \class cppbash
/// \brief Class to load and execute bash source files
///
class cppbash
{
  public:
    ///
    /// \brief Default constructor for cppbash class
    ///
    cppbash();
    ///
    /// \brief Constructor for cppbash class; Loads file for running
    /// \param file_name Name of bash source file
    ///
    cppbash(std::string file_name);
    ///
    /// \brief Destructor for cppbash class
    ///
    ~cppbash();
    ///
    /// \brief Function to load file for running
    /// \param file_name Name of bash source file
    /// \return true on successful load and parse, false otherwise
    ///
    bool load_source(std::string file_name);
    ///
    /// \brief runs the loaded bash source
    ///
    void run() {eval_subtree(bash_ast.tree);}
		///
		/// \brief outputs the contents of the symbol table to stdout
		///
		void output_st();
  private:
    ///
    /// \brief evaluates the sub tree
    /// \param subtree the sub tree to evaluate
    ///
    void eval_subtree(const pANTLR3_BASE_TREE& subtree);
    ///
    /// \brief gets the resulting stream from the sub tree
    /// \param subtree to get string value of
    /// \return resulting string from subtree
    ///
    std::string get_string(const pANTLR3_BASE_TREE& subtree);
    ///
    /// \brief initialize the values of the members at NULL
    ///
    void init_nulls();
    ///
    /// \var bash_ast
    /// \brief contains the AST for the loaded file
    ///
    bashastParser_start_return bash_ast;
    ///
    /// \var parser
    /// \brief pointer to the parser for the source file
    ///
    pbashastParser parser;
    ///
    /// \var lexer
    /// \brief pointer to the lexer for the source file
    ///
    pbashastLexer lexer;
    ///
    /// \var token_stream
    /// \brief points to the token stream for the source file
    ///
    pANTLR3_COMMON_TOKEN_STREAM token_stream;
    ///
    /// \var input
    /// \brief points to the input stream for the source file
    ///
    pANTLR3_INPUT_STREAM input;
    
    // RULE FUNCTIONS

    ///
    /// \brief tells the interpreter how to handle a list subtree
    /// \param subtree pointer to sub tree containing the list
    ///
    void list_rule(const pANTLR3_BASE_TREE& subtree);
		///
		/// \brief tells the interpreter how to handle variable setting
		/// \param subtree pointer to sub tree containing the variable def
		///
		void var_def_rule (const pANTLR3_BASE_TREE& subtree);
    // DATA STRUCTURES

    ///
    /// \var symbol_table
    /// \brief simple map to hold values of variables
    ///
    std::map<std::string, std::string> symbol_table;
};

#endif
