#!/bin/bash
# Remove any crud from previous usage
# Determine if the salt bundle is installed, remove the correlating stuff
if [ -f "/usr/bin/zypper" ] && [ -d "/etc/venv-salt-minion" ]; then
DIRECTORY="venv-salt-minion"
zypper -n rm venv*
rm /etc/zypp/repos.d/suseman*
elif [ -d "/etc/yum.repos.d" ] && [ -d "/etc/venv-salt-minion" ]; then
yum -y erase venv*
rm -rf /etc/yum.repos.d/suseman*
DIRECTORY="venv-salt-minion"
elif [ -f "/usr/bin/apt" ] && [ -d "/etc/venv-salt-minion" ]; then
DIRECTORY="venv-salt-minion"
apt remove -y venv* 
else
DIRECTORY="salt"
fi
if [ -f "/usr/bin/apt" ] && [ -d "/etc/salt" ]; then
apt remove -y salt-minion
elif [ -d "/etc/yum.repos.d" ] && [ -d "/etc/salt" ]; then
yum -y erase salt-minion
rm -rf /etc/yum.repos.d/suseman*
elif [ -f "/usr/bin/zypper" ] && [ -d "/etc/salt" ]; then
zypper -n rm salt-minion
rm /etc/zypp/repos.d/suseman*
fi
rm /var/cache/"$DIRECTORY"/* -Rf
rm /etc/"$DIRECTORY"/minion_id -Rf
rm /etc/"$DIRECTORY"/pki/minion/* -Rf
rm /etc/"$DIRECTORY"/minion.d/susemanager* -Rf
rm /etc/zypp/repos.d/susemanager* -Rf
# Prepare hostname
vi /etc/hostname
hostname -F /etc/hostname
