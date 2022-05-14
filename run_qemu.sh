#!/bin/bash
set -e
#set -x
#linux源码路径
LINUX_SRC_PATH=/home/develop/linux
#放置本run_qemu.sh脚本的目录
RUN_QEMU_TOOLS_PATH=/home/develop/hulk-tools
#linaro aarch64交叉编译工具链的路径
LINARO_AARCH64_GNU_PATH=/opt/buildtools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu

BUSYBOX_NAME=busybox-1.35.0

if [ "$1" = "-h" ]; then
	echo "compile_kernel aarch64|x86_64"
	echo "download_image busybox|ubuntu"
	echo "build_rootfs busybox|ubuntu aarch64|x86_64"
	echo "run_qemu busybox|ubuntu aarch64|x86_64"
fi

#https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/ 获取最新的linaro工具链gcc-linaro-xxx-x86_64_aarch64-linux-gnu.tar.xz
#解压之后将/path/gcc-linaro-xxx-x86_64_aarch64-linux-gnu/bin放到PATH环境变量
function compile_kernel_aarch64() {
	make mrproper
	make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 defconfig
	make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 Image -j8
	if [ $? -ne 0 ]; then
		echo "kernel build failed!!!!!!!!!!!!!!!!"
		exit 1
	fi
}

function compile_kernel_x86_64() {
	make mrproper
	make ARCH=x86_64 defconfig
	make ARCH=x86_64 -j8
	if [ $? -ne 0 ]; then
		echo "kernel build failed!!!!!!!!!!!!!!!!"
		exit 1
	fi
}

function download_image_busybox() {
	rm -rf $BUSYBOX_NAME.tar.bz2
	wget https://busybox.net/downloads/$BUSYBOX_NAME.tar.bz2 --no-check-certificate
	if [ $? -ne 0 ]; then
		echo "download image failed!!!!!!!!!!!!!!!!"
		exit 1
	fi
	rm -rf $BUSYBOX_NAME
	tar -jxf $BUSYBOX_NAME.tar.bz2
	if [ $? -ne 0 ]; then
		echo "build rootfs failed!!!!!!!!!!!!!!!!"
		exit 1
	fi
}

function build_rootfs_busybox() {
	pushd $BUSYBOX_NAME
	make defconfig
	sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/1' .config
	if [ "$1" = "aarch64" ]; then
		sed -i 's/^CONFIG_CROSS_COMPILER_PREFIX=""/CONFIG_CROSS_COMPILER_PREFIX="aarch64-linux-gnu-"/1' .config
	fi
	sleep 1
	make && make install
	if [ $? -ne 0 ]; then
		echo "build rootfs failed!!!!!!!!!!!!!!!!"
		exit 1
	fi
	popd

	rm -rf rootfs/
	dd if=/dev/zero of=rootfs_busybox_$1.img bs=1M count=1000
	mkfs.ext4 rootfs_busybox_$1.img
	mkdir rootfs/
	sudo mount -t ext4 -o loop rootfs_busybox_$1.img rootfs
	sudo cp $BUSYBOX_NAME/_install/* rootfs/ -raf
	sudo mkdir -p rootfs/dev/
	sudo mkdir -p rootfs/etc/
	sudo mkdir -p rootfs/etc/init.d/
	sudo mkdir -p rootfs/proc/
	sudo mkdir -p rootfs/sys/
	sudo mkdir -p rootfs/tmp/
	sudo mkdir -p rootfs/lib
	if [ "$1" = "aarch64" ]; then
		sudo cp -arf $LINARO_AARCH64_GNU_PATH/aarch64-linux-gnu/libc/lib/* rootfs/lib/
	fi
	sudo bash -c "cat>rootfs/etc/fstab<<EOF
proc            /proc              proc    defaults    0   0
tmpfs           /tmp               tmpfs   defaults    0   0
sysfs           /sys               sysfs   defaults    0   0
debugfs         /sys/kernel/debug  debugfs defaults    0   0 
EOF"
	sudo bash -c "cat>rootfs/etc/inittab<<EOF
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
tty2::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF"
	sudo bash -c "cat>rootfs/etc/profile<<EOF
# /etc/profile: system-wide .profile file for the Bourne shells

echo
# no-op
echo
EOF"
	sudo bash -c "cat>rootfs/etc/init.d/rcS<<EOF
#! /bin/sh

/bin/mount -a

mount -t tmpfs cgroup_root /sys/fs/cgroup
mkdir /sys/fs/cgroup/cpuset
mount -t cgroup -o cpuset cgroup /sys/fs/cgroup/cpuset
mkdir /sys/fs/cgroup/cpu,cpuacct
mount -t cgroup -o cpu,cpuacct cgroup /sys/fs/cgroup/cpu,cpuacct
EOF"
	sudo chmod 777 rootfs/etc/init.d/rcS
	sudo umount rootfs
}

function run_qemu_busybox_aarch64() {
	qemu-system-aarch64 \
		-M virt \
		-cpu cortex-a57 \
		-smp 8 \
		-m 4096M \
		-kernel $LINUX_SRC_PATH/arch/arm64/boot/Image \
		-hda $RUN_QEMU_TOOLS_PATH/rootfs_busybox_aarch64.img \
		-append "root=/dev/vda rw printk.time=y" \
		-nographic
	if [ $? -ne 0 ]; then
		echo "run qemu failed!!!!!!!!!!!!!!!!"
		exit 1
	fi
}

function run_qemu_busybox_x86_64() {
	qemu-system-x86_64 \
		-smp 8 \
		-m 4096M \
		-kernel $LINUX_SRC_PATH/arch/x86/boot/bzImage \
		-hda $RUN_QEMU_TOOLS_PATH/rootfs_busybox_x86_64.img \
		-append "console=ttyS0 printk.time=y root=/dev/sda rw" \
		-nographic
	if [ $? -ne 0 ]; then
		echo "run qemu failed!!!!!!!!!!!!!!!!"
		exit 1
	fi
}

if [ "$1" = "compile_kernel" ]; then
	pushd $LINUX_SRC_PATH
	compile_kernel_$2
	popd
elif [ "$1" = "download_image" ]; then
	pushd $RUN_QEMU_TOOLS_PATH
	download_image_$2
	popd
elif [ "$1" = "build_rootfs" ]; then
	pushd $RUN_QEMU_TOOLS_PATH
	build_rootfs_$2 $3
	popd
elif [ "$1" = "run_qemu" ]; then
	run_qemu_$2_$3
fi

exit 0
