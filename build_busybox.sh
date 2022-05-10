#!/bin/bash
set -e
#set -x
source ./global.sh

initialize()
{
    if [ -d $BUILD_DIR ] ; then
		rm -rfv $BUILD_DIR
    fi
	if [ -d $INSTALL_DIR/rootfs ]; then
		sudo rm -rvf $INSTALL_DIR/rootfs
	fi
	if [ -d $LOG_PATH ]; then
		sudo rm -rvf $LOG_PATH
	fi
	mkdir -pv $BUILD_DIR
    mkdir -pv $LOG_PATH
    mkdir -pv $INSTALL_DIR
}

build_busybox() {
	echo "start to build busybox"
    LOG_BUSYBOX=$LOG_PATH/`basename $SRC_BUSYBOX`
	BUILD_BUSYBOX=$BUILD_DIR/`basename $SRC_BUSYBOX`
	if [ -d $BUILD_BUSYBOX ]; then
		rm -rfv $BUILD_BUSYBOX > $LOG_BUSYBOX 2>&1
    fi
	cp -pr $SRC_BUSYBOX $BUILD_DIR >> $LOG_BUSYBOX 2>&1
	cd $BUILD_BUSYBOX	
	make defconfig >> $LOG_BUSYBOX 2>&1
	sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/1' .config >> $LOG_BUSYBOX 2>&1
	make -j$(nproc) >> $LOG_BUSYBOX 2>&1
	make install >> $LOG_BUSYBOX 2>&1
	cp -prv _install/* $ROOTFS/ >> $LOG_BUSYBOX 2>&1
}

prepare_rootfs()
{
	LOG_ROOTFS=$LOG_PATH/rootfs
    if [ -d $ROOTFS ]; then
		rm -rfv $ROOTFS
    fi

    echo "Prepare Rootfs"
    cp -pr $TOP_DIR/configs/rootfs.template $ROOTFS > $LOG_ROOTFS 2>&1

    echo "Create directories"
    mkdir -pv $ROOTFS/{proc,srv,sys,dev,var,root} >> $LOG_ROOTFS 2>&1
    echo "Install directories"
    install -dv -m 1777 $ROOTFS/tmp $ROOTFS/var/tmp >> $LOG_ROOTFS 2>&1
    echo "Copy system libs"
	if [ -d `$CC -print-sysroot`/lib ]; then
	    cp -prv `$CC -print-sysroot`/lib $ROOTFS/  >> $LOG_ROOTFS 2>&1
	fi
	if [ -d `$CC -print-sysroot`/lib64 ]; then
	    cp -prv `$CC -print-sysroot`/lib64 $ROOTFS/ >> $LOG_ROOTFS 2>&1
	fi
}

build_bash()
{
    BUILD_BASH=$BUILD_DIR/`basename $SRC_BASH`
	LOG_BASH=$LOG_PATH/`basename $SRC_BASH`
    if [ -d $BUILD_BASH ]; then
		rm -rfv $BUILD_BASH  > $LOG_BASH 2>&1
    fi
	cp -pr $SRC_BASH $BUILD_DIR >> $LOG_BASH 2>&1
    cd $BUILD_BASH
    echo "Configure `basename $BUILD_BASH`"
	#./configure --prefix=$ROOTFS --host=$TARGET >> $LOG_BASH 2>&1
	#./configure --prefix=$INSTALL/bash --host=$TARGET >> $LOG_BASH 2>&1
	./configure --prefix=/ --host=$TARGET >> $LOG_BASH 2>&1
    echo "Build `basename $BUILD_BASH`"
    make -j$(nproc) >> $LOG_BASH 2>&1
    echo "Install `basename $BUILD_BASH`"
    #make install DESTDIR=$INSTALL_DIR/bash >> $LOG_BASH 2>&1
	#cp -rf $INSTALL_DIR/bash/* $ROOTFS/
	make install DESTDIR=$ROOTFS >> $LOG_BASH 2>&1
}

build_openssl()
{
    BUILD_OPENSSL=$BUILD_DIR/`basename $SRC_OPENSSL`
    LOG_OPENSSL=$LOG_PATH/`basename $SRC_OPENSSL`
    if [ -d $BUILD_OPENSSL ]; then
		rm -rfv $BUILD_OPENSSL > $LOG_OPENSSL 2>&1
    fi

    cp -prv $SRC_OPENSSL $BUILD/ > $LOG_OPENSSL 2>&1
    cd $BUILD_OPENSSL
    echo "Configure `basename $SRC_OPENSSL`"
    #./configure linux-armv4 shared --prefix=/usr >> $LOG_OPENSSL 2>&1
	./configure shared --prefix=/usr >> $LOG_OPENSSL 2>&1
    echo "Build `basename $SRC_OPENSSL`"
    make >> $LOG_OPENSSL 2>&1
    echo "Install `basename $SRC_OPENSSL`"
    make INSTALL_PREFIX=$ROOTFS install >> $LOG_OPENSSL 2>&1
}

build_openssh() {
    BUILD_OPENSSH=$BUILD_DIR/`basename $SRC_OPENSSH`
	LOG_OPENSSH=$LOG_PATH/`basename $SRC_OPENSSH`
	if [ -d $BUILD_OPENSSH ]; then
		rm -rfv $BUILD_OPENSSH > $LOG_OPENSSH 2>&1
	fi
    cp -pr $SRC_OPENSSH $BUILD_DIR/ >> $LOG_OPENSSH 2>&1
	cd $BUILD_OPENSSH
    echo "Configure `basename $SRC_OPENSSH`"
	# CC=$CROSS_CC \
	# 	AR=$CROSS_AR \
	# 	RANLIB=$CROSS_RANLIB \
	# 	STRIP=$CROSS_STRIP \
	# 	$SRC_OPENSSH/configure --prefix=/ --sysconfdir=/etc/ssh --exec-prefix=/usr --host=$TARGET --with-zlib=$ROOTFS/usr --with-ssl-dir=$ROOTFS/usr --disable-strip >>$LOG_OPENSSH 2>&1
	./configure --prefix=/ --sysconfdir=/etc/ssh --exec-prefix=/usr --host=$TARGET --with-zlib=$ROOTFS/usr --with-ssl-dir=$ROOTFS/usr --disable-strip >> $LOG_OPENSSH 2>&1
	echo "Build `basename $SRC_OPENSSH`"
	make -j$(nproc) >> $LOG_OPENSSH 2>&1
	echo "Install `basename $SRC_OPENSSH`"
	make DESTDIR=$ROOTFS -k install >> $LOG_OPENSSH 2>&1
}

build_zlib()
{
    BUILD_ZLIB=$BUILD_DIR/`basename $SRC_ZLIB`
	LOG_ZLIB=$LOG_PATH/`basename $SRC_ZLIB`
    if [ -d $BUILD_ZLIB ]; then
		rm -rfv $BUILD_ZLIB > $LOG_ZLIB 2>&1
    fi
    cp -pr $SRC_ZLIB $BUILD_DIR/ >> $LOG_ZLIB 2>&1
    cd $BUILD_ZLIB
    echo "Configure `basename $SRC_ZLIB`"
    ./configure --prefix=$ROOTFS/usr --static >> $LOG_ZLIB 2>&1
    echo "Build `basename $SRC_ZLIB`"
    make -j$(nproc) >> $LOG_ZLIB 2>&1
    echo "Install `basename $SRC_ZLIB`"
    make install >> $LOG_ZLIB 2>&1
}

main(){
	initialize
	prepare_rootfs
	build_busybox
	build_bash
	build_zlib
	build_openssl
	build_openssh
	echo "finish build"
}
#main entry
export arch=$1
toolchain_$1

case ${arch} in
	arm64)
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
		make mrproper
		;;
	*)
		echo "usage:"
		echo "./build.sh [platform]"
		echo " "
		echo "eg:"
		echo "   ./build.sh arm64     #build default  arm64 config"
		echo "   ./build.sh arm       #build default arm config"
		echo "   ./build.sh x86_64       #build default x86_64 config"
		exit 1
		;;
esac
