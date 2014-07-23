#!/bin/bash

set -x
env

VARIANT=${VARIANT:-ubuntutrusty}
RAM=${RAM:-512}
BRIDGE=${BRIDGE:-virbr0}

test -z "$NAME" && \
	{ echo "NAME env variable is required"; exit 1; }

virt-install --os-variant ${VARIANT} \
	--connect qemu:///system \
	--virt-type kvm \
	--name ${NAME} --ram ${RAM} \
	--disk path=/var/lib/libvirt/images/${NAME}.qcow2,format=qcow2 \
	--graphics vnc --import --noautoconsole --autostart \
	--network bridge=${BRIDGE}


