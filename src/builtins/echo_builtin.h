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
/// \file echo_builtin.h
/// \author Nathan Eloe
/// \brief class that implements the echo builtin
///

#ifndef ECHO_BUILTIN_H
#define ECHO_BUILTIN_H

#include <cstdlib>
#include <iterator>
#include "../cppbash_builtin.h"

///
/// \class echo_builtin
/// \brief the echo builtin for bash
///
class echo_builtin: public virtual cppbash_builtin
{
  public:
    ///
    /// \brief default constructor, sets default streams
    /// \param outstream where to send standard output. Default: cout
    /// \param errstream where to send standard error. Default: cerr
    /// \param instream where to get standard input from.  Default cin
    ///
    echo_builtin(std::ostream &outstream=std::cout, std::ostream &errstream=std::cerr, std::istream &instream=std::cin);
    ///
    /// \brief runs the echo plugin on the supplied arguments
    /// \param bash_args the arguments to the echo builtin
    /// \return exit status of echo
    ///
    virtual int exec(std::vector<std::string> bash_args);
  private:
    ///
    /// \brief determines the options passed as arguments
    /// \param args list of arguments passed to echo
    /// \param suppress_nl returns back whether to suppress newlines
    /// \param enable_escapes returns back whether to enable escapes
    void determine_options(std::vector<std::string> &args, bool &suppress_nl, bool &enable_escapes);
    ///
    /// \brief checks to see if the trailing newline is suppressed
    /// \param args arguments to check, removes suppressing escape sequences
    /// \return true if newlines are suppressed, false otherwise
    ///
    bool newline_suppressed(std::vector<std::string> &args);
    ///
    /// \brief replaces all escape seqs in std::string with actual escape seq.
    /// \param args list of arguments to replace escape sequences in
    ///
    void replace_escapes(std::vector<std::string> &args);
    ///
    /// \brief replaces all instances of to_rep with rep
    /// \param word word to replace instances in
    /// \param to_rep the pattern to replace in the std::string
    /// \param rep what to replace to_rep with
    ///
    void replace_all(std::string &word, const std::string &to_rep, const std::string &rep);
    ///
    /// \brief replaces octal and hex escapes with escape sequences
    /// \param word std::string to replace numeric escapes in
    ///
    void replace_numeric_escapes(std::string &word);
};

#endif
