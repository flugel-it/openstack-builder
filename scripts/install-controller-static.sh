    This file is part of Openstack-Builder.

    Openstack-Builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Openstack-Builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.

    Copyright flugel.it LLC
    Authors: Luis Vinay <luis@flugel.it>
             Diego Woitasen <diego@flugel.it>



#!/bin/bash
# You can optionally connect to the VM with
# virt-viewer -c qemu:///system Debian7

#
# usage:
#
#      install-controller.sh [kvm_server]
#

# export OS=pe-den-con-01
DEST=$1
OS=$2
DIR=$3
IPADDR=$4
NETMASK=$5
GATEWAY=$6

[ "$OS" == "" ] && OS=Ubuntu-14.04
[ "$DIR" == "" ] && DIR=/var/lib/libvirt/images

#--file /var/lib/libvirt/images/openstack_controller.img \

virt-install \
--connect qemu+ssh://root@${DEST}/system \
--name ${OS} \
--ram 2048 \
--vcpus 2 \
--file ${DIR}/${OS}.img \
--file-size=30 \
--location http://us.archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/ \
--virt-type kvm \
--os-variant ubuntutrusty \
--network bridge=virbr0 \
--extra-args "auto=true hostname=${OS} domain=openstack.io url=http://cloud-master.flugel.it/openstack-builder.seed netcfg/get_ipaddress=${IPADDR} netcfg/get_netmask=${NETMASK} netcfg/get_gateway=${GATEWAY} netcfg/get_nameservers=8.8.8.8 netcfg/disable_dhcp=true"

