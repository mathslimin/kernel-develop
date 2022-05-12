#!/bin/bash
set -e
set -x
source ./global.sh

export SRC_BASH=$SRC_DIR/bash-5.1.16
export SRC_OPENSSL=$SRC_DIR/openssl-3.0.3
export SRC_ZLIB=$SRC_DIR/zlib-1.2.12
export SRC_BUSYBOX=${SRC_DIR}/busybox-1.35.0
export SRC_OPENSSH=${SRC_DIR}/openssh-9.0p1

#main entry
export PLATFORM=$1
if [ 0 = $# ]; then
    usage
    exit
fi

toolchain_${PLATFORM}

TOOLCHAIN=${CROSS_COMPILE}
CROSS_CC=${TOOLCHAIN}gcc
CROSS_CXX=${TOOLCHAIN}g++
CROSS_NM=${TOOLCHAIN}nm
CROSS_AR=${TOOLCHAIN}ar
CROSS_RANLIB=${TOOLCHAIN}ranlib
CROSS_LD=${TOOLCHAIN}ld
CROSS_STRIP=${TOOLCHAIN}strip

# export CC=${TOOLCHAIN}gcc
# export CXX=${TOOLCHAIN}g++
# export NM=${TOOLCHAIN}nm
# export AR=${TOOLCHAIN}ar
# export ANLIB=${TOOLCHAIN}ranlib
# export LD=${TOOLCHAIN}ld
# export STRIP=${TOOLCHAIN}strip

#set cflags位置无关fPIC
export CFLAGS='-O -fPIC'

clean_output() {
    if [ -d $BUILD_DIR ]; then
        sudo rm -rfv $BUILD_DIR
    fi
    if [ -d $INSTALL_DIR/rootfs ]; then
        sudo rm -rvf $INSTALL_DIR/rootfs
    fi
    if [ -d $LOG_PATH ]; then
        sudo rm -rvf $LOG_PATH
    fi
}

initialize() {
    mkdir -pv $BUILD_DIR
    mkdir -pv $LOG_PATH
    mkdir -pv $INSTALL_DIR
}

build_busybox() {
    echo "start to build busybox"
    LOG_BUSYBOX=$LOG_PATH/$(basename $SRC_BUSYBOX)
    BUILD_BUSYBOX=$BUILD_DIR/$(basename $SRC_BUSYBOX)
    if [ -d $BUILD_BUSYBOX ]; then
        rm -rfv $BUILD_BUSYBOX >$LOG_BUSYBOX 2>&1
    fi
    cp -pr $SRC_BUSYBOX $BUILD_DIR >>$LOG_BUSYBOX 2>&1
    cd $BUILD_BUSYBOX
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig >>$LOG_BUSYBOX 2>&1
    sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/1' .config >>$LOG_BUSYBOX 2>&1
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc) >>$LOG_BUSYBOX 2>&1
    make install -j$(nproc) >>$LOG_BUSYBOX 2>&1
    cp -prv _install/* $ROOTFS/ >>$LOG_BUSYBOX 2>&1
}

prepare_rootfs() {
    LOG_ROOTFS=$LOG_PATH/rootfs
    if [ -d $ROOTFS ]; then
        rm -rfv $ROOTFS
    fi
    #echo "Prepare Rootfs"
    #cp -pr $TOP_DIR/configs/rootfs.template $ROOTFS >$LOG_ROOTFS 2>&1

    echo "Create directories"
    mkdir -pv $ROOTFS/{proc,srv,sys,dev,var,root} >>$LOG_ROOTFS 2>&1
    echo "Install directories"
    install -dv -m 1777 $ROOTFS/tmp $ROOTFS/var/tmp >>$LOG_ROOTFS 2>&1
    echo "Copy system libs"
    if [ -d $($GCC_PATH -print-sysroot)/lib ]; then
        cp -prv $($GCC_PATH -print-sysroot)/lib $ROOTFS/ >>$LOG_ROOTFS 2>&1
    fi
    if [ -d $($GCC_PATH -print-sysroot)/lib64 ]; then
        cp -prv $($GCC_PATH -print-sysroot)/lib64 $ROOTFS/ >>$LOG_ROOTFS 2>&1
    fi
}

build_bash() {
    BUILD_BASH=$BUILD_DIR/$(basename $SRC_BASH)
    LOG_BASH=$LOG_PATH/$(basename $SRC_BASH)
    if [ -d $BUILD_BASH ]; then
        rm -rfv $BUILD_BASH >$LOG_BASH 2>&1
    fi

    #mkdir -pv $BUILD_BASH >$LOG_BASH 2>&1
    cp -pr $SRC_BASH $BUILD_DIR >>$LOG_BASH 2>&1

    cd $BUILD_BASH
    echo "Configure $(basename $SRC_BASH)"
    CC=$CROSS_CC \
        ./configure --prefix=$ROOTFS --host=$TARGET_HOST >>$LOG_BASH 2>&1
    echo "Build $(basename $SRC_BASH)"
    make -j$(nproc) >>$LOG_BASH 2>&1
    echo "Install $(basename $SRC_BASH)"
    make install -j$(nproc) >>$LOG_BASH 2>&1
}

build_openssl() {
    BUILD_OPENSSL=$BUILD_DIR/$(basename $SRC_OPENSSL)
    LOG_OPENSSL=$LOG_PATH/$(basename $SRC_OPENSSL)
    if [ -d $BUILD_OPENSSL ]; then
        rm -rfv $BUILD_OPENSSL >$LOG_OPENSSL 2>&1
    fi

    cp -prv $SRC_OPENSSL $BUILD_DIR/ >$LOG_OPENSSL 2>&1

    cd $BUILD_OPENSSL
    echo "Configure $(basename $SRC_OPENSSL)"
    # CC=$CROSS_CC \
    #   RANLIB=$CROSS_RANLIB \
    #   AR=$CROSS_AR \
    #   $SRC_OPENSSL/Configure linux-armv4 shared --prefix=$ROOTFS/usr >> $LOG_OPENSSL 2>&1
    if [ "${PLATFORM}" = "arm" ]; then
        #PLATFORM=linux-arm
        CONFIG_PLATFORM=linux-armv4
    elif [ "${PLATFORM}" = "aarch64" ]; then
        CONFIG_PLATFORM=linux-aarch64
    elif [ "${PLATFORM}" = "x86_64" ]; then
        CONFIG_PLATFORM=linux-x86_64
    else
        echo "platform is null"
        exit 1
    fi
    # CC=$CROSS_CC \
    #     RANLIB=$CROSS_RANLIB \
    #     AR=$CROSS_AR \
    #     $SRC_OPENSSL/Configure $PLATFORM shared --prefix=$ROOTFS/usr >>$LOG_OPENSSL 2>&1
    echo "CC:$CC"
    CC=gcc \
        RANLIB=ranlib \
        AR=ar \
        ./Configure $CONFIG_PLATFORM shared --prefix=$ROOTFS/usr -fPIC >>$LOG_OPENSSL 2>&1
    #./config no-asm shared --prefix=$ROOTFS/usr >>$LOG_OPENSSL 2>&1

    # if [ "${PLATFORM}" = "x86_64" ]; then
    #     echo "CC:$CC"
    #     ./config no-asm shared --prefix=$ROOTFS/usr >>$LOG_OPENSSL 2>&1
    # else
    #     $BUILD_OPENSSL/Configure $CONFIG_PLATFORM --cross-compile-prefix= shared --prefix=$ROOTFS/usr >>$LOG_OPENSSL 2>&1
    #
    #   CC=$CROSS_CC \
    #   RANLIB=$CROSS_RANLIB \
    #   AR=$CROSS_AR \
    #   $SRC_OPENSSL/Configure $CONFIG_PLATFORM shared --prefix=$ROOTFS/usr >> $LOG_OPENSSL 2>&1
    # fi
    echo "Build $(basename $SRC_OPENSSL)"
    make -j$(nproc) >>$LOG_OPENSSL 2>&1
    echo "Install $(basename $SRC_OPENSSL)"
    make install -j$(nproc) >>$LOG_OPENSSL 2>&1
}

build_openssh() {
    BUILD_OPENSSH=$BUILD_DIR/$(basename $SRC_OPENSSH)
    LOG_OPENSSH=$LOG_PATH/$(basename $SRC_OPENSSH)
    if [ -d $BUILD_OPENSSH ]; then
        rm -rfv $BUILD_OPENSSH >$LOG_OPENSSH 2>&1
    fi

    #mkdir -pv $BUILD_OPENSSH >$LOG_OPENSSH 2>&1
    cp -prv $SRC_OPENSSH $BUILD_DIR/ >$LOG_OPENSSH 2>&1

    cd $BUILD_OPENSSH
    echo "Configure $(basename $SRC_OPENSSH)"
    if [ "${PLATFORM}" = "x86_64" ]; then
        echo "CC:$CC"
         CC=$CROSS_CC \
            AR=$CROSS_AR \
            RANLIB=$CROSS_RANLIB \
            STRIP=$CROSS_STRIP \
            ./configure --prefix=/ --sysconfdir=/etc/ssh --exec-prefix=/usr --host=$TARGET_HOST --with-zlib=$ROOTFS/usr --with-ssl-dir=$ROOTFS/usr --disable-strip >>$LOG_OPENSSH 2>&1
    else
        CC=$CROSS_CC \
            AR=$CROSS_AR \
            RANLIB=$CROSS_RANLIB \
            STRIP=$CROSS_STRIP \
            ./configure --prefix=/ --sysconfdir=/etc/ssh --exec-prefix=/usr --host=$TARGET_HOST --with-zlib=$ROOTFS/usr --with-ssl-dir=$ROOTFS/usr --disable-strip >>$LOG_OPENSSH 2>&1
    fi
    echo "Build $(basename $SRC_OPENSSH)"
    make -j$(nproc) >>$LOG_OPENSSH 2>&1
    is_ok
    turnError off
    echo "Install $(basename $SRC_OPENSSH)"
    make DESTDIR=$ROOTFS -k install -j$(nproc) >>$LOG_OPENSSH 2>&1
    turnError on
}

build_zlib() {
    BUILD_ZLIB=$BUILD_DIR/$(basename $SRC_ZLIB)
    LOG_ZLIB=$LOG_PATH/$(basename $SRC_ZLIB)
    if [ -d $BUILD_ZLIB ]; then
        rm -rfv $BUILD_ZLIB >$LOG_ZLIB 2>&1
    fi

    cp -prv $SRC_ZLIB $BUILD_DIR/ >$LOG_ZLIB 2>&1
    cd $BUILD_ZLIB
    echo "Configure $(basename $SRC_ZLIB)"
    CC=$CROSS_CC \
        AR=$CROSS_AR \
        ./configure --prefix=$ROOTFS/usr >>$LOG_ZLIB 2>&1
    echo "Build $(basename $SRC_ZLIB)"
    make -j$(nproc) >>$LOG_ZLIB 2>&1
    echo "Install $(basename $SRC_ZLIB)"
    make install -j$(nproc) >>$LOG_ZLIB 2>&1
}

main() {
    clean_output
    initialize
    prepare_rootfs
    build_busybox
    build_bash
    build_zlib
    build_openssl
    build_openssh
    echo "finish build"
}

case ${PLATFORM} in
    aarch64)
        main
        ;;
    arm)
        main
        ;;
    x86_64)
        main
        ;;
    clean)
        echo "start to clean!!"
        clean_output
        ;;
    *)
        echo "usage:"
        echo "./build.sh [platform]"
        echo " "
        echo "eg:"
        echo "   ./build.sh aarch64     #build default  aarch64 config"
        echo "   ./build.sh arm       #build default arm config"
        echo "   ./build.sh x86_64       #build default x86_64 config"
        exit 1
        ;;
esac
