#!/bin/bash
# Copyright (c) 2019 SUSE Linux GmbH
#
#
# This script is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License

usage() {
    echo "This script creates and mounts a partition for SUMA container storage"
    echo "on the device you specify"
    echo
    echo "Usage: $0 <storage-disk-device>"
    echo
    echo "<storage-disk-device> will be used for all container storage."
    echo
    echo "Use 'fdisk -l' to list available storage disk devices"
}


case "$1" in
  "-h"|"--help"|"")
    usage
    exit 0
    ;;
esac
export device=$1

# Check to see if this is NVMe or not
if [[ $device == *nvme* ]]; then
  partition=${device}p1
  else
  partition=${device}1
fi
echo $partition

# Make a new partition table, and stop if disk is in use
parted -s $device mklabel GPT
if [ $? != 0 ]; then
     echo "Creating new GPT label failed.  Is disk already in use?"
     echo "Aborting storage provisioning."
     exit
fi

# Make a new partition and format it as xfs
parted -s $device mkpart primary 2048s 100%
mkfs.xfs -f $partition &>/dev/null 

# Create the mountpoint directory if not already present
mkdir -p /var/lib/containers/storage/volumes

# Find the UUID of our partition
export uuid=$(blkid -s UUID -o value $partition)

# Mount the partition using the UUID
mount UUID=$uuid /var/lib/containers/storage/volumes

# Create /etc/fstab entry so it is mounted on boot
echo "UUID=$uuid /var/lib/containers/storage/volumes xfs defaults,nofail 1 2" >> /etc/fstab

# Finish with a nice message
echo "SUSE Manager storage is now provisioned to use $partition"
