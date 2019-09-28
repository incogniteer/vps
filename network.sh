#Forward shadowsocks traffic through an internal vps in CN
#Enable ipv4 forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/enable_ip_forward && sysctl -p /etc/sysctl.d/*

#Enable firewalld
systemctl -q is-enabled firewalld >/dev/null 2>&1
! [ $? -eq 0 ] && systemctl -q enable --now firewalld

#Allow TCP&UDP ports
#Note: brace expansion can be used!
firewall-cmd -q --permanent --add-port={18888,18388}/{tcp,udp}

#USLA BWH
firewall-cmd -q --permanent --add-forward-port=port=18388:proto={tcp,udp}:toport=18388:toaddr=216.24.183.179 && firewall-cmd -q --reload

#USSA VIRMACH
firewall-cmd --permanent --add-forward-port=port=18388:proto={tcp,udp}:toport=18388:toaddr=107.174.240.124 && firewall-cmd -q --reload

#USLA HOSTDARE
firewall-cmd -q --permanent --add-forward-port=port=18388:proto={tcp,udp}:toport=18388:toaddr=185.238.250.78 && firewall-cmd -q --reload

#HK-TECENT 
firewall-cmd -q --permanent --add-forward-port=port=18888:proto={tcp,udp}:toport=18888:toaddr=124.156.100.46 && firewall-cmd -q --reload

#Enable masquerading
firewall-cmd -q --permanent --add-masquerade 
