TARGET = quant 
LIBS=-lm -lstdc++
CC=g++
CFLAGS= \
-O3 \
-Wall \
-Wno-unused-function \
-Wno-strict-aliasing \
-Wno-format-overflow \
-fpermissive \
-fno-strict-aliasing \
-I.

OBJ = quant.o gguf.o zuf.o ../../../base/net.o ../../../src/soc.o

%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET) : $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

all: $(TARGET) 

clean:
	rm -f $(OBJ) $(TARGET) 
