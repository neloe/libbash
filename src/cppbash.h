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

#include <bashast.h>
#include <iostream>
#include <string>
#include <builtin_map.h>
#include <cppbash_builtin.h>
#include <builtins.h>

///
/// \class cppbash
/// \brief Class to load and excute bash source files
///
class cppbash
{
  public:
    ///
    /// \fn cppbash
    /// \brief Default constructor for cppbash class
    ///
    cppbash();
    ///
    /// \fn cppbash
    /// \brief Constructor for cppbash class; Loads file for running
    /// \param file_name Name of bash source file
    ///
    cppbash(std::string file_name);
    ///
    /// \fn ~cppbash
    /// \brief Destructor for cppbash class
    ///
    ~cppbash();
    ///
    /// \fn load_source
    /// \brief Function to load file for running
    /// \param file_name Name of bash source file
    /// \return true on successful load and parse, false otherwise
    ///
    bool load_source(std::string file_name);
    ///
    /// \fn output_ast()
    /// \brief FOR DEBUGGING; outputs AST as a string to stdout
    ///
    void output_ast(){std::cout<<(char*)(bash_ast.tree->toStringTree(bash_ast.tree)->chars) << std::endl;}
    ///
    ///
    void run() {eval_subtree(bash_ast.tree);}
  private:
    ///
    /// \fn eval_subtree
    /// \brief evaluates the sub tree
    /// \param subtree the sub tree to evaluate
    ///
    void eval_subtree(const pANTLR3_BASE_TREE& subtree);
    ///
    /// \fn get_string
    /// \brief gets the string from the sub tree
    /// \param subtree to get the string value of
    ///
    std::string get_string(const pANTLR3_BASE_TREE& subtree);
    ///
    /// \fn init_nulls()
    /// \brief initialize the values of the variables at NULL
    ///
    void init_nulls();
    ///
    /// \var bash_ast
    /// \brief Contains the AST for the loaded file
    ///
    bashastParser_start_return bash_ast;
    ///
    /// \var parsr
    /// \brief contains the parser for the source file
    ///
    pbashastParser parsr;
    ///
    /// \var lexr
    /// \brief contains the lexer for the source file
    ///
    pbashastLexer lexr;
    ///
    /// \var token_stream
    /// \brief contains the token stream for the source file
    ///
    pANTLR3_COMMON_TOKEN_STREAM token_stream;
    ///
    /// \var input
    /// \brief contains the input stream for the source file
    ///
    pANTLR3_INPUT_STREAM input;
    ///
    /// \var registered_builtins
    /// \brief the map for the built in functions
    ///
    builtin_map registered_builtins;

    ///
    /// \fn register_builtin
    /// \brief function that registers builtin functions with the interpreter
    /// \param trigger command for the built in function
    /// \param fcn function class associated with builtin function
    ///
    void register_builtin(std::string trigger, cppbash_builtin &fcn);
    ///
    /// \fn init_builtins
    /// \brief function to register all the built ins in the constructor
    ///
    void init_builtins();

    // RULE FCNS (for the case)

    ///
    /// \fn list_rule
    /// \brief tells the interpreter how to handle a list subtree
    /// \param subtree subtree containing the list
    ///
    void list_rule(const pANTLR3_BASE_TREE& subtree);
    ///
    /// \fn command_rule
    /// \breif tells the interpreter how to handle a command subtree
    /// \param subtree subtree containing the list
    ///
    void command_rule(const pANTLR3_BASE_TREE& subtree);
};

#endif

