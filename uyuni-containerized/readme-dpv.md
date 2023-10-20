# using Uyuni in containers

### System Requirements

Uyuni containerized is currently a single system container, running on a dedicated host using podman. There are numerous benefits to this - with more to come. 
In future this will expand to multiple containers and be offered to run on k8s.  Then we can offer modular scalability and resilience

#### Server requirements
Uyuni server runs on a single container host with the following requirements:

openSUSE Leap 15.4 or 15.5, Leap Micro 5.4
16 GB RAM (minimum)
10GB root volume storage (minimum)

Additional storage 200GB (minimum) mounted on '/var/lib/containers/storage' 

Uyuni server installation will map the volumes for persistent storage there by default.


#### Network requirements
The documented Uyuni requirements for networking are similar to the standard install and can be found here: 
https://www.uyuni-project.org/uyuni-docs/en/uyuni/installation-and-upgrade/network-requirements.html

Exception is noted here:
 * **FQDN**: Define the FQDN of the containerized Uyuni server separate from the container host.  It must be resolvable by the client systems, and should be defined before installing.





**The Uyuni container tools are a work in progress**

* `uyuniadm` used to help user administer uyuni servers on k8s and podman
* `uyunictl` used to help user managing Uyuni and SUSE Manager Servers mainly through its API



## Uyuniadm usage

Available Commands:
  * **help**: Help about any command
  * **install**: install a new server from scratch
  * **migrate**: migrate a remote server to containers
  * **uninstall**: uninstall a server

For more information about flags `uyuniadm --help`


### Using Uyuniadm to install a containerized server

Install a new server from scratch

The install command assumes the following:
  * podman or kubectl is installed locally
  * if kubectl is installed, a working kubeconfig should be set to connect to the cluster to deploy to

When installing on kubernetes, the helm values file will be overridden with the values from the uyuniadm parameters or configuration.

NOTE: for now installing on a remote cluster or podman is not supported!

```
Usage:
  uyuniadm install [fqdn] [flags]
```

Here is an example:
```
uyuniadm install podman uyuni-container.site.com --ssl-city Anderson --ssl-country US --ssl-state Indiana --tz 'America/Detroit' --image registry.opensuse.org/systemsmanagement/uyuni/master/containers/uyuni/server 
```
The current uyuni containerized images are on registry.opensuse.org:
```
registry.opensuse.org/systemsmanagement/uyuni/master/containers/uyuni/server
```

For more information about flags `uyuniadm install --help`

### Uyuniadm migrate

Migrate a remote server to containers

This migration command assumes a few things:
  * the SSH configuration for the source server is complete, including user and
    all needed options to connect to the machine,
  * an SSH agent is started and the key to use to connect to the server is added to it,
  * podman or kubectl is installed locally
  * if kubectl is installed, a working kubeconfig should be set to connect to the cluster to deploy to

NOTE: for now installing on a remote cluster or podman is not supported yet!

```
Usage:
  uyuniadm migrate [source server FQDN] [flags]
```
For more information about flags `uyuniadm migrate --help`

#### SSH Configuration Example
1. In the destination server, add to `~/.ssh/config` :
   ```
   Host SOURCE_HOSTNAME
    Hostname SOURCE_HOSTNAME
    StrictHostKeyChecking no
    Port 22
    User SOURCE_USER
    ```
2. If you already have a key, run:

    ```
    ssh-copy-id YOUR_HOST
    ```
    If not, run `ssh-keygen` to generate it.
3. If the `SOURCE_USER` user is not root, it should be able to run `rsync`. It can be done by adding to `/etc/sudoers`:
    ```
    add to sudoers file
    SOURCE_USER ALL=(ALL) NOPASSWD:/usr/bin/rsync
    ```
4. To provide a ssh agent with key, in the destination server:
    ```
    eval `ssh-agent`
    ssh-add $KEY_PATH
    ```
### Uyuniadm uninstall

Uninstall a server
```
Usage:
  uyuniadm uninstall [flags]
```

For more information about flags `uyuniadm uninstall --help`


## Uyunictl usage
Available Commands:
  * **cp**: copy files to and from the containers
  * **exec**: execute commands inside the uyuni containers using 'sh -c'
  * **help**: Help about any command

Using `uyunictl` to access a remote cluster requires `kubectl` to be configured to connect to it before hand.

