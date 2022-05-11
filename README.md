# description
This is an develop test environment for linux kernel using QEMU virtual machine.
# download source
```
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

```
# install
```
./install.sh
```
It will install compile tools chains of arm and arm64, and qemu environment.

## toolchain install

```shell
wget https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz 
sudo tar xvf gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz -C /opt/buildtools
```

- **environment variables set**

  `sudo vim /etc/profile`

  add `PATH=$PATH:/opt/buildtools/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin` at tail

- **test toolchain**

  ```shell
  source /etc/profile`
  arm-none-linux-gnueabihf-gcc --version
  ```

  if output as below, succeed:

  > arm-none-linux-gnueabihf-gcc (GNU Toolchain for the A-profile Architecture 9.2-2019.12 (arm-9.10)) 9.2.1 20191025

# build busybox
```
./build_busybox.sh  aarch64

eg:
./build_busybox.sh arm      #compile arm platform 
./build_busybox.sh aarch64    #compile aarch64 platform
./build_busybox.sh x86_64    #compile x86_64 platform
```

# build rootfs
```
./build_rootfs.sh aarch64
```
This build will invoke build_busybox.sh to generate busybox bin for rootfs.

# generate config
```
./generate_config.sh aarch64
```

# build kernel
```
./build_kernel.sh aarch64
```

# run qemu
```
./qemu_start.sh aarch64
```

# stop qemu
```
./qemu_stop.sh aarch64
```

# docs
https://ops.tips/notes/booting-linux-on-qemu/

https://github.com/google/syzkaller/blob/master/docs/linux/setup_linux-host_qemu-vm_arm64-kernel.md

issue, you need to add the ‘sshd’ user on the server.
Edit the file /etc/passwd and add the below line:
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
and the below line in the /etc/group file
sshd:x:74:
You will now be able to restart the sshd service.
# /etc/init.d/sshd restart
Stopping sshd: [ OK ]
Starting sshd: [ OK ]
Another solution is to disable UsePrivilegeSeparation. E

chown -R root.root /var/empty
chmod 744 /var/empty

编译dropbear,它是arm端的ssh server,

ifconfig eth0 10.0.2.15
ifconfig eth0 up

