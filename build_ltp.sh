#!/bin/bash

set -e
set -x
source ./global.sh

#TOP_DIR=`pwd`
#WORK_DIR=$TOP_DIR/build
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

arch=$1

if [ "${arch}" = "" ]; then
    arch=arm64
fi
mkdir -p ${WORK_DIR}
cd ltp
make clean
make distclean
make autotools
#./configure CC=arm-linux-gnueabi-gcc --build=i686-pc-linux-gnu --target=arm-linux --host=arm-linux  CFLAGS="-static" LDFLAGS="-static  -pthread"
if [ "${arch}" = "arm" ]; then
    echo "arm"
    export ARCH=arm
    export CC=arm-linux-gnueabi-gcc
    ./configure --prefix=${WORK_DIR}/ltp CC=arm-linux-gnueabi-gcc --host=arm-linux-gnueabi
    make
    make install
elif [ "${arch}" = "arm64" ]; then
    echo "arm64"
    export ARCH=arm64
	export CC=aarch64-linux-gnu-gcc
    ./configure --prefix=${WORK_DIR}/ltp CC=aarch64-linux-gnu-gcc --host=aarch64-linux-gnu
    make
    make install
else
    echo "x86_64"
    export ARCH=x86_64
	export CC=gcc
    ./configure --prefix=${WORK_DIR}/ltp CC=gcc --host=x86_64-linux-gnu
    make
    make install
fi

