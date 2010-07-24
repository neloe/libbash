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
#include "../cppbash_builtin.h"

///
/// \class echo_builtin
/// \brief the echo builtin for bash
///
class echo_builtin: public virtual cppbash_builtin
{
  public:
    ///
    /// \fn echo_builtin
    /// \brief default constructor
    ///
    echo_builtin(){};
    ///
    /// \fn exec
    /// \brief runs the echo plugin on the supplied arguments
    /// \param bash_args the arguments to the echo builtin
    /// \return exit status of echo
    ///
    virtual int exec(vector<string> bash_args);
  private:
    ///
    /// \fn newline_suppressed
    /// \brief checks to see if the trailing newline is suppressed
    /// \param args arguments to check, removes suppressing options
    /// \return true if newlines are suppressed, false otherwise
    ///
    bool newline_suppressed(vector<string> &args);
    ///
    /// \fn enable_escapes
    /// \brief checks to see if escape sequences should be enabled
    /// \param args arguments to check, removes -e and -E arguments
    /// \return true if escaped sequences are enabled, false otherwise
    ///
    bool enable_escapes(vector<string> &args);
    ///
    /// \fn replace_escapes
    /// \brief replaces all escape seqs in string with actual escape seq.
    /// \param args list of arguments to replace escape sequences in
    ///
    void replace_escapes(vector<string> &args);
    ///
    /// \fn replace_all
    /// \brief replaces all instances of to_rep with rep
    /// \param word word to replace instances in
    /// \param to_rep the pattern to replace in the string
    /// \param rep what to replace to_rep with
    ///
    void replace_all(string &word, const string &to_rep, const string &rep);
    ///
    /// \fn replace_numeric_escapes
    /// \brief replaces numeric escapes (\xHH, \0nnn) with escape sequences
    /// \param word string to replace numeric escapes in
    ///
    void replace_numeric_escapes(string &word);
};

#endif
