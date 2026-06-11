#!/usr/bin/env bash
set -eou pipefail

mkdir -p /bind9
cd /bind9
apt update -y
apt upgrade -y


### Solving build dependencies ###
apt install git curl vim 7zip build-essential  \
    pkg-config liburcu-dev libuv1-dev libnghttp2-dev libcap-dev libxml2-dev -y

#https://www.libressl.org/
sudo wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.3.2.tar.gz
sudo tar -xf libressl-4.3.2.tar.gz
cd libressl-4.3.2
sudo ./configure --prefix=/usr/local
sudo make -j$(nproc)
sudo make install

cd /bind9
### libxml2
# verificar se realmente precisa dessa versão ou o libxml2-dev já instalada é suficiente
wget http://ftp.br.debian.org/debian/pool/main/libx/libxml2/libxml2_2.9.14+dfsg-1.3~deb12u5_amd64.deb
dpkg -i libxml2_2.9.14+dfsg-1.3~deb12u5_amd64.deb
### Building bind9 from source ###
wget -O bind9.tar.xz https://downloads.isc.org/isc/bind9/9.20.23/bind-9.20.23.tar.xz

tar -xf bind9.tar.xz



cd bind-9.20.23
sudo ./configure  --with-openssl --enable-threads --with-libxml2

sudo make -j$(nproc)
sudo make install    

sudo ldconfig