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
/// \file test_symbol_table.cpp
/// \brief series of unit tests for symbol table structure
/// \author Nathan Eloe
///

#include <UnitTest++.h>
#include <iostream>
#include "../symbol_table.h"
using namespace std;

//Test to make sure that accessing a variable that hasn't been declared yet
//produces an empty string
TEST(CheckEmptyVariable)
{
	symbol_table my_tab;
	CHECK_EQUAL(my_tab.get_value("foo").c_str(), "");
}

//Test to ensure adding a variable saves it's value
TEST(VariableAdd)
{
	symbol_table my_tab;
	my_tab.set_value("foo", "bar");
	CHECK_EQUAL(my_tab.get_value("foo").c_str(),"bar");
}

//Test to create and change a variable's value
TEST(VariableChange)
{
	symbol_table my_tab;
	my_tab.set_value("foo","bar");
	CHECK_EQUAL(my_tab.get_value("foo").c_str(),"bar");
	my_tab.set_value("foo","bar2");
	CHECK_EQUAL(my_tab.get_value("foo").c_str(),"bar2");
}

int main()
{
	return UnitTest::RunAllTests();
}
