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
/// \file builtin_map.h
/// \author Nathan Eloe
/// \brief Declaration of a class to keep track of builtin functions
///

#ifndef BUILTIN_MAP_H
#define BUILTIN_MAP_H

#include <map>
#include <vector>
#include "cppbash_builtin.h"

typedef std::pair<std::string, cppbash_builtin*> builtin_entry;

class builtin_map
{
  public:
    builtin_map();
    bool register_builtin(const std::string bi_name, cppbash_builtin *bi);
    bool is_registered (const std::string bi_name);
    int exec_builtin(const std::string name, std::vector<std::string> args);
  private:
    std::map<std::string, cppbash_builtin*> registered_builtins;
};

#endif
