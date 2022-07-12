#!/bin/bash
set -e
function usage() {
    echo ""
    echo "usage:"
    echo "  ./qemu_start.sh arm"
    echo ""
    exit 1
}

if [ 0 = $# ]; then
        usage
        exit
fi

export PLATFORM=$1
source ./global.sh
cd $SKERNEL_DIR

if [ "${PLATFORM}" = "arm" ]; then
        qemu-system-arm -M vexpress-a9 \
                -smp 2 \
                -m 1024m \
                -kernel arch/arm/boot/zImage \
                -append "root=/dev/mmcblk0 rw console=ttyAMA0 loglevel=8" \
                -dtb ${KERNEL_DIR}/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
                -sd $IMAGE_DIR/buildroot-arm/images/rootfs.ext4 \
                -net nic \
                -net user,host=10.0.2.10,hostfwd=tcp::10022-:22 \
                -nographic
elif [ "${PLATFORM}" = "aarch64" ]; then
        qemu-system-aarch64 \
                -machine virt \
                -cpu cortex-a57 \
                -smp 8 \
                -m 2048M \
                -kernel ${KERNEL_DIR}/arch/arm64/boot/Image \
                -hda $IMAGE_DIR/buildroot-aarch64/images/rootfs.ext4 \
                -append "console=ttyAMA0 root=/dev/vda rw printk.time=y oops=panic panic_on_warn=1 panic=-1 ftrace_dump_on_oops=orig_cpu debug earlyprintk=serial slub_debug=UZ" \
                -net nic,model=e1000 \
                -net user,host=10.0.2.10,hostfwd=tcp::10022-:22 \
                -nographic
elif [ "${PLATFORM}" = "x86_64" ]; then
        qemu-system-x86_64 \
                -smp 8 \
                -m 2048M \
                -kernel ${KERNEL_DIR}/arch/x86/boot/bzImage \
                -drive file=$IMAGE_DIR/buildroot-x86_64/images/rootfs.ext4,format=raw \
                -append "console=ttyS0 printk.time=y root=/dev/sda rw" \
                -net nic,model=e1000e \
                -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10022-:22 \
                -nographic
        # qemu-system-x86_64 -smp 2 -m 1024M \
        # -display none -nographic \
        # -kernel /home/paas/workspace/buildroot/buildroot-x86_64/images/bzImage \
        # -boot c \
        # -hda $IMAGE_DIR/buildroot-x86_64/images/rootfs.ext4 \
        # -device e1000,netdev=net0 \
        # -netdev user,id=net0,host=10.0.2.1,hostfwd=tcp::10022-:22 \
        # -append "console=ttyS0 root=/dev/sda rw"
else
        echo "no platform"
        exit 1
fi
