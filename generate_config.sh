#!/bin/bash
set -e
#set -x
source ./global.sh
#main entry

export PLATFORM=$1
if [ 0 = $# ]; then
    usage
    exit
fi

# build_aarch64() {
# 	export ARCH=arm64
# 	toolchain_aarch64
# 	make mrproper
# 	make defconfig CROSS_COMPILE=$CROSS_COMPILE
# 	sed -i 's/^# CONFIG_KCOV is not set/CONFIG_KCOV=y/1' .config
# 	sed -i "/CONFIG_LKDTM/aCONFIG_KASAN=y" .config
# 	sed -i 's/^CONFIG_CMDLINE=\"\"/CONFIG_CMDLINE=\"console=ttyAMA0\"/1' .config
# 	sed -i "/CONFIG_LKDTM/aCONFIG_KCOV_INSTRUMENT_ALL=y" .config
# 	#make menuconfig
# 	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
# }

# build_arm() {
# 	export ARCH=arm
# 	toolchain_arm
# 	make mrproper
# 	#make defconfig CROSS_COMPILE=$CROSS_COMPILE
# 	cp ${CONFIGS}/arch/arm/configs/qemu_defconfig .config
# 	#sed -i "/CONFIG_KUNIT/aCONFIG_E1000=y" .config
# 	#sed -i "/CONFIG_KUNIT/aCONFIG_E1000E=y" .config
# 	#make menuconfig
# 	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
# }

# build_x86_64() {
# 	export ARCH=x86_64
# 	toolchain_x86_64
# 	make mrproper
# 	make x86_64_defconfig CROSS_COMPILE=$CROSS_COMPILE
# 	sed -i 's/^# CONFIG_KCOV is not set/CONFIG_KCOV=y/1' .config
# 	sed -i "/CONFIG_LKDTM/aCONFIG_KASAN=y" .config
# 	sed -i 's/^CONFIG_CMDLINE=\"\"/CONFIG_CMDLINE=\"console=ttyAMA0\"/1' .config
# 	sed -i "/CONFIG_LKDTM/aCONFIG_KCOV_INSTRUMENT_ALL=y" .config
# 	sed -i 's/^CONFIG_E1000=m/CONFIG_E1000=y/1' .config
# 	sed -i 's/^CONFIG_E1000E=m/CONFIG_E1000E=y/1' .config
# 	#make menuconfig
# 	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
# }


build_aarch64() {
	toolchain_aarch64
	make mrproper
	cp ${CONFIGS}/aarch64/qemu_defconfig .config
	cp ${CONFIGS}/aarch64/my.config .
	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
	merge_config
}

build_arm() {
	toolchain_arm
	make mrproper
	cp ${CONFIGS}/arm/qemu_defconfig .config
	cp ${CONFIGS}/arm/my.config .
	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
	merge_config
}

build_x86_64() {
	toolchain_x86_64
	make mrproper
	make mrproper
	cp ${CONFIGS}/arm/qemu_defconfig .config
	cp ${CONFIGS}/arm/my.config .
	make olddefconfig ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
	merge_config
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
