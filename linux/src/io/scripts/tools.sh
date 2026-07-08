
#!/bin/bash

apt-get update
apt-get install -y stress-ng iotop sysstat htop 

systemctl enable sysstat
systemctl start sysstat
systemctl daemon-reload