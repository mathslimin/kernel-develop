#!/bin/bash
set -e
function usage() {
    echo ""
    echo "usage:"
    echo "  ./build_xxx.sh arm helloworld"
    echo ""
    exit 1
}

if [ 0 = $# ] || [ 1 = $# ]; then
    usage
    exit
fi
export PLATFORM=$1
export MODULE_NAME=$2
source ./global.sh

rm -r -f 
build_aarch64() {
	toolchain_aarch64
	export CC=${GCC_PATH}
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE M=$SRC_DIR/modules/$MODULE_NAME modules
	make ARCH=$ARCH CROSS_COMPILE=${CROSS_COMPILE} M=$SRC_DIR/modules/$MODULE_NAME INSTALL_MOD_STRIP=1 modules_install LOCALVERSION= INSTALL_MOD_PATH=${INSTALL_DIR}/$PLATFORM
    echo "make modules $MODULE_NAME succeed..."
}

build_arm() {
	toolchain_arm
	export CC=${GCC_PATH}
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE M=$SRC_DIR/modules/$MODULE_NAME modules
	make ARCH=$ARCH CROSS_COMPILE=${CROSS_COMPILE} M=$SRC_DIR/modules/$MODULE_NAME INSTALL_MOD_STRIP=1 modules_install LOCALVERSION= INSTALL_MOD_PATH=${INSTALL_DIR}/$PLATFORM
    echo "make modules $MODULE_NAME succeed..."
}

build_x86_64() {
	toolchain_x86_64
	export CC=${GCC_PATH}
    make ARCH=$ARCH M=$SRC_DIR/modules/$MODULE_NAME modules
	make ARCH=$ARCH CC=${GCC_PATH} M=$SRC_DIR/modules/$MODULE_NAME INSTALL_MOD_STRIP=1 modules_install LOCALVERSION= INSTALL_MOD_PATH=${INSTALL_DIR}/$PLATFORM
    echo "make modules $MODULE_NAME succeed..."
}

rm -r -f $SRC_DIR/modules
cp -r $TOP_DIR/modules $SRC_DIR/
cd $KERNEL_DIR

build_${PLATFORM}

