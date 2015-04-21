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
--extra-args "auto=true domain=flugel.it url=http://cluod-master.flugel.it/openstack-builder.seed"
