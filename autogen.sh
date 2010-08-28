#!/bin/sh
libtoolize
aclocal -I m4
automake --add-missing
autoreconf
./configure --enable-gtest
