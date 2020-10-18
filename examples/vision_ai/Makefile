TARGET = vision_ai 

CFLAGS = -ggdb -Wall -std=c++11 `pkg-config --cflags gtk+-3.0 opencv`
LDFLAGS = -ggdb -Wall -std=c++11 `pkg-config --libs gtk+-3.0 opencv`
CC = g++ 

all: $(TARGET)

$(TARGET): gui.o vision_ai.o webcam.o ../../software/target/builds/libzta.a
	$(CC) $(LDFLAGS) -o $@ $^ `pkg-config --libs gtk+-3.0 opencv` -L../../software/target/builds -lpthread -lzta

%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(TARGET) *.a *.o *~

