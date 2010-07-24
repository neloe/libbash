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
/// \file echotest.cpp
/// \author Nathan Eloe
/// \brief tests the run function of the cppbash class
///
#include "../src/cppbash.h"
#include <iostream>
#include <cstdlib>
#include <string>
using namespace std;

int main(int argc, char* argv[])
{
  if (argc<2)
  {
    cerr << "Please supply a file\n";
    exit(1);
  }
  cppbash test_bash((string)argv[1]);
  test_bash.run();
  return (0);
}
