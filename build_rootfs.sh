#!/bin/bash
set -e
set -x
source ./global.sh

arch=$1
sudo rm -r -f $WORK_DIR/rootfs
mkdir -p $WORK_DIR/rootfs

echo current dir:`pwd`
cp -r ${WORK_DIR}/busybox/$arch/_install $WORK_DIR/rootfs/$arch

cd $WORK_DIR/rootfs/$arch
mkdir etc
mkdir dev
mkdir mnt
mkdir -p etc/init.d/
mkdir -p home/workspace
if [ -d "${WORK_DIR}/ltp" ]; then
    has_test=true
    sudo cp -r ${WORK_DIR}/ltp home/workspace/
fi
# create rcS for target board
cat > etc/init.d/rcS << EOF
mkdir -p /proc
mkdir -p /tmp
mkdir -p /sys
mkdir -p /mnt
/bin/mount -a
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
EOF

chmod +x ./etc/init.d/rcS

# create fstab for target board
cat > etc/fstab << EOF
proc /proc proc defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
sysfs /sys sysfs defaults 0 0
tmpfs /dev tmpfs defaults 0 0
debugfs /sys/kernel/debug debugfs defaults 0 0
EOF

# create inittab for target board
cat > etc/inittab << EOF
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF

# create dev node

cd dev
sudo mknod console c 5 1
sudo mknod null c 1 3


# generate rootfs.ext3
#cd rootfs/${arch}
sudo rm -r -f  $WORK_DIR/images
mkdir -p $WORK_DIR/images/${arch}
cd $WORK_DIR/images/${arch}
mkdir -p sdcard
if [ -d "${WORK_DIR}/ltp" ]; then
	sudo dd if=/dev/zero of=rootfs.ext3 bs=1M count=2048
else
	sudo dd if=/dev/zero of=rootfs.ext3 bs=1M count=50
fi
sudo mkfs.ext3 rootfs.ext3
sudo mount -t ext3 rootfs.ext3 sdcard -o loop
sudo cp -fra $WORK_DIR/rootfs/${arch}/* sdcard/ 
sudo umount sdcard/
sudo chmod 666 rootfs.ext3

echo "Build rootfs success!!"
