#!/usr/bin/env bash

# bash变量保留换行符方法
# $'string' allows insert escape sequence in strings
input1=$'Hello World!\n==============\n'
# \cx x=control char
# \nnn octal, \xnn hex, \uxxxx, unicode, \Uxxxxxxxx
input2=$'Hello World!\cj==============\n'
input3=$'Hello World!\xa==============\n'
input4=$'Hello World!\12==============\n'
input5=$'Hello World!\u000a==============\n'
input6=$'Hello World!\ua==============\n'
input7=$'Hello World!\Ua==============\n'
input8=$'Hello World!\U0000000a==============\n'

for i in {1..8}; do
    eval echo -e \$input$i
    echo
done

echo printf method:
# printf -v NL, save output to NL
printf -v NL 'Hello World!\n===============\n'
echo "$NL"

echo

echo other method:
NL2='Hello World!
===============
'
echo "$NL2"
