#!/bin/bash
set -e
set -x
source ./global.sh
build_arm64() {
	echo "start to build ARM64 $1 modules"
	export ARCH=arm64
	export CROSS_COMPILE=aarch64-linux-gnu-
    make M=$SRC_DIR/modules/$1 modules SUBDIRS=$SRC_DIR/modules/$2
    echo "make modules $2 succeed..."
}

build_arm() {
	echo "start to build ARM $1 kernel image!!"
	export ARCH=arm
	export CROSS_COMPILE=arm-linux-gnueabi-
    make M=$SRC_DIR/modules/$1 modules SUBDIRS=$SRC_DIR/modules/$2
    echo "make modules $2 succeed..."
}

build_x86_64() {
	echo "start to build x86_64 $1 kernel image!!"
	export ARCH=x86_64
	export CC=gcc
    make M=$SRC_DIR/modules/$1 modules SUBDIRS=$SRC_DIR/modules/$2
    echo "make modules $2 succeed..."
}

arch=$1
cd $SRC_DIR/linux-kernel
case ${arch} in
	arm64)
		build_arm64 $2
		;;
	arm)
		build_arm $2
		;;
	x86_64)
		build_x86_64 $2
		;;
	clean)
		echo "start to clean!!"
        cd $SRC_DIR/modules/$2
        make clean 
        echo "make clean $2 succeed..."
		;;
	*)
		echo "usage:"
		echo "./build_modules.sh [platform] module_name"
		echo " "
		echo "eg:"
		echo "   ./build_modules.sh arm64 helloworld"
		;;
esac


