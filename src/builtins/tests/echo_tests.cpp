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
#include <UnitTest++.h>

using namespace std;
SUITE(echo_builtin_tests)
{
	TEST(simple_output)
	{
		vector<string> args;
		args.push_back("hello");
		args.push_back("world");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("hello world\n", test_output.str().c_str());
	}
	TEST(suppress_newline)
	{
		vector<string> args;
		args.push_back("-n");
		args.push_back("foo");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("foo",test_output.str().c_str());
	}
	TEST(enable_escape)
	{
		vector<string> args;
		args.push_back("-e");
		args.push_back("foo\\t");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("foo\t\n",test_output.str().c_str());
	}
	TEST(no_escape)
	{
		vector<string> args;
		args.push_back("foo\\t");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("foo\\t\n",test_output.str().c_str());
	}
	TEST(only_options)
	{
		vector<string> args;
		args.push_back("-n");
		args.push_back("foo");
		args.push_back("-e");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("foo -e",test_output.str().c_str());
	}
	TEST(only_options2)
	{
		vector<string> args;
		args.push_back("foo");
		args.push_back("-n");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("foo -n\n",test_output.str().c_str());
	}
	TEST(combined_options)
	{
		vector<string> args;
		args.push_back("-ne");
		args.push_back("fo\\to");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("fo\to",test_output.str().c_str());
	}
	TEST(combined_options2)
	{
		vector<string> args;
		args.push_back("-enE");
		args.push_back("fo\\to");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("fo\\to",test_output.str().c_str());
	}
	TEST(fake_options)
	{
		vector<string> args;
		args.push_back("-nea");
		args.push_back("fo\\to");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("-nea fo\\to\n",test_output.str().c_str());
	}
	TEST(combined_options_alternating_e)
	{
		vector<string> args;
		args.push_back("-enEeEe");
		args.push_back("fo\\to");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("fo\to",test_output.str().c_str());
	}
	TEST(coflicting_options)
	{
		vector<string> args;
		args.push_back("-e");
		args.push_back("-E");
		args.push_back("fo\\to");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("fo\\to\n",test_output.str().c_str());
	}
	TEST(coflicting_options2)
	{
		vector<string> args;
		args.push_back("-e");
		args.push_back("-E");
		args.push_back("-e");
		args.push_back("fo\\to");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("fo\to\n",test_output.str().c_str());
	}
	TEST(oct_escape)
	{
		vector<string>args;
		args.push_back("-e");
		args.push_back("\\0135");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("]\n", test_output.str().c_str());
	}
	TEST(hex_escape)
	{
		vector<string>args;
		args.push_back("-e");
		args.push_back("\\x57");
		stringstream test_output;
		echo_builtin my_echo(test_output,cerr,cin);
		my_echo.exec(args);
		CHECK_EQUAL("W\n", test_output.str().c_str());
	}
}
