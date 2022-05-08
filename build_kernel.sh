#!/bin/bash
set -e
set -x
source ./global.sh

build_arm64() {
	echo "start to build ARM64 $1 kernel image!!"
	export ARCH=arm64
	export CROSS_COMPILE=aarch64-linux-gnu-
	cp ../configs/arch/arm64/configs/qemu_defconfig arch/arm64/configs/
	make $1 
	#make -j$(nproc)
	make bzImage -j$(nproc)
}

build_arm() {
	echo "start to build ARM $1 kernel image!!"
	export ARCH=arm
	export CROSS_COMPILE=arm-linux-gnueabi-
	cp ../configs/arch/arm/configs/qemu_defconfig arch/arm/configs/
	make $1 
	make bzImage -j$(nproc)
	make dtbs
}

build_x86_64() {
	echo "start to build x86_64 $1 kernel image!!"
	export ARCH=x86_64
	#export CROSS_COMPILE=arm-linux-gnueabi-
	export CC=gcc
	cp ../configs/arch/x86/configs/qemu_defconfig arch/x86/configs/
	#make ARCH=x86_64 x86_64_defconfig #使用默认config
	#make ARCH=x86_64 menuconfig
	#please change .config CONFIG_RETPOLINE=n
	make ARCH=x86_64 CC=gcc qemu_defconfig
	make ARCH=x86_64 CC=gcc bzImage -j$(nproc)
}

#main entry

arch=$1
cd linux-5-kernel
if [ -e arch/arm64/boot/Image -a "${arch}" != "arm64" ]; then
	echo "arch/arm64/boot/Image exist, make distclean"
	rm arch/arm64/boot/Image -f
	make distclean
elif [ -e arch/arm/boot/zImage -a "${arch}" != "arm" ]; then
	echo "arch/arm/boot/zImage exist, make distclean"
	rm arch/arm/boot/zImage -f
	make distclean
elif [ -e arch/x86/boot/zImage -a "${arch}" != "x86_64" ]; then
	echo "arch/x86/boot/zImage exist, make distclean"
	rm arch/x86/boot/zImage -f
	make distclean
fi


case ${arch} in
	arm64)
		build_arm64 qemu_defconfig
		;;
	arm)
		build_arm qemu_defconfig
		;;
	x86_64)
		build_x86_64
		;;
	select)
		echo "start to select config to build kernel image!!"
		i=0
		arch=($(ls arch/))
		for file in ${arch[@]}
		do
			echo ${i}:${file##*/};
			((i++));
		done
		echo please input your choice:
		read index
		target_arch=${arch[${index}]##*/}

		i=0
		configs=($(ls arch/${target_arch}/configs/*))
		for file in ${configs[@]}
		do
			echo ${i}:${file##*/};
			((i++));
		done

		echo please input your choice:
		read index
		target_config=${configs[${index}]##*/}
		echo target is: ${target_arch} ${target_config}

		if [ ${target_arch} = "arm64" ];then
			build_arm64 ${target_config}
		else
			build_arm ${target_config}
		fi	
		;;
	clean)
		echo "start to clean!!"
		rm arch/arm64/boot/Image -f
		rm arch/arm/boot/zImage -f
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


