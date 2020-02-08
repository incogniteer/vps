#!/usr/bin/env bash

RED='\x1b[1;31m'
NC='\x1b[0m'
# differences between ;(semicolon) and +(plus sign)
# both are mandatory in order to terminate the shell commands invoked by -exec/execdir
# how arguments are passed into find's -exec/-execdir parameter
# ; will execute multiple commands(separately for each argument)
echo find /etc/rc\* -exec echo Arg: {} ';' # \;, ";"
find /etc/rc* -exec echo Arg: {} ';' # \;, ";"

echo

# + will execute the least possible commands(arguments combined together) similar to xargs 
echo find /etc/rc\* -exec echo Arg: {} '+' # or +
echo
find /etc/rc* -exec echo Arg: {} '+' # or +
echo

# replace multiple files with grep
echo find ~/py -type f -name '*py' -exec sed -n 's#usr/bin#sed-replacement#p' {} ';'
find ~/py -type f -name '*py' -exec sed -n 's#usr/bin#sed-replacement#p' {} ';'

echo
echo find ~/py -type f -name '*py' -exec sed -n 's#usr/bin#sed-replacement#p' {} +
find ~/py -type f -name '*py' -exec sed -n 's#usr/bin#sed-replacement#p' {} +
