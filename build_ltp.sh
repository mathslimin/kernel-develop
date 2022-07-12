#!/bin/bash

set -e
function usage() {
    echo ""
    echo "usage:"
    echo "  ./build_xxx.sh arm"
    echo ""
    exit 1
}

if [ 0 = $# ]; then
    usage
    exit
fi

export PLATFORM=$1
source ./global.sh
mkdir -p ${BUILD_DIR}
rm -r -f ${BUILD_DIR}/ltp
cd ${SRC_DIR}/ltp
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
    ./configure --prefix=${BUILD_DIR}/ltp CC=${GCC_PATH}
    make -j$(nproc)
    make install -j$(nproc)
fi
