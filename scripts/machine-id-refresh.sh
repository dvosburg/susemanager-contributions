#!/bin/bash
rm /etc/machine-id -Rf
rm /var/lib/dbus/machine-id -Rf
dbus-uuidgen --ensure
systemd-machine-id-setup
