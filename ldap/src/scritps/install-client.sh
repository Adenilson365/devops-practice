#!/bin/bash
#####Instalação Cliente LDAP CenOS Stream 9
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
ldap_default_authtok = $1

cache_credentials = True
enumerate = True
EOF

sudo systemctl enable sssd
sudo systemctl start sssd


### #####Instalação Cliente LDAP Debian 12

apt install ldap-client
apt install libpam-ldap libnss-ldap


