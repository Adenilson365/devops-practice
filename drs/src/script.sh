#!/bin/bash

apt update
apt install apache2 -y


cat >/var/www/html/index.html <<EOF
<h1>AWS DRS LAB</h1>
<p>Servidor original on-premises</p>
EOF

systemctl enable apache2
systemctl start apache2

cat /scripts/events.service > /etc/systemd/system/events.service
chmod +x /scripts/events.sh
systemctl daemon-reload
systemctl enable events.service
systemctl restart events.service