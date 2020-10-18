TARGET = resize 
LIBS=-lzta -lrt -lm -lstdc++
AR=arm-linux-gnueabihf-ar
CC=arm-linux-gnueabihf-gcc
CFLAGS=-mfloat-abi=hard \
-std=gnu++11 \
-O3 \
-Wall \
-L../../software/target/builds \
-I.

OBJ = resize.o

%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET) : $(OBJ) ../../software/target/builds/libzta.a
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

all: $(TARGET) 

clean:
	rm -f $(OBJ) $(TARGET) 
