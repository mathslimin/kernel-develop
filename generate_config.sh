#!/bin/bash
set -e

function usage() {
    echo ""
    echo "usage:"
    echo "  ./generate_config.sh arm"
    echo ""
    exit 1
}

if [ 0 = $# ]; then
    usage
    exit
fi
export PLATFORM=$1
source ./global.sh

build_aarch64() {
	toolchain_aarch64
	make mrproper
	cp ${CONFIGS}/aarch64/linux.config .config
	cp ${CONFIGS}/aarch64/my.config .
	merge_config
	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
}

build_arm() {
	toolchain_arm
	make mrproper
	cp ${CONFIGS}/arm/qemu_defconfig .config
	cp ${CONFIGS}/arm/my.config .
	merge_config
	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
}

build_x86_64() {
	toolchain_x86_64
	make mrproper
	cp ${CONFIGS}/x86_64/linux.config .config
	cp ${CONFIGS}/x86_64/my.config .
	merge_config
	make olddefconfig ARCH=$ARCH CC=${GCC_PATH}
	#make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
}
cd $KERNEL_DIR
if [ -e arch/arm64/boot/Image -a "${PLATFORM}" != "aarch64" ]; then
	echo "arch/arm64/boot/Image exist, make distclean"
	rm -f arch/arm64/boot/Image
	make clean
	make distclean
elif [ -e arch/arm/boot/zImage -a "${PLATFORM}" != "arm" ]; then
	echo "arch/arm/boot/zImage exist, make distclean"
	rm -f arch/arm/boot/zImage
	make clean
	make distclean
elif [ -e arch/x86/boot/zImage -a "${PLATFORM}" != "x86_64" ]; then
	echo "arch/x86/boot/zImage exist, make distclean"
	rm -f arch/x86/boot/zImage
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
	*)
		echo "usage:"
		echo "./build.sh [platform]"
		echo " "
		echo "eg:"
		echo "   ./build.sh aarch64     #build default  aarch64 config"
		echo "   ./build.sh arm       #build default arm config"
		echo "   ./build.sh x86_64       #build default arm config"
		;;
esac
