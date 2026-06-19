#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    apache2 \
    vim \
    dnsutils


rm -rf /var/www/html/*
cat <<EOF > /var/www/html/index.html
<h1>Welcome to the Server 1 </h1>
EOF