#!/bin/bash

ISO=$1
DEV=$2
DIST=trusty

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run with root privilege. Trying to sudo command."
    exit -1
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

clear
echo "# -------------------------- WARNING!!! --------------------------------- #"
echo "# Review this information, otherwise you'll end-up LOOSING DATA!!!        #"
echo "# ----------------------------------------------------------------------- #"
echo "# Linux image: $ISO"
echo "# Target device (IMPORTANT): $DEV"
echo "# ----------------------------------------------------------------------- #"
echo "When you're ready press ENTER"
read

TMPMNT=$(mktemp -d)
BUILD=/tmp/bootstrap

mount -o loop $ISO $TMPMNT
rsync -va --delete ${TMPMNT}/ ${BUILD}/

echo "copy isolinux files..."
mkdir -p $BUILD
mkdir $BUILD/scripts
cp /usr/lib/syslinux/menu.c32 $BUILD/isolinux
cp ../preseed/akilion.seed $BUILD/preseed
cp ../scripts/rc.local ../scripts/changeHostname.sh $BUILD/scripts

cat > $BUILD/isolinux/isolinux.cfg << EOF

ui /isolinux/menu.c32
prompt 0
default seed
timeout 100

label Seed (Mini-PC)
kernel /install/vmlinuz
append initrd=/install/initrd.gz vga=768 auto file=/cdrom/preseed/akilion.seed netcfg/get_hostname=atlas-seed locale=en_US netcfg/choose_interface=p6p1 debconf/priority=critical -- console=ttyS0,115200n8 quiet –

label Hyper (Regular x86 PC)
kernel /install/vmlinuz
append initrd=/install/initrd.gz vga=768 auto file=/cdrom/preseed/akilion.seed netcfg/get_hostname=atlas-hyper locale=en_US netcfg/choose_interface=p6p1 debconf/priority=critical -- 

label Seed (Regular x86 PC)
kernel /install/vmlinuz
append initrd=/install/initrd.gz vga=normal auto file=/cdrom/preseed/akilion.seed netcfg/get_hostname=atlas-seed locale=en_US console-setup/layoutcode=us netcfg/choose_interface=eth0 debconf/priority=critical --

label Hardware Detection Tool
kernel hdt.c32

EOF

echo "Creating iso image..."
cd $BUILD/isolinux
mkisofs -q -V "UbuntuNetInstall" \
	-o /tmp/atlas.iso \
	-b isolinux/isolinux.bin -c boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table -r -J \
       	$BUILD
cd -
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
	parted -s $DEV mkpart primary 1 3500
	parted -s $DEV set 1 boot on
	mkfs.vfat ${DEV}1
	echo "Copying files ..."
	mount ${DEV}1 $MNTTMP
	rsync -va ${BUILD}/ ${MNTTMP}/
	cp $BUILD/isolinux/isolinux.cfg ${MNTTMP}/syslinux.cfg
	syslinux -i ${DEV}1
	umount ${DEV}1
	echo "USB Done!"
fi

umount $TMPMNT
rmdir $TMPMNT
echo "clean up..."
#rm -r $BUILD

