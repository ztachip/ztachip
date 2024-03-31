include ../../py/mkenv.mk

CROSS = 1 

ZTA_OBJS = $(ZTACHIP)/SW/build/base/newlib.o \
	$(ZTACHIP)/SW/build/base/ztalib.o \
	$(ZTACHIP)/SW/build/base/ztalog.o \
	$(ZTACHIP)/SW/build/base/tensor.o \
	$(ZTACHIP)/SW/build/base/util.o \
	$(ZTACHIP)/SW/build/base/graph.o \
	$(ZTACHIP)/SW/build/base/task.o \
	$(ZTACHIP)/SW/build/apps/main/kernels/main.m.o \
	$(ZTACHIP)/SW/build/apps/color/kernels/color.m.o \
	$(ZTACHIP)/SW/build/apps/color/color.o \
	$(ZTACHIP)/SW/build/apps/of/kernels/of.m.o \
	$(ZTACHIP)/SW/build/apps/of/of.o \
	$(ZTACHIP)/SW/build/apps/canny/kernels/canny.m.o \
	$(ZTACHIP)/SW/build/apps/canny/canny.o \
	$(ZTACHIP)/SW/build/apps/harris/kernels/harris.m.o \
	$(ZTACHIP)/SW/build/apps/harris/harris.o \
	$(ZTACHIP)/SW/build/apps/resize/kernels/resize.m.o \
	$(ZTACHIP)/SW/build/apps/resize/resize.o \
	$(ZTACHIP)/SW/build/apps/gaussian/kernels/gaussian.m.o \
	$(ZTACHIP)/SW/build/apps/gaussian/gaussian.o \
	$(ZTACHIP)/SW/build/apps/equalize/kernels/equalize.m.o \
	$(ZTACHIP)/SW/build/apps/equalize/equalize.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_add.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_concat.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_conv2d.o \
	$(ZTACHIP)/SW/build/apps/nn/nn.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_logistic.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_objdect.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_poolavg.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_reshape.o \
	$(ZTACHIP)/SW/build/apps/nn/nn_util.o \
	$(ZTACHIP)/SW/build/apps/nn/tf.o \
	$(ZTACHIP)/SW/build/apps/nn/tf_util.o \
	$(ZTACHIP)/SW/build/apps/nn/kernels/conv.m.o \
	$(ZTACHIP)/SW/build/apps/nn/kernels/fcn.m.o \
	$(ZTACHIP)/SW/build/apps/test/kernels/test.m.o \
	$(ZTACHIP)/SW/build/apps/gdi/gdi.o \
	$(ZTACHIP)/SW/build/src/soc.o \
	$(ZTACHIP)/SW/build/src/mpy.o

# qstr definitions (must come before including py.mk)
QSTR_DEFS = qstrdefsport.h

# MicroPython feature configurations
MICROPY_ROM_TEXT_COMPRESSION ?= 1

# include py core make definitions
include $(TOP)/py/py.mk

ifeq ($(CROSS), 1)
CROSS_COMPILE ?= riscv32-unknown-elf-
endif

MABI=ilp32
MARCH := rv32im

INC += -I.
INC += -I$(ZTACHIP)
INC += -I$(TOP)
INC += -I$(BUILD)

DFU = $(TOP)/tools/dfu.py
PYDFU = $(TOP)/tools/pydfu.py
CFLAGS_RISCV = -march=rv32im -mabi=ilp32
CFLAGS += $(INC) -Wall -Wno-unused-variable -Wno-misleading-indentation $(CFLAGS_RISCV)
CFLAGS += -O3 -ggdb
LDFLAGS = -march=$(MARCH) -mabi=$(MABI)
LDFLAGS +=  -nostdlib -lgcc -lc -lgloss -lm -lstdc++ -lgcc -lc -lgcc -mcmodel=medany -nostartfiles -ffreestanding -Wl,-Bstatic,-T,linker.ld,--print-memory-usage

CC=/opt/riscv//bin/riscv32-unknown-elf-gcc
LD=$(CC)

LIBS = 

SRC_ASM = \
	setjmp.S \
	crt.S

SRC_C = \
	main.c \
	zta.c \
	uart_core.c \
	shared/libc/printf.c \
	shared/readline/readline.c \
	shared/runtime/pyexec.c \
	shared/runtime/stdout_helpers.c \
	$(BUILD)/_frozen_mpy.c

SRC_QSTR += zta.c

ifeq ($(CROSS), 1)
SRC_C += shared/libc/string0.c
endif

SRC_QSTR += shared/readline/readline.c shared/runtime/pyexec.c

OBJ += $(PY_CORE_O)
OBJ += $(addprefix $(BUILD)/, $(SRC_C:.c=.o))
OBJ += $(addprefix $(BUILD)/, $(SRC_CXX:.cpp=.o))
OBJ += $(addprefix $(BUILD)/, $(SRC_ASM:.S=.o))
OBJ += $(ZTA_OBJS)


ifeq ($(CROSS), 1)
all: $(BUILD)/firmware.hex
else
all: $(BUILD)/firmware.elf
endif

$(BUILD)/firmware.hex: $(BUILD)/firmware.elf
	$(Q)$(OBJCOPY) -O ihex $^ $@

$(BUILD)/_frozen_mpy.c: $(TOP)/tests/frozen/frozentest.mpy $(BUILD)/genhdr/qstrdefs.generated.h
	$(ECHO) "MISC freezing bytecode"
	$(Q)$(TOP)/tools/mpy-tool.py -f -q $(BUILD)/genhdr/qstrdefs.preprocessed.h -mlongint-impl=none $< > $@

$(BUILD)/firmware.elf: $(OBJ)
	$(ECHO) "LINK $@"
	$(Q)$(LD) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS) 
	$(Q)$(SIZE) $@

$(BUILD)/firmware.bin: $(BUILD)/firmware.elf
	$(Q)$(OBJCOPY) -O binary -j .isr_vector -j .text -j .data $^ $(BUILD)/firmware.bin

$(BUILD)/firmware.dfu: $(BUILD)/firmware.bin
	$(ECHO) "Create $@"
	$(Q)$(PYTHON) $(DFU) -b 0x08000000:$(BUILD)/firmware.bin $@

deploy: $(BUILD)/firmware.dfu
	$(ECHO) "Writing $< to the board"
	$(Q)$(PYTHON) $(PYDFU) -u $<

# Run emulation build on a POSIX system with suitable terminal settings
run:
	@saved_=`stty -g`; \
	  stty raw opost -echo; \
	  $(BUILD)/firmware.elf; \
	  echo "Exit status: $$?"; \
	  stty $$saved_

test: $(BUILD)/firmware.elf
	$(Q)/bin/echo -e "print('hello world!', list(x+1 for x in range(10)), end='eol\\\\n')\\r\\n\\x04" | $(BUILD)/firmware.elf | tail -n2 | grep "^hello world! \\[1, 2, 3, 4, 5, 6, 7, 8, 9, 10\\]eol"

include $(TOP)/py/mkrules.mk
