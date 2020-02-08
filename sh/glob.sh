#!/usr/bin/env bash

# globbing doesn't occure inside single quotes or double quotes
# please note echo $f will expand to: echo *py, so the output will be a list of filename, unless quoted
for f in '*py'; do
    echo $f
done

for f in "*py"; do
    echo $f
done

for f in *py; do
    echo $f
done

