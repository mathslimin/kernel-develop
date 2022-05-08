#!/bin/bash
set -e
set -x
source ./global.sh

build_arm64() {
	echo "start to build ARM64 $1 kernel image!!"
	export ARCH=arm64
	export CROSS_COMPILE=aarch64-linux-gnu-
	cp ../configs/busybox/configs/qemu_arm64_defconfig configs/
	make qemu_arm64_defconfig
	make install
}

build_arm() {
	echo "start to build ARM $1 kernel image!!"
	export ARCH=arm
	export CROSS_COMPILE=arm-linux-gnueabi-
	cp ../configs/busybox/configs/qemu_arm_defconfig configs/
	make qemu_arm_defconfig
	make install
}


build_x86_64() {
	echo "start to build x86_64 $1 kernel image!!"
	export ARCH=x86_64
	export CC=gcc
	cp ../configs/busybox/configs/qemu_x86_64_defconfig configs/
	make ARCH=$ARCH CC=$CC qemu_x86_64_defconfig
	#make ARCH=$ARCH CC=$CC defconfig
	#make ARCH=$ARCH CC=$CC menuconfig # Select "Build static binary"
	make install
}


#main entry

arch=$1
cd busybox-1.35.0

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
	clean)
		echo "start to clean!!"
		make mrproper 
		;;
	*)
		echo "usage:"
		echo "./build.sh [platform]"
		echo " "
		echo "eg:"
		echo "   ./build.sh arm64     #build default  arm64 config"
		echo "   ./build.sh arm       #build default arm config"
		echo "   ./build.sh x86_64       #build default x86_64 config"
		exit 1
		;;
esac


