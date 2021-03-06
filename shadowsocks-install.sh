#!/usr/bin/env bash

#Unofficial bash strict mode!
#IFS=$'\n\t', $' \t\n' is too eager
set -o nounset
set -o pipefail
set -o errexit
set +o histexpand

#set -o xtrace
DEBUG=true
[[ "${DEBUG:-false}" == true ]] && set -o xtrace

#ANSI C color code
RED='\x1b[1;31m'
NC='\x1b[0m'

#bash cleanup for more robust and reliable script and less debugging!
#cleanup code for ERR
_err_trap() {
    local RETVAL=$?
    printf "${RED}%s${NC}\n" "Error trapped, exiting now..." >&2
    exit $RETVAL
}

trap _err_trap ERR 

#cleanup code for EXIT
_exit_trap() {
    local RETVAL=$?
    if [[ $RETVAL != 0 ]]; then
    printf "${RED}%s\x21${NC}\n" "Something is wrong, exiting now..." >&2
    exit $RETVAL
else
    printf "${RED}%s\x21  %s${NC}\n" "Run sucessfully" "Existing now..." >&2
fi
    
}

trap _exit_trap EXIT 

#immutable/unchangeable variable
readonly INSTALL_DIR=/usr/local/src/shadowsocks-libev
readonly CONFIG_DIR=/etc/shadowsocks-libev
readonly SERVICE=shadowsocks-libev

install_dependency() {
#firstly instal epel-release
dependencies=(
            epel-release asciidoc autoconf automake c-ares-devel 
            gcc gettext git libev-devel libsodium libsodium-devel
            libtool make mbedtls mbedtls-devel pcre pcre-devel 
            screen wget xmlto
             )

for package in "${dependencies[@]}"; do 
#rpm -q not working for vim!
    if rpm -q "${package}" >/dev/null || which "${package}"; then
        #Put color code in format strings!
        printf "%s${RED}%*s${NC}" "${package}" $(($(tput cols)-$(printf "${package}"|wc -m))) "Installed"
        else
        printf "%s\n" "Starting to install $package..."
        yum -y install "${package}"
    fi
done
}

#Compile
compile_shadowsocks() {
cd /usr/local/src
git clone https://github.com/shadowsocks/shadowsocks-libev.git

if [ $? -eq 0 ]; then
    cd ${INSTALL_DIR}
    git submodule update --init --recursive
    ./autogen.sh
    ./configure --disable-documentation
    make && make install &&
    printf "${RED}%s${NC}\x21\n" "Shadowsocks-libev complied succeeded"
    #NOT USE exit 0 otherwise the script will exit without run the following functions/commands!!!
else 
    echo "Installation failed, please check" >&2
    exit 1
fi
}

#exclude 4 from output of shuf, seq, tr<urandom then choose
#while true
rand_port() {
    #port=$(shuf -i 1025-40000 -n1)
    #seq 2025 40000|sort -R|head -n1
    #n different from port
    local n=$((RANDOM+7233))
    #initialize port unless unbound variable thrown
    #port=$((RANDOM+7233))
    while :; do
    if [[ $n =~ 4 ]]; then
        n=$((RANDOM+7233))
    else
        port=$n
        break
    fi
#    if [[ ! $port =~ 4 ]]; then
#        printf "%d" $port
#        break
#    fi
    done
    printf '%d' ${port}
}

set_port() {
#Enable timeout for read
#need to use if statement; read -t10 -p "Please set up a server port(Default: 18388): " SERVER_PORT
#Validity checkup
default=$(rand_port)
read -p "Please enter server port(Default: ${default})..." SERVER_PORT
while [[ ! ( ${SERVER_PORT:=${default}} =~ ^[[:digit:]]{4,5}$ && $SERVER_PORT -gt 1024 && $SERVER_PORT -lt 65535 ) ]]; do
  echo -n "Please enter port number between 1024 and 65535: "
  read SERVER_PORT
done

#Set the default SERVER_PORT for furhter use
printf "%s${RED}%s${NC}\n" "You have selected server port: " "${SERVER_PORT}."
}

set_ip() {
    #use <<< instead of <<
    read -p "Please set up server address: " SERVER_ADDR <<<$(curl -sSL ifconfig.co | xargs)
    printf "%s${RED}%s${NC}\n" "You have selected server address: " "${SERVER_ADDR}."
}

set_cipher() {

ciphers=(
aes-256-gcm 
aes-256-cfb
chacha20-ietf-poly1305
xchacha20-ietf-poly1305
)

PS3="Please pick up a preferred cipher..."
COLUMNS=0 #Force select menu display in one single column.
select cipher in "${ciphers[@]}";
do
    case $cipher in 
      aes-256-gcm|aes-256-cfb|chacha20-ietf-poly1305|xchacha20-ietf-poly1305)
      #Escape !
      printf "%s${RED}%s${NC}\x21\n" "You selected " "$cipher"
      cipher=$cipher
      break
      ;;
      *)
      echo "Please select a valid cipher"! >&2
      ;;
    esac
