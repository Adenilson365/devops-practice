#!/usr/bin/env bash
set -e

type=$1

apt install -y wget curl gnupg2 postgresql
sudo systemctl enable --now postgresql
sudo systemctl status postgresql

if [ "$type" = "server-agent" ]; then


    wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian12_all.deb
    dpkg -i zabbix-release_latest_7.4+debian12_all.deb
    apt update

    apt install -y zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent2 
    apt install -y zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql

    sudo -u postgres createuser --pwprompt zabbix
    sudo -u postgres createdb -O zabbix zabbix

    zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

    echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf

    systemctl restart zabbix-server zabbix-agent2 apache2
    systemctl enable zabbix-server zabbix-agent2 apache2
elif [ "$type" == "agent" ]; then
    wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian12_all.deb
    dpkg -i zabbix-release_latest_7.4+debian12_all.deb
    apt update
    apt install zabbix-agent2
    apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql
    systemctl enable zabbix-agent2
    systemctl restart zabbix-agent2
else
    echo "Invalid type. Please specify 'server' or 'agent'."
    exit 1
fi

