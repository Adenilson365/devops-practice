#!/bin/bash

mkdir -p /data
CPU=$(lscpu | grep -i "model name" | head -n1 | awk -F":" '{print $2}' | sed 's/ //g')
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - CPU: $CPU" \
        >> /data/events.log
    sleep 60
done