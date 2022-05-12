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
	make mrproper
	make defconfig CROSS_COMPILE=$CROSS_COMPILE
	sed -i 's/^# CONFIG_KCOV is not set/CONFIG_KCOV=y/1' .config
	sed -i "/CONFIG_LKDTM/aCONFIG_KASAN=y" .config
	sed -i 's/^CONFIG_CMDLINE=\"\"/CONFIG_CMDLINE=\"console=ttyAMA0\"/1' .config
	sed -i "/CONFIG_LKDTM/aCONFIG_KCOV_INSTRUMENT_ALL=y" .config
	make menuconfig
}

build_arm() {
	export ARCH=arm
	toolchain_arm
	make mrproper
	make defconfig CROSS_COMPILE=$CROSS_COMPILE
	make menuconfig
}

build_x86_64() {
	export ARCH=x86_64
	toolchain_x86_64
	make mrproper
	make x86_64_defconfig CROSS_COMPILE=$CROSS_COMPILE
	sed -i 's/^# CONFIG_KCOV is not set/CONFIG_KCOV=y/1' .config
	sed -i "/CONFIG_LKDTM/aCONFIG_KASAN=y" .config
	sed -i 's/^CONFIG_CMDLINE=\"\"/CONFIG_CMDLINE=\"console=ttyAMA0\"/1' .config
	sed -i "/CONFIG_LKDTM/aCONFIG_KCOV_INSTRUMENT_ALL=y" .config
	sed -i 's/^CONFIG_E1000=m/CONFIG_E1000=y/1' .config
	sed -i 's/^CONFIG_E1000E=m/CONFIG_E1000E=y/1' .config
	make menuconfig
}

cd $SRC_DIR/linux-next
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
	select)
		echo "start to select config to build kernel image!!"
		i=0
		arch=($(ls arch/))
		for file in ${arch[@]}; do
			echo ${i}:${file##*/}
			((i++))
		done
		echo please input your choice:
		read index
		target_arch=${arch[${index}]##*/}

		i=0
		configs=($(ls arch/${target_arch}/configs/*))
		for file in ${configs[@]}; do
			echo ${i}:${file##*/}
			((i++))
		done

		echo please input your choice:
		read index
		target_config=${configs[${index}]##*/}
		echo target is: ${target_arch} ${target_config}

		if [ ${target_arch} = "arm64" ]; then
			build_aarch64 ${target_config}
		else
			build_arm ${target_config}
		fi
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
