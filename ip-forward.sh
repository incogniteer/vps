#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

RED='\033[0;31m'
NC='\033[0m'

DEBUG=false
[[ "$DEBUG" == *true* ]] && set -o xtrace

err() {
    printf "${RED}%s${NC}\n" "Something is wrong, exiting..."
}

cleanup() {
    printf "${RED}%s${NC}\n" "Something is wrong, exiting..."
}

trap err ERR
trap cleanup EXIT

BWH=216.24.183.179
HOSTDARE=185.238.250.78 
VIRMACH=107.174.240.124
TXHK=124.156.100.46
ALIHK=47.240.38.80

#Forward shadowsocks traffic through an internal vps in CN
#Enable ipv4 forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/enable_ip_forward && sysctl -p /etc/sysctl.d/*

#Enable firewalld
! systemctl -q is-enabled firewalld >/dev/null 2>&1 &&
systemctl -q enable --now firewalld

#Enable masquerading
firewall-cmd -q --permanent --add-masquerade && firewall-cmd -q --reload

#Allow TCP&UDP ports
#Note: brace expansion can be used!
#Note: source forwarded ports MUST be different!

#USLA BWH
enable_forward() {
    local IP=$1
    local FROM_PORT=$2
    local TO_PORT=$3

    if firewall-cmd --list-ports | tr -d '(/udp|/tcp)' | grep -wq $FROM_PORT; then
        :
    else
    firewall-cmd -q --permanent --zone=public --add-port=$FROM_PORT/{tcp,udp} &&
    printf "${RED}%s${NC}\x21\n" "$FROM_PORT added successfully"
    fi

    firewall-cmd -q --permanent --zone=public \
--add-forward-port=port=${FROM_PORT}:proto={tcp,udp}:toport=${TO_PORT}:toaddr=${IP} && 
    printf "${RED}%s${NC}\x21\n" "$FROM_PORT forwarded to $TO_PORT successfully" &&
    firewall-cmd -q --reload && printf "${RED}%s${NC}\x21\n" "Reloaded successfully"
}

enable_forward $BWH 18388 18388
enable_forward $VIRMACH 18188 18388
enable_forward $HOSTDARE 18588 38888
enable_forward $TXHK 18888 18888
enable_forward $ALIHK 18688 18388
