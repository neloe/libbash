#Copyright 2010 Nathan Eloe
#
#This file is part of libbash.
#
#libbash is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 2 of the License, or
#	(at your option) any later version.
#
#libbash is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with libbash.  If not, see <http://www.gnu.org/licenses/>.

#ADD TESTS AND BUILTINS HERE
TEST_SRC=echo_tests.cpp
BUILTIN_SRC=../echo_builtin.cpp
#ADD TESTS AND BUITLINS ABOVE THIS LINE
PARENT_SRC=../../cppbash_builtin.cpp
DRIVER_SRC=run_tests.cpp
TEST_OBJS=$(TEST_SRC:.cpp=.o)
BUILTIN_OBJS=$(BUILTIN_SRC:.cpp=.o)
PARENT_OBJ=$(PARENT_SRC:.cpp=.o)
DRIVER_OBJ=$(DRIVER_SRC:.cpp=.o)
EXECUTABLE=run_tests

CC=g++
LDFLAGS=-lUnitTest++
CFLAGS=-c
all: $(DRIVER_SRC) $(TEST_SRC) $(EXECUTABLE)

$(EXECUTABLE): $(DRIVER_OBJ) $(TEST_OBJS) $(BUILTIN_OBJS) $(PARENT_OBJ)
	$(CC) $(LDFLAGS) $(DRIVER_OBJ) $(TEST_OBJS) $(BUILTIN_OBJS) $(PARENT_OBJ) -o $(EXECUTABLE)

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	@rm $(EXECUTABLE) *.o ../*.o ../../cppbash_builtin.o 2> /dev/null
