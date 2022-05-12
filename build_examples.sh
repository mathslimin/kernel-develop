#!/bin/bash
set -e
#set -x
source ./global.sh
if [ 0 = $# ]; then
    usage
    exit
fi

export PLATFORM=$1
toolchain_${PLATFORM}
export CC=${GCC_PATH}
export CXX=${CXX_PATH}

build_aarch64() {
    toolchain_aarch64
    make
}

build_arm() {
    toolchain_arm
    make
}

build_x86_64() {
    toolchain_x86_64
    make
}

#main entry
cd examples
pwd
make clean
case ${PLATFORM} in
    aarch64)
        build_aarch64
        ;;
    arm)
        build_arm
        ;;
    x86_64)
        build_x86_64
        ;;
    clean)
        echo "start to clean!!"
        make clean
        ;;
    *)
        echo "usage:"
        echo "./build_examples.sh [platform]"
        ;;
esac
