#!/bin/bash
# A "featureful" script that demonstrates all the functionality of the parser

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

#comment
#demonstrates expansions in strings both double- and non-quoted
function lots_o_echo() {
  echo "The number of tests that have failed: $failedtests"
  echo '$failedtests'
  echo $failedtests
}

do_some_arith() {
  (( 5*4 ))
  (( 5**4 ))
  (( $failedtests+5/4 ))
  (( $z+-3 ))
}

function arrays() (
  asdf=(a b c d)
  echo ${asdf[3]}
  foo=(`echo 6` b c d)
  arr[foo]=3
  bar=(a b [5]=c);
)

echo {a,b}
echo {a..d}
echo {{a,b},c,d}
echo a{b,c}

$(echo foobar)
ls |grep gunit >> filelist

case `echo asdf` in
gz)
echo yay
;;
bzip)
echo three
;;
*) echo woo
;;
esac

for each in `ls |grep log`; do
  echo $each
  cat each
done

for ((5+3;6+2;3+1)); do echo yay; done

select each in `ls |grep output`; do
 echo asdf 2> /dev/null
done

if echo yay2; then
  echo yay
fi

until [[ -a this/is.afile ]]; do
  touch this/is.afile
done

while [ -n foobar ]; do
  echo "file found"
done

if test 5 -eq 6; then
  echo "something's wrong"
fi

echo this command has multiple arguments

wc <(cat /usr/share/dict/linux.words)

cd build && ./configure && make && make_install || echo fail

cd /usr/bin; ls -al|grep more

asdf=parameters
${asdf:-foo}
${asdf:8}
${!asdf*}
${!asdf@}
${#foo}
${replaice/with/pattern}
${asdf#bar}
${asdf##bar}
${asdf%bar}
${asdf%bar}
$1 $@ $*
$?
${PV//./_}
${PV/#foo/bar}
${PV/%foo/bar}

MY_PN=${PN/asterisk-}

cat asdf |grep three 2>&1 > /dev/null
echo asdf >> APPEND
echo cat <<<word
