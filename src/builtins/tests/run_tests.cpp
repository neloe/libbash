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
/// \file run_tests.cpp
/// \brief runs unit tests for builtin bash functionality
///

#include<gtest/gtest.h>

///
/// \brief runs all the unit tests linked to this file
///
int main(int argc, char* argv[])
{
  ::testing::InitGoogleTest (&argc, argv);
  return RUN_ALL_TESTS();
}
