#!/bin/bash

set -e

sudo apt-get install -y python3 python3-pip tar
pip3 install numpy

export BUILD_DIR=$PWD
export PATH=$PWD/riscv/bin:$PATH
mkdir -p riscv && cd riscv
wget https://github.com/fedy0/riscvxx-unknown-elf-prebuilt/releases/latest/download/riscvxx-unknown-elf-prebuilt.tar.gz
tar -xzvf riscvxx-unknown-elf-prebuilt.tar.gz

cd ../SW/compiler
make clean all
cd ../fs
python3 bin2c.py
cd ..
make clean all -f makefile.kernels
make clean all RISCV_PATH=$BUILD_DIR/riscv/ RISCV_NAME=riscv64-unknown-elf UNIT_TEST=yes
