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
/// \file cppbash_builtin.h
/// \author Nathan Eloe
/// \brief Base class for builtin functions in bash
///

#ifndef CPPBASH_BUILTIN_H
#define CPPBASH_BUILTIN_H

//some macros for easier input/output

#ifndef OUTPUT_BUF
#define OUTPUT_BUF *cppbash_builtin::out_stream
#endif

#ifndef ERROR_BUF
#define ERROR_BUF *cppbash_builtin::err_stream
#endif

#ifndef INPUT_BUF
#define INPUT_BUF *cppbash_builtin::inp_stream
#endif

#include <iostream>
#include <vector>
#include <string>

//the standard classes being used for this class
//cout,cerr, and cin are used for default output/input locations
using std::cout;
using std::cerr;
using std::cin;
using std::istream;
using std::ostream;
using std::vector;
using std::string;

class cppbash_builtin
{
  public:
    cppbash_builtin();
    virtual int exec(vector<string> bash_args)=0;
    void set_output_stream(ostream& ostr) {out_stream = &ostr;}
    void set_error_steram(ostream& ostr) {err_stream = &ostr;}
    void set_input_stream(istream& istr) {inp_stream = &istr;}
  protected:
    ostream *out_stream;
    ostream *err_stream;
    istream *inp_stream;
};

#endif
