#!/bin/bash
set -x
export GCC_ARM_PATH=/opt/buildtools/gcc-linaro-arm-linux-gnueabihf
#export GCC_ARM_PATH=/home/paas/software/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf
#export GCC_ARM_PATH=/home/paas/software/gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf
export GCC_PATH=$GCC_ARM_PATH/bin/arm-linux-gnueabihf-gcc
#sudo umount rootfs
sudo rm -r -f rootfs
ROOTFS=./rootfs
rm rootfs.ext2
cp backup_rootfs.ext2 rootfs.ext2
mkdir -p rootfs
sleep 1
sudo mount -o loop rootfs.ext2 rootfs
#sudo cp -r /home/paas/workspace/shell/hulk_test/qemu/output/ltp/ $ROOTFS/opt/
sudo cp -r ./ltp/ $ROOTFS/opt/
sudo cp /home/paas/workspace/shell/hulk_test/qemu/examples/helloworld $ROOTFS/opt/
sudo mkdir -p $ROOTFS/usr/local/libc/usr/lib
sudo mkdir -p $ROOTFS/usr/local/libc/lib
#sudo mkdir -p $ROOTFS/usr/lib
#sudo mkdir -p $ROOTFS/lib

#sudo cp -prv $($GCC_PATH -print-sysroot)/lib/*so* $ROOTFS/usr/local/libc/lib/
#sudo cp -prv $($GCC_PATH -print-sysroot)/usr/lib/*so* $ROOTFS/usr/local/libc/usr/lib
#sudo cp -prv $($GCC_PATH -print-sysroot)/lib/*so* $ROOTFS/lib/
#sudo cp -prv $($GCC_PATH -print-sysroot)/usr/lib/*so* $ROOTFS/usr/lib/

#echo 'export LD_LIBRARY_PATH=/usr/local/libc/lib:/usr/local/libc/usr/lib:$LD_LIBRARY_PATH' | sudo tee --append $ROOTFS/etc/profile
sudo umount rootfs
