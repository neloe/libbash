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

#first, set up the classpath
if type -p java-config > /dev/null; then
	export CLASSPATH=".:$(java-config -dp antlr-3)"
else
	export CLASSPATH=".:/usr/share/java/antlr-3.2.jar:/Users/squishy/ANTLR/antlr.jar"
fi
let failedtests=0
for gtest in `ls |grep gunit`; do
	grammar=`cat $gtest |grep gunit|awk '{print $2}'|awk -F';' '{print $1}'`
	grammar="$grammar.g"
	echo "Running unit tests for: $grammar"
	cp ../$grammar .
	java org.antlr.Tool $grammar
	javac *.java
	java org.antlr.gunit.Interp $gtest > $grammar.output
	failed=`cat $grammar.output|grep "Failures:"|awk -F: '{print $3}'|awk '{print $1}'`

	if [[ failed -ne '0' ]]; then
		echo "Test failed"
		let failedtests=failedtests+1
	else
		echo "Test Passed"
		rm $grammar.output
	fi
	rm *.java *.class *.g *.tokens
done

cat *.output 2> /dev/null
rm *.output 2> /dev/null

exit $failedtests
