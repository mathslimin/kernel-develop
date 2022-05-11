#!/bin/bash
set -e
set -x
source ./global.sh
build_aarch64() {
	toolchain_aarch64
	export CC=${GCC_PATH}
    make M=$SRC_DIR/modules/$1 modules SUBDIRS=$SRC_DIR/modules/$2
    echo "make modules $2 succeed..."
}

build_arm() {
	toolchain_arm
	export CC=${GCC_PATH}
    make M=$SRC_DIR/modules/$1 modules SUBDIRS=$SRC_DIR/modules/$2
    echo "make modules $2 succeed..."
}

build_x86_64() {
	toolchain_x86_64
	export CC=${GCC_PATH}
    make M=$SRC_DIR/modules/$1 modules SUBDIRS=$SRC_DIR/modules/$2
    echo "make modules $2 succeed..."
}

export PLATFORM=$1
cd $SRC_DIR/linux-next
case ${PLATFORM} in
	aarch64)
		build_aarch64 $2
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
		echo "   ./build_modules.sh aarch64 helloworld"
		;;
esac


