#!/bin/bash
export TOP_DIR=$(pwd)
export WORK_DIR=/home/data/workdir
export SRC_DIR=${WORK_DIR}/src
export BUILD_DIR=${WORK_DIR}/build
export LOG_PATH=$BUILD_DIR/log
export INSTALL_DIR=${WORK_DIR}/output
export ROOTFS=$INSTALL_DIR/rootfs
export KERNEL_DIR=$SRC_DIR/$PLATFORM/linux
export IMAGE_DIR=/home/data/qemu
export CONFIGS=$TOP_DIR/configs/

# export GCC_AARCH64_PATH=/opt/buildtools/gcc-aarch64-linux-gnu

# export GCC_ARM_PATH=/opt/buildtools/gcc-arm-none-linux-gnueabihf 
# export GCC_X86_PATH=/opt/buildtools/x-tools/x86_64-unknown-linux-gnu

is_ok() {
    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi
    echo OK
}

toolchain_aarch64() {
    export ARCH=arm64
    export PATH=/opt/buildtools/gcc-aarch64/bin:$PATH
    export CROSS_COMPILE=aarch64-none-linux-gnu-
    export GCC_PATH=${CROSS_COMPILE}gcc
    export CXX_PATH=${CROSS_COMPILE}g++
    export TARGET_HOST=aarch64-none-linux-gnu
}


toolchain_arm() {
    export ARCH=arm
    export PATH=/opt/buildtools/gcc-arm/bin:$PATH
    export CROSS_COMPILE=arm-none-linux-gnueabihf-
    export GCC_PATH=${CROSS_COMPILE}gcc
    export CXX_PATH=${CROSS_COMPILE}g++
    export TARGET_HOST=arm-none-linux-gnueabihf
}

toolchain_x86_64_cross_compile() {
    export ARCH=x86_64
    export PATH=/opt/buildtools/gcc-x86_64/bin:$PATH
    export CROSS_COMPILE=x86_64-buildroot-linux-gnu-
    export GCC_PATH=${CROSS_COMPILE}gcc
    export CXX_PATH=${CROSS_COMPILE}g++
    export TARGET_HOST=x86_64-buildroot-linux-gnu
}

# toolchain_x86_64() {
#     export ARCH=x86_64
#     export TOOLCHAIN=x86_64-linux-gnu-
#     export GCC_PATH=${TOOLCHAIN}gcc
#     export CXX_PATH=${TOOLCHAIN}g++
#     export TARGET_HOST=x86_64-linux-gnu
# }

toolchain_x86_64() {
    export ARCH=x86_64
    export TOOLCHAIN=
    export GCC_PATH=${TOOLCHAIN}gcc
    export CXX_PATH=${TOOLCHAIN}g++
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

function merge_config() {
    sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|" .config
    if [ -f $KERNEL_DIR/my.config ]; then
        echo "merge config file"
        cat $KERNEL_DIR/my.config
        $KERNEL_DIR/scripts/kconfig/merge_config.sh -m -O $KERNEL_DIR $KERNEL_DIR/.config $KERNEL_DIR/my.config
    fi
}

