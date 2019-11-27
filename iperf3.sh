#!/bin/bash

#[ rpm -qa | grep iperf3 ], wrong usage of [ just rpm -qa | grep iperf3 
rpm --quiet -q iperf3  || yum -y install iperf3 && \
    firewall-cmd --zone=public --permanent --add-port=5201/{tcp,udp} \
    && firewall-cmd --reload
