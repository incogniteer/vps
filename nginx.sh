#!/usr/bin/env bash

is_root() {
    if [[ $EUID != 0 ]]; then
        printf "${RED}%s${NC}" "Please run as root user!"
        exit 1
    fi  
}

is_root

DEBUG=true
[[ "${DEBUG:-false}" == true ]] && set -o xtrace

set -o errexit
set -o nounset
set -o pipefail
set +o histexpand

readonly RED='\x1b[1;31m' 
readonly NC='\x1b[0m'

finish() {
    if [[ "${?}" == 0 ]]; then
        printf "${RED}%s${NC}\n" "Run successfully! Existing now..."
    else
        printf "${RED}%s${NC}\n" "Something wrong, exiting..."
    fi
}

trap finish EXIT ERR

os_ver() {
    local OS_VER=$(rpm -q --queryformat '%{VERSION}' centos-release)
    printf "%s" ${OS_VER}
}

readonly OS_VER=$(os_ver)

if [[ ${OS_VER} =~ 8 ]]; then
    dnf -y install nginx
else
    yum -y install nginx
fi

systemctl enable --now nginx

#firewall
firewall-cmd --zone=public --permanent --add-service={http,https} &&
firewall-cmd --reload
