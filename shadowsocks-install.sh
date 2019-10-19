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

