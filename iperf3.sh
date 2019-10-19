#!/bin/bash

yum -y install iperf3

[ $? -eq 0 ] && firewall-cmd --zone=public --permanent --add-port=5201/{tcp,udp} \
    && firewall-cmd --reload