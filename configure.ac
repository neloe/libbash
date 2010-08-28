#############################################
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
##############################################

AC_PREREQ([2.65])
AC_CONFIG_MACRO_DIR([m4])
AC_INIT([libbash], [0.1],[powerofazure@gmail.com])
AM_INIT_AUTOMAKE([parallel-tests subdir-objects])
AC_PROG_CXX
LT_INIT
AC_PROG_LIBTOOL
AM_PROG_LIBTOOL
AC_PATH_PROG([JAVA],[java],"no")
if test "$JAVA" = "no"; then
	AC_MSG_ERROR([No java executable found])
fi
GTEST_LIB_CHECK(,[:],[:])
AC_ARG_WITH(antlr, [],with_antlr=$withval,with_antlr=jc)
if test "$with_antlr" = "jc"; then
	AC_PATH_PROG(JAVA_CONFIG, java-config, "no")
	if test "$JAVA_CONFIG" = "no"; then
		AC_MSG_ERROR([java-config tool not found.  Please give the location of an antlr3 jar using --with-antlr])
	fi
	AC_SUBST(antlr_cp,["$($JAVA_CONFIG -dp antlr-3)"])
else
	AC_CHECK_FILE(["$with_antlr"],[],[AC_MSG_ERROR(Antlr jar $with_antlr not found)])
	AC_SUBST(antlr_cp,["$with_antlr"])
fi
AC_PATH_PROG([PDFLATEX],[pdflatex],"no")
if test "$PDFLATEX" = "no"; then
	AC_MSG_RESULT([pdflatex not found on your system. You will be unable to generate the coding standard])
fi
AC_CHECK_LIB([antlr3c],[antlr3AsciiFileStreamNew],[],[AC_MSG_ERROR(libasntlr3c not found.  Have you installed the C antlr runtime?)])
AC_CONFIG_FILES([Makefile])
DX_HTML_FEATURE(ON)
DX_MAN_FEATURE(OFF)
DX_CHM_FEATURE(OFF)
DX_CHI_FEATURE(OFF)
DX_RTF_FEATURE(OFF)
DX_XML_FEATURE(OFF)
DX_PDF_FEATURE(OFF)
DX_PS_FEATURE(OFF)
DX_INIT_DOXYGEN([$PACKAGE_NAME], [Doxyfile])
AC_OUTPUT
