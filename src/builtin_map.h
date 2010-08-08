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

///
/// \var typedef std::pair<std::string, cppbash_builtin*> builtin_entry
/// \brief type definition for entries to the builtin map
///
typedef std::pair<std::string, cppbash_builtin*> builtin_entry;

///
/// \class builtin_map
/// \brief a class to keep track of registered builtin functions
///
class builtin_map
{
  public:
		///
		/// \brief Default constructor
		///
		builtin_map();
		///
		/// \brief registers the builtin with the runtime for use
		/// \param bi_name the name of the builtin (triggers use of builtin)
		/// \param bi a pointer to the builtin class
		///
    void register_builtin(const std::string &bi_name, cppbash_builtin *bi);
    ///
		/// \brief Checks to see if the builting bi_name is registered
		/// \param bi_name the name of the builtin to check
		/// \return true if builtin is registered, false otherwise
		///
		bool is_registered (const std::string &bi_name) const;
		///
		/// \brief executes the registered builtin with the supplied arguments
		/// \param name name of builtin to execute
		/// \param args arguments to pass to builtin
		/// \return exit status of executing the builtin, -1 if builting not found
		///
    int exec_builtin(const std::string &bi_name, std::vector<std::string> args) const;
  private:
		///
		/// \var std::map<std::string, cppbash_builtin> registered_builtins
		/// \brief a map to hold the registered builtins
		///
    std::map<std::string, cppbash_builtin*> registered_builtins;
};

#endif
