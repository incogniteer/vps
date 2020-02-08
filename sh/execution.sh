#!/usr/bin/env bash

# order of execution in bash
# bash alias, escaped by backslash
# special builtins(only in POSIX mode):break : . continue eval exec exit export readonly return set shift trap unset
# functions
# builtins
# search in $PATH with hash table

# function > builtin
pwd() {
    echo '/'
}

pwd

# skip functions,alias use command
# disable builtin: enable -n 
