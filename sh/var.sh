#!/usr/bin/env bash

# A variable is a parameter denoted by name
# A variable has a value and zero or more attribute
# Attributes are assigned using the declare builtin

# -n nameref
nameref=ref
ref="Name referenced by name ref using declare -n"
declare -n nameref

# A variable may be assigned to by a statement of the form
# name=[value], missing value = null string
# All values undergo tilde expansion, parameter and variable expansion, command substitution, arithmetic expansion, quote removal
# 下面的IFS包含空格换行符，这样赋值没问题
savedIFS=$IFS # IFS undergo variable expansion
cat -A <<< $savedIFS
od -An -ta <<< $savedIFS
od -An -tc <<< $savedIFS

