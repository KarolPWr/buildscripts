#!/bin/bash

set -x

# shellcheck source=setup.sh
. setup.sh

DEVICE=$1


##### Przygotowanie karty SD ######

sudo umount $DEVICE?*

sudo sfdisk "$DEVICE" < sdb.sfdisk

# Formatujemy partycje
mkfs.vfat -F 32 -n boot $DEVICE"1"
mkfs.ext4 -L root       $DEVICE"2"

# Montujemy partycje 
sudo mount $DEVICE"1" /mnt/boot
sudo mount $DEVICE"2" /mnt/root

##### Setup u-boota #####
cp $UBOOT_DIR/u-boot.bin /mnt/boot

#Ściągamy firmware dla Raspberry Pi 4
svn checkout https://github.com/raspberrypi/firmware/trunk/boot

# mayne this would be better? 
#git clone https://github.com/raspberrypi/firmware/tree/stable/boot 

#Kopiujemy bootloader vendora na kartę SD
cp boot/{bootcode.bin,start4.elf} /mnt/boot


#Hakujemy tak żeby włączył się u-boot
cat << EOF > config.txt
enable_uart=1
arm_64bit=1
kernel=u-boot.bin
EOF
cp config.txt /mnt/boot

# Piszemy bootscript dla u-boota (co ma zrobić po wstaniu)
cat << EOF > boot_cmd.txt
fatload mmc 0:1 \${kernel_addr_r} Image
setenv bootargs "console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rw rootwait init=/bin/sh"
booti \${kernel_addr_r} - \${fdt_addr}
EOF

# Tworzymy z pliku txt plik który może przeczytać uboot
$UBOOT_DIR/tools/mkimage -A arm64 -O linux -T script -C none -d boot_cmd.txt boot.scr

# Kopiujemy na partycję 
cp boot.scr /mnt/boot

### Dodajemy devicetree ###
cp $KERNEL_DIR/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /mnt/boot
cp $KERNEL_DIR/arch/arm64/boot/Image /mnt/boot

### Wgrywanie rootfs ###
sudo cp -r $ROOTFS_DIR/* /mnt/root


sync
