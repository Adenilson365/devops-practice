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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apache2 Test Page</title>
</head>
<body>
    <h1>Welcome to the Apache2 Test Page!</h1>
    <p>This page is served by Apache2 running on the server.</p>
</body>
</html>
EOF