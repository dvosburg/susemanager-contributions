#!/bin/bash
#  This script copies the proxy data from an existing containerized proxy to this one
# Define the source proxy server variable
PROXY1=suma5-proxy1.site.com
# Start by ensuring the services are stopped
mgrpxy stop
# Backup the existing files
mkdir -p /var/lib/containers/storage/volumes/backupvolumes/
mv /var/lib/containers/storage/volumes/uy* /var/lib/containers/storage/volumes/backupvolumes/
#
# Copy the files from PROXY1 to this proxy with rsync
rsync -Pav root@$PROXY1:/var/lib/containers/storage/volumes/uy* /var/lib/containers/storage/volumes/
echo "Copying of proxy cache complete!"
#
# Start up the proxy services on this server
mgrpxy start
#
echo "Proxy startup complete with new cache"
