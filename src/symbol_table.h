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
/// \file symbol_table.h
/// \brief declaration of a simple symbol table
/// \author Nathan Eloe
///

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <map>
#include <string>
#include <cstdlib>

using std::map;
using std::string;
///
/// \class symbol_table
/// \brief a class to implement a symbol table for bash
///
class symbol_table
{
	public:
		///
		/// \fn get_value
		/// \brief get the value associated with the variable name
		/// \param key name of variable to get value of
		/// \return value associated with the variable
		///
		string get_value(string key) {return table[key];}
		///
		/// \fn get_int_value
		/// \brief get the integer value associated with the variable name
		/// \param key name of variable to get integer value of
		/// \return integer value associated with the variable
		///
		int get_int_value(string key) {return (std::atoi(table[key].c_str()));}
		///
		/// \fn set_value
		/// \brief set the value of the variable with name key to val
		/// \brief key name of variable to set value of
		/// \brief string val value to set variable to
		///
		void set_value(string key, string val) {table[key]=val;}
	private:
		///
		/// \var table
		/// \brief map to hold variable names and values
		///
		map<string,string> table;
};
#endif

