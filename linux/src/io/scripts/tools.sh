
#!/bin/bash

apt-get update
apt-get install -y stress-ng iotop sysstat htop vim

if [ -f /etc/default/sysstat ]; then
        sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
else
	echo "Verify if sysstat has installed"
fi


systemctl enable sysstat
systemctl start sysstat
systemctl daemon-reload
