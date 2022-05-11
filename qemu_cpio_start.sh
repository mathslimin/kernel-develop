#!/bin/bash
source ./global.sh
set -e
set -x

PLATFORM=$1

ROOTDIR=`pwd`

if [ "${PLATFORM}" = "" ];then
	PLATFORM=arm64
fi

# generate cpio initramfs
#cd rootfs/${arch}/_install
cd $BUILD_DIR/rootfs/${PLATFORM}

find . | cpio -H newc -ov --owner root:root > $IMAGE_DIR/${PLATFORM}/initramfs.cpio

#cd ../
cd $IMAGE_DIR/${PLATFORM}
rm -f initramfs.cpio.gz
gzip -qq initramfs.cpio

cd ${ROOTDIR}/linux-next

if [ "${PLATFORM}" = "arm" ];then
	qemu-system-arm -M vexpress-a9 \
		-smp 2 \
		-m 1024M \
		-kernel arch/arm/boot/zImage \
		-append "rdinit=/linuxrc console=ttyAMA0 loglevel=8" \
		-dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
		-initrd $IMAGE_DIR/${PLATFORM}/initramfs.cpio.gz \
		-nographic
elif [ "${PLATFORM}" = "arm64" ];then
	qemu-system-aarch64 -machine virt \
		-cpu cortex-a57 \
		-machine type=virt \
		-m 1024m \
		-smp 2 \
		-kernel arch/arm64/boot/Image \
		-append "rdinit=/linuxrc console=ttyAMA0 loglevel=8  trace_event=sched:*,timer:*,irq:* trace_buf_size=40M" \
		-initrd $IMAGE_DIR/${PLATFORM}/initramfs.cpio.gz \
		-nographic
else
	# 必须root用/dev/sda否则会报错，rw表示可以读写
	qemu-system-x86_64 \
		-smp 2 \
		-m 1024m \
		-kernel arch/x86/boot/bzImage \
		-append "console=ttyS0 root=/dev/sda rw earlyprintk=serial net.ifnames=0" \
		-drive file=$IMAGE_DIR/${PLATFORM}/initramfs.cpio.gz,format=raw \
		-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
		-net nic,model=e1000 \
		-nographic
fi