done

}

config_shadowsocks() {
mkdir -p ${CONFIG_DIR}
cd ${CONFIG_DIR}

#超时时间越长，连接被保持得也就越长，导致并发的tcp的连接数也就越多。对于公共代理，这个值应该调整得小一些。推荐60秒。
#comment not allowed in here doc. Use 0.0.0.0
#Delete local_port, local_address to avoid errors
cat > config.json <<eof
{
  "server":"0.0.0.0",
  "server_port":"$SERVER_PORT",
  "password":"884595ds12",
  "timeout":60,
  "method":"$cipher",
  "mode":"tcp_and_udp",
  "fast_open":true
} 
eof

}

install_shadowsocks() {
cd "${INSTALL_DIR}"/rpm/SOURCES/systemd/

#Installation in /usr/local
sed -i.bak -e '/ExecStart/{s!/usr/bin!/usr/local/bin!;}' shadowsocks-libev.service
cp shadowsocks-libev.service /usr/lib/systemd/system/ 
cp shadowsocks-libev.default /etc/sysconfig/shadowsocks-libev

#Enable and start service
systemctl enable --now shadowsocks-libev 

}

remove_shadowsocks() {
#Remove shadowsocks-libev service
#systemctl disable --now shadowsocks-libev

#first check if unit file exists
#This is wrong[[ systemctl list-unit-files | grep -q 'shadowsocks-libev' ]] &
systemctl list-unit-files | grep -q 'shadowsocks-libev' && {
if systemctl -q is-active ${SERVICE}; then
    systemctl stop ${SERVICE} 
fi

if systemctl -q is-enabled ${SERVICE}; then
    systemctl disable ${SERVICE}
fi
}

#This is wrong test, use -d or -f isntead: if [[ ${INSTALL_DIR} ]]; then
if [[ -d "${INSTALL_DIR}" ]]; then
rm -rf ${INSTALL_DIR}
rm -f  /usr/lib/systemd/system/shadowsocks-libev.service
rm -f /etc/sysconfig/shadowsocks-libev/shadowsocks-libev.default 
systemctl daemon-reload
systemctl reset-failed #disable failed warning message after removed

disable_port ${SERVER_PORT:-18388}
fi

}

check_firewall() {
    if systemctl -q is-active; then
        return 0
    else
        return 1
    fi
}

enable_firewall() {
    if ! check_firewall; then
        systemctl enable --now firewalld
    else
        :
    fi
}

#Trim whitespace in variable
trim_whitespace() {
    local var="$*"

    #Remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    #Remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"

    printf "%s" "$var"
}

enable_port() {
    local PORT="$(trim_whitespace ${1})"
    if enable_firewall; then
        firewall-cmd --permanent --zone=public \
        --add-port="${PORT}"/{tcp,udp} &&
        firewall-cmd --reload
    else
        printf "%s\n" "Firewall is not enabled yet, exiting..."
        exit 1
    fi
}

disable_port() {
    local PORT="$(trim_whitespace ${1})"
    if enable_firewall; then
        #remove duplicate ports
        if firewall-cmd --list-ports | tr -d '/(tcp|udp)' | awk -v RS='[ \n]+' '!_[$0]++' | grep -q ${PORT}; then
        firewall-cmd --permanent --zone=public \
        --remove-port="${PORT}"/{tcp,udp} &&
        firewall-cmd --reload
    else
        #printf "${RED}%s\x21${NC}\n" "Port are not disabled properly...please try again later." >&2
        #exit 1
        printf "%s\n" "${PORT} is not enabled yet, continu..."
        fi
    fi
}

info() {
    printf "%s\n" "Installed successfully, enjoyed it..."
    printf "%s${RED}%s${NC};\n" "Server address: " "${SERVER_ADDR}"
    printf "%s${RED}%s${NC};\n" "Server port: " "${SERVER_PORT}"
    printf "%s${RED}%s${NC};\n" "Cipher: " "$cipher"
    printf "%s\n" "Finished, bye"
}

is_root() {
    if [[ $EUID != 0 ]]; then
        printf "${RED}%s${NC}" "Please run as root user!"
        exit 1
    fi
}

os_ver() {
    local OS_VER=$(rpm -q --queryformat '%{VERSION}' centos-release)
    printf "%s" ${OS_VER}
}

main() {
    is_root
    install_dependency 
    remove_shadowsocks
    compile_shadowsocks
    set_port
    set_ip
    set_cipher
    config_shadowsocks
    install_shadowsocks
    enable_port ${SERVER_PORT}  #not forget to ref $1
    info
}

main
