# 用qemu调试内核  
文章参考 https://github.com/SundanceMultiprocessorTechnology/VCS-1/wiki/Install-Ubuntu-minimal-on-the-VCS-1
【RK3399】rk3399 arm64 ubuntu18.04 根文件系统制作
https://blog.csdn.net/dghfjj/article/details/113685487

## 环境:
```bash
sudo apt-get install gcc-aarch64-linux-gnu build-essential pkg-config libglib2.0-dev libpixman-1-dev libfdt-dev flex bison qemu libssl-dev
```
## 编译内核：
```bash
export ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- # arm64
export ARCH=x86_64
export ARCH=um
make defconfig ARCH=um
make menuconfig ARCH=um
make -j16
```
## 下载根文件系统：
http://releases.linaro.org/openembedded/aarch64/17.01/ 
Download vexpress64-openembedded_minimal-armv8-gcc-5.2_20170127-761.img.gz 
[debian](http://fs.devloop.org.uk/filesystems/Debian-Jessie/Debian-Jessie-AMD64-root_fs.bz2)

## 制作Ubuntu 根文件系统
[ ubuntu-base-18.04.5-base-amd64.tar.gz](http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.5-base-amd64.tar.gz)
[ ubuntu-base-18.04.5-base-arm64.tar.gz](http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.5-base-arm64.tar.gz)
```bash
dd if=/dev/zero of=ubuntu.img bs=1024 count=1M
mkfs.ext4 -F -L linuxroot ubuntu.img
mkdir rootfs
sudo mount -o loop ubuntu.img rootfs/
sudo tar zxvf ubuntu-base-18.04.5-base-amd64.tar.gz -C rootfs/
sudo cp -b /etc/resolv.conf rootfs/etc/
sudo cp -b /etc/apt/sources.list rootfs/etc/apt/
sudo mount -t proc /proc rootfs/proc
sudo mount -t sysfs /sys rootfs/sys
sudo mount -o bind /dev rootfs/dev
sudo mount -o bind /dev/pts rootfs/dev/pts
sudo chroot rootfs
apt-get update
apt-get install build-essential gdb vim sudo ssh net-tools ethtool ifupdown network-manager --no-install-recommends
echo "ubuntu" > /etc/hostname
```
Inside /etc/hosts:
```bash
127.0.0.1 localhost
127.0.0.1 ubuntu
```
```shell
sudo vim /etc/ssh/sshd_config
PermitRootLogin yes #允许root登录
```
```bash
sudo umount rootfs/proc
sudo umount rootfs/sys
sudo umount rootfs/dev/pts
sudo umount rootfs/dev
sudo umount rootfs/
```
## 启动内核：
```bash
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a57 \
  -smp 4 \
  -kernel arch/arm64/boot/Image \
  -drive if=none,file=rootfs.img,id=fs \
  -device virtio-blk-device,drive=fs \
  -append 'console=ttyAMA0 root=/dev/vda2 rw' \
  -nographic \
  -net nic -net user,hostfwd=tcp::5022-:22
  
qemu-system-x86_64 \
  -smp 4 -m 1024M \
  -kernel ../linux/arch/x86_64/boot/bzImage \
  -append 'console=ttyS0 root=/dev/sda rw nokaslr' \
  -hda ubuntu.img \
  -nographic \
  -net nic -net user,hostfwd=tcp::5022-:22
```
```bash
mount -t ext4 -o rw,remount /dev/sda
```
>guest use 10.0.2.2 to visit host
>guest can visit network
>host use 5022 port to visit guest 22 port
## 调试内核
```bash
gdb -tui vmlinux
(gdb) target remote localhost:1234
