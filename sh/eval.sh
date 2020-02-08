#!/usr/bin/env bash


input1='variable input1'
input2='variable input2'
input3='variable input3'
input4='variable input4'
input5='variable input5'
input6='variable input6'
input7='variable input7'
input8='variable input8'
input9='variable input9'
input10='variable input10'

# 先扩展$i，\$因为quoted所以不求值，扩展后变成，eval echo -e $input1，$input2，...，接着eval 把后面的arg运行,再次求值
# eval [arg...], combine the args into a single string, and used as input to the shell, then execute the resulting shell command
# eval: posix shell builtin: construct command  by concatenating arguments
for i in {1..10}; do
    eval echo -e \$input$i
    echo
done

# usually used with command substitution
# without explicit eval, shell tries to execute the results, instead of evaluating it
$(echo var=value) # var=value: command not found
echo

eval $(echo var=value)
echo $var

# eval parsed twice, in each parsing, quote removal performed last
var1=25
var2='$var1'
var3='$var2'
echo "$var3" # output: $var2
eval echo "$var3" # output: $var1
eval eval echo "$var3" # output: 25
