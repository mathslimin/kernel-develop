#!/bin/bash
export TOP_DIR=$(pwd)
export SRC_DIR=$TOP_DIR/src
export BUILD_DIR=$TOP_DIR/build
export LOG_PATH=$BUILD_DIR/log
export INSTALL_DIR=$TOP_DIR/output
export ROOTFS=$INSTALL_DIR/rootfs
export IMAGE_DIR=$INSTALL_DIR/images
export SRC_LINUX=$SRC_DIR/linux-next
export CONFIGS=$TOP_DIR/configs/

#export GCC_AARCH64_PATH=/opt/buildtools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
export GCC_AARCH64_PATH=/opt/buildtools/gcc-aarch64-linux-gnu

#export GCC_ARM_PATH=/opt/buildtools/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf
export GCC_ARM_PATH=/opt/buildtools/gcc-arm-none-linux-gnueabihf 
export GCC_X86_PATH=/opt/buildtools/x-tools/x86_64-unknown-linux-gnu

is_ok() {
    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi
    echo OK
}

toolchain_aarch64_xxx() {
    export ARCH=arm64
    export TOOLCHAIN=$GCC_AARCH64_PATH/bin/aarch64-none-linux-gnu-
    export CROSS_COMPILE=$TOOLCHAIN
    export CROSS_COMPILE_PREFIX=aarch64-none-linux-gnu-
    export GCC_PATH=$GCC_AARCH64_PATH/bin/aarch64-none-linux-gnu-gcc
    export CXX_PATH=$GCC_AARCH64_PATH/bin/aarch64-none-linux-gnu-g++
    #export CC=${GCC_PATH}
    #export CXX=${CXX_PATH}
    export TARGET_HOST=aarch64-none-linux-gnu
}

toolchain_aarch64() {
    export ARCH=arm64
    export TOOLCHAIN=$GCC_AARCH64_PATH/bin/aarch64-linux-gnu-
    export CROSS_COMPILE=$TOOLCHAIN
    export CROSS_COMPILE_PREFIX=aarch64-linux-gnu-
    export GCC_PATH=$GCC_AARCH64_PATH/bin/aarch64-linux-gnu-gcc
    export CXX_PATH=$GCC_AARCH64_PATH/bin/aarch64-linux-gnu-g++
    #export CC=${GCC_PATH}
    #export CXX=${CXX_PATH}
    export TARGET_HOST=aarch64-linux-gnu
}


toolchain_arm() {
    export ARCH=arm
    export TOOLCHAIN=$GCC_ARM_PATH/bin/arm-none-linux-gnueabihf-
    export CROSS_COMPILE=$TOOLCHAIN
    export CROSS_COMPILE_PREFIX=arm-none-linux-gnueabihf-
    export GCC_PATH=$GCC_ARM_PATH/bin/arm-none-linux-gnueabihf-gcc
    export CXX_PATH=$GCC_ARM_PATH/bin/arm-none-linux-gnueabihf-g++
    #export CC=${GCC_PATH}
    #export CXX=${CXX_PATH}
    export TARGET_HOST=arm-none-linux-gnueabihf
}

toolchain_x86_64() {
    export ARCH=x86_64
    export TOOLCHAIN=$GCC_X86_PATH/bin/x86_64-unknown-linux-gnu-
    export CROSS_COMPILE=$TOOLCHAIN
    export CROSS_COMPILE_PREFIX=x86_64-unknown-linux-gnu-
    export GCC_PATH=$GCC_X86_PATH/bin/x86_64-unknown-linux-gnu-gcc
    export CXX_PATH=$GCC_X86_PATH/bin/x86_64-unknown-linux-gnu-g++
    #export CC=${GCC_PATH}
    #export CXX=${CXX_PATH}
    export TARGET_HOST=x86_64-unknown-linux-gnu
}

log() {
    log_type=$1
    log_info=$2
    level=$3
    for i in $(seq 2 $level); do
        log_type="|----"$log_type
    done
    echo $log_type: $log_info
    if [ "$log_type" = "FATAL" ]; then
        exit 1
    fi
}

_exe() {
    [ $1 == on ] && {
        set -x
        return
    } 2>/dev/null
    [ $1 == off ] && {
        set +x
        return
    } 2>/dev/null
    echo + "$@"
    "$@"
}

exe() {
    { _exe "$@"; } 2>/dev/null
}

turnError() {
    [ $1 == on ] && {
        set -e
        return
    } 2>/dev/null
    [ $1 == off ] && {
        set +e
        return
    } 2>/dev/null
    echo + "$@"
}

function usage() {
    echo ""
    echo "usage:"
    echo "  ./build_xxx.sh arm"
    echo ""
    exit 1
}
