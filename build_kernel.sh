#!/bin/bash
set -e
set -x
source ./global.sh

build_arm64() {
	echo "start to build ARM64 $1 kernel image!!"
	# export ARCH=arm64
	# export CROSS_COMPILE=aarch64-linux-gnu-
	toolchain_arm64
	make mrproper
	make defconfig
	make Image -j$(nproc)
}

build_arm() {
	echo "start to build ARM $1 kernel image!!"
	# export ARCH=arm
	# export CROSS_COMPILE=arm-none-linux-gnueabihf-
	toolchain_arm
	make mrproper
	make defconfig
	make bzImage -j$(nproc)
	make dtbs
}

build_x86_64() {
	echo "start to build x86_64 $1 kernel image!!"
	# export ARCH=x86_64
	# export CROSS_COMPILE=${GCC_X86_PATH}/bin/x86_64-unknown-linux-gnu-
	toolchain_x86_64
	make mrproper
	make x86_64_defconfig CROSS_COMPILE=$CROSS_COMPILE
	make bzImage CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)
}

#main entry

export arch=$1
cd src/linux-next
if [ -e arch/arm64/boot/Image -a "${arch}" != "arm64" ]; then
	echo "arch/arm64/boot/Image exist, make distclean"
	make clean
	make distclean
elif [ -e arch/arm/boot/zImage -a "${arch}" != "arm" ]; then
	echo "arch/arm/boot/zImage exist, make distclean"
	make clean
	make distclean
elif [ -e arch/x86/boot/zImage -a "${arch}" != "x86_64" ]; then
	echo "arch/x86/boot/zImage exist, make distclean"
	make clean
	make distclean
fi

case ${arch} in
	arm64)
		build_arm64
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
			build_arm64 ${target_config}
		else
			build_arm ${target_config}
		fi
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
		echo "   ./build.sh arm64     #build default  arm64 config"
		echo "   ./build.sh arm       #build default arm config"
		echo "   ./build.sh x86_64       #build default arm config"
		echo "   ./build.sh select    #select platform and config to build"
		;;
esac
