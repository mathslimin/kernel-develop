#!/bin/bash
set -e
set -x
source ./global.sh
arch=$1

ROOTDIR=`pwd`

if [ "${arch}" = "" ];then
	arch=arm64
fi

cd linux-5-kernel

if [ "${arch}" = "arm" ];then
	qemu-system-arm -M vexpress-a9 \
		-smp 4 \
		-m 1024m \
		-kernel arch/arm/boot/zImage \
		-append "root=/dev/mmcblk0 rw console=ttyAMA0 loglevel=8" \
		-dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
		-sd $WORK_DIR/images/${arch}/rootfs.ext3 \
		-nographic
elif [ "${arch}" = "arm64" ];then
	qemu-system-aarch64 -machine virt \
		-cpu cortex-a57 \
		-machine type=virt \
		-m 2048 \
		-smp 2 \
		-kernel arch/arm64/boot/Image \
		-append "root=/dev/mmcblk0 rw console=ttyAMA0 loglevel=8  trace_event=sched:*,timer:*,irq:* trace_buf_size=40M" \
		-sd $WORK_DIR/images/${arch}/rootfs.ext3 \
		-nographic
else
	qemu-system-x86_64 \
		-m 2G \
		-smp 2 \
		-kernel arch/x86/boot/bzImage \
		-append "console=ttyS0 root=/dev/sda rw earlyprintk=serial net.ifnames=0" \ #必须root用/dev/sda否则会报错，rw表示可以读写
		-drive file=$WORK_DIR/images/${arch}/rootfs.ext3,format=raw \
		-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
		-net nic,model=e1000 \
		-nographic
fi
