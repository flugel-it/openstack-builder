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

