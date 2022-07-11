#!/bin/bash
set -e
set -x
source ./global.sh
#main entry

export PLATFORM=$1
if [ 0 = $# ]; then
    usage
    exit
fi


build_aarch64() {
	export ARCH=arm64
	toolchain_aarch64
    merge_config
    make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
    make Image -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=$CROSS_COMPILE LOCALVERSION=
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules LOCALVERSION= -j$(nproc)
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_STRIP=1 modules_install LOCALVERSION= INSTALL_MOD_PATH=${INSTALL_DIR}/aarch64 -j$(nproc)
}

build_arm() {
	export ARCH=arm
	toolchain_arm
    merge_config
    make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
    make zImage -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=$CROSS_COMPILE LOCALVERSION=
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules LOCALVERSION= -j$(nproc)
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_STRIP=1 modules_install LOCALVERSION= INSTALL_MOD_PATH=${INSTALL_DIR}/arm -j$(nproc)
    make dtbs CROSS_COMPILE=$CROSS_COMPILE LOCALVERSION=
}

build_x86_64() {
	export ARCH=x86_64
	toolchain_x86_64
	merge_config
    make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
    make bzImage -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=$CROSS_COMPILE LOCALVERSION=
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules LOCALVERSION= -j$(nproc)
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_STRIP=1 modules_install LOCALVERSION= INSTALL_MOD_PATH=${INSTALL_DIR}/x86_64 -j$(nproc)
}

cd $SRC_DIR/linux-next
if [ -e arch/arm64/boot/Image -a "${PLATFORM}" != "aarch64" ]; then
	echo "arch/arm64/boot/Image exist, make distclean"
	make clean
	make distclean
elif [ -e arch/arm/boot/zImage -a "${PLATFORM}" != "arm" ]; then
	echo "arch/arm/boot/zImage exist, make distclean"
	make clean
	make distclean
elif [ -e arch/x86/boot/zImage -a "${PLATFORM}" != "x86_64" ]; then
	echo "arch/x86/boot/zImage exist, make distclean"
	make clean
	make distclean
fi

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
		rm arch/arm64/boot/Image -f
		rm arch/arm/boot/zImage -f
		make clean
		make distclean
		;;
	*)
		echo "usage:"
		echo "./build.sh [platform]"
		echo " "
		echo "eg:"
		echo "   ./build.sh aarch64     #build default  aarch64 config"
		echo "   ./build.sh arm       #build default arm config"
		echo "   ./build.sh x86_64       #build default arm config"
		echo "   ./build.sh select    #select platform and config to build"
		;;
esac
