dnl ############################################
dnl Copyright 2010 Nathan Eloe
dnl
dnl This file is part of libbash.
dnl
dnl libbash is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation, either version 2 of the License, or
dnl (at your option) any later version.
dnl
dnl libbash is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with libbash.  If not, see <http://www.gnu.org/licenses/>.
dnl #############################################

AC_PREREQ(2.65)
AC_CONFIG_MACRO_DIR([m4])
AC_INIT([libbash],[0.1],[powerofazure@gmail.com])
AM_INIT_AUTOMAKE([foreign parallel-tests subdir-objects])
AC_PROG_CXX
LT_INIT
AX_BOOST_BASE
AC_PATH_PROG([JAVA],[java],"no")
if test "$JAVA" = "no"; then
	AC_MSG_ERROR([No java executable found])
fi
GTEST_LIB_CHECK(,[:],[:])

AC_ARG_WITH(antlr, [],with_antlr=$withval,with_antlr=jc)
AS_IF([test "$with_antlr" = "jc"], [
		AC_PATH_PROG(JAVA_CONFIG, java-config, "no")
		if test "$JAVA_CONFIG" = "no"; then
			AC_MSG_ERROR([java-config tool not found.  Please give the location of an antlr3 jar using --with-antlr])
		fi
		AC_SUBST(antlr_cp,["$($JAVA_CONFIG -dp antlr-3)"])
	 ],
	 [test -f "$with_antlr"], [AC_SUBST(antlr_cp,["$with_antlr"])],
	 [AC_MSG_ERROR([Antlr jar $with_antlr not found])])

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
