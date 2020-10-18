#!/bin/sh
PATH=~/mips-elf/bin:$PATH
LIBS=-L~/mips-elf/lib
ZCC=../../tools/compiler/compiler
MCC=mips-linux-gnu-gcc
OBJCOPY=mips-linux-gnu-objcopy

rm \
ztachip.hex \
mcore.hex \
../apps/main/kernels/main.o \
../apps/nn/kernels/conv.o \
../apps/nn/kernels/fcn.o \
../apps/color/kernels/color.o \
../apps/resize/kernels/resize.o \
../apps/equalize/kernels/equalize.o \
../apps/gaussian/kernels/gaussian.o \
../apps/canny/kernels/canny.o \
../apps/harris/kernels/harris.o \
../apps/of/kernels/of.o \
../apps/main/kernels/main.hex \
../apps/nn/kernels/conv.hex \
../apps/nn/kernels/fcn.hex \
../apps/color/kernels/color.hex \
../apps/resize/kernels/resize.hex \
../apps/equalize/kernels/equalize.hex \
../apps/gaussian/kernels/gaussian.hex \
../apps/canny/kernels/canny.hex \
../apps/harris/kernels/harris.hex \
../apps/of/kernels/of.hex 


DFLAG=ZTA_DEBUG2
PFILE=pcore.p
MFILE=mcore.m
LDFILE=mcore.ld
CFG=../../../hardware/config.xml

gcc -E -x c ../apps/main/kernels/main.p > temp.p
../../tools/compiler/compiler -I ../apps/main/kernels/main.m temp.p
mips-elf-gcc -c ../apps/main/kernels/main.m.c -D${DFLAG} -o ../apps/main/kernels/main.o -O3 -mips1

gcc -E -x c ../apps/nn/kernels/conv.p > temp.p
../../tools/compiler/compiler -I ../apps/nn/kernels/conv.m temp.p
mips-elf-gcc -c ../apps/nn/kernels/conv.m.c -D${DFLAG} -o ../apps/nn/kernels/conv.o -O3 -mips1

gcc -E -x c ../apps/nn/kernels/fcn.p > temp.p
../../tools/compiler/compiler -I ../apps/nn/kernels/fcn.m temp.p
mips-elf-gcc -c ../apps/nn/kernels/fcn.m.c -D${DFLAG} -o ../apps/nn/kernels/fcn.o -O3 -mips1

gcc -E -x c ../apps/color/kernels/color.p > temp.p
../../tools/compiler/compiler -I ../apps/color/kernels/color.m temp.p
mips-elf-gcc -c ../apps/color/kernels/color.m.c -D${DFLAG} -o ../apps/color/kernels/color.o -O3 -mips1

gcc -E -x c ../apps/resize/kernels/resize.p > temp.p
../../tools/compiler/compiler -I ../apps/resize/kernels/resize.m temp.p
mips-elf-gcc -c ../apps/resize/kernels/resize.m.c -D${DFLAG} -o ../apps/resize/kernels/resize.o -O3 -mips1

gcc -E -x c ../apps/equalize/kernels/equalize.p > temp.p
../../tools/compiler/compiler -I ../apps/equalize/kernels/equalize.m temp.p
mips-elf-gcc -c ../apps/equalize/kernels/equalize.m.c -D${DFLAG} -o ../apps/equalize/kernels/equalize.o -O3 -mips1

gcc -E -x c ../apps/gaussian/kernels/gaussian.p > temp.p
../../tools/compiler/compiler -I ../apps/gaussian/kernels/gaussian.m temp.p
mips-elf-gcc -c ../apps/gaussian/kernels/gaussian.m.c -D${DFLAG} -o ../apps/gaussian/kernels/gaussian.o -O3 -mips1

gcc -E -x c ../apps/canny/kernels/canny.p > temp.p
../../tools/compiler/compiler -I ../apps/canny/kernels/canny.m temp.p
mips-elf-gcc -c ../apps/canny/kernels/canny.m.c -D${DFLAG} -o ../apps/canny/kernels/canny.o -O3 -mips1

gcc -E -x c ../apps/harris/kernels/harris.p > temp.p
../../tools/compiler/compiler -I ../apps/harris/kernels/harris.m temp.p
mips-elf-gcc -c ../apps/harris/kernels/harris.m.c -D${DFLAG} -o ../apps/harris/kernels/harris.o -O3 -mips1

gcc -E -x c ../apps/of/kernels/of.p > temp.p
../../tools/compiler/compiler -I ../apps/of/kernels/of.m temp.p
mips-elf-gcc -c ../apps/of/kernels/of.m.c -D${DFLAG} -o ../apps/of/kernels/of.o -O3 -mips1

mips-elf-gcc -c ../base/ztam.c -D${DFLAG} -o ztam.o -O3 -mips1
mips-elf-gcc -c ../base/task.s -o task.o -O3 -mips1

../../tools/compiler/compiler -L mcore.ld \
../apps/main/kernels/main.hex \
../apps/nn/kernels/conv.hex \
../apps/nn/kernels/fcn.hex \
../apps/color/kernels/color.hex \
../apps/resize/kernels/resize.hex \
../apps/equalize/kernels/equalize.hex \
../apps/gaussian/kernels/gaussian.hex \
../apps/canny/kernels/canny.hex \
../apps/harris/kernels/harris.hex \
../apps/of/kernels/of.hex

mips-elf-gcc -O3 -Tmcore.ld -mips1 \
ztam.o \
task.o \
../apps/main/kernels/main.o \
../apps/nn/kernels/conv.o \
../apps/nn/kernels/fcn.o \
../apps/color/kernels/color.o \
../apps/resize/kernels/resize.o \
../apps/equalize/kernels/equalize.o \
../apps/gaussian/kernels/gaussian.o \
../apps/canny/kernels/canny.o \
../apps/harris/kernels/harris.o \
../apps/of/kernels/of.o \
-o temp
echo ""
echo "> Generate mcore.hex"
mips-elf-objcopy -O ihex temp mcore.hex
objdump --syms temp > ztachip.map
../../tools/compiler/compiler -M mcore.hex ztachip.map ztachip.hex


