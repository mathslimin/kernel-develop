#!/bin/bash

arch=$1

ROOTDIR=`pwd`

if [ "${arch}" = "" ];then
	arch=arm64
fi

# generate rootfs.ext3
cd rootfs/${arch}
mkdir -p sdcard
sudo dd if=/dev/zero of=rootfs.ext3 bs=1M count=50
sudo mkfs.ext3 rootfs.ext3
sudo mount -t ext3 rootfs.ext3 sdcard -o loop
sudo cp _install/* sdcard/ -fra
sudo umount sdcard/
sudo chmod 666 rootfs.ext3

cd ${ROOTDIR}

if [ "${arch}" = "arm" ];then
	qemu-system-arm -M vexpress-a9 \
		-smp 4 \
		-m 1024m \
		-kernel linux-5-kernel/arch/arm/boot/zImage \
		-append "root=/dev/mmcblk0 rw console=ttyAMA0 loglevel=8" \
		-dtb linux-5-kernel/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
		-sd rootfs/${arch}/rootfs.ext3 \
		-nographic
else
	qemu-system-aarch64 -machine virt \
		-cpu cortex-a57 \
		-machine type=virt \
		-nographic -m 2048 \
		-smp 2 \
		-kernel linux-5-kernel/arch/arm64/boot/Image \
		-append "root=/dev/mmcblk0 rw console=ttyAMA0 loglevel=8  trace_event=sched:*,timer:*,irq:* trace_buf_size=40M" \
		-sd rootfs/${arch}/rootfs.ext3
fi
