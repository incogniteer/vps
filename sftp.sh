#!/usr/bin/env bash

umask 0022
PATH='/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin'

set -o errexit
set -o nounset
set -o pipefail

check_user() {
    if [[ $(whoami) != 'root' ]]; then
    # if [[ ${EUID} != 0 ]]; then
        echo 'Must run as root!'
        exit 1
    fi
}

rand_passwd() {
    local default_length
    # default_length=${1:=16} error: positional parameter can't assign in this way
    default_length=${1:-16}
    LC_ALL=C </dev/urandom tr -cd '_0-9A-Za-z!@#$%^&*' | \
    head -c ${default_length}; echo
}

generate_passwd() {
passwd=$(rand_passwd)
echo "${passwd}" >> /root/rand_passwd
}

add_ftpuser() {
# create dedicated SFTP user and group
groupadd sftpusers
useradd -g sftpusers -s /sbin/nologin ftpuser1
printf '%s' "${passwd}" | passwd --stdin ftpuser1
}

modify_sshd() {
# replace Subsystem sftp /usr/libexec/openssh/sftp-server with
# Subsystem sftp internal-sftp

if grep -q "^Subsystem" /etc/ssh/sshd_config; then
    sed -i 's/^Subsystem.*/#&/' /etc/ssh/sshd_config
    sed -i '/^Subsystem.*/a \
        Subsystem sftp internal-sftp' /etc/ssh/sshd_config
    # or awk '/^Subsystem.*/ {print "Subsystem sftp internal-sftp"} 1'
else
    echo 'Subsystem sftp internal-sftp' >> /etc/ssh/sshd_config
fi

# restrict sftpusers access
cat <<'EOF' >> /etc/ssh/sshd_config
Match Group sftpusers
X11Forwarding no
AllowTcpForwarding no
ChrootDirectory %h
ForceCommand internal-sftp
EOF
}

add_ftp_directory() {
# create dedicated direcotyr for sftp
chown -R root /home/ftpuser1
chmod -R 755 /home/ftpuser1
mkdir -p /home/ftpuser1/ftp-data
chown -R sftpuser1 /home/ftpuser1/ftp-data
}

### main ###
main() {
check_user
generate_passwd
add_ftpuser
modify_sshd
add_ftp_directory
systemctl reload sshd
}

main
