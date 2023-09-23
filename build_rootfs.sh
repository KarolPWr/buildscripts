#!/bin/bash

set -x

. setup.sh

mkdir "$ROOTFS_DIR"
cd "$ROOTFS_DIR" || exit
mkdir {bin,dev,etc,home,lib64,proc,sbin,sys,tmp,usr,var}
mkdir usr/{bin,lib,sbin}
mkdir var/log

ln -s lib64 lib

sudo chown -R root:root *

wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tar -xf busybox-1.36.1.tar.bz2 
rm busybox-1.36.1.tar.bz2 
cd busybox-1.36.1/ || exit

export PATH=$CROSSTOOL_DIR/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
export CROSS_COMPILE=aarch64-rpi4-linux-gnu-
make CROSS_COMPILE="$CROSS_COMPILE" defconfig

sed -i "s%^CONFIG_PREFIX=.*$%CONFIG_PREFIX=\"$ROOTFS_DIR\"%" .config   # sus, uwaga


CROSS_COMPILE="$BIN_DIR"/aarch64-rpi4-linux-gnu-

make CROSS_COMPILE="$CROSS_COMPILE" install
cd ..
readelf -a bin/busybox | grep -E "(program interpreter)|(Shared library)"
export SYSROOT=$(aarch64-rpi4-linux-gnu-gcc -print-sysroot)
sudo cp -L ${SYSROOT}/lib64/{ld-linux-aarch64.so.1,libm.so.6,libresolv.so.2,libc.so.6} lib64/
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1