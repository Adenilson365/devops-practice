#!/bin/bash

sudo dnf -y install epel-release
sudo dnf -y install openldap openldap-servers openldap-clients

sudo systemctl start slapd.service
sudo systemctl enable slapd.service
sudo firewall-cmd --permanent --add-port=389/tcp --add-port=389/udp
sudo firewall-cmd --reload
sudo setsebool -P allow_ypbind=1 authlogin_nsswitch_use_ldap=1
sudo setsebool -P httpd_can_connect_ldap on

systemctl start slapd.service
systemctl enable slapd.service