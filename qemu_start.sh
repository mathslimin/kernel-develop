#!/bin/bash
source ./global.sh
set -e
set -x

arch=$1

ROOTDIR=`pwd`

if [ "${arch}" = "" ];then
	arch=arm64
fi

# generate cpio initramfs
#cd rootfs/${arch}/_install
cd $WORK_DIR/rootfs/${arch}

find . | cpio -H newc -ov --owner root:root > $IMAGE_DIR/${arch}/initramfs.cpio

#cd ../
cd $IMAGE_DIR/${arch}
rm -f initramfs.cpio.gz
gzip -qq initramfs.cpio

cd ${ROOTDIR}/linux-5-kernel

if [ "${arch}" = "arm" ];then
	qemu-system-arm -M vexpress-a9 \
		-smp 4 \
		-m 1024M \
		-kernel arch/arm/boot/zImage \
		-append "rdinit=/linuxrc console=ttyAMA0 loglevel=8" \
		-dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
		-initrd $IMAGE_DIR/${arch}/initramfs.cpio.gz \
		-nographic
elif [ "${arch}" = "arm64" ];then
	qemu-system-aarch64 -machine virt \
		-cpu cortex-a57 \
		-machine type=virt \
		-nographic -m 2048 \
		-smp 2 \
		-kernel arch/arm64/boot/Image \
		-append "rdinit=/linuxrc console=ttyAMA0 loglevel=8  trace_event=sched:*,timer:*,irq:* trace_buf_size=40M" \
		-initrd $IMAGE_DIR/${arch}/initramfs.cpio.gz \
		-nographic
else
	# qemu-system-x86_64 \
	# 	-m 2048 \
	# 	-smp 2 \
	# 	-kernel arch/x86/boot/bzImage \
	# 	-append "rdinit=/linuxrc console=ttyAMA0 loglevel=8  trace_event=sched:*,timer:*,irq:* trace_buf_size=40M" \
	# 	-initrd $IMAGE_DIR/${arch}/initramfs.cpio.gz \
	# 	-nographic
	qemu-system-x86_64 \
		-m 2G \
		-smp 2 \
		-kernel arch/x86/boot/bzImage \
		#必须root用/dev/sda否则会报错，rw表示可以读写
		-append "console=ttyS0 root=/dev/sda rw earlyprintk=serial net.ifnames=0" \
		-drive file=$IMAGE_DIR/${arch}/initramfs.cpio.gz,format=raw \
		-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
		-net nic,model=e1000 \
		-nographic
fi

