#!/bin/bash

set -x

mkdir crosstool-ng

git clone https://github.com/crosstool-ng/crosstool-ng

cd crosstool-ng/ || exit

#git checkout crosstool-ng-1.25.0 -b 1.25.0

# change output dir
# CT_PREFIX_DIR="${CT_PREFIX:-${HOME}/x-tools}/${CT_HOST:+HOST-${CT_HOST}/}${CT_TARGET}"
# to
# CT_PREFIX_DIR="${CT_PREFIX:-${PWD}/x-tools}/${CT_HOST:+HOST-${CT_HOST}/}${CT_TARGET}"


./bootstrap

./configure --prefix=${PWD}


make

make install

export PATH="${PWD}/bin:${PATH}"

ct-ng show-aarch64-rpi4-linux-gnu

ct-ng aarch64-rpi4-linux-gnu

sed -i '/^CT_PREFIX_DIR=/s/.*/CT_PREFIX_DIR="${CT_PREFIX:-${PWD}\/x-tools}\/${CT_HOST:+HOST-${CT_HOST}\/}${CT_TARGET}"/' .config

ct-ng build

#cd .build/tarballs/
#wget https://zlib.net/fossils/zlib-1.2.12.tar.gz
#cd ../..
#ct-ng build



