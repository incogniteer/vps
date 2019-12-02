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

finish() {
    if [[ $? == 0 ]]; then
        printf "${RED}%s${NC}\n" "Run sucessfully, exiting..."
    else
    printf "${RED}%s${NC}\n" "Something is wrong, exiting..."
    fi
}

trap err ERR
trap finish EXIT

BWH1=216.24.183.179
BWH2=199.19.111.45
HOSTDARE1=185.238.250.78 
HOSTDARE2=103.99.178.243 
PR=155.94.151.120
VIRMACH=107.174.240.124
TXHK=124.156.100.46
ALIHK=47.240.38.80

#Forward shadowsocks traffic through an internal vps in CN
#Enable ipv4 forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/enable_ip_forward && sysctl -p /etc/sysctl.d/*

#Enable & start firewalld
! (systemctl -q is-enabled firewalld && systemctl -q is-active firewalld) >/dev/null 2>&1 &&
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
    printf "${RED}%s${NC}\x21\n" "$FROM_PORT already enabled"
    else
    firewall-cmd -q --permanent --zone=public --add-port=$FROM_PORT/{tcp,udp} &&
    printf "${RED}%s${NC}\x21\n" "$FROM_PORT added successfully"
    fi

    firewall-cmd -q --permanent --zone=public \
--add-forward-port=port=${FROM_PORT}:proto={tcp,udp}:toport=${TO_PORT}:toaddr=${IP} && 
    printf "${RED}%s${NC}\x21\n" "$FROM_PORT forwarded to $TO_PORT successfully" &&
    firewall-cmd -q --reload && printf "${RED}%s${NC}\x21\n" "Reloaded successfully"
}

#Usage: enable_forward $IP $FROM_PORT $TO_PORT
enable_forward $BWH1 18388 18388
enable_forward $BWH2 18288 25123
enable_forward $VIRMACH 18188 18388
enable_forward $HOSTDARE1 18588 38888
enable_forward $HOSTDARE2 18788 36532
enable_forward $PR 19888 18063
enable_forward $TXHK 18888 18888
enable_forward $ALIHK 18688 18388
