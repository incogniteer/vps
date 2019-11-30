#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

cd 
mkdir -p benchmark && cd benchmark 

#unixbench
mkdir -p unixbench && cd unixbench

wget --no-check-certificate https://github.com/teddysun/across/raw/master/unixbench.sh
chmod 744 unixbench.sh
rpm -q screen || yum -y install screen || dnf -y install screen
screen -S unixbench
./unixbench.sh |& tee out.$(date +%F)

