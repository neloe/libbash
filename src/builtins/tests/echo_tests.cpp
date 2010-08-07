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
/// \file echo_tests.cpp
/// \brief series of unit tests for echo built in
/// \author Nathan Eloe
///
#include <iostream>
#include "../builtins.h"
#include <sstream>
#include <vector>
#include <gtest/gtest.h>

using namespace std;
TEST(echo_builtin_test, simple_output)
{
	vector<string> args;
	args.push_back("hello");
	args.push_back("world");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("hello world\n", test_output.str());
}
TEST(echo_builtin_test, suppress_newline)
{
	vector<string> args;
	args.push_back("-n");
	args.push_back("foo");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("foo",test_output.str());
}
TEST(echo_builtin_test, enable_escape)
{
	vector<string> args;
	args.push_back("-e");
	args.push_back("foo\\t");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("foo\t\n",test_output.str());
}
TEST(echo_builtin_test, no_escape)
{
	vector<string> args;
	args.push_back("foo\\t");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("foo\\t\n",test_output.str());
}
TEST(echo_builtin_test, only_options)
{
	vector<string> args;
	args.push_back("-n");
	args.push_back("foo");
	args.push_back("-e");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("foo -e",test_output.str());
}
TEST(echo_builtin_test, only_options2)
{
	vector<string> args;
	args.push_back("foo");
	args.push_back("-n");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("foo -n\n",test_output.str());
}
TEST(echo_builtin_test, combined_options)
{
	vector<string> args;
	args.push_back("-ne");
	args.push_back("fo\\to");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("fo\to",test_output.str());
}
TEST(echo_builtin_test, combined_options2)
{
	vector<string> args;
	args.push_back("-enE");
	args.push_back("fo\\to");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("fo\\to",test_output.str());
}
TEST(echo_builtin_test, fake_options)
{
	vector<string> args;
	args.push_back("-nea");
	args.push_back("fo\\to");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("-nea fo\\to\n",test_output.str());
}
TEST(echo_builtin_test, combined_options_alternating_e)
{
	vector<string> args;
	args.push_back("-enEeEe");
	args.push_back("fo\\to");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("fo\to",test_output.str());
}
TEST(echo_builtin_test, coflicting_options)
{
	vector<string> args;
	args.push_back("-e");
	args.push_back("-E");
	args.push_back("fo\\to");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("fo\\to\n",test_output.str());
}
TEST(echo_builtin_test, coflicting_options2)
{
	vector<string> args;
	args.push_back("-e");
	args.push_back("-E");
	args.push_back("-e");
	args.push_back("fo\\to");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("fo\to\n",test_output.str());
}
TEST(echo_builtin_test, oct_escape)
{
	vector<string>args;
	args.push_back("-e");
	args.push_back("\\0135");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("]\n", test_output.str());
}
TEST(echo_builtin_test, hex_escape)
{
	vector<string>args;
	args.push_back("-e");
	args.push_back("\\x57");
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(args);
	ASSERT_EQ("W\n", test_output.str());
}

