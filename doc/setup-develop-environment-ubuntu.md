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
