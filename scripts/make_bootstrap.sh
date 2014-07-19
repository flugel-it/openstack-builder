#!/bin/bash

#Read variable from file or use the defaults
if [ -f ~/.akilion.cfg ]; then
	. ~/.akilion.cfg
else
        TEMPDIR=/tmp/bootstrap
	DIST=trusty	
	SEED_URL=http://192.168.1.100/Akilion/akilion.seed
	BUILD=$TEMPDIR/iso
	VERSION=14.04
fi

SERIAL_HEADER=$( cat << EOF
CONSOLE 0\n
SERIAL 0 115200 0\n
\n
EOF

)

SYSLINUX_HEADER=$( cat << EOF
default seed\n
ui menu.c32\n
prompt 0\
timeout 100\n
\n
EOF

)


ISOLINUX_HEADER=$( cat << EOF
default seed\n
\n
EOF

)

MENU_OPTION=$( cat << EOF
label seed\n
menu label ^Seed bootstrap\n
kernel /install/vmlinuz\n
#append initrd=initrd64.gz vga=normal auto file=/cdrom/preseed/AkilionSeed.seed locale=en_US console-setup/layoutcode=ch console-setup/variantcode=fr netcfg/choose_interface=p4p1 debconf/priority=critical -- console=ttyS0,115200n8 quiet –\n
append initrd=/install/initrd.gz vga=normal auto file=/cdrom/preseed/AkilionSeed.seed locale=en_US console-setup/layoutcode=ch console-setup/variantcode=fr netcfg/choose_interface=p4p1 debconf/priority=critical -- console=ttyS0,115200n8 quiet –\n
\n
label hyper\n
menu label ^Hyper bootstrap\n
kernel /install/vmlinuz\n
#append initrd=initrd64.gz vga=normal auto file=/cdrom/preseed/AkilionHyper.seed locale=en_US console-setup/layoutcode=ch console-setup/variantcode=fr netcfg/choose_interface=p4p1 debconf/priority=critical -- console=ttyS0,115200n8 quiet –\n
append initrd=/install/initrd.gz vga=normal auto file=/cdrom/preseed/AkilionHyper.seed locale=en_US console-setup/layoutcode=ch console-setup/variantcode=fr netcfg/choose_interface=eth0 debconf/priority=critical quiet –\n
\n
label compute\n
menu label ^Compute bootstrap\n
kernel /install/vmlinuz\n
#append initrd=initrd64.gz vga=normal auto file=/cdrom/preseed/AkilionCompute.seed locale=en_US console-setup/layoutcode=ch console-setup/variantcode=fr netcfg/choose_interface=p4p1 debconf/priority=critical -- console=ttyS0,115200n8 quiet –\n
append initrd=/install/initrd.gz vga=normal auto file=/cdrom/preseed/AkilionCompute.seed locale=en_US console-setup/layoutcode=ch console-setup/variantcode=fr netcfg/choose_interface=eth0 debconf/priority=critical quiet -\n
\n
EOF

)

SYSLINUX_FOOTER=$( cat << EOF

label Hardware Detection Tool\n
menu label ^Hardware Detection Tool\n
kernel hdt.c32\n
\n
label Reboot\n
menu label ^Reboot\n
com32 reboot.c32\n
\n
EOF

)

ISOLINUX_FOOTER=$( cat << EOF
label install\n
  menu label ^Install Ubuntu Server\n
  kernel /install/vmlinuz\n
  append  file=/cdrom/preseed/ubuntu-server.seed vga=788 initrd=/install/initrd.gz quiet --\n
label cloud\n
  menu label ^Multiple server install with MAAS\n
  kernel /install/vmlinuz\n
  append   modules=maas-enlist-udeb vga=788 initrd=/install/initrd.gz quiet --\n
label check\n
  menu label ^Check disc for defects\n
  kernel /install/vmlinuz\n
  append   MENU=/bin/cdrom-checker-menu vga=788 initrd=/install/initrd.gz quiet --\n
label memtest\n
  menu label Test ^memory\n
  kernel /install/mt86plus\n
label hd\n
  menu label ^Boot from first hard disk\n
  localboot 0x80\n
\n
EOF

)


