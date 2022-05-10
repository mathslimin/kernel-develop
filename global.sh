#!/bin/bash
export TOP_DIR=$(pwd)
export SRC_DIR=$TOP_DIR/src
export BUILD_DIR=$TOP_DIR/build
export LOG_PATH=$BUILD_DIR/log
export INSTALL_DIR=$TOP_DIR/install
export ROOTFS=$INSTALL_DIR/rootfs
export IMAGE_DIR=$INSTALL_DIR/images
export SRC_LINUX=$SRC_DIR/linux-next
export SRC_BASH=$SRC_DIR/bash-5.1.16
#export SRC_BASH=$SRC_DIR/bash-4.3.30
export SRC_ZLIB=$SRC_DIR/zlib-1.2.12
export SRC_BUSYBOX=${SRC_DIR}/busybox-1.35.0
export SRC_OPENSSH=${SRC_DIR}/openssh-9.0p1


export GCC_AARCH64_PATH=/opt/buildtools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
export GCC_ARM_PATH=/opt/buildtools/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf
export GCC_X86_PATH=/opt/buildtools/x-tools/x86_64-unknown-linux-gnu

is_ok ()
{
   if [ $? -ne 0 ]; then
       echo Failed
       exit 1
   fi
   echo OK
}

toolchain_arm64() {
	export ARCH=arm64
	export CROSS_COMPILE=$GCC_AARCH64_PATH/bin/aarch64-linux-gnu-
    export GCC_PATH=$GCC_AARCH64_PATH/bin/aarch64-linux-gnu-gcc
    export CC=${GCC_PATH}
    export TARGET=aarch64-linux-gnu
}

toolchain_arm() {
	export ARCH=arm
	export CROSS_COMPILE=$GCC_ARM_PATH/bin/arm-none-linux-gnueabihf-
    export GCC_PATH=$GCC_ARM_PATH/bin/arm-none-linux-gnueabihf-gcc
    export CC=${GCC_PATH}
    export TARGET=arm-none-linux-gnueabihf
}

toolchain_x86_64() {
	export ARCH=x86_64
	export CROSS_COMPILE=${GCC_X86_PATH}/bin/x86_64-unknown-linux-gnu-
    export GCC_PATH=${GCC_X86_PATH}/bin/x86_64-unknown-linux-gnu-gcc
    export CC=${GCC_PATH}
    export TARGET=x86_64-unknown-linux-gnu
}
