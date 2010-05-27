#!/bin/bash
#first, set up the classpath
OLDCP=$CLASSPATH
export CLASSPATH=".:/usr/share/java/antlr-3.2.jar:/Users/squishy/ANTLR/antlr.jar"
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
