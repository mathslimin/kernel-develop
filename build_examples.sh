#!/bin/bash
set -e
set -x
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
    make ${PLATFORM}
}

build_arm() {
    toolchain_arm
    make ${PLATFORM}
}

build_x86_64() {
    toolchain_x86_64
    make ${PLATFORM}
}

#main entry
cd examples
pwd
make clean
echo $CC
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
