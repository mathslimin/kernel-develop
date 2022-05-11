# description
This is an develop test environment for linux kernel using QEMU virtual machine.
# download source
```
./doc/downlod_source.sh
```
[toc]

**for ubuntu20.04, refer this [setup4ubuntu20.04](./doc/set-develop-environment-ubuntu.md)**


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

