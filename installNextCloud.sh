#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

RED='\x1b[1;31m'
NC='\x1b[0m'

DEBUG=false
[[ "${DEBUG,,}" == *true* ]] && set -o x

finish() {
    if [[ "$?" != 0 ]]; then
    printf "${RED}%s${NC}\x21\n" "Something wrong, exiting..."
    fi
}

#Nextcloud dependencies
dependencies=(
    epel-release
    yum-utils
    unzip
    bzip2
    curl
    wget
    bash-completion
    mlocate
    policycoreutils-python
    screen
}

for pkg in "${dependencies[@]}"; do
    rpm -q "$pkg" || yum -y install "${pkg}"
done

yum -y update

php_extensions=(
php-fpm php-mysqlnd php-ctype php-dom php-gd php-iconv php-json php-libxml php-mbstring php-posix php-xml php-zip php-openssl php-zlib php-curl php-fileinfo php-bz2 php-intl php-mcrypt php-ftp php-exif php-gmp php-memcached php-imagick
)

for extension in "${php_extensions[@]}"; do
rpm -q "${extension}" || sudo  yum --enablerepo='remi-php74' -y install "${extension}"
done






