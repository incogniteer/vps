#!/usr/bin/env bash

CUSTOM_BBR_CONF=/etc/sysctl.d/bbr.conf
QDISC="net.core.default_qdisc"
CONGESTION="net.ipv4.tcp_congestion_control"

if ! sysctl -nq $CONGESTION | grep -i bbr &>/dev/null || \
   ! lsmod | grep -i bbr -qs ]; then

if ! grep $QDISC $CUSTOM_BBR_CONF;then
echo "net.core.default_qdisc=fq" | tee -a $CUSTOM_BBR_CONF
fi

if ! grep $CONGESTION $CUSTOM_BBR_CONF;then
echo "net.ipv4.tcp_congestion_control=bbr" | tee -a $CUSTOM_BBR_CONF
fi

sysctl --system

fi
