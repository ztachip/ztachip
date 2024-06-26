#!/bin/bash

set -e

sudo apt-get install -y python3 python3-pip tar
pip3 install numpy

export BUILD_DIR=$PWD
export PATH=$PWD/riscv/bin:$PATH
mkdir -p riscv && cd riscv
wget https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-131023/riscv32-unknown-elf.gcc-13.2.0.tar.gz
tar -xzvf riscv32-unknown-elf.gcc-13.2.0.tar.gz

cd ../SW/compiler
make clean all
cd ../fs
python3 bin2c.py
cd ..
make clean all -f makefile.kernels
make clean all RISCV_PATH=$BUILD_DIR/riscv/ RISCV_NAME=riscv32-unknown-elf
