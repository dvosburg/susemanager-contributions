#!/bin/bash
hostnamectl set-hostname suma5-server-image.site.com
echo "Hostname set to suma5-server-image.site.com"
nmcli device modify eth0 \
  ipv4.method manual \
  ipv4.addresses 10.173.1.50/24 \
  ipv4.gateway 10.173.1.1 \
  ipv4.dns 10.173.1.1

echo "IP address set to 10.173.1.50"
echo  "rebooting in one minute..."
shutdown -r 1
