TARGET = edge_detect 
LIBS=-lzta -lrt -lm -lstdc++
AR=arm-linux-gnueabihf-ar
CC=arm-linux-gnueabihf-gcc
CFLAGS=-mfloat-abi=hard \
-std=gnu++11 \
-O3 \
-Wall \
-L../../software/target/builds \
-I.

OBJ = edge_detect.o

%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET) : $(OBJ) ../../software/target/builds/libzta.a
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

all: $(TARGET) 

clean:
	rm -f $(OBJ) $(TARGET) 
