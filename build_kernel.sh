#!/bin/bash

set -x

. setup.sh

git clone --depth=1 -b rpi-5.19.y https://github.com/raspberrypi/linux.git

cd linux || exit

export PATH=$CROSSTOOL_DIR/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH

make ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu- bcm2711_defconfig

make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu-