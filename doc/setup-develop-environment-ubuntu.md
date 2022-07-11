# install
```
./install.sh
```
It will install compile tools chains of arm and arm64, and qemu environment.

## toolchain install

```shell
wget https://mirrors.nju.edu.cn/armbian-releases/_toolchain/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz
sudo tar xf gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz
mv gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf /opt/buildtools/gcc-arm-none-linux-gnueabihf
```

- **environment variables set**

  `sudo vim /etc/profile`

  add `export GCC_AARCH64_PATH=/opt/buildtools/gcc-aarch64-none-linux-gnu` at tail

- **test toolchain**

  ```shell
  source /etc/profile`
  arm-none-linux-gnueabihf-gcc --version
  ```

## arch64-linux-gnu
download from https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/
gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
```shell
#wget https://publishing-ie-linaro-org.s3.amazonaws.com/releases/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
sudo tar xvf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
mv gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu gcc-aarch64-linux-gnu
#add to /etc/profile
export GCC_AARCH64_PATH=/opt/buildtools/gcc-aarch64-linux-gnu
```
## Crosstool
```shell
sudo apt install -y libtool-bin
sudo apt install -y help2man
sudo apt-get install -y texinfo
sidp apt-get install -y gawk

wget https://github.com/crosstool-ng/crosstool-ng/archive/crosstool-ng-1.25.0.tar.bz2
tar xf crosstool-ng-1.25.0.tar.bz2
cd crosstool-ng-1.25.0
./bootstrap
./configure --enable-local
make
test -x ct-ng || echo "ctng setup unsuccessful"
./ct-ng x86_64-unknown-linux-gnu
./ct-ng menuconfig # Change #of parallel jobs two 4 and remove fortran and java languages
./ct-ng build
export PATH=$PATH:$HOME/x-tools/x86_64-unknown-linux-gnu/bin/
(test -x x86_64-unknown-linux-gnu-gcc && x86_64-unknown-linux-gnu-gcc -v) || echo "ctng build unsuccessful"
cd ..
```


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

arm端内部ip需要设置为10.0.2.15.或者使用dhcpc命令分配。为什么是这样，可以参考qemu的文档

ifconfig eth0 10.0.2.15

ifconfig eth0 up

download buildroot compiler https://toolchains.bootlin.com/?ref=hackernoon.com
