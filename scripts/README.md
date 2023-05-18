# Here are some scripts you might find useful for SUSE Manager clients, especially when building labs or demos

* machine-id-refresh.sh  - Removes and sets the /etc/machine-id using dbus and systemd tools
* prep-and-clean.sh   - removes either salt-minion or venv-salt-minion if installed, and sets hostname; works on SUSE, Debian or RH-derivatives
* two-gb-swapfile-create.sh  - creates a persisting 2GB swapfile on /




If you want all of them in '/usr/local/bin' you can issue this command from your client:

```
curl -Sks https://raw.githubusercontent.com/dvosburg/susemanager-contributions/master/scripts/get-suma-scripts.sh | /bin/bash
```
