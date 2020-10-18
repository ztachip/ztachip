TARGET = ztachip.a
AR=arm-linux-gnueabihf-ar
CC=arm-linux-gnueabihf-gcc
CFLAGS=-mfloat-abi=hard \
-std=gnu++11 \
-O3 \
-Wall \
-lrt \
-lm \
-lstdc++ \
-I.

OBJ = ../base/util.o \
../base/memmgr.o \
../base/programer.o \
../base/tensor.o \
../base/graph.o \
../base/ztahost.o \
../base/bitmap.o \
../apps/resize/resize.o \
../apps/color/color.o \
../apps/canny/canny.o \
../apps/gaussian/gaussian.o \
../apps/harris/harris.o \
../apps/of/of.o \
../apps/equalize/equalize.o \
../apps/nn/tf.o \
../apps/nn/tf_util.o \
../apps/nn/nn.o \
../apps/nn/nn_util.o \
../apps/nn/nn_concat.o \
../apps/nn/nn_conv2d.o \
../apps/nn/nn_logistic.o \
../apps/nn/nn_objdect.o \
../apps/nn/nn_reshape.o \
../apps/nn/nn_add.o \
../apps/nn/nn_poolavg.o

%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

libzta.a: $(OBJ) 
	$(AR) rcs $@ $^

all: libzta.a

clean:
	rm -f $(OBJ) *.a
