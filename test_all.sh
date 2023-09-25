#!/bin/bash

set -x

# shellcheck source=setup.sh
. setup.sh


bash build_crosstool.sh
cd "$MAINDIR" || exit
if [ -d "$CROSSTOOL_DIR/x-tools/aarch64-rpi4-linux-gnu/bin/" ]; then
    echo "Crosstool dir does exist."
else
    echo "Crosstool dir does NOT exist, exiting..."
    exit 1
fi

if [ -f "$ROOTFS_DIR/bin/busybox" ]; then
    echo "rootfs does exist."
else
    echo "rootfs does NOT exist. Build rootfs outside of container and re-run this script. Exiting..."
    exit 1
fi

bash build-uboot.sh
cd "$MAINDIR"  || exit
if [ -f "$UBOOT_DIR/u-boot.bin" ]; then
    echo "u-boot binary does exist."
else
    echo "u-boot binary does NOT exist, exiting..."
    exit 1
fi

bash build_kernel.sh
cd "$MAINDIR"  || exit
if [ -f "$KERNEL_DIR/vmlinux" ]; then
    echo "Kernel image does exist."
else
    echo "Kernel image does NOT exist, exiting..."
    exit 1
fi

exit 0

bash upload_to_sd.sh /dev/sdX 
ls -la /mnt/boot/Image
ls -la /mnt/root/bin/busybox 