#!/bin/bash
curl -Sks https://raw.githubusercontent.com/dvosburg/susemanager-contributions/master/suma5/suma5-bigdisk.sh > /usr/local/bin/suma5-bigdisk.sh
curl -Sks https://raw.githubusercontent.com/dvosburg/susemanager-contributions/master/suma5/set_hostname_and_ip_for_suma5.sh > /usr/local/bin/set_hostname_and_ip_for_suma5.sh
chmod +x /usr/local/bin/suma5-bigdisk.sh
chmod +x /usr/local/bin/set_hostname_and_ip_for_suma5.sh
