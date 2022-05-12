#!/bin/bash

set -e
set -x
source ./global.sh
# default compile
#./configure CC=arm-linux-gnueabi-gcc --build=i686-pc-linux-gnu --target=arm-linux --host=arm-linux  CFLAGS="-static" LDFLAGS="-static  -pthread"

if [ 0 = $# ]; then
    usage
    exit
fi

export PLATFORM=$1
mkdir -p ${BUILD_DIR}
rm -r -f ${BUILD_DIR}/ltp
cd src/ltp
make clean
make distclean
make autotools
if [ "${PLATFORM}" = "arm" ]; then
    toolchain_arm
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET_HOST}
    make -j$(nproc)
    make install -j$(nproc)
elif [ "${PLATFORM}" = "aarch64" ]; then
    toolchain_aarch64
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET_HOST}
    make -j$(nproc)
    make install -j$(nproc)
else
    toolchain_x86_64
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET_HOST}
    make -j$(nproc)
    make install -j$(nproc)
fi
