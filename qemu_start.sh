#!/bin/bash
set -e
set -x
source ./global.sh
function usage() {
    echo ""
    echo "usage:"
    echo "  ./build_ltp.sh arm"
    echo ""
    exit 1
}
if [ 0 = $# ]; then
    usage
    exit
fi

export PLATFORM=$1

if [ "${PLATFORM}" = "" ]; then
    usage
fi

cd $SRC_DIR/linux-next

if [ "${PLATFORM}" = "arm" ]; then
        qemu-system-arm -M vexpress-a9 \
                -smp 2 \
                -m 1024m \
                -kernel arch/arm/boot/zImage \
                -append "root=/dev/mmcblk0 rw console=ttyAMA0 loglevel=8" \
                -dtb ${SRC_LINUX}/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
                -sd $IMAGE_DIR/rootfs_busybox_${PLATFORM}.img \
                -nographic
elif [ "${PLATFORM}" = "aarch64" ]; then
        qemu-system-aarch64 \
                -M virt \
                -cpu cortex-a57 \
                -smp 8 \
                -m 4096M \
                -kernel ${SRC_LINUX}/arch/arm64/boot/Image \
                -hda $IMAGE_DIR/rootfs_busybox_${PLATFORM}.img \
                -append "root=/dev/vda rw printk.time=y" \
                -net nic \
                -net user,hostfwd=tcp::2222-:22 \
                -nographic
elif [ "${PLATFORM}" = "x86_64" ]; then
        # 必须root用/dev/sda否则会报错，rw表示可以读写
        qemu-system-x86_64 \
                -smp 8 \
                -m 4096M \
                -kernel ${SRC_LINUX}/arch/x86/boot/bzImage \
                -drive file=$IMAGE_DIR/rootfs_busybox_${PLATFORM}.img,format=raw \
                -append "console=ttyS0 printk.time=y root=/dev/sda rw" \
                -net nic -net user,hostfwd=tcp::10021-:22 \
                -nographic

        # qemu-system-x86_64 \
        #         -smp 8 \
        #         -m 4096M \
        #         -kernel arch/x86/boot/bzImage \
        #         -drive file=$BUILD_DIR/rootfs_busybox_${arch}.img,format=raw \
        #         -append "console=ttyS0 printk.time=y root=/dev/sda rw" \
        #         -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:2022 \
        #         -net nic,model=e1000 \
        #         -nographic
        # qemu-system-x86_64 \
        #         -smp 2 \
        #         -m 1024m \
        #         -kernel arch/x86/boot/bzImage \
        #         -append "console=ttyS0 root=/dev/sda rw earlyprintk=serial net.ifnames=0" \
        #         -drive file=$BUILD_DIR/images/${arch}/rootfs.ext3,format=raw \
        #         -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
        #         -net nic,model=e1000 \
        #         -nographic
else
        echo "no platform"
        exit 1
fi
