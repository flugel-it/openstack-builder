#!/bin/bash

ISO=$1
DEV=$2
DIST=trusty

function usage {
  echo "create-booteable-netinstall.sh [iso_image] [device]"
}

if [ $(test -f ${ISO}) == 0 ]
then
  echo "${ISO}: is not a regular file"
  usage
  exit 1
fi

if [ $(test -b ${DEV}) == 0 ]
then
  echo "${ISO}: is not a block device"
  usage
  exit 1
fi

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

TMPMNT=$(mktemp -d)
BUILD=/tmp/bootstrap

mount -o loop $ISO $TMPMNT
rsync -va --delete ${TMPMNT}/ ${BUILD}/

echo "copy isolinux files..."
mkdir -p $BUILD
mkdir $BUILD/scripts $BUILD/isolinux
cp /usr/lib/syslinux/menu.c32 $BUILD/isolinux
cp ../preseed/openstack-builder.seed $BUILD/preseed
cp ../preseed/flugel-first-boot.conf $BUILD/scripts

cat > $BUILD/isolinux/isolinux.cfg << EOF

CONSOLE 0
SERIAL 0 115200 0

ui /isolinux/menu.c32
prompt 0
default openstack-flugel
timeout 100

label openstack-flugel
kernel /install/vmlinuz
append initrd=/install/initrd.gz vga=normal auto file=/cdrom/preseed/openstack-builder.seed netcfg/get_hostname=openstack-flugel locale=en_US console-setup/layoutcode=us netcfg/choose_interface=eth0 debconf/priority=critical --

EOF

mkdir -p $BUILD/boot/grub

cat > $BUILD/boot/grub/grub.cfg << EOF

if loadfont /boot/grub/font.pf2 ; then
        set gfxmode=auto
        insmod efi_gop
        insmod efi_uga
        insmod gfxterm
        terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

menuentry "openstack-flugel" {
        set gfxpayload=keep
        linux   /install/vmlinuz vga=normal auto file=/cdrom/preseed/openstack-builder.seed netcfg/get_hostname=openstack-flugel locale=en_US console-setup/layoutcode=us netcfg/choose_interface=eth0 debconf/priority=critical --
        initrd  /install/initrd.gz
}

EOF

echo "Creating iso image..."
cd $BUILD/isolinux
mkisofs -q -V "UbuntuNetInstall" \
	-o /tmp/openstack-builder.iso \
	-b isolinux/isolinux.bin -c boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table -r -J \
       	$BUILD
cd -
echo "ISO Done!"

echo "command parameters: " $1
if [ -n "$DEV" ]; then
  rmdir $TMPMNT 2>/dev/null
	echo "Creating USB booteable...."
	MNTTMP=$(mktemp -d)
	umount ${DEV}* > /dev/null 2>&1

  if [ 1 == 0 ]
  then
	  echo "Erasing USB stick ..."
	  dd if=/dev/zero of=$DEV bs=512 count=1 conv=notrunc
	  echo "Creating partitioning and filesystem"
	  install-mbr --force $DEV
	  parted -s $DEV mkpart primary 1 3500
	  parted -s $DEV set 1 boot on
    DEV=${DEV}1
	  mkfs.vfat -I -n openstack-builder ${DEV}
  else
    DEV=${DEV}1
  fi

	echo "Copying files ..."
	mount ${DEV} $MNTTMP
	rsync -va ${BUILD}/ ${MNTTMP}/
	cp $BUILD/isolinux/isolinux.cfg ${MNTTMP}/syslinux.cfg
	syslinux -i ${DEV}
	umount ${DEV}
	echo "USB Done!"
fi

umount $TMPMNT
rmdir $TMPMNT
echo "clean up..."
rm -r $BUILD

