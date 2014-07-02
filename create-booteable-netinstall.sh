#!/bin/bash


DIST=trusty
DEV=$1
SEED_URL=http://192.168.1.100/Akilion/akilion.seed

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run with root privilege. Trying to sudo command."
	sudo $0 $1
    exit
fi

if [ ! -f /usr/lib/syslinux/isolinux.bin ]; then
        apt-get update
        apt-get install -y syslinux
fi


if [ ! -f /sbin/install-mbr ]; then
	apt-get update
	apt-get install -y mbr
fi

if [ ! -f /usr/bin/mkisofs ]; then
        apt-get update
        apt-get install -y genisoimage
fi


echo "copy isolinux files..."
mkdir -p /tmp/iso
cp isolinux/* /tmp/iso

wget -cq http://pciids.sourceforge.net/v2.2/pci.ids -O /tmp/iso/pci.ids

echo "download 64bit ${DIST} kernel and initrd..."
wget -cq http://archive.ubuntu.com/ubuntu/dists/${DIST}/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux -O /tmp/iso/linux64
wget -cq http://archive.ubuntu.com/ubuntu/dists/${DIST}/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz -O /tmp/iso/initrd64.gz

cat > /tmp/iso/isolinux.cfg << EOF

default seed
#ui menu.c32
timeout 100
menu title Ubuntu NetInstall CD - Akilion

label install
kernel linux64
append initrd=initrd64.gz vga=normal auto url=$SEED_URL locale=en_US console-setup/layoutcode=us netcfg/choose_interface=eth0 debconf/priority=critical --

label seed
kernel linux64
append initrd=initrd64.gz vga=768 auto url=$SEED_URL locale=en_US console-setup/layoutcode=ch console-setup/variantcode=fr netcfg/choose_interface=p6p1 debconf/priority=critical -- console=ttyS0,115200n8 quiet –

label Hardware Detection Tool
kernel hdt.c32

EOF

echo "Creating iso image..."
mkisofs -q -V "UbuntuNetInstall" -o /tmp/UbuntuNetInstall.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -r -J /tmp/iso
echo "ISO Done!"

echo "command parameters: " $1
if [ -n "$DEV" ]; then
	echo "Creating USB booteable...."
	MNTTMP=$(mktemp -d)
	umount ${DEV}* > /dev/null 2>&1
	echo "Erasing USB stick ..."
	dd if=/dev/zero of=$DEV bs=512 count=1 conv=notrunc
	echo "Creating partitioning and filesystem"
	install-mbr --force $DEV
	parted -s $DEV mkpart primary 1 100
	parted -s $DEV set 1 boot on
	mkfs.vfat ${DEV}1
	echo "Copying files ..."
	mount ${DEV}1 $MNTTMP
	cp -a /tmp/iso/* $MNTTMP
	cp /tmp/iso/isolinux.cfg /tmp/iso/syslinux.cfg
	syslinux -i ${DEV}1
	umount ${DEV}1
	echo "USB Done!"
fi

echo "clean up..."
rm -r /tmp/iso

