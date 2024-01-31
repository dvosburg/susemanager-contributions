# Set Up SUMA 4.3 from VM image

## What is the VM image?

You will find the minimal images for SUSE Manager 4.3 in various formats.  It includes the underlying OS bits (SLES15 SP4) and the SUSE Manager software current at the time of build.
Download the appropriate one for your environment.

### Server requirements
SUSE Manager server has the following requirements:

16 GB RAM (minimum)

15 GB root volume storage (default for the image)

Additional storage 300GB (minimum)  

### Create startup file to set the root password
The SUSE Manager VM image does not setup root or any other user account. User or root authentications need to be setup during first boot. This can be done using either Ignition or Cloud-Init methods.
#### Ignition method
Ignition is a provisioning tool that enables you to configure a system according to your specification on the first boot. When the system is booted for the first time, Ignition is loaded as part of an initramfs and searches for a configuration file within a specific directory (on a USB flash disk, or you can provide a URL).

Ignition uses a configuration file in the JSON format. The file is called ```config.ign```.

##### Set root password using Ignition
These preparatory steps should be performed from any Linux host.
You will be creating an ISO image to be attached to the virtual machine.
It MUST be present at first boot to define the root user and password.

Create the root user with a hashed password in the Ignition configuration file.
Obtain the password hash you will use by issuing this interactive command:
```
openssl passwd -6
```
Use this hash as the value of the ```passwordHash``` attribute.

The users attribute must contain at least one ```name``` attribute.

Create the directory structure for the ignition ISO:
```
mkdir -p root/Ignition
```
Create a ```root/ignition/config.ign``` file with this content:
```
{
  "ignition": {
    "version": "3.2.0"
  },
  "passwd": {
    "users": [
      {
        "name": "root",
        "passwordHash": "$2a$10$qV298UV11u9lCFDjpHpCUe1cErBiVR.G3shukxs3.2PAO1xhJWs0K"
      }
    ]
  }
}
```
Substitute your password hash for the one in this example - which would set the root password to ```linux```.

Prepare the Ignition ISO file using the command:
```
mkisofs -full-iso9660-filenames -o suma_ignition.iso -V ignition root
```
Copy the resulting ```suma_ignition.iso``` file to a place where you can assign it to the SUMA virtual machine as a CDROM device.  
## Boot the new VM in your chosen hypervisor
Once you have assigned the network device, VM image, ignition ISO, and additional storage device to the VM profile, start it. Connect to it over SSH using the root user and password you defined.

### Add SUSE Manager registration key

Obtain your SUSE Manager Registration Code from SUSE Customer Center - https://scc.suse.com

Register SUSE Manager with SCC per the example below:
```
SUSEConnect -e <EMAIL_ADDRESS> -r <SUSE_MANAGER_CODE>
```
Validate the authorized extensions by running the list extensions command:
```
SUSEConnect --list-extensions
```
### Set up storage for SUSE Manager

The SUSE Manager VM image uses xfs for its 15GB root.  Since SUSE Manager requires more space for ```/var/spacewalk```, ```/var/lib/pgsql```, and ```/var/cache```, the image includes a script to direct those to additional storage.

When you launch your instance, you can log in to the SUSE Manager Server and use this command to find all available storage devices:
```
hwinfo --disk | grep -E "Device File:"
```
If you are not sure which device to choose, use the ```lsblk```command to see the name and size of each device. Choose the name that matches with the size of the virtual disk you are looking for.

You can set up the external disk with the ```suma-storage``` command. This creates an XFS partition mounted at /manager_storage and uses it as the location for the database and repositories:
```
/usr/bin/suma-storage <storage-disk-device> [<database-disk-device>]
```
If ```<database-disk-device>```is specified, the given disk device will be set up
as data base storage (recommended). If omitted, ```<storage-disk-device>``` will
be used for both channel and data base storage.

Optionally you can partition and mount the virtual disks at the following locations using YaST Partitioner (yast2 disk).

Storage size values are the absolute minimum. They are suitable only for a small test or demonstration installation, such as a server with only a few clients. Especially ```/var/spacewalk/``` may quickly need more space as more products are added to SUMA. You may consider creating a separate partition for ```/srv``` where Kiwi images
are stored if SUSE Manager will be used for image management.

| Additional Storage   | Name      | Sizing        | Mount point  |
| ------------------   | --------- | ------------- | ------------ |
| Device/partition2    | spacewalk | 250 GB        | /var/spacewalk |
| Device/partition3    | pgsql     | 100 GB        | /var/lib/pgsql |
| Device/partition4    | varcache  | 50  GB        | /var/cache   |




### Network requirements
By default, the minimal image uses a single-interface DHCP.  This assumes that the specific hostname will be assigned to the MAC address via DHCP.  

Without a specific assignment, the system will fall back to the name 'localhost'. This needs to be changed before setting up the SUSE Manager server.   
 * **FQDN**: Define the FQDN of the SUMA server  It must be resolvable by the client systems, and should be defined before completing setup
 - Step 1 - ```hostnamectl set-hostname <<suma.full.fqdn>>```
 - Step 2 - Add a new line to ```/etc/hosts``` for the server like this example, with both the FQDN and the short name of the SUMA server:

 ```
 10.10.10.1  suma.full.fqdn suma
 ```
### Add the SUSE Manager registration key

Obtain your SUSE Manager Registration Code from SUSE Customer Center.  This will typically be a key for 'Lifecycle Management +'

 - https://scc.suse.com

Register SUSE Manager with SCC per the example below:
```
SUSEConnect -e <EMAIL_ADDRESS> -r <SUSE_MANAGER_CODE>
```
Validate the authorized extensions by running the list extensions command:
```
SUSEConnect --list-extensions
```

### Apply all available updates and reboot
The vm image comes with the necessary SUSE Manager and operating system packages already installed.

Apply all available updates to the server and reboot:
```
zypper up
shutdown -r now
```

### Completing setup
When you have finished installing the SUSE Manager Server, you need to set it up so it is ready to use. For more information, see SUSE Manager Server Setup:
https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/server-setup.html