DEV=$1

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run with root privilege. Trying to sudo command."
	sudo $0 $1
    exit
fi

mkdir -p $TEMPDIR

if [ ! -f $TEMPDIR/ubuntu-$VERSION-server-amd64.iso ]; then
   echo "Downloading ISO image"	
   wget -P $TEMPDIR http://releases.ubuntu.com/$VERSION/ubuntu-$VERSION-server-amd64.iso
else
   echo "ISO image already exists"
fi

rm -rf $BUILD
mkdir $BUILD

umount $TEMPDIR/mnt* > /dev/null 2>&1
mkdir -p $TEMPDIR/mnt

echo "Mounting ISO image"
mount -r -o loop  $TEMPDIR/ubuntu-$VERSION-server-amd64.iso $TEMPDIR/mnt/
echo "Syncing ISO image"
rsync -av $TEMPDIR/mnt/ $BUILD/ > /dev/null 2>&1
chmod -R u+w $BUILD/
umount /$TEMPDIR/mnt



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
cp /usr/lib/syslinux/isolinux.bin $BUILD
cp /usr/lib/syslinux/vesamenu.c32 $BUILD
cp /usr/lib/syslinux/menu.c32 $BUILD
cp /usr/lib/syslinux/hdt.c32 $BUILD
cp /usr/lib/syslinux/reboot.c32 $BUILD
#cp /usr/lib/syslinux/poweroff.c32 $BUILD

wget -cq http://pciids.sourceforge.net/v2.2/pci.ids -O $TEMPDIR/pci.ids
cp $TEMPDIR/pci.ids $BUILD/pci.ids

echo "download 64bit ${DIST} kernel and initrd..."
wget -cq http://archive.ubuntu.com/ubuntu/dists/${DIST}/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux -O $TEMPDIR/linux64
cp $TEMPDIR/linux64 $BUILD
wget -cq http://archive.ubuntu.com/ubuntu/dists/${DIST}/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz -O $TEMPDIR/initrd64.gz
cp $TEMPDIR/initrd64.gz $BUILD

echo "copying custom preseed"
cp -aR ../preseed/* $BUILD/preseed

#echo "copying profiles"
cp -aR ../profiles $BUILD/

#echo "copying dists"
#cp -r ../image/dists $BUILD/dists

#echo "copying pool"
#cp -r ../image/dists $BUILD/pool

# TODO: try graphical and text menus in future version
#ui menu.c32
#menu title Ubuntu NetInstall CD - Akilion


echo -e $SYSLINUX_HEADER $MENU_OPTION $SYSLINUX_FOOTER > $BUILD/syslinux.cfg
echo -e $ISOLINUX_HEADER $MENU_OPTION $ISOLINUX_FOOTER > $BUILD/isolinux/txt.cfg

echo "Creating iso image..."
mkisofs -q -V "Atlas_bootstrap" -o $TEMPDIR/Atlas_bootstrap.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -r -J $BUILD
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
	parted -s $DEV mkpart primary 1 4096
	parted -s $DEV set 1 boot on
	mkfs.vfat ${DEV}1
	echo "Copying files ..."
	mount ${DEV}1 $MNTTMP
        rsync -av $BUILD/ $MNTTMP> /dev/null 2>&1
	#cp -a $BUILD/* $MNTTMP
	#cp /tmp/iso/isolinux.cfg /tmp/iso/syslinux.cfg
        mv $BUILD/isolinux $BUILD/syslinux
	syslinux -i ${DEV}1
	umount ${DEV}1
	echo "USB Done!"
fi

echo "clean up..."
#rm -r $BUILD

