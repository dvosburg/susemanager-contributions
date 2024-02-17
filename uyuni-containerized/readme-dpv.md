# using Uyuni in containers

### System Requirements

Uyuni containerized is currently a single system container, running on a dedicated host using podman. There are numerous benefits to this - with more to come.
In future this will expand to multiple containers and be offered to run on k8s.  Then we can offer modular scalability and resilience

#### Server requirements
Uyuni server runs on a single container host with the following requirements:

openSUSE Leap 15.5, Leap Micro 5.5, SLE Micro 5.5
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

* `mgradm` used to help user administer uyuni servers on k8s and podman
* `mgrctl` used to help user managing Uyuni and SUSE Manager Servers mainly through its API



## mgradm usage

Available Commands:
  * **help**: Help about any command
  * **install**: install a new server from scratch
  * **migrate**: migrate a remote server to containers
  * **uninstall**: uninstall a server

For more information about flags `mgradm --help`


### Using mgradm to install a containerized server

Install a new server from scratch

The install command assumes the following:
  * podman or kubectl is installed locally
  * if kubectl is installed, a working kubeconfig should be set to connect to the cluster to deploy to

When installing on kubernetes, the helm values file will be overridden with the values from the mgradm parameters or configuration.

NOTE: for now installing on a remote cluster or podman is not supported!

```
Usage:
  mgradm install [fqdn] [flags]
```

Here is an example:
```
mgradm install podman uyuni-container.site.com --ssl-city Anderson --ssl-country US --ssl-state Indiana --tz 'America/Detroit' --image registry.opensuse.org/systemsmanagement/uyuni/master/containers/uyuni/server
```
The current uyuni containerized images are on registry.opensuse.org:
```
registry.opensuse.org/systemsmanagement/uyuni/master/containers/uyuni/server
```

For more information about flags `mgradm install --help`

### mgradm migrate

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
  mgradm migrate [source server FQDN] [flags]
```
For more information about flags `mgradm migrate --help`

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
### mgradm uninstall

Uninstall a server
```
Usage:
  mgradm uninstall [flags]
```

For more information about flags `mgradm uninstall --help`


## mgrctl usage
Available Commands:
  * **cp**: copy files to and from the containers
  * **exec**: execute commands inside the uyuni containers using 'sh -c'
  * **help**: Help about any command

Using `mgrctl` to access a remote cluster requires `kubectl` to be configured to connect to it before hand.

In order to connect to a remote `podman`, ensure the `podman.socket` systemd unit is active on the server by running `systemctl enable --now podman.socket`.
Then configure the Podman connection on the client machine:

```
podman system connection add <name> ssh://root@<host.fqdn>
```

Then export `CONTAINER_CONNECTION=<name>` before running `mgrctl`.
Note that passing `--identity <file>` may be needed to tell SSH which key to use to connect to the podman host.


### mgrctl cp

Takes a source and destination parameters. One of them can be prefixed with 'server:' to indicate the path is within the server pod.

```
Usage:
  mgrctl cp [path/to/source.file] [path/to/destination.file] [flags]
```
For more information about flags `mgrctl cp --help`

### mgrctl exec

Execute commands inside the uyuni containers using 'sh -c'

```
Usage:
  mgrctl exec '[command-to-run --with-args]' [flags]
```
For more information about flags `mgrctl exec --help`

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
    For Leap 15.5:
	```
	zypper ar -f https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/openSUSE_Leap_15.5/systemsmanagement:Uyuni:Stable:ContainerUtils.repo
	```
    For Leap Micro 15.5:
    ```
	zypper ar -f https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/openSUSE_Leap_Micro_5.5/systemsmanagement:Uyuni:Stable:ContainerUtils.repo
	```
    For SLE Micro 5.5:
    ```
	zypper ar -f https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/SLE-Micro55/systemsmanagement:Uyuni:Stable:ContainerUtils.repo
	```
3. You will need to accept the repository signing key for this newly added repository.  

    For Leap 15.5:

    ```
    rpm --import https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/openSUSE_Leap_15.5/repodata/repomd.xml.key
    ```

    For Leap Micro 15.5:
   
    ```
    transactional-update run 'rpm --import https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/openSUSE_Leap_15.5/repodata/repomd.xml.key' && reboot
    ```

    For SLE Micro 5.5:
   
    ```
    transactional-update run 'rpm --import https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:/ContainerUtils/SLE-Micro55/repodata/repomd.xml.key' && reboot
    ```

4. Install the necessary packages:

	For Leap 15.5:
    ```
	zypper in mgrctl mgradm

	```
    For Leap Micro or SLE Micro:
    ```
    transactional-update -n pkg install mgrctl mgradm && reboot
    ```
5. Install the Uyuni server using the 'mgradm' tool

     Example using the Master (development) image of Uyuni:
     ```
     mgradm install podman uyuni-container.site.com --ssl-city Anderson --ssl-country US --ssl-state Indiana --tz 'America/Detroit' --image registry.opensuse.org/systemsmanagement/uyuni/master/containers/uyuni/server
      ```
      Example using the latest supported release of Uyuni:
      ```
      mgradm install podman uyuni-container.site.com --ssl-city Anderson --ssl-country US --ssl-state Indiana --tz 'America/Detroit' --image registry.opensuse.org/uyuni/server
      ```

6. Log in to the webUI and set your Organization name, login user, and password.  In this example, the user is 'admin' and the password 'susemanager'

7. Add some channels that might interest you.  These are examples that do not require special SCC credentials:

Leap Micro 5.5:
```
mgrctl exec 'spacewalk-common-channels -u admin -p susemanager -a x86_64 opensuse_micro5_5*'
```
AlmaLinux9:
```
mgrctl exec 'spacewalk-common-channels -u admin -p susemanager -a x86_64 almalinux9 almalinux9-uyuni-client almalinux9-appstream'
```
Ubuntu 22.04:
```
mgrctl exec 'spacewalk-common-channels -u admin -p susemanager ubuntu-2204-pool-amd64-uyuni ubuntu-2204-amd64-main-uyuni ubuntu-2204-amd64-main-updates-uyuni ubuntu-2204-amd64-main-security-uyuni ubuntu-2204-amd64-uyuni-client ubuntu-2204-amd64-main-backports-uyuni'
```
Give your server some time to sync all the channels, and check to ensure they completed by looking at the Software list in the webUI.  

8. Create Activation Keys in the webUI to align with the channels you created.  Best practice for simplicity is to create them with labels to match the distribution:
```
1-leapmicro55
1-almalinux9
1-ubuntu2204
```
9. Create bootstrap scripts to register systems to your Uyuni.  An example is below:
```
mgrctl exec 'mgr-bootstrap  --script=bootstrap-ubuntu2204.sh  --activation-keys=1-ubuntu2204 --ssl-cert=/srv/www/htdocs/pub/RHN-ORG-TRUSTED-SSL-CERT'
```
10. Register systems with Uyuni using the bootstrap scripts.  You can find the listing with a web browser, substituting your own server FQDN:
```
https://uyuni.server.fqdn/pub/bootstrap
```

Copy the URL link to the specific bootstrap script desired from there, and run it from a root terminal on the client you wish to register.  Here is an example:
```
curl -Sks http://10.173.1.46/pub/bootstrap/bootstrap-ubuntu2204.sh | /bin/bash
```
