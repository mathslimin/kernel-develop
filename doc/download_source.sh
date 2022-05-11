#!/bin/bash
cd src
wget https://mirrors.tuna.tsinghua.edu.cn/kernel/v5.x/linux-5.10.113.tar.gz
tar zxvf linux-5.*.tar.gz
mv linux-5.10.113 linux-next

wget https://www.busybox.net/downloads/busybox-1.35.0.tar.bz2
tar zvf busybox-1.35.0.tar.bz2

wget https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/openssh-9.0p1.tar.gz
tar zxvf openssh-9.0p1.tar.gz

git clone https://github.com/linux-test-project/ltp.git

wget https://ftp.gnu.org/gnu/bash/bash-5.1.16.tar.gz
tar zxvf bash-5.1.16.tar.gz

wget https://zlib.net/zlib-1.2.12.tar.gz
tar zxvf zlib-1.2.12.tar.gz

wget https://www.openssl.org/source/openssl-3.0.3.tar.gz
tar zxvf openssl-3.0.3.tar.gz
