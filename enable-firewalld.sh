#!/bin/bash

if ! [ which firewalld >/dev/null 2>&1 || \
    rpm -q firewalld >/dev/null 2>/dev/null || \
    systemctl is-enabled firewalld ]; then
    [ rpm -q epel-release &>/dev/null || \
    yum -y install epel-release ] && yum -y install firewalld &&
    systemctl enable --now firewalld
else 
    :
fi
