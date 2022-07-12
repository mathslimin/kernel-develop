#!/bin/bash
set -e

function usage() {
    echo ""
    echo "usage:"
    echo "  ./menuconfig.sh arm"
    echo ""
    exit 1
}

if [ 0 = $# ]; then
    usage
    exit
fi
export PLATFORM=$1
source ./global.sh

toolchain_$PLATFORM
cd $KERNEL_DIR
make menuconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
