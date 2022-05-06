#!/bin/bash

set -e
set -x
cd ltp
./configure CC=arm-linux-gnueabi-gcc --build=i686-pc-linux-gnu --target=arm-linux --host=arm-linux  CFLAGS="-static" LDFLAGS="-static  -pthread"