#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o histexpand

NC='\x1b[0m'
RED='\x1b[1;31m'

finish() {
    printf "${RED}%s${NC}" "Something wrong, exiting..."
}

trap finish ERR

dependencies=(
    cmake
    g++
    pkg-config
    git
    vim-common
    libwebsockets-dev
    libjson-c-dev
    libssl-dev
)

#VERSION=$(rpm -q --qf '%{VERSION}' $(rpm -q --whatprovides centos-release))
#
#if [[ ${VERSION} =~ 8 ]]; then
#    for pkg in "${dependencies[@]}"; do
#        ! { rpm -q "${pkg}" || which "${pkg}" &>/dev/null; } &&  dnf -y install "${pkg}"
#    done
#
#else
#
#    for pkg in "${dependencies[@]}"; do
#        ! { rpm -q "${pkg}" || which "${pkg}" &>/dev/null; } &&  yun -y install "${pkg}"
#    done
#fi

mkdir -p ~/bin
wget -c -O ~/bin/ttyd  https://github.com/tsl0922/ttyd/releases/download/1.5.2/ttyd_linux.x86_64

chmod u+x ~/bin/ttyd
