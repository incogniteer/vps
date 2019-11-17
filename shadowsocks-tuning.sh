#!/usr/bin/env bash

#Strick mode
set -o errexit
set -o nounset
set -o pipefail

#Environment
readonly INSTALL_DIR="/usr/lib/systemd/system"

tuning=/etc/sysctl.d/shadowsocks_tuning.conf

sysctl_tune() {

cat >> "$tuning"  <<EOF
#Optimize shadowsocks connections

# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096
# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1
EOF

}

increase_nofile() {
cat >> /etc/security/limits.conf <<EOF

    * soft nofile 65535
    * hard nofile 65535

EOF

    cd "${INSTALL_DIR}"
    #LimitNOFILE must be same as ulimit -n
    #sed change line: c\ to replace whole line or using .*
    sed -i -e '/ExecStart/iExecStartPre=/bin/sh -c "ulimit -n 65535"' \
           -e '/LimitNOFILE/c\LimitNOFILE=65535' shadowsocks-libev.service
}

reload_shadowsocks() {
    #reload systemd unit file and recreate dependency tree
    systemctl daemon-reload &&
    systemctl reset-failed &&
    systemctl restart shadowsocks-libev
}

main() {
    sysctl_tune
    increase_nofile
    reload_shadowsocks
}

main
