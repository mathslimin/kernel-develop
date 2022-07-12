#!/bin/bash

arch=$1

if [ "${arch}" = "arm" ];then
	killall qemu-system-arm 
elif [ "${arch}" = "x86_64" ];then
	killall qemu-system-x86_64 
elif [ "${arch}" = "aarch64" ];then
	killall qemu-system-aarch64 
else
	echo "arch wrong"
fi
