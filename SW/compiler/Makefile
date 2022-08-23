TARGET = compiler 
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

OBJ = ast.o class.o const.o gen.o graph.o ident.o \
instruction.o mcore.o prune.o term.o util.o config.o main.o \
lex.yy.o Parser.tab.o

lex.yy.c : Lexer.l
	flex $<

Parser.tab.c : Parser.y
	bison -d $<

%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET) : $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

all: $(TARGET) 

clean:
	rm -f $(OBJ) Parser.tab.c lex.yy.c $(TARGET) 
