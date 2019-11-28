#!/usr/bin/env bash

#Strict mode
set -o errexit
set -o nounset
set -o pipefaile

DEBUG=false
[[ ${DEBUG:-false} == *true* ]] && set -o xtrace

cleanup() {
    printf "%s\n" "Something is wrong, exiting now..."
}

trap cleanup EXIT ERR

#Aliase for one word, func preferred over alias, esp. for +2 words
git() {
    git commit -a -m "Miscellaneous" && 
    git push
}

#history expansion
h() {
    local num="${1:-10}"
    history $num
}

killbash() {
    local pids=( $(pgrep bash | grep -v $$) )
    for pid in "${pids[@]}"; do
        kill $pid
    done
} 2>/dev/null

mkcd() {
    mkdir -pv $1;
    cd $1;
}
