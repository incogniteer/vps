#!/usr/bin/env bash

# single quote in double quote
echo "var=\'value\'" #output: var=\'value\'
echo "var='value'" #output: var='value'
echo "var=\"value\"" #output: var="value"

# ${string}, \', \" interpreted as quotes
echo $'var=\'value\'' #output: var="value"
echo $'var=\"value\"' #output: var="value"
