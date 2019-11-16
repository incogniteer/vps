#!/usr/bin/env bash

#Unofficial bash strick mode!
# set -euo pipefail with IFS=$'\n\t' #Bash $' \t'n' is too eager
set -o nounset #set -u
set -o pipefail
set -o errexit #set -e
#set -o xtrace #set -x
[[ "$DEBUG" == true ]] && set -o xtrace

RED='\033[0;31m'
NC='\033[0m'
DEBUG=false
#immutable/unchangeable variable
readonly INSTALL_DIR=/usr/local/src/shadowsocks-libev
readonly CONFIG_DIR=/etc/shadowsocks-libev

#bash cleanup for more robust and reliable script and less debugging!
#cleanup code for ERR
ERR_TRAP() {
    local RETVAL=$?
    printf "%s\n" "Something is wrong, exiting now..."
    exit $RETVAL
}

trap ERR_TRAP ERR 

#cleanup code for EXIT
EXIT_TRAP() {
    local RETVAL=$?
    printf "%s\n" "Something is wrong, exiting now..."
    exit $RETVAL
}

trap EXIT_TRAP ERR 

main() {
    install_dependency 
    compile_shadowsocks
    set_port
    set_ip
    set_cipher
    config_shadowsocks
    install_shadowsocks
    whitelist_port
}

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
#Check if shadowsocks-libev direcotory exists
ls shadowsocks-libev &>/dev/null && rm -rf shadowsocks-libev/
#Download the source code
git clone https://github.com/shadowsocks/shadowsocks-libev.git

if [ $? -eq 0 ]; then
    cd ${INSTALL_DIR}
    git submodule update --init --recursive
    ./autogen.sh
    ./configure --disable-documentation
    make && make install &&
    echo "installation succeeded!"
    exit 0
else 
    echo "Something wrong, exit..."
    exit 1
fi
}

#Get port number
set_port() {
read -p "Please set up a server port(Default: 18388): " server_port

#Check if port valid
while [[ ! ( ${server_port:=18388} =~ ^[[:digit:]]{4,5}$ && $server_port -gt 1024 && $server_port -lt 65535 ) ]]; do
  echo -n "Please enter port number between 1024 and 65535: "
  read server_port
done

printf "%s${RED}%s${NC}\n"You have selected server port: " "$server_port."
}

set_ip() {
read -p "Please set up server address: " server_address
printf "%s${RED}%s${NC}\n" "You have selected server address: " "$server_address."
}

#Get ciper method
set_cipher() {

ciphers=(
aes-256-gcm 
aes-256-cfb
chacha20-ietf-poly1305
xchacha20-ietf-poly1305
)

PS3="Please pick up a preferred cipher..."
#Force select menu display in one single column.
COLUMNS=0
select cipher in "${ciphers[@]}";
do
    #Use extended globbing
    case $cipher in 
      aes-256-gcm|aes-256-cfb|chacha20-ietf-poly1305|xchacha20-ietf-poly1305)
        #Escape !
      printf "%s${RED}%s${NC}\x21\n" "You selected " "$cipher"
      cipher=$cipher
      break
      ;;
      *)
      echo "Please select a valid cipher"!
      ;;
    esac
done

}

config_shadowsocks() {
mkdir -p ${CONFIG_DIR}
cd ${CONFIG_DIR}

#超时时间越长，连接被保持得也就越长，导致并发的tcp的连接数也就越多。对于公共代理，这个值应该调整得小一些。推荐60秒。
cat > config.json <<eof
{
  "server":"$server_address",
  "server_port":"$server_port",
  "local_address":"127.0.0.1",
  "local_port":1080,
  "password":"884595ds12",
  "timeout":60,
  "method":"$cipher",
  "mode":"tcp_and_udp",
  "fast_open":true
} 
eof

}

install_shadowsocks() {
#Change ExecStart from /usr/bin/ to /usr/local/bin
cd ${INSTALL_DIR}/rpm/SOURCES/systemd/
sed -i.bak -e '/ExecStart/{s_/usr/bin_usr/local/bin_;}' -e '/ExecStart/aExecPreStart=/bin/sh -c "ulimit -n 51200"' shadowsocks-libev.service
cp shadowsocks-libev.service /usr/lib/systemd/system/
cp shadowsocks-libev.default /etc/sysconfig/shadowsocks-libev

#Enable and start service
systemctl enable --now shadowsocks-libev

}

#Firewall settings
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

whilelist_port() {
    local PORT="$(trim_whitespace "${1}")"
    if enable_firewall(); then
        firewall-cmd --permanent --zone=public \
        --add-port=${PORT}/{tcp,udp} &&
        firewall-cmd --reload
    else
        printf "%s\n" "Firewall is not enabled yet, exiting..."
    fi
}
