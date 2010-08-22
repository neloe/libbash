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

static void test_echo(const string& expected, std::initializer_list<string> args)
{
	stringstream test_output;
	echo_builtin my_echo(test_output,cerr,cin);
	my_echo.exec(vector<string>(args));
	ASSERT_EQ(expected, test_output.str());
}

#define TEST_ECHO(name, expected, ...) \
	TEST(echo_builtin_test, name) { test_echo(expected, {__VA_ARGS__}); }

TEST_ECHO(simple_output,                  "hello world\n", "hello", "world")
TEST_ECHO(suppress_newline,               "foo",           "-n", "foo")
TEST_ECHO(enable_escape,                  "foo\t\n",       "-e", "foo\\t")
TEST_ECHO(no_escape,                      "foo\\t\n",      "foo\\t")
TEST_ECHO(only_options,                   "foo -e",        "-n", "foo", "-e")
TEST_ECHO(only_options2,                  "foo -n\n",      "foo", "-n")
TEST_ECHO(combined_options,               "fo\to",         "-ne", "fo\\to")
TEST_ECHO(combined_options2,              "fo\\to",        "-enE", "fo\\to")
TEST_ECHO(fake_options,                   "-nea fo\\to\n", "-nea", "fo\\to")
TEST_ECHO(combined_options_alternating_e, "fo\to",         "-enEeEe", "fo\\to")
TEST_ECHO(conflicting_options,            "fo\\to\n",      "-e", "-E", "fo\\to")
TEST_ECHO(conflicting_options2,           "fo\to\n",       "-e", "-E", "-e", "fo\\to")
TEST_ECHO(oct_escape,                     "]\n",           "-e", "\\0135")
TEST_ECHO(hex_escape,                     "W\n",           "-e", "\\x57")
