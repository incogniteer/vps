#!/bin/bash

# Install dependencies and basics
#yum -y install wget git epel-release screen
#yum -y install pcre pcre-devel git gettext gcc autoconf libtool automake make asciidoc xmlto c-ares-devel libev-devel
#yum -y install libsodium-devel mbedtls-devel

cd /usr/local/src
#Check if shadowsocks-libev direcotory exists
ls shadowsocks-libev &>/dev/null && rm -rf shadowsocks-libev/
#Download the source code
git clone https://github.com/shadowsocks/shadowsocks-libev.git

#Clear /usr/local/lib
rm -rf /usr/local/lib/

#Compile
if [ $? -eq 0 ]; then
cd /usr/local/src/shadowsocks-libev
git submodule update --init --recursive
./autogen.sh
./configure --disable-documentation
make && make install &&
echo success!
exit 0
else 
    echo "Something wrong, exit..."
    exit 1
fi

if [ $? -eq 0 ]; then
#Configurations
#Get port number
read -p "Please set up a server port(Default: 18388): " server_port
#Check if port valid
#POSIX ERE not supporting \d or \w. Using [[:digit:]] [0-9] and ^$ instead
#" ; " is required before then
#Using -gt -lt for arithmetic. > < for strings!
#Using while or for loop, instead of if, then construct
while [[ ! ( $server_port =~ ^[[:digit:]]{4,5}$ && $server_port -gt 1024 && $server_port -lt 65535 ) ]]; do
  echo -n "Please enter port number between 1024 and 65535: "
  read server_port
done
