#!/usr/bin/env bash

# bash 文件名匹配默认输出分隔符是空格
# 如果要修改成：file1:file2:file3:...., 可以用 tr ' ' ':', 但是如果文件名包含空格则失效
# 其他方法如下，参考stacoverflow

# method 1
dirs="$(printf "%s:" /usr/bin/*)"
dirs="${dirs%:}"
echo $dirs

# method 2
printf "%s\n" /usr/bin/* | tr "\n" ":" | head -c -1 ; echo

# method 3: IFS and "arr[*]"
dirs=(/usr/bin/*)
savedIFS=$IFS 
