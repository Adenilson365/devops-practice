#!/usr/bin/env bash
set -euo pipefail

# This script is used to configure the client for the bind9 tests.
# It is called by the test scripts to set up the client environment.    

# Install necessary packages for the client
apt-get update
apt-get install -y dnsutils vim 
# Configure resolv.conf to use the local DNS server
echo "nameserver 192.168.56.53" | sudo tee /etc/resolv.conf

