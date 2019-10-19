#!/usr/bin/env bash

CUSTOM_BBR_CONF=/etc/sysctl.d/bbr.conf

if ! [ sysctl -n net.ipv4.tcp_available_congestion_control -q | \
       grep -i bbr &>/dev/null ||
       lsmod | grep -i bbr -qs ]; then

echo "net.core.default_qdisc=fq" | tee -a $CUSTOM_BBR_CONF
echo "net.ipv4.tcp_congestion_control=bbr" | tee -a $CUSTOM_BBR_CONF
sysctl --system

fi
