#!/bin/bash

#    This file is part of Openstack-Builder.
#
#    Openstack-Builder is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openstack-Builder is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.
#
#    Copyright flugel.it LLC
#    Authors: Luis Vinay <luis@flugel.it>
#             Diego Woitasen <diego@flugel.it>
#

if ! [[ -f /etc/libvirt/.skipinstallpackages ]]
then
	echo "Installing packages, please wait..." | wall
	apt-get install qemu-kvm virtinst libvirt-bin screen vim -y --force-yes

	echo "Rebooting in 5 seconds..." | wall
	sleep 5
	[[ $? == 0 ]] && > /etc/libvirt/.skipinstallpackages
	#reboot
fi

if ! [[ -f /etc/libvirt/.skipbridgebr0  ]]
then

	echo "Configuring bridges, please wait..." | wall

sed -i 's/eth0/br0/g' /etc/network/interfaces
sed -i '/iface br0 inet dhcp/a \
        bridge-ports eth0' /etc/network/interfaces

	echo "Rebooting in 5 seconds..." | wall
	sleep 5

echo '
auto br1
iface br1 inet manual
        bridge_ports none' >> /etc/network/interfaces

	echo "Rebooting in 5 seconds..." | wall
	sleep 5

[[ $? == 0 ]] && > /etc/libvirt/.skipbridgebr0
#reboot
fi

if ! [[ -f /etc/libvirt/.skiplibvirtcleanup ]]
then

	echo "Configuring libvirt, please wait..." | wall

	wget -O /tmp/internal.xml http://flugel.it/public/internal.xml
	wget -O /tmp/external.xml http://flugel.it/public/external.xml

	virsh net-destroy default
	virsh net-undefine default
	
	virsh net-define /tmp/internal.xml 
	virsh net-define /tmp/external.xml 

	virsh net-autostart internal
	virsh net-autostart external

	echo "Rebooting in 5 seconds..." | wall
	sleep 5

[[ $? == 0 ]] && > /etc/libvirt/.skiplibvirtcleanup

if ! [[ -f /etc/libvirt/.skipstorage ]]
then
  virsh pool-define-as storage  dir - - - - /var/lib/libvirt/storag
  virsh pool-build storage
  virsh pool-start storage
  virsh pool-autostart storage
fi
[[ $? == 0 ]] && > /etc/libvirt/.skipstorage

#reboot
fi
