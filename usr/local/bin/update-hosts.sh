#!/bin/bash

export WHOAMI=`whoami`
export WSLHOSTIP=`ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1`
export WSL2ALIASES=""


export WINDOWS_USER_HOMEDIR=`wslpath "$(wslvar USERPROFILE)" | grep -v "wslvar"`
export WINDOWS_HOMEDIR=`wslpath "$(wslvar WINDIR)" | grep -v "wslvar"`
export WINDOWS_HOSTSFILE="${WINDOWS_HOMEDIR}/System32/drivers/etc/hosts"

cp ${WINDOWS_HOSTSFILE} ~/hosts
sudo chmod a+w ~/hosts
sed -i "/wsl2hosts.wsl/d" ~/hosts 

for DOMAIN in `cat ~/.wsl2hosts`; do echo "${WSLHOSTIP} wsl2hosts.wsl ${DOMAIN}" >> ~/hosts ; done;
cp ~/hosts ${WINDOWS_HOSTSFILE}

start-servers.sh