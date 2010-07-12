#!/bin/bash
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
#variable for number of tests
let failedtests=0

#test running function
function rtest {
	freason=""
	gramname=`cat $SCRIPTDIR/$1 |grep gunit|awk '{print $2}'|awk -F';' '{print $1}'`
	grammar="$gramname.g"
	if [[ ! -a "$grammar" ]]; then
		cp "$SCRIPTDIR/../$grammar" $SCRIPTDIR
	fi
	if [[ ! -a "$SCRIPTDIR/${gramname}Lexer.java" && ! -a "$SCRIPTDIR/${gramname}Parser.java" ]]; then
		java -Xmx512m org.antlr.Tool -Xconversiontimeout 20000 $SCRIPTDIR/$grammar
		if [[ ! -a "$SCRIPTDIR/${gramname}Lexer.java" && ! -a "$SCRIPTDIR/${gramname}Parser.java" ]]; then
			freason="Grammar generation failure"
		fi
	fi
	if [[ $freason == "" && ! -a "$SCRIPTDIR/${gramname}Lexer.class" && ! -a "$SCRIPTDIR/${gramname}Parser.class" ]]; then
		javac $SCRIPTDIR/*.java 2> /dev/null
		if [[ ! -a "$SCRIPTDIR/${gramname}Lexer.class" && ! -a "$SCRIPTDIR/${gramname}Parser.class" ]]; then
			freason="Compilation failure"
		fi
	fi
	java org.antlr.gunit.Interp $SCRIPTDIR/$1 > $1.output
	failed=`cat $1.output|grep "Failures:"|awk -F: '{print $3}'|awk '{print $1}'`

	if [[ $freason == "" && failed -ne '0' ]]; then
		freason="Unit test failure"
	fi
	if [[ $freason == "" ]]; then
		printf "\e[0;0m$1:\e[0;32m passed\e[0;0m\n"
		rm $1.output
	else
		printf "\e[0;0m$1:\e[0;31m fail\e[0m: $freason\n"
		((failedtests++))
	fi
}

#Get the directory of the script
SCRIPTDIR=`dirname $0`
#set up the classpath
if type -p java-config > /dev/null; then
	export CLASSPATH=".:$SCRIPTDIR:$(java-config -dp antlr-3)"
else
	export CLASSPATH=".:$SCRIPTDIR:/usr/share/java/antlr-3.2.jar:/Applications/ANTLRWorks.app/Contents/Resources/Java/antlrworks.jar"
fi

if [[ $# -eq 0  ]]; then
	for gtest in `ls ${SCRIPTDIR}|grep gunit`; do
		rtest $gtest
	done
else
	for gtest in "$@"; do
		if [[ -a $gtest ]]; then
			rtest $gtest
		else
			echo "gunit file not found: $gtest"
		fi
	done
	cat $SCRIPTDIR/*.output 2> /dev/null
	rm $SCRIPTDIR/*.output 2> /dev/null
fi
if [[ $# -gt 0 ]]; then
	testsrun=$#
else
	testsrun=`ls $SCRIPTDIR | grep gunit | wc -l`
fi
echo "==========================="
printf "Test summary:\n\e[0;32mPass:\e[0;0m $(($testsrun-$failedtests))\n\e[0;31mFail: \e[0;0m$failedtests\n"

rm $SCRIPTDIR/*.output 2> /dev/null
rm $SCRIPTDIR/*.java 2> /dev/null
rm $SCRIPTDIR/*.class 2> /dev/null
rm $SCRIPTDIR/*.tokens 2> /dev/null
rm $SCRIPTDIR/*.g 2> /dev/null
exit $failedtests
