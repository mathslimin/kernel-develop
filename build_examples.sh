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
toolchain_${PLATFORM}
export CC=${GCC_PATH}
export CXX=${CXX_PATH}

build_aarch64() {
    toolchain_aarch64
    make CC=${GCC_PATH}
}

build_arm() {
    toolchain_arm
    make CC=${GCC_PATH}
}

build_x86_64() {
    toolchain_x86_64
    make CC=${GCC_PATH}
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
