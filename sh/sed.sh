#!/usr/bin/env bash

# sed one-liner for case-conversion
# $'string' 保留变量中的换行符
input=$'This is for the sed one-liner of Case-Conversion\nTest Prueba'

echo -e "input=This is for the sed one-liner of Case-Conversion\nTest,pruEba"
echo

tr '[:upper:]' '[:lower:]' <<<$input
tr A-Z a-z <<<$input

# gnu sed extension
# \L: Turn the replacement to lowercase until a \U or \E is found
# \l: Turn the next character to lowercase
# \U: Turn the replacement to uppercase until a \L or \E is found,
# \u: Turn the next character to uppercase
# \E: Stop case conversion started by \L or \U

sed -e 's/\(.*\)/\L\1/' <<<$input
sed -e 's/.*/\L&/' <<<$input

# sed s command: s/regexp/replacement/flags
# flags: g,number,p, w,e,i|I,m|M
# p: If the substitution was made, then print the new pattern space.
echo "TestTEst" | sed 's/test/TEST/'
echo "TestTEst" | sed 's/test/TEST/i'
echo "TestTEst" | sed 's/test/TEST/ig'
echo "TestTEst" | sed 's/test/TEST/g2'
echo "TestTEst" | sed 's/test/TEST/ip'

# sed accept multiple files at once
sed -n 's@#!/@sedsed@p' /etc/rc*/*