In order to connect to a remote `podman`, ensure the `podman.socket` systemd unit is active on the server by running `systemctl enable --now podman.socket`.
Then configure the Podman connection on the client machine:

```
podman system connection add <name> ssh://root@<host.fqdn>
```

Then export `CONTAINER_CONNECTION=<name>` before running `uyunictl`.
Note that passing `--identity <file>` may be needed to tell SSH which key to use to connect to the podman host.


### Uyunictl cp

Takes a source and destination parameters. One of them can be prefixed with 'server:' to indicate the path is within the server pod.

```
Usage:
  uyunictl cp [path/to/source.file] [path/to/destination.file] [flags]
```
For more information about flags `uyunictl cp --help`

### Uyunictl exec

Execute commands inside the uyuni containers using 'sh -c'

```
Usage:
  uyunictl exec '[command-to-run --with-args]' [flags]
```
For more information about flags `uyunictl exec --help`

## Configuration File Example
All the commands can accept flags or yaml configuration file (using the option `-c`). This is an example of configuration file:
```
db:
  password: YOUR_DB_PASSWORD
cert:
  password: YOUR_DB_PASSWORD
scc:
  user: YOUR_SCC_USER
  password: YOUR_SCC_PASSWORD
email: YOUR_MAIL
emailFrom: YOUR_MAIL
image: YOUR_IMAGE_REGISTRY

helm:
  uyuni:
    chart: oci://OCI_REGISTRY
    values: /root/chart-values.yaml
podman:
  arg:
    - -p
    - 8000:8000
    - -p
    - 8001:8001
    - ""
```
## Setting Up Uyuni for the First Time

Here is a basic workflow example for setting up Uyuni in containers for the first time.

1. Install the OS and partition the disk as required.
2. Add the repository for the tools:  
	```
	zypper ar -f https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Master:/ServerContainer/openSUSE_Leap_15.4/ uyuni-container-tools
	```
3. Install the necessary packages:
	```
	zypper in uyunictl uyuniadm
	```
4. Install the Uyuni server as outlined above:

 ```
uyuniadm install podman uyuni-container.site.com --ssl-city Anderson --ssl-country US --ssl-state Indiana --tz 'America/Detroit' --image registry.opensuse.org/systemsmanagement/uyuni/master/containers/uyuni/server 
```
5. Log in to the webUI and set your Organization name, login user, and password.  In this example, the user is 'admin' and the password 'susemanager'

6. Add some channels that might interest you.  These are examples that do not require special SCC credentials:

Leap Micro 5.4:
```
uyunictl exec 'spacewalk-common-channels -u admin -p susemanager -a x86_64 opensuse_micro5_4*' 
```
AlmaLinux9:
```
uyunictl exec 'spacewalk-common-channels -u admin -p susemanager -a x86_64 almalinux9 almalinux9-uyuni-client almalinux9-appstream' 
```
Ubuntu 22.04:
```
uyunictl exec 'spacewalk-common-channels -u admin -p susemanager ubuntu-2204-pool-amd64-uyuni ubuntu-2204-amd64-main-uyuni ubuntu-2204-amd64-main-updates-uyuni ubuntu-2204-amd64-main-security-uyuni ubuntu-2204-amd64-uyuni-client ubuntu-2204-amd64-main-backports-uyuni' 
```
Give your server some time to sync all the channels, and check to ensure they completed by looking at the Software list in the webUI.  

7. Create Activation Keys in the webUI to align with the channels you created.  Best practice for simplicity is to create them with labels to match the distribution:
```
1-leapmicro54
1-almalinux9
1-ubuntu2204
```
8. Create bootstrap scripts to register systems to your Uyuni.  An example is below:
```
uyunictl exec 'mgr-bootstrap  --script=bootstrap-ubuntu2204.sh  --activation-keys=1-ubuntu2204 --ssl-cert=/srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT'
```
9. Register systems with Uyuni using the bootstrap scripts.  You can find the listing with a web browser:
https://<<uyuni_server_fqdn>>/pub/bootstrap

Copy the URL link desired from there, and run it from a root terminal on the client you wish to register.  Here is an example:
```
curl -Sks http://10.173.1.46/pub/bootstrap/bootstrap-ubuntu2204.sh | /bin/bash
```
