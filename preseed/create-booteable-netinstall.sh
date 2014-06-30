#!/bin/bash

DIST=trusty
DEV=$1

if [ ! -f /usr/lib/syslinux/isolinux.bin ]; then
	apt-get update
	apt-get install -y syslinux
fi

echo "copy isolinux files..."
mkdir -p /tmp/iso
cp /usr/lib/syslinux/isolinux.bin /tmp/iso
cp /usr/lib/syslinux/vesamenu.c32 /tmp/iso
cp /usr/lib/syslinux/hdt.c32 /tmp/iso
wget -cq http://pciids.sourceforge.net/v2.2/pci.ids -O /tmp/iso/pci.ids

echo "download 64bit ${DIST} kernel and initrd..."
wget -cq http://archive.ubuntu.com/ubuntu/dists/${DIST}/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux -O /tmp/iso/linux64
wget -cq http://archive.ubuntu.com/ubuntu/dists/${DIST}/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz -O /tmp/iso/initrd64.gz

cat > /tmp/iso/isolinux.cfg << EOF

default vesamenu.c32
timeout 100
#menu background background.jpg
menu title Ubuntu NetInstall CD - Akilion

label install
kernel linux64
append initrd=initrd64.gz vga=normal auto url=http://diegowspublic.s3.amazonaws.com/akilion.seed locale=en_US console-setup/layoutcode=us netcfg/choose_interface=eth0 debconf/priority=critical --

label Hardware Detection Tool
kernel hdt.c32

EOF

echo "Creating iso image..."
mkisofs -q -V "UbuntuNetInstall" -o /tmp/UbuntuNetInstall.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -r -J /tmp/iso
echo "ISO Done!"

if [ -n "$DEV" ]; then
	echo "Creating USB booteable...."
	MNTTMP=$(mktemp -d)
	umount ${DEV}* > /dev/null 2>&1
	install-mbr $DEV
	parted -s $DEV rm 1
	parted -s $DEV mkpart primary 1 100
	parted -s $DEV set 1 boot on
	mkfs.vfat ${DEV}1
	mount ${DEV}1 $MNTTMP
	cp -a /tmp/iso/* $MNTTMP
	cp /tmp/iso/isolinux.cfg /tmp/iso/syslinux.cfg
	syslinux -i ${DEV}1
	umount ${DEV}1
	echo "USB Done!"
fi

echo "clean up..."
#rm -r /tmp/iso

