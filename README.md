# description
This is an develop test environment for linux kernel using QEMU virtual machine.
# download source
```
wget https://mirrors.tuna.tsinghua.edu.cn/kernel/v5.x/linux-5.10.113.tar.gz
tar zxvf linux-5.*.tar.gz
mv linux-5.10.113 linux-5-kernel
wget https://www.busybox.net/downloads/busybox-1.35.0.tar.bz2
tar zvf busybox-1.35.0.tar.bz2
```
# install
```
./install.sh
```
It will install compile tools chains of arm and arm64, and qemu environment.

# build busybox
```
./build_busybox.sh  xxx

eg:
./build_busybox.sh arm      #compile arm platform 
./build_busybox.sh arm64    #compile arm64 platform
./build_busybox.sh x86_64    #compile x86_64 platform
```

# build rootfs
```
./build_rootfs.sh xxx

eg:
./build_rootfs.sh arm      #compile arm platform 
```
This build will invoke build_busybox.sh to generate busybox bin for rootfs.

# build kernel
```
./build_kernel.sh
eg:
./build_kernel.sh arm      #compile arm platform 
```

# run qemu
```
./qemu_start.sh arm
```

# stop qemu
```
./qemu_stop.sh arm
```

# docs
https://ops.tips/notes/booting-linux-on-qemu/
