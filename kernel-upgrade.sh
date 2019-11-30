#!/bin/bash

#rpm -q --queryformat '%{VERSION}' centos-release
os_ver=$(rpm -q --queryformat '%{VERSION}' centos-release)

if [[ ${os_ver} =~ 7 ]]; then
yum -y update && yum -y upgrade

if [ $(sort -t. -k1,1 -k2,2 <(echo 4.90) <(uname -r) -gr | head -n1) = 4.90 ]; then
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
    yum --disablerepo="*" --enablerepo="elrepo-kernel" -y install kernel-ml
    grub2-set-default 0
    grub2-mkconfig -o /boot/grub2/grub.cfg &&
    reboot
fi

else

dnf -y update && dnf -y upgrade

if [ $(sort -t. -k1,1 -k2,2 <(echo 4.90) <(uname -r) -gr | head -n1) = 4.90 ]; then
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh https://www.elrepo.org/elrepo-release-8.0-2.el8.elrepo.noarch.rpm
    yum --disablerepo="*" --enablerepo="elrepo-kernel" -y install kernel-ml
    grub2-set-default 0
    grub2-mkconfig -o /boot/grub2/grub.cfg &&
    reboot
fi

fi
