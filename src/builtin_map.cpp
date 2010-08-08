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
/// \file builtin_map.cpp
/// \author Nathan Eloe
/// \brief Implementation of a class to keep track of built in functions
///

#include "builtin_map.h"

builtin_map::builtin_map()
{
}

void builtin_map::register_builtin(const std::string& bi_name, cppbash_builtin *bi)
{
  registered_builtins.insert(builtin_entry(bi_name, bi));
}

bool builtin_map::is_registered(const std::string &bi_name) const
{
	return registered_builtins.find(bi_name) != registered_builtins.end();
}

int builtin_map::exec_builtin(const std::string &bi_name, std::vector<std::string> args) const
{
  if (registered_builtins.find(bi_name) != registered_builtins.end())
  {
    return registered_builtins.find(bi_name)->second->exec(args);
  }
  return -1;
}
