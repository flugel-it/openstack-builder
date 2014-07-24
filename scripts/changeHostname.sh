#!/bin/bash

# ----------------------------------------------------------------- #
# v0.0.1
# Autoconfiguration script for:
# - Hostname
# - Minion ID
# - Network Addresses
#
#
# ToDo:
# - Network config Templates
# - Clean code up
#
# Luis Vinay
# ----------------------------------------------------------------- #

function network-seed {
   [ test -f /etc/network/interfaces.bak ] || cp /etc/network/interfaces /etc/network/interfaces.bak
   cat < EOF > /etc/network/interfaces
auto lo eth0

iface lo inet loopback

iface eth0 inet dhcp

iface eth1 inet static
   address ${NEWADDRESS}
   netmask 255.255.255.0
EOF
}

function network-hyper {
   [ test -f /etc/network/interfaces.bak ] || cp /etc/network/interfaces /etc/network/interfaces.bak
   cat < EOF > /etc/network/interfaces

iface lo inet loopback
auto lo br0 br1

iface br0 inet dhcp
        bridge_ports eth0

iface br1 inet manual
        bridge_ports eth1
}

# ---- Configure Hostname ----

CURRHOSTNAME=`/bin/hostname | awk -F'.' '{print $1}'`
MAC=$(ip a s dev eth0 | grep link\/eth | awk '{print $2}' | awk -F\: '{print $4$5$6}')

if ! [ grep ${MAC}.cheff.akilion.biz /etc/hostname ]; then

   NEWHOSTNAME=atlas-${CURRHOSTNAME}-$MAC.cheff.akilion.biz
   echo ${NEWHOSTNAME} > /etc/hostname

   if [ test -f /etc/salt/minion_id ]; then
      echo ${NEWHOSTNAME} > /etc/salt/minion_id
      /etc/init.d/salt-minion restart 
   fi

   echo "New hostname: ${NEWHOSTNAME}"
   reboot
fi

# ---- Configure Network Interfaces ----

NEWADDRESS=`printf "10.%d.%d.1\n" 0x${MAC:0:2} 0x${MAC:2:2}`

if [ grep -i seed /etc/hostname ]; then
   grep -q ${NEWADDRESS} /etc/network/interfaces || network-seed
   reboot
fi

if [ grep -i hyper /etc/hostname ];then
   grep br0 /etc/network/interfaces || network-hyper
   reboot
fi

exit 0

