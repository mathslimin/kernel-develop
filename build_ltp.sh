#!/bin/bash

set -e
set -x
source ./global.sh
# default compile
#./configure CC=arm-linux-gnueabi-gcc --build=i686-pc-linux-gnu --target=arm-linux --host=arm-linux  CFLAGS="-static" LDFLAGS="-static  -pthread"

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

export PLATFORM=$1

if [ "${PLATFORM}" = "" ]; then
    usage
fi
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
    make install
elif [ "${PLATFORM}" = "aarch64" ]; then
    toolchain_aarch64
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET_HOST}
    make -j$(nproc)
    make install
else
    toolchain_x86_64
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH} --host=${TARGET_HOST}
    make -j$(nproc)
    make install
fi
