#!/bin/bash

apt install nfs-common -y
mkdir -p /data

echo "192.168.56.32:/srv/nfs /data nfs defaults 0 0" >> /etc/fstab
mount /data