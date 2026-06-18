#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

BIND_VERSION="9.20.23"
BUILD_DIR="/bind9"

sudo useradd \
  --system \
  --home-dir /var/lib/named \
  --shell /usr/sbin/nologin \
  --gid named named

sudo mkdir -p /etc/bind/zones
sudo mkdir -p /var/cache/bind
sudo mkdir -p /var/lib/named
sudo mkdir -p /var/log/named


sudo chown -R root:named /etc/bind
sudo chown -R named:named /var/cache/bind
sudo chown -R named:named /var/lib/named
sudo chown -R named:named /var/log/named

sudo chmod 750 /etc/bind
sudo chmod 750 /etc/bind/zones



apt-get update

apt-get install -y \
    ca-certificates \
    wget \
    curl \
    git \
    vim \
    xz-utils \
    build-essential \
    pkg-config \
    libssl-dev \
    liburcu-dev \
    libuv1-dev \
    libnghttp2-dev \
    libcap-dev \
    libxml2-dev

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

wget -O "bind-${BIND_VERSION}.tar.xz" \
    "https://downloads.isc.org/isc/bind9/${BIND_VERSION}/bind-${BIND_VERSION}.tar.xz"

tar -xf "bind-${BIND_VERSION}.tar.xz"
cd "bind-${BIND_VERSION}"

./configure \
    --prefix=/usr/local \
    --sysconfdir=/etc/bind \
    --localstatedir=/var \
    --with-openssl \
    --with-libxml2

make -j"$(nproc)"
make install

ldconfig

/usr/local/sbin/named -V



### Creating systemd service for bind9
sudo tee /etc/bind/named.conf >/dev/null <<'EOF'
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
EOF

sudo tee /etc/bind/named.conf.local >/dev/null <<'EOF'
// Insert zone configurations here
EOF

sudo tee /etc/bind/named.conf.options >/dev/null <<'EOF'
options {
    directory "/var/cache/bind";

    listen-on {
        127.0.0.1;
        any;
    };

    listen-on-v6 {
        none;
    };

    allow-query {
        localhost;
        localnets;
    };

    recursion yes;

    allow-recursion {
        localhost;
        localnets;
    };

    forwarders {
        1.1.1.1;
        8.8.8.8;
    };

    dnssec-validation auto;

    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};
EOF


sudo tee /etc/systemd/system/named.service >/dev/null <<'EOF'
[Unit]
Description=BIND 9 Domain Name Server
Documentation=https://bind9.readthedocs.io/
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=named
Group=named

RuntimeDirectory=named
RuntimeDirectoryMode=0755

ExecStartPre=/usr/local/bin/named-checkconf /etc/bind/named.conf
ExecStart=/usr/local/sbin/named -f -u named -c /etc/bind/named.conf
ExecReload=/usr/local/sbin/rndc reload

Restart=on-failure
RestartSec=5

LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable --now named
sudo systemctl status named
