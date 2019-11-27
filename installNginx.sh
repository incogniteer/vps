#!/usr/bin/env bash

set -euo pipefail

#install prerequisites
yum -y install yum-utils

cat >/etc/yum.repos.d/nginx.repo <<EOF 
[nginx-stable]
name=Nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=Nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

#By default, the repository for stable nginx packages is used. If you would like to use mainline nginx packages, run the following command:
yum-config-manager --enable nginx-mainline

EOF

yum -y install nginx

#start and enable service
systemctl enable --now nginx

#whitelist firewalld
firewall-cmd --permanent --zone=public --add-service=http{,s}
firewall-cmd --reload


