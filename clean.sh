#!/bin/bash

set -x

# shellcheck source=setup.sh
. setup.sh


rm -rf "$UBOOT_DIR" "$ROOTFS_DIR" "$KERNEL_DIR" "$CROSSTOOL_DIR" boot/