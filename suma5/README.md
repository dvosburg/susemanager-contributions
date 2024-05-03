# Here is a disk provisioning script you might find useful for SUSE Manager 5.X storage

* suma5-bigdisk.sh  - One argument - device name from 'fdisk -l', and it creates one large XFS partition, mounts it on '/var/lib/containers/storage/volumes', and creates the 'etc/fstab' entry

If you want this in '/usr/local/bin' you can issue this command from your client:

```
curl -Sks https://raw.githubusercontent.com/dvosburg/susemanager-contributions/master/suma5/get-suma-script.sh | /bin/bash
```
