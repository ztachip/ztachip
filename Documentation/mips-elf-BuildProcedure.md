# Install MIPS GNU cross-compiler and linker

This document describes the steps to build GNU cross-compiler and linker for ztachip mcore programming. 

But you can also get a prebuilt version of this compiler from git

```
       cd ~
       git clone https://github.com/ztachip/mips-elf.git
```

## Build procedure

- Download the GNU bin utility [binutils-2.24.tar.bz2](http://ftp.gnu.org/gnu/binutils/)
```
       cd ~
       mkdir mips-elf
       mkdir comparch
       cd comparch
       cp ~/Downloads/binutils-2.24.tar.bz2 .
       tar jxvf binutils-2.24.tar.bz2
       cd binutils-2.24.1

       ## Edit Makefile and replace CFLAGS with the line below
       CFLAGS = -g -O2 -Wno-implicit-fallthrough -Wno-unused-value -Wno-format-overflow -Wno-unused-but-set-variable -Wno-pointer-compare -Wno-shift-negative-value -Wno-maybe-uninitialized -Wno-format-security -Wno-unused-const-variable

       export TARGET=mips-elf
       export PREFIX=~/$TARGET
       export PATH=$PATH:$PREFIX/bin
       ./configure --target=$TARGET --prefix=$PREFIX
       make
       make install
```
- Download the GCC source [gcc-4.9.0.tar.bz2](http://ftp.gnu.org/gnu/gcc)

```
       cd ~/comparch
       cp ~/Download/gcc-4.9.0.tar.bz2 .
       tar jxvf gcc-4.9.0.tar.bz2
       cd gcc-4.9.0
       sudo ./contrib/download_prerequisites

       There is a complication error with this version of GNU. Apply the patches below
       https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;h=ec1cc0263f156f70693a62cf17b254a0029f4852

       export TARGET=mips-elf
       export PREFIX=~/$TARGET
       export PATH=$PATH:$PREFIX/bin // include the new path, so you can
       ./configure --target=$TARGET --prefix=$PREFIX --withoutheaders --with-newlib --with-gnu-as --with-gnu-ld
       make all-gcc
       make install-gcc

