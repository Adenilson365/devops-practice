#!/bin/bash

apt install nfs-kernel-server -y

mkdir -p /srv/nfs
chmod 777 /srv/nfs
echo "/srv/nfs *(rw,sync,no_subtree_check,no_root_squash)" > /etc/exports
exportfs -ra




