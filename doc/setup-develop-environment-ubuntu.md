## Crosstool
```shell
sudo apt install libtool-bin
sudo apt install help2man

wget https://github.com/crosstool-ng/crosstool-ng/archive/crosstool-ng-1.25.0.tar.bz2
tar xf crosstool-ng-1.25.0.tar.bz2
cd crosstool-ng-1.25.0
./bootstrap
./configure --enable-local --prefix=/opt/buildtools/crosstool-ng-1.25.0
make
test -x ct-ng || echo "ctng setup unsuccessful"
./ct-ng x86_64-unknown-linux-gnu
./ct-ng menuconfig # Change #of parallel jobs two 4 and remove fortran and java languages
./ct-ng build
export PATH=$PATH:$HOME/x-tools/x86_64-unknown-linux-gnu/bin/
(test -x x86_64-unknown-linux-gnu-gcc && x86_64-unknown-linux-gnu-gcc -v) || echo "ctng build unsuccessful"
cd ..
```

sudo apt-get install qemu-system-arm

2.主机的ssh工具要安装

3.参照网上的里程编译内核，制作文件系统

基本和这篇文章类似 https://blog.csdn.net/linyt/article/details/42504975

4.编译dropbear,它是arm端的ssh server,

5.启动虚拟机

qemu-system-arm \
    -M vexpress-a9 \
    -m 256M \
    -kernel zImage \
    -nographic \
    -append "root=/dev/mmcblk0 rw rootfstype=ext4 console=ttyAMA0 init=/linuxrc" \
    -sd ext4.img \
    -dtb vexpress-v2p-ca9.dtb \
    -net nic \
      -net user,hostfwd=tcp::2222-:22

6.通过ssh连接。在主机端执行

ssh -p 2222 root@127.0.0.1

即可。

 

我在第6部，花了1天时间都没有连上，各种尝试，最后仔细发现arm端内部ip需要设置为10.0.2.15.或者使用dhcpc命令分配。为什么是这样，可以参考qemu的文档

ifconfig eth0 10.0.2.15

ifconfig eth0 up

