#!/bin/bash
set -e
set -x
source ./global.sh
alias cp='cp -i'

if [ 0 = $# ]; then
    usage
    exit
fi

export PLATFORM=$1
if [ -d $IMAGE_DIR ]; then
    sudo rm -rfv $IMAGE_DIR
fi
toolchain_${PLATFORM}
mkdir -p $IMAGE_DIR
cd $IMAGE_DIR
if [ -d rootfs ]; then
    sudo umount rootfs >/dev/null 2>&1 &
    sleep 10
    sudo rm -r -f rootfs
fi
sudo rm -f $IMAGE_DIR/rootfs_busybox_$PLATFORM.img
echo current dir:$(pwd)

dd if=/dev/zero of=rootfs_busybox_$PLATFORM.img bs=1M count=2048
mkfs.ext4 rootfs_busybox_$PLATFORM.img
mkdir rootfs/
sudo mount -t ext4 -o loop rootfs_busybox_$PLATFORM.img rootfs
sudo cp $ROOTFS/* rootfs/ -raf
sudo mkdir -p rootfs/dev/
sudo mkdir -p rootfs/etc/
sudo mkdir -p rootfs/etc/init.d/
sudo mkdir -p rootfs/proc/
sudo mkdir -p rootfs/sys/
sudo mkdir -p rootfs/tmp/
sudo mkdir -p rootfs/lib
sudo mkdir -p rootfs/usr/lib
sudo mkdir -p rootfs/lib64
sudo mkdir -p rootfs/home/workspace
sudo mkdir -p rootfs/opt/bin
sudo mkdir -p rootfs/opt/conf
if [ -d "${BUILD_DIR}/ltp" ]; then
    sudo cp -r ${BUILD_DIR}/ltp rootfs/opt/
fi

if [ -f "${TOP_DIR}/examples/helloworld" ]; then
    sudo cp -r ${TOP_DIR}/examples/helloworld rootfs/opt/bin/
fi

#添加交叉编译环境
if [ "$PLATFORM" = "aarch64" ]; then
    #sudo cp -arf $GCC_AARCH64_PATH/aarch64-linux-gnu/libc/lib/* rootfs/lib/
    pushd ${TOP_DIR}/go
    #bash init.sh
    bash ./build.sh arm64
    sudo cp bin/* ${IMAGE_DIR}/rootfs/opt/bin/
    sudo cp host_key* ${IMAGE_DIR}/rootfs/opt/conf/
    popd
elif [ "$PLATFORM" = "arm" ]; then
    #sudo cp -arf $GCC_ARM_PATH/arm-none-linux-gnueabihf/libc/lib/* rootfs/lib/
    # sudo cp -prv $($GCC_PATH -print-sysroot)/usr/lib/*so* rootfs/usr/lib/
    pushd ${TOP_DIR}/go
    #bash init.sh
    bash ./build.sh arm
    sudo cp bin/* ${IMAGE_DIR}/rootfs/opt/bin/
    sudo cp host_key* ${IMAGE_DIR}/rootfs/opt/conf/
    popd
elif [ "$PLATFORM" = "x86_64" ]; then
    #sudo cp $GCC_X86_PATH/x86_64-unknown-linux-gnu/sysroot/lib/*so* rootfs/lib/
    #sudo cp $GCC_X86_PATH/x86_64-unknown-linux-gnu/sysroot/lib64/*so* rootfs/lib64/
    #sudo cp -arf $GCC_X86_PATH/lib64/* rootfs/lib64/
    pushd ${TOP_DIR}/go
    #bash init.sh
    bash ./build.sh amd64
    sudo cp bin/* ${IMAGE_DIR}/rootfs/opt/bin/
    #x86 openssh 编译会报错，用go版本的sshd
    #sudo cp bin/sshd_server ${IMAGE_DIR}/rootfs/usr/sbin/sshd
    sudo cp host_key* ${IMAGE_DIR}/rootfs/opt/conf/
    popd
fi
# sudo mkdir -p rootfs/etc/rc.d
# sudo touch rootfs/etc/rc.d/rc.local
# #sudo sed -i '$a/opt/bin/sshd_server &>/dev/null &' rootfs/etc/rc.d/rc.local
# sudo bash -c "cat>rootfs/etc/rc.d/rc.local<<EOF
# # start scripts
# /opt/bin/sshd_server &>/tmp/sshd_server.log &
# EOF"

# sudo bash -c "cat>rootfs/etc/fstab<<EOF
# proc            /proc              proc    defaults    0   0
# tmpfs           /tmp               tmpfs   defaults    0   0
# sysfs           /sys               sysfs   defaults    0   0
# debugfs         /sys/kernel/debug  debugfs defaults    0   0
# EOF"
# sudo bash -c "cat>rootfs/etc/inittab<<EOF
# ::sysinit:/etc/init.d/rcS
# ::respawn:-/bin/sh
# tty2::askfirst:-/bin/sh
# ::ctrlaltdel:/bin/umount -a -r
# EOF"
# sudo bash -c "cat>rootfs/etc/profile<<EOF
# # /etc/profile: system-wide .profile file for the Bourne shells

# echo
# # no-op
# echo
# EOF"
# sudo bash -c "cat>rootfs/etc/init.d/rcS<<EOF
# #! /bin/sh

# /bin/mount -a

# mount -t tmpfs cgroup_root /sys/fs/cgroup
# mkdir /sys/fs/cgroup/cpuset
# mount -t cgroup -o cpuset cgroup /sys/fs/cgroup/cpuset
# mkdir /sys/fs/cgroup/cpu,cpuacct
# mount -t cgroup -o cpu,cpuacct cgroup /sys/fs/cgroup/cpu,cpuacct
# touch /tmp/hello.txt
# chmod a+x /etc/rc.d/rc.local
# /etc/rc.d/rc.local
# EOF"
# sudo chmod 777 rootfs/etc/init.d/rcS
echo "Prepare Rootfs"
sudo cp -rvf $TOP_DIR/configs/rootfs.template/* rootfs/
sudo chmod a+x rootfs/etc/rc.d/*
sudo cp -r rootfs img_rootfs
sudo umount rootfs
echo "Build rootfs success!!"
