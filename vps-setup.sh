#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set +o histexpand

readonly RED='\x1b[1;31m' 
readonly NC='\x1b[0m'
readonly ROOTPASSWD='884595ds12'
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

echo "${PASSWD}" | passwd --stdin

ln -sf /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
#timedatectl set-timezone Asia/Hong_Kong

hostnamectl set-hostname "${HOSTNAME}"

#add user
useradd "${USER}"
echo "${PASSWD}" | passwd --stdin
usermod -aG wheel "${USER}"

dependencies=(
    epel-release
    vim
    screen
    unzip
    wget
    curl
)

for package in ${dependencies[@]}; do
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
systemctl enable --now firewalld

