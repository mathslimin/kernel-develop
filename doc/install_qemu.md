
### 卸载系统默认的qemu
```shell
sudo apt-get remove --auto-remove qemu
```
### 下载源代码
```shell
wget https://download.qemu.org/qemu-6.2.0.tar.xz
tar xvJf qemu-6.2.0.tar.xz
cd qemu-6.2.0
```
### ubuntu源码安装qemu
```shell
#ubuntu
sudo apt-get build-dep qemu
sudo apt-get install -y ninja-build
./configure --prefix=/opt/soft/qemu --enable-kvm --enable-virtfs
make -j 16
sudo make install
echo 'export PATH=/opt/soft/qemu/bin:$PATH' | sudo tee --append /etc/profile
```
### 欧拉系统安装qemu
```shell
sudo yum install glib2-devel pixman-devel ninja-build
./configure --prefix=/opt/soft/qemu --enable-kvm --enable-virtfs
make -j$(nproc)
sudo make install
echo 'export PATH=/opt/soft/qemu/bin:$PATH' | sudo tee --append /etc/profile
```
