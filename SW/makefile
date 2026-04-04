PROJ_NAME=ztachip

#########################################################
###
### Choose which test to run 
###
### Set to yes for one of the option below, and no to others
###
### UNIT_TEST: Verify against some test vectors
###
### LLM_TEST: run chat bot using smollm2-135M
###
### VISION_TEST: run various vision tests with
###
#######

UNIT_TEST=no

LLM_TEST=no


########################################################

#DEBUG=yes
DEBUG=no
BENCH=no
MULDIV=yes

MAIN = src/main.cpp

SRCS = 	base/newlib.c \
	base/ztalib.c \
	base/ztalog.c \
	base/tensor.cpp \
	base/util.c \
	base/graph.cpp \
	base/crt.S \
	base/task.S \
	base/net.cpp \
	src/test.cpp \
	src/test_llm.cpp \
	src/vision_ai.cpp \
	src/mpy.cpp \
	apps/main/kernels/main.m.c \
	apps/color/kernels/color.m.c \
	apps/color/color.cpp \
	apps/of/kernels/of.m.c \
	apps/of/of.cpp \
	apps/canny/kernels/canny.m.c \
	apps/canny/canny.cpp \
	apps/harris/kernels/harris.m.c \
	apps/harris/harris.cpp \
	apps/resize/kernels/resize.m.c \
	apps/resize/resize.cpp \
	apps/gaussian/kernels/gaussian.m.c \
	apps/gaussian/gaussian.cpp \
	apps/equalize/kernels/equalize.m.c \
	apps/equalize/equalize.cpp \
	apps/nn/nn_add.cpp \
	apps/nn/nn_concat.cpp \
	apps/nn/nn_conv2d.cpp \
	apps/nn/nn.cpp \
	apps/nn/nn_logistic.cpp \
	apps/nn/nn_objdect.cpp \
	apps/nn/nn_poolavg.cpp \
	apps/nn/nn_reshape.cpp \
	apps/nn/nn_util.cpp \
	apps/nn/tf.cpp \
	apps/nn/tf_util.cpp \
	apps/nn/kernels/conv.m.c \
	apps/nn/kernels/fcn.m.c \
	apps/nn/kernels/objdet.m.c \
	apps/llm/kernels/llm.m.c \
	apps/llm/reference/llm_ref.c \
	apps/llm/llm.cpp \
	apps/llm/tokenizer.cpp \
	apps/llm/gguf/gguf.cpp \
	apps/llm/gguf/zuf.cpp \
	apps/gdi/gdi.cpp \
	apps/test/kernels/test.m.c \
	thirdparty/FatFs/ff.c \
	src/sdmm.c \
	src/chat.cpp \
	src/soc.cpp

OBJDIR = build

INC  =
LIBS = 
LIBSINC = -L$(OBJDIR)
LDSCRIPT = linker.ld

#include ../../../resources/gcc.mk
# Set it to yes if you are using the sifive precompiled GCC pack
SIFIVE_GCC_PACK ?= yes

ifeq ($(SIFIVE_GCC_PACK),yes)
	RISCV_NAME ?= riscv32-unknown-elf
	RISCV_PATH ?= /opt/riscv/
else
	RISCV_NAME ?= riscv32-unknown-elf
	ifeq ($(MULDIV),yes)
		RISCV_PATH ?= /opt/riscv32im/
	else
		RISCV_PATH ?= /opt/riscv32i/
	endif
endif

MABI=ilp32
MARCH := rv32im

CFLAGS += -Wall -Wno-unused-variable -Wno-misleading-indentation -march=$(MARCH) -mabi=$(MABI)
LDFLAGS += -march=$(MARCH)  -mabi=$(MABI) 

#include ../../../resources/subproject.mk


ifeq ($(DEBUG),yes)
	CFLAGS += -ggdb -O0 
endif

ifeq ($(DEBUG),no)
#	CFLAGS += -g0 -O3
	CFLAGS += -ggdb -O3
endif

ifeq ($(BENCH),yes)
	CFLAGS += -fno-inline
endif

ifeq ($(UNIT_TEST),yes)
	CFLAGS += -DZTACHIP_UNIT_TEST
endif

ifeq ($(LLM_TEST),yes)
	CFLAGS += -DZTACHIP_LLM_TEST
endif

CFLAGS += -I./apps/nn/flatbuffer

ifeq ($(SIFIVE_GCC_PACK),yes)
	RISCV_CLIB=$(RISCV_PATH)/$(RISCV_NAME)/lib/$(MARCH)/$(MABI)/
else
	RISCV_CLIB=$(RISCV_PATH)/$(RISCV_NAME)/lib/
endif

RISCV_OBJCOPY = $(RISCV_PATH)/bin/$(RISCV_NAME)-objcopy
RISCV_OBJDUMP = $(RISCV_PATH)/bin/$(RISCV_NAME)-objdump
RISCV_CC=$(RISCV_PATH)/bin/$(RISCV_NAME)-gcc
RISCV_AR=$(RISCV_PATH)/bin/$(RISCV_NAME)-ar

CFLAGS += -MD -fstrict-volatile-bitfields -fno-strict-aliasing
LDFLAGS +=  -nostdlib -lgcc -lc -lm -lstdc++ -lgcc -lc -lgcc -mcmodel=medany -nostartfiles -ffreestanding -Wl,-Bstatic,-T,$(LDSCRIPT),-Map,$(OBJDIR)/$(PROJ_NAME).map,--print-memory-usage

OBJS := $(SRCS)
OBJS := $(OBJS:.c=.o)
OBJS := $(OBJS:.cpp=.o)
OBJS := $(OBJS:.S=.o)
OBJS := $(OBJS:..=miaou)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))

MAIN_OBJ := $(MAIN)
MAIN_OBJ := $(MAIN_OBJ:.c=.o)
MAIN_OBJ := $(MAIN_OBJ:.cpp=.o)
MAIN_OBJ := $(addprefix $(OBJDIR)/,$(MAIN_OBJ))

all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).asm $(OBJDIR)/$(PROJ_NAME).v $(OBJDIR)/libzta.a

$(OBJDIR)/libzta.a: $(OBJS) | $(OBJDIR)
	$(RISCV_AR) rcs $@ $^

$(OBJDIR)/%.elf: $(OBJS) $(MAIN_OBJ) | $(OBJDIR)
	$(RISCV_CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(LIBSINC) $(LIBS)

%.hex: %.elf
	$(RISCV_OBJCOPY) -O ihex $^ $@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $^ $@

%.v: %.elf
	$(RISCV_OBJCOPY) -O verilog $^ $@

%.asm: %.elf
	$(RISCV_OBJDUMP) -S -d $^ > $@

$(OBJDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^
	$(RISCV_CC) -S $(CFLAGS)  $(INC) -o $@.disasm $^

$(OBJDIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^

$(OBJDIR)/%.o: %.S
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS) -o $@ $^ -D__ASSEMBLY__=1

$(OBJDIR):
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(OBJDIR)
	rm -f $(OBJDIR)/$(PROJ_NAME).elf
	rm -f $(OBJDIR)/$(PROJ_NAME).hex
	rm -f $(OBJDIR)/$(PROJ_NAME).map
	rm -f $(OBJDIR)/$(PROJ_NAME).v
	rm -f $(OBJDIR)/$(PROJ_NAME).asm
	find $(OBJDIR) -type f -name '*.o' -print0 | xargs -0 -r rm
	find $(OBJDIR) -type f -name '*.d' -print0 | xargs -0 -r rm

clean-all : clean 

.SECONDARY: $(OBJS)
