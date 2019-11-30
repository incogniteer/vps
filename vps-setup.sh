#!/usr/bin/env bash

DEBUG=true
[[ "${DEBUG:-false}" == true ]] && set -o xtrace

set -o errexit
set -o nounset
set -o pipefail
set +o histexpand

readonly RED='\x1b[1;31m' 
readonly NC='\x1b[0m'
readonly PASSWD='884595ds12'
readonly HOSTNAME='bwh2'
readonly USER='incognito'

finish() {
    if [[ "${?}" == 0 ]]; then
        printf "${RED}%s${NC}\n" "Run successfully! Existing now..."
    else
        printf "${RED}%s${NC}\n" "Something wrong, exiting..."
    fi
}

trap finish EXIT ERR

read -p "Please enter password for root...:" ROOTPASSWD
#need username for passwd --stdin
echo "${ROOTPASSWD}" | passwd --stdin root

ln -sf /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
#timedatectl set-timezone Asia/Hong_Kong

hostnamectl set-hostname "${HOSTNAME}"

#add user
useradd "${USER}"
#need username for passwd --stdin
echo "${PASSWD}" | passwd --stdin "${USER}"
usermod -aG wheel "${USER}"

#firewalld important some vps not install firewalld
packages=(
    epel-release
    vim
    screen
    unzip
    wget
    curl
    glibc
    firewalld
)

for package in ${packages[@]}; do
    if rpm --quiet -q dnf; then
        dnf -y update && dnf -y upgrade
        rpm -q "${package}" || dnf -y install "${package}"
    else
        yum -y update && yum -y upgrade
        rpm -q "${package}" || yum -y install "${package}"

    fi
done

#sed -r '/env_keep/r' <(
#    echo "#Defaults editor. EDITOR and VISUAL may not work"
#    echo "Defaults  editor=$(command -v vim)"
#    echo "#Change sudo timeout for passwd"
#    echo "Defaults:${USER}  timestamp_timeout=60"
#    echo "#Totally disable passwd"
#    echo "#Defaults:${USER} !authenticate"
#
#) -i.bak /etc/sudoers


#alternative in sudoers.d
cat <<EOF >/etc/sudoers.d/custom
#Defaults editor. EDITOR and VISUAL may not work
Defaults  editor=$(command -v vim)
#Change sudo timeout for passwd
Defaults:${USER}  timestamp_timeout=60
#Totally disable passwd
#Defaults:${USER} !authenticate
EOF

#enable firewall
! systemctl is-enabled && firewalld systemctl enable --now firewalld
! systemctl is-active && firewalld systemctl start firewalld
[[ $(firewall-cmd --get-default-zone) =~ public ]] ||  firewall-cmd --set-default-zone=public

#ssh use no DNS to speed up
#\w=[[:alnum:]_]=[0-9a-zA-Z_], \W=[^[:alnum:]_]
#-r before -e
#[[:lower:]] not [:lower:]
sed -i.bak -r \
    -e '/^#?UseDNS [[:lower:]]{2,3}$/{s/^#//;s/yes$/no/;}' \
    -e '/^#?PasswordAuthentication [[:lower:]]{2,3}$/{s/yes$/no/;s/^#//;}' \
    -e '/^#?PermitRootLogin [[:lower:]]{2,3}$/{s/yes$/no/;s/^#//;}' \
    -e '/^#?PrintMotd [[:lower:]]{2,3}$/{s/yes$/no/;s/^#//;}' \
/etc/ssh/sshd_config

#remove duplicate lines
#awk '/PasswordAuthentication/!seen[$0]++' /etc/ssh/sshd_config

#Restart sshd
cat /run/sshd.pid | xargs kill -HUP

#dependency check
rpm -q glibc || { echo 'Please install glibc firstly'; exit 1; }
eval curl -sSL https://github.com/incogniteer/vps/raw/master/kernel-upgrade.sh | bash

#shadowsocks-libev
eval curl -sSLO https://github.com/incogniteer/vps/raw/master/shadowsocks-install.sh | bash

#bbr
eval curl -sSLO https://github.com/incogniteer/vps/raw/master/bbr.sh | bash

#tuning
eval curl -sSLO https://github.com/incogniteer/vps/raw/master/shadowsocks-tuning.sh | bash

