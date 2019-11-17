#!/usr/bin/env bash

#Unofficial bash strick mode!
# set -euo pipefail with IFS=$'\n\t' #Bash $' \t'n' is too eager
set -o nounset #set -u
set -o pipefail
set -o errexit #set -e
#set -o xtrace #set -x
DEBUG=true
[[ "${DEBUG:-false}" == true ]] && set -o xtrace

#bash cleanup for more robust and reliable script and less debugging!
#cleanup code for ERR
_err_trap() {
    local RETVAL=$?
    printf "%s\n" "Something is wrong, exiting now..." >&2
    exit $RETVAL
}

trap _err_trap ERR 

#cleanup code for EXIT
_exit_trap() {
    local RETVAL=$?
    if [[ $RETVAL != 0 ]]; then
    printf "%s\n" "Script is exiting by trapping...probably something wrong.."
    exit $RETVAL
else
    printf "%s\x21\n" "Script run without problems"
fi
    
}

trap _exit_trap EXIT 

RED='\033[0;31m'
NC='\033[0m'
#immutable/unchangeable variable
readonly INSTALL_DIR=/usr/local/src/shadowsocks-libev
readonly CONFIG_DIR=/etc/shadowsocks-libev
readonly SERVICE=shadowsocks-libev

install_dependency() {
dependencies=(
            asciidoc autoconf automake c-ares-devel epel-release
            gcc gettext git libev-devel libsodium libsodium-devel
            libtool make mbedtls mbedtls-devel pcre pcre-devel 
            screen wget xmlto
             )

for package in "${dependencies[@]}"; do 
    if rpm -q "$package" >/dev/null; then
        #Put color code in format strings!
        printf "%s${RED}%*s${NC}" "$package" $(($(tput cols)-$(printf "$package"|wc -m))) "Installed"
        else
        printf "%s\n" "Starting to install $package..."
        yum -y install "$package"
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
    printf "${RED}%s${NC}\x21\n" "installation succeeded"
    #NOT USE exit 0 otherwise the script will exit without run the following functions/commands!!!
else 
    echo "Installation failed, please check" >&2
    exit 1
fi
}

set_port() {
read -p "Please set up a server port(Default: 18388): " server_port

#Validity checkup
while [[ ! ( ${server_port:=18388} =~ ^[[:digit:]]{4,5}$ && $server_port -gt 1024 && $server_port -lt 65535 ) ]]; do
  echo -n "Please enter port number between 1024 and 65535: "
  read server_port
done

printf "%s${RED}%s${NC}\n" "You have selected server port: " "$server_port."
}

set_ip() {
    #use <<< instead of <<
    read -p "Please set up server address: " server_address <<<$(curl -sSL ifconfig.co | xargs)
    printf "%s${RED}%s${NC}\n" "You have selected server address: " "$server_address."
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
  "server_port":"$server_port",
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

if systemctl -q is-active ${SERVICE}; then
    systemctl stop ${SERVICE} 
fi

if systemctl -q is-enabled ${SERVICE}; then
    systemctl disable ${SERVICE}
fi

if [[ ${INSTALL_DIR} ]]; then
rm -rf ${INSTALL_DIR}
rm -f  /usr/lib/systemd/system/shadowsocks-libev.service
rm -f /etc/sysconfig/shadowsocks-libev/shadowsocks-libev.default 
systemctl daemon-reload
systemctl reset-failed #disable failed warning message after removed

disable_port ${server_port}
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
        firewall-cmd --permanent --zone=public \
        --remove-port="${PORT}"/{tcp,udp} &&
        firewall-cmd --reload
    else
        printf "%s\n" "Port are not disabled properly...please try again later."
        exit 1
    fi
}

info() {
    printf "%s\n" "Installed successfully, enjoyed it..."
    printf "%s${RED}%s${NC};\n" "Server address: " "$server_address"
    printf "%s${RED}%s${NC};\n" "Server port: " "$server_port"
    printf "%s${RED}%s${NC};\n" "Cipher: " "$cipher"
    printf "%s\n" "Finished, bye"
}

main() {
    install_dependency 
    remove_shadowsocks
    compile_shadowsocks
    set_port
    set_ip
    set_cipher
    config_shadowsocks
    install_shadowsocks
    enable_port $server_port  #not forget to ref $1
    info
}

main
