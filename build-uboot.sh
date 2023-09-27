#!/bin/bash

set -x

# shellcheck source=setup.sh
. setup.sh

git clone git://git.denx.de/u-boot.git

cd "$UBOOT_DIR" || exit

git checkout v2023.07 -b v2023.07

export PATH=$CROSSTOOL_DIR/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH

export CROSS_COMPILE=aarch64-rpi4-linux-gnu-

make rpi_4_defconfig

make
