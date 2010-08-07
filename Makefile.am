###############################################
#Copyright 2010 Nathan Eloe
#
#This file is part of libbash.
#
#libbash is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 2 of the License, or
#(at your option) any later version.
#
#libbash is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with libbash.  If not, see <http://www.gnu.org/licenses/>.
###############################################
# Makefile.am for libbash
# Author: Nathan Eloe
###############################################
include doxygen.am

ACLOCAL_AMFLAGS = -I m4

TESTS = bashast/gunit/runtests.sh
TEST_EXTENSIONS= .sh
SH_LOG_COMPILER = /bin/bash

if HAVE_GTEST
TESTS += builtin_unittests
check_PROGRAMS = builtin_unittests
builtin_unittests_SOURCES = src/builtins/tests/run_tests.cpp
builtin_unittests_SOURCES += src/builtins/tests/echo_tests.cpp
builtin_unittests_LDADD = ${GTEST_LIBS} libcppbash.la
endif

lib_LTLIBRARIES = libcppbash.la
libcppbash_la_SOURCES = src/cppbash_builtin.cpp
libcppbash_la_SOURCES += src/builtins/echo_builtin.cpp

coding_standard.pdf: coding_standard/coding_standard.tex
	@PDFLATEX@ coding_standard/coding_standard.tex 2&>1 > /dev/null

grammar.run: bashast.g
	@JAVA@ -classpath @antlr_cp@ -Xmx1024m org.antlr.Tool -Xconversiontimeout 20000 $<
	touch $@

bashast.g: bashast/bashast.g
	sed -e 's/CommonTree/pANTLR3_BASE_TREE/g' -e 's/Java/C/g' $< > $@

