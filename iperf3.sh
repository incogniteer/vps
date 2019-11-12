#!/bin/bash

[ rpm -qa | grep iperf3 ] || yum -y install iperf3 && \
    firewall-cmd --zone=public --permanent --add-port=5201/{tcp,udp} \
    && firewall-cmd --reload
