#!/bin/bash

sudo dnf -y install epel-release
sudo dnf -y install openldap openldap-servers openldap-clients

sudo systemctl start slapd.service
sudo systemctl enable slapd.service
sudo firewall-cmd --permanent --add-port=389/tcp --add-port=389/udp
sudo firewall-cmd --reload
sudo setsebool -P allow_ypbind=1 authlogin_nsswitch_use_ldap=1
sudo setsebool -P httpd_can_connect_ldap on

systemctl restart slapd.service


rpm -q openldap 
rpm -q openldap-servers 
rpm -q openldap-clients

#####Instalação Cliente LDAP
sudo dnf install -y sssd sssd-ldap oddjob oddjob-mkhomedir openldap-clients authselect

cat <<EOF | sudo tee /etc/sssd/sssd.conf
[sssd]
services = nss, pam
config_file_version = 2
domains = default

[domain/default]
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap

ldap_uri = ldap://192.168.56.20
ldap_search_base = dc=knz,dc=dev,dc=br

ldap_default_bind_dn = cn=ldapadm,dc=knz,dc=dev,dc=br
ldap_default_authtok = admin123

cache_credentials = True
enumerate = True
EOF

sudo systemctl enable sssd
sudo systemctl start sssd