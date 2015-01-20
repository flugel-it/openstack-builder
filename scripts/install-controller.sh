#!/bin/sh
# You can optionally connect to the VM with
# virt-viewer -c qemu:///system Debian7

#
# usage:
#
#      install-controller.sh [kvm_server]
#

export OS=pe-den-con-01

DEST=$1

virt-install \
--connect qemu+ssh://root@${DEST}/system \
--name ${OS} \
--ram 512 \
--vcpus 1 \
--file /var/lib/libvirt/images/${OS}.img \
--file-size=15 \
--location http://us.archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/ \
--virt-type kvm \
--os-variant ubuntutrusty \
--network bridge=virbr0 \
--extra-args "auto=true hostname=${OS} domain=flugel.it url=http://www.ppmg.com.ar/openstack-builder.seed"
