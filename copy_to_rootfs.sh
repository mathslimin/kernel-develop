#!/usr/bin/env bash
set -e
function help() {
    echo "usage: ./copy_to_rootfs.h ARCH machineName"
    echo "example: ./copy_to_rootfs.h x86_64 linux-x86_64"
}
if [ 0 = $# ] || [ 1 = $# ]; then
    help
    exit
fi
export PLATFORM=$1
export MACHINE_NAME=$2
source ./global.sh
which guestmount || {
    echo "guestmount is not exist, sudo apt install libguestfs-tools"
    sudo apt-get install -y libguestfs-tools
}

export IMAGE_DIR=${QEMU_HOME_DIR}/images/${MACHINE_NAME}
cd $IMAGE_DIR

sudo rm -r -f rootfs
ROOTFS=${IMAGE_DIR}/rootfs
mkdir -p rootfs
sleep 3
if [ -f ${IMAGE_DIR}/rootfs.ext4 ]; then
    if [ ! -f ${IMAGE_DIR}/backup_rootfs.ext4 ]; then
        cp ${IMAGE_DIR}/rootfs.ext4 ${IMAGE_DIR}/backup_rootfs.ext4
    fi
    sudo mount -o loop ${IMAGE_DIR}/rootfs.ext4 rootfs
elif [ -f ${IMAGE_DIR}/rootfs.qcow2 ]; then
    if [ ! -f ${IMAGE_DIR}/backup_rootfs.qcow2 ]; then
        cp ${IMAGE_DIR}/rootfs.qcow2 ${IMAGE_DIR}/backup_rootfs.qcow2
    fi
    sudo guestmount -a ${IMAGE_DIR}/rootfs.qcow2 -m /dev/sda2 rootfs
else
    echo "Error: rootfs not exists"
    exit 1
fi
if [ -d "${INSTALL_DIR}/ltp" ]; then
    sudo cp -r ${INSTALL_DIR}/ltp rootfs/opt/
fi
if [ -f "${TOP_DIR}/examples/helloworld" ]; then
    sudo mkdir -p rootfs/opt/bin
    sudo cp -r ${TOP_DIR}/examples/helloworld rootfs/opt/bin/
fi
if [ -d "${INSTALL_DIR}/lib" ]; then
    sudo rm -f ${INSTALL_DIR}/lib/module/build
    sudo rm -f ${INSTALL_DIR}/lib/module/source
    sudo rm -r -f rootfs/lib/modules
    sudo cp -r ${INSTALL_DIR}/lib/modules rootfs/lib/
fi
TS=$(date '+%Y%m%d%H%M%S' | sed 's/-//g')
echo $TS >rootfs/root/deploy.info
if [ -f ${IMAGE_DIR}/rootfs.ext4 ]; then
    sudo umount rootfs
elif [ -f ${IMAGE_DIR}/rootfs.qcow2 ]; then
    sudo guestunmount rootfs
else
    echo "Error: rootfs not exists"
    exit 1
fi
echo "success replace rootfs"
ls -lh ${IMAGE_DIR}
