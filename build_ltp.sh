#!/bin/bash

set -e
set -x
source ./global.sh

function usage() {
    echo ""
    echo "usage:"
    echo "  ./build_ltp.sh arm"
    echo ""
    exit 1
}
if [ 0 = $# ]; then
    usage
    exit
fi

export arch=$1

if [ "${arch}" = "" ]; then
    arch=arm64
fi
mkdir -p ${BUILD_DIR}
rm -r -f ${BUILD_DIR}/ltp
cd src/ltp
make clean
make distclean
make autotools
#./configure CC=arm-linux-gnueabi-gcc --build=i686-pc-linux-gnu --target=arm-linux --host=arm-linux  CFLAGS="-static" LDFLAGS="-static  -pthread"
if [ "${arch}" = "arm" ]; then
    toolchain_arm
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET}
    make -j$(nproc)
    make install
elif [ "${arch}" = "arm64" ]; then
    toolchain_arm64
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET}
    make -j$(nproc)
    make install
else
    toolchain_x86_64
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET}
    make -j$(nproc)
    make install
fi
