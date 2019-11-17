#!/usr/bin/env bash

#Strict mode
set -o errexit
set -o nounset
set -o pipefail

DEBUG=false
[[ ${DEBUG:-false} == *true* ]] && set -o xtrace

readonly CUSTOM_BBR_CONF=/etc/sysctl.d/bbr.conf
readonly QDISC="net.core.default_qdisc"
readonly CONGESTION="net.ipv4.tcp_congestion_control"

enable_bbr() {
if ! sysctl -nq $CONGESTION | grep -iqs  bbr &>/dev/null || 
   ! lsmod | grep -iqs bbr ]; then

if ! grep $QDISC $CUSTOM_BBR_CONF;then
echo "net.core.default_qdisc=fq" | tee -a $CUSTOM_BBR_CONF
fi

if ! grep $CONGESTION $CUSTOM_BBR_CONF;then
echo "net.ipv4.tcp_congestion_control=bbr" | tee -a $CUSTOM_BBR_CONF
fi

sysctl --system

fi

}

main() {
    enable_bbr
}

main
