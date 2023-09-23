#!/bin/bash

set -x

# shellcheck source=setup.sh
. setup.sh

DEVICE=$1
BOOT_MOUNT=$2
ROOT_MOUNT=$3


##### Przygotowanie karty SD ######

sudo umount $DEVICE?*

(
echo p # print information
echo d # delete first partition
echo   # accept default
echo d # delete second partition
echo   # accept default
echo p # print information
echo w # write
) | sudo fdisk $DEVICE

(
echo n # new partition
echo p # primary partition
echo 1 # choose first partition
echo   # accept default start sector
echo +100M # define size (end sector)
echo p # print info
echo t # change type of partition
echo b # choose DOS partition
echo p # print info
echo n # new partition
echo p # primary partition
echo 2 # second partition
echo   # accept default start sector
echo   # define size (end sector, all available memory)
echo p # print info
echo w # write
) | sudo fdisk $DEVICE

# Formatujemy partycje
mkfs.vfat -F 32 -n boot $DEVICE"1"
mkfs.ext4 -L root       $DEVICE"2"

# Montujemy partycje 
sudo mount $DEVICE"1" /mnt/boot
sudo mount $DEVICE"2" /mnt/root

##### Setup u-boota #####
cp $UBOOT_DIR/u-boot.bin $BOOT_MOUNT

#Ściągamy firmware dla Raspberry Pi 4
svn checkout https://github.com/raspberrypi/firmware/trunk/boot

#Kopiujemy bootloader vendora na kartę SD
cp boot/{bootcode.bin,start4.elf} $BOOT_MOUNT


#Hakujemy tak żeby włączył się u-boot
cat << EOF > config.txt
enable_uart=1
arm_64bit=1
kernel=u-boot.bin
EOF
cp config.txt $BOOT_MOUNT

# Piszemy bootscript dla u-boota (co ma zrobić po wstaniu)
cat << EOF > boot_cmd.txt
fatload mmc 0:1 \${kernel_addr_r} Image
setenv bootargs "console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rw rootwait init=/bin/sh"
booti \${kernel_addr_r} - \${fdt_addr}
EOF

# Tworzymy z pliku txt plik który może przeczytać uboot
$UBOOT_DIR/tools/mkimage -A arm64 -O linux -T script -C none -d boot_cmd.txt boot.scr

# Kopiujemy na partycję 
cp boot.scr $BOOT_MOUNT

### Dodajemy devicetree ###
cp $KERNEL_DIR/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb $BOOT_MOUNT

sync
