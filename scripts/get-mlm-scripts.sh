#!/bin/bash
curl -Sks https://raw.githubusercontent.com/dvosburg/susemanager-contributions/master/scripts/machine-id-refresh.sh > /usr/local/bin/machine-id-refresh.sh
curl -Sks https://raw.githubusercontent.com/dvosburg/susemanager-contributions/master/scripts/prep-and-clean.sh > /usr/local/bin/prep-and-clean.sh
curl -Sks https://raw.githubusercontent.com/dvosburg/susemanager-contributions/master/scripts/two-gb-swap-file-create.sh > /usr/local/bin/two-gb-swapfile-create.sh
chmod +x /usr/local/bin/*.sh
