#!/bin/bash
set -e
#set -x
source ./global.sh

build_arm64() {
	toolchain_arm64
	make
}

build_arm() {
	toolchain_arm
	make
}

build_x86_64() {
	toolchain_x86_64
	make
}

#main entry
export arch=$1
cd examples
pwd
make clean
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
		make clean
		;;
	*)
		echo "usage:"
		echo "./build_examples.sh [platform]"
		;;
esac
