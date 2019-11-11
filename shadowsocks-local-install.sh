#!/bin/bash

#Compile
cd /usr/local/src/shadowsocks-libev
git submodule update --init --recursive
./autogen.sh
./configure --disable-documentation
make && make install

#Configurations
#Get port number
read -p "Please set up a server port(Default: 18388): " server_port
echo "You have selected server port: $server_port."
read -p "Please set up server address: " server_address
echo "You have selected server address: $server_address."

#Check if port valid
#POSIX ERE not supporting \d or \w. Using [[:digit:]] [0-9] and ^$ instead
#" ; " is required before then
#Using -gt -lt for arithmetic. > < for strings!
#Using while or for loop, instead of if, then construct
#while [[ ! ( $server_port =~ ^[[:digit:]]{4,5}$ && $server_port -gt 1024 && $server_port -lt 65535 ) ]]; do
#  echo -n "Please enter port number between 1024 and 65535: "
#  read server_port
#done

#Get ciper method
ciphers=(
aes-256-gcm 
aes-256-cfb
chacha20-ietf-poly1305
xchacha20-ietf-poly1305
)

select cipher in $ciphers;
do
    case $cipher in
      aes-256-gcm|aes-256-cfb|chacha20-ietf-poly1305|xchacha20-ietf-poly1305)
      echo "You selected $cipher!"
      cipher=$cipher
      break
      ;;
      *)
      echo "Please select a valid cipher!"
      ;;
    esac
done

mkdir -p /etc/shadowsocks-libev
cd /etc/shadowsocks-libev

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

#Change ExecStart from /usr/bin/ to /usr/local/bin
cd rpm/SOURCES/systemd/
sed -i.bak -e '/ExecStart/{s_/usr/bin_usr/local/bin_;}' -e '/ExecStart/aExecPreStart=/bin/sh -c "ulimit -n 51200"' /shadowsocks-libev.service
cp shadowsocks-libev.service /usr/lib/systemd/system/
cp shadowsocks-libev.default /etc/sysconfig/shadowsocks-libev

#Enable and start service
systemctl enable --now shadowsocks-libev

#Firewall settings
[ systemctl is-active firewalld ] || systemctl enable --now firewalld && firewall-cmd --permanent --add-port="${server_port:-18388}"/{tcp,udp} && firewall-cmd --reload
