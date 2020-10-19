################################################
#
# Makefile to Manage QuartusII/QSys Design
#
# Copyright Altera (c) 2016
# All Rights Reserved
#
################################################

SHELL := /bin/bash

.SUFFIXES: # Delete the default suffixes

################################################
# Tools

CAT := cat
CD := cd
CHMOD := chmod
CP := cp -rf
ECHO := echo
DATE := date
FIND := find
GREP := grep
HEAD := head
MKDIR := mkdir -p
MV := mv
RM := rm -rf
SED := sed
TAR := tar
TOUCH := touch
WHICH := which

# Helpful Macros
SPACE := $(empty) $(empty)

ifndef COMSPEC
ifdef ComSpec
COMSPEC = $(ComSpec)
endif # ComSpec
endif # COMSPEC

ifdef COMSPEC # if Windows OS
IS_WINDOWS_HOST := 1
endif

ifeq ($(IS_WINDOWS_HOST),1)
ifneq ($(shell $(WHICH) cygwin1.dll 2>/dev/null),)
IS_CYGWIN_HOST := 1
endif
endif

ifneq ($(shell $(WHICH) quartus 2>/dev/null),)
HAVE_QUARTUS := 1
endif

ifeq ($(HAVE_QUARTUS),1)
HAVE_QSYS := 1
endif

#<unused>
#ifneq ($(shell $(WHICH) quartus_pgm 2>/dev/null),)
#HAVE_QUARTUS_PGM := 1
#endif

################################################

################################################
.PHONY: default
default: help
################################################

################################################
.PHONY: all
all: preloader uboot dts dtb sd-fat

ifeq ($(HAVE_QUARTUS),1)
all: sof rbf
endif
################################################

################################################
# Target Stamping

SOCEDS_VERSION := $(if $(wildcard $(SOCEDS_DEST_ROOT)/version.txt),$(shell $(CAT) $(SOCEDS_DEST_ROOT)/version.txt 2>/dev/null | $(GREP) Version | $(HEAD) -n1 | $(SED) -e 's,^Version[: \t=]*\([0-9.]*\).*,\1,g' 2>/dev/null))

define get_stamp_dir
stamp$(if $(SOCEDS_VERSION),/$(SOCEDS_VERSION))
endef

define get_stamp_target
$(get_stamp_dir)$(if $1,/$1.stamp,$(error ERROR: Arg 1 missing to $0 function))
endef

define stamp_target
@$(MKDIR) $(@D)
@$(TOUCH) $@
endef

.PHONY: clean
clean:
	@$(ECHO) "Cleaning stamp files (which will trigger rebuild)"
	@$(RM) $(get_stamp_dir)
	@$(ECHO) " TIP: Use 'make scrub_clean' to get a deeper clean"
################################################


################################################
# Archiving & Cleaning your QuartusII/QSys Project

AR_TIMESTAMP := $(if $(SOCEDS_VERSION),$(subst .,_,$(SOCEDS_VERSION))_)$(subst $(SPACE),,$(shell $(DATE) +%m%d%Y_%k%M%S))

AR_DIR := tgz
AR_FILE := $(AR_DIR)/$(basename $(firstword $(wildcard *.qpf)))_$(AR_TIMESTAMP).tar.gz

SOFTWARE_DIR := software
PRELOADER_DIR := $(SOFTWARE_DIR)/preloader

AR_REGEX += \
	Makefile ip readme.txt ds5 \
	altera_avalon* *.qpf *.qsf *.sdc *.v *.sv *.vhd *.qsys *.tcl *.terp *.stp \
	*.sed quartus.ini *.sof *.rbf *.sopcinfo *.jdi output_files \
	hps_isw_handoff */*.svd */synthesis/*.svd */synth/*.svd *.dts *.dtb *.xml \
	$(SOFTWARE_DIR)

AR_FILTER_OUT += %_tb.qsys
################################################



################################################
# Build QuartusII/QSys Project
#

#############
# QSys
QSYS_FILE := $(firstword $(wildcard *top*.qsys) $(wildcard *main*.qsys) $(wildcard *soc*.qsys) $(wildcard *.qsys))
ifeq ($(QSYS_FILE),)
$(error ERROR: QSYS_FILE *.qsys file not set and could not be discovered)
endif
QSYS_DEPS += $(wildcard *.qsys)
QSYS_BASE := $(basename $(QSYS_FILE))
QSYS_QIP := $(wildard $(QSYS_BASE)/synthesis/$(QSYS_BASE).qip) $(wildcard $(QSYS_BASE)/$(QSYS_BASE).qip)
QSYS_SOPCINFO := $(QSYS_BASE).sopcinfo
QSYS_STAMP := $(call get_stamp_target,qsys)

# Under cygwin, ensure TMP env variable is not a cygwin style path
# before calling ip-generate
ifeq ($(IS_CYGWIN_HOST),1)
ifneq ($(shell $(WHICH) cygpath 2>/dev/null),)
SET_QSYS_GENERATE_ENV = TMP="$(shell cygpath -m "$(TMP)")"
endif
endif

.PHONY: qsys_compile
qsys_compile: $(QSYS_STAMP)

ifeq ($(HAVE_QSYS),1)
$(QSYS_SOPCINFO) $(QSYS_QIP): $(QSYS_STAMP)
endif

$(QSYS_STAMP): $(QSYS_DEPS)
	$(SET_QSYS_GENERATE_ENV) qsys-generate $(QSYS_FILE) --synthesis=VERILOG $(QSYS_GENERATE_ARGS)
	$(stamp_target)

HELP_TARGETS += qsys_edit

qsys_edit.HELP := Launch QSys GUI
ifneq ($(HAVE_QSYS),1)
qsys_edit.HELP := $(qsys_edit.HELP) (Install Quartus II Software to enable)
endif

.PHONY: qsys_edit
qsys_edit:
	qsys-edit $(QSYS_FILE) &


SCRUB_CLEAN_FILES += $(wildcard .qsys_edit)

ifeq ($(HAVE_QSYS),1)
SCRUB_CLEAN_FILES += $(QSYS_QIP) $(QSYS_SOPCINFO) $(QSYS_BASE) 
endif

#############
# Quartus II

QUARTUS_QPF := $(firstword $(wildcard *.qpf))
ifeq ($(QUARTUS_QPF),)
$(error ERROR: QUARTUS_QPF *.qpf file not set and could not be discovered)
endif
QUARTUS_QSF := $(patsubst %.qpf,%.qsf,$(QUARTUS_QPF))
QUARTUS_BASE := $(basename $(QUARTUS_QPF))
QUARTUS_HDL_SOURCE := $(wildcard *.v *.sv *.vhd)
QUARTUS_MISC_SOURCE := $(wildcard *.stp *.sdc)

QUARTUS_PIN_ASSIGNMENTS_STAMP := $(call get_stamp_target,quartus_pin_assignments)
QUARTUS_DEPS += $(QUARTUS_QPF) $(QUARTUS_QSF) $(QUARTUS_HDL_SOURCE) $(QUARTUS_MISC_SOURCE) $(QSYS_STAMP) $(QSYS_QIP) $(QUARTUS_PIN_ASSIGNMENTS_STAMP)

QUARTUS_SOF := output_files/$(QUARTUS_BASE).sof
QUARTUS_STAMP := $(call get_stamp_target,quartus)

.PHONY: quartus_compile
quartus_compile: $(QUARTUS_STAMP)

ifeq ($(HAVE_QUARTUS),1)
$(QUARTUS_SOF): $(QUARTUS_STAMP)
endif

$(QUARTUS_PIN_ASSIGNMENTS_STAMP): $(QSYS_STAMP)
	quartus_map $(QUARTUS_QPF)
	quartus_cdb --merge $(QUARTUS_QPF)
	$(MAKE) quartus_apply_tcl_pin_assignments QUARTUS_ENABLE_PIN_ASSIGNMENTS_APPLY=1
	$(stamp_target)

#######
# we need to recursively call this makefile to 
# apply *_pin_assignments.tcl script because the
# pin_assignment.tcl files may not exist yet 
# when makefile was originally called

ifeq ($(QUARTUS_ENABLE_PIN_ASSIGNMENTS_APPLY),1)

QUARTUS_TCL_PIN_ASSIGNMENTS = $(wildcard $(QSYS_BASE)/synthesis/submodules/*_pin_assignments.tcl) $(wildcard $(QSYS_BASE)/synth/submodules/*_pin_assignments.tcl)
QUARTUS_TCL_PIN_ASSIGNMENTS_APPLY_TARGETS = $(patsubst %,quartus_apply_tcl-%,$(QUARTUS_TCL_PIN_ASSIGNMENTS))

.PHONY: quartus_apply_tcl_pin_assignments
quartus_apply_tcl_pin_assignments: $(QUARTUS_TCL_PIN_ASSIGNMENTS_APPLY_TARGETS)

.PHONY: $(QUARTUS_TCL_PIN_ASSIGNMENTS_APPLY_TARGETS)
$(QUARTUS_TCL_PIN_ASSIGNMENTS_APPLY_TARGETS): quartus_apply_tcl-%: %
	@$(ECHO) "Applying $<... to $(QUARTUS_QPF)..."
	quartus_sta -t $< $(QUARTUS_QPF)

endif # QUARTUS_ENABLE_PIN_ASSIGNMENTS_APPLY == 1
######

$(QUARTUS_STAMP): $(QUARTUS_DEPS)
	quartus_stp $(QUARTUS_BASE)
	quartus_sh --flow compile $(QUARTUS_QPF)
	$(stamp_target)

HELP_TARGETS += quartus_edit
quartus_edit.HELP := Launch Quartus II GUI

ifneq ($(HAVE_QUARTUS),1)
quartus_edit.HELP := $(quartus_edit.HELP) (Install Quartus II Software to enable)
endif


.PHONY: quartus_edit
quartus_edit:
	quartus $(QUARTUS_QPF) &

HELP_TARGETS += sof
sof.HELP := QSys generate & Quartus compile this design
ifneq ($(HAVE_QUARTUS),1)
sof.HELP := $(sof.HELP) (Install Quartus II Software to enable)
endif

BATCH_TARGETS += sof

.PHONY: sof
sof: $(QUARTUS_SOF)


QUARTUS_RBF := $(patsubst %.sof,%.rbf,$(QUARTUS_SOF))
#
# This converts the sof into compressed, unencrypted 
# raw binary format corresponding to MSEL value of 8 
# in the FPGAMGRREGS_STAT register. If you read the 
# the whole register, it should be 0x50.
#
# CVSoC DevBoard SW1 MSEL should be set to up,down,up,down,up,up
#

ifeq ($(HAVE_QUARTUS),1)
$(QUARTUS_RBF): $(QUARTUS_STAMP)
endif

QUARTUS_CPF_ENABLE_COMPRESSION ?= 1
ifeq ($(QUARTUS_CPF_ENABLE_COMPRESSION),1)
QUARTUS_CPF_ARGS += -o bitstream_compression=on
endif

$(QUARTUS_RBF): %.rbf: %.sof
	quartus_cpf -c $(QUARTUS_CPF_ARGS) $< $@

.PHONY: rbf
rbf: $(QUARTUS_RBF)

.PHONY: create_rbf
create_rbf:
	quartus_cpf -c $(QUARTUS_CPF_ARGS) $(QUARTUS_SOF) $(QUARTUS_RBF)


ifeq ($(HAVE_QUARTUS),1)
SCRUB_CLEAN_FILES += $(QUARTUS_SOF) $(QUARTUS_RBF) output_files hps_isw_handoff
endif

################################################


################################################
# QSYS/Quartus Project Generation
#  - we don't run this generation step automatically because 
#    it will destroy any changes and/or customizations that 
#    you've made to your qsys or your quartus project
#
QSYS_QSYS_GEN := $(firstword $(wildcard create_*_qsys.tcl))
QUARTUS_TOP_GEN := $(firstword $(wildcard create_*_top.tcl))
QUARTUS_QSF_QPF_GEN := $(firstword $(wildcard create_*_quartus.tcl))

.PHONY: quartus_generate_qsf_qpf
ifneq ($(QUARTUS_QSF_QPF_GEN),)
quartus_generate_qsf_qpf: $(QUARTUS_QSF_QPF_GEN)
	$(RM) $(QUARTUS_QSF) $(QUARTUS_QPF)
	quartus_sh --script=$< $(QUARTUS_TCL_ARGS)
else
quartus_generate_qsf_qpf:
	@$(ECHO) "Make target '$@' is not supported for this design"
endif

.PHONY: quartus_generate_top
ifneq ($(QUARTUS_TOP_GEN),)
quartus_generate_top: $(QUARTUS_TOP_GEN)
	@$(RM) *_top.v
	quartus_sh --script=$< $(QUARTUS_TCL_ARGS)
else
quartus_generate_top:
	@$(ECHO) "Make target '$@' is not supported for this design"
endif

.PHONY: qsys_generate_qsys
ifneq ($(QSYS_QSYS_GEN),)

# Note that this target has a strange & known issue 
# that requires the Stratix V device family to be installed.
# If the stratix V device family is not installed then the target 
# will hang. This issue will hopefully be resolved in a future
# version of quartus/qsys.

qsys_generate_qsys: $(QSYS_QSYS_GEN)
	$(RM) $(QSYS_FILE)
	qsys-script --script=$< $(QSYS_TCL_ARGS)
else
qsys_generate_qsys:
	@$(ECHO) "Make target '$@' is not supported for this design"
endif
################################################


################################################
# Quartus Programming
QUARTUS_PGM_STAMP := $(call get_stamp_target,quartus_pgm)

# set these for your board
# BOARD_CABLE =

# FPGA Board Device Index. Default to 2 since this is the most
#  common setting for dev board
# For SoCKIT board, this should be set to 1
BOARD_DEVICE_INDEX ?= 2

define quartus_pgm_sof
jtagconfig
quartus_pgm --mode=jtag $(if $(BOARD_CABLE),--cable="$(BOARD_CABLE)") --operation=p\;$1$(if $(BOARD_DEVICE_INDEX),"@$(BOARD_DEVICE_INDEX)")
jtagconfig $(if $(BOARD_CABLE),-c "$(BOARD_CABLE)") -n
endef

.PHONY: pgm
pgm: $(QUARTUS_PGM_STAMP)

$(QUARTUS_PGM_STAMP): $(QUARTUS_SOF)
	$(call quartus_pgm_sof,$<)
	$(stamp_target)

HELP_TARGETS += program_fpga
program_fpga.HELP := Quartus program sof to your attached dev board

.PHONY: program_fpga
program_fpga:
	$(call quartus_pgm_sof,$(QUARTUS_SOF))


# HPS Device Index. Default to 1 since this is the most
#  common setting for dev board
BOARD_HPS_DEVICE_INDEX ?= 1

define quartus_hps_pgm_qspi
jtagconfig
quartus_hps $(if $(BOARD_CABLE),--cable="$(BOARD_CABLE)") $(if $(BOARD_HPS_DEVICE_INDEX),--device=$(BOARD_HPS_DEVICE_INDEX)) --operation=PV $1
endef

HELP_TARGETS += program_qspi
program_qspi.HELP := Flash program preloader into QSPI Flash

.PHONY: program_qspi
program_qspi: $(PRELOADER_DIR)/preloader-mkpimage.bin
	$(call quartus_hps_pgm_qspi,$<)


# GHRD HPS Reset Targets
ifneq ($(wildcard ghrd_reset.tcl),)
# use the already programmed fpga to reset the hps
HPS_RESET_TARGETS := hps_cold_reset hps_warm_reset hps_debug_reset

.PHONY: $(HPS_RESET_TARGETS) 
$(HPS_RESET_TARGETS): hps_%_reset:
	quartus_stp --script=ghrd_reset.tcl $(if $(BOARD_CABLE),--cable-name "$(BOARD_CABLE)") $(if $(BOARD_DEVICE_INDEX),--device-index "$(BOARD_DEVICE_INDEX)") --$*-reset
endif

################################################


################################################
# Preloader

QSYS_HPS_INST_NAME ?= hps_0

SBT.CREATE_SETTINGS := bsp-create-settings
SBT.GENERATE := bsp-generate-files

HELP_TARGETS += preloader
preloader.HELP := Build Preloader BSP for this design into $(PRELOADER_DIR) directory

PRELOADER_ID := hps_isw_handoff/$(QSYS_BASE)_$(QSYS_HPS_INST_NAME)/id
PRELOADER_DEPS += $(PRELOADER_ID)

ifeq ($(HAVE_QUARTUS),1)
PRELOADER_DEPS += $(QUARTUS_STAMP)

$(PRELOADER_ID): $(QUARTUS_STAMP) 
endif

PRELOADER_STAMP := $(call get_stamp_target,preloader)

PRELOADER_DISABLE_WATCHDOG ?= 1
ifeq ($(PRELOADER_DISABLE_WATCHDOG),1)
PRELOADER_EXTRA_ARGS += --set spl.boot.WATCHDOG_ENABLE false
endif

PRELOADER_ENABLE_ECC_SCRUBBING ?= 1
ifeq ($(PRELOADER_ENABLE_ECC_SCRUBBING),1)
# If enabled, we should scrub all 1GB of DDR. This may be overkill
PRELOADER_EXTRA_ARGS += \
	--set spl.boot.SDRAM_SCRUBBING true
endif


.PHONY: preloader
preloader: $(PRELOADER_STAMP)

# Create and build preloader with watchdog disabled.
# This is useful for board bring up and troubleshooting.
$(PRELOADER_STAMP): $(PRELOADER_DEPS)

	@$(MKDIR) $(PRELOADER_DIR)

	$(SBT.CREATE_SETTINGS) \
		--type spl \
		--bsp-dir $(PRELOADER_DIR) \
		--preloader-settings-dir "hps_isw_handoff/$(QSYS_BASE)_$(QSYS_HPS_INST_NAME)" \
		--settings $(PRELOADER_DIR)/settings.bsp \
		$(PRELOADER_EXTRA_ARGS)

	$(MAKE) -C $(PRELOADER_DIR)

	$(stamp_target)


UBOOT_STAMP := $(call get_stamp_target,uboot)

$(UBOOT_STAMP): $(PRELOADER_STAMP)
	$(MAKE) -C $(PRELOADER_DIR) uboot
	$(stamp_target)


ifeq ($(IS_WINDOWS_HOST),1)
EXE_EXT := .exe
endif
UBOOT_MKIMAGE := $(PRELOADER_DIR)/uboot-socfpga/tools/mkimage$(EXE_EXT)
AR_REGEX += $(UBOOT_MKIMAGE)


HELP_TARGETS += uboot
uboot.HELP := Build U-Boot into $(PRELOADER_DIR) directory

.PHONY: uboot
uboot: $(UBOOT_STAMP)


SCRUB_CLEAN_FILES += $(PRELOADER_DIR)

################################################


################################################
# Preloader/Uboot SD Card Programming

# Update the A2 Partition on your sd card with
# the preloader and uboot that build with this design

# These targets assume you have a pre-imaged sd card
# or an sd card *.img file 
# An example sd image for the Altera SoC Development
# Board can be found here:
# <soceds_install>/embeddedsw/socfpga/prebuilt_images

ALT_BOOT_DISK_UTIL := alt-boot-disk-util

ifeq ($(IS_WINDOWS_HOST),1)

ifeq ($(SDCARD),)
ifeq ($(SD_DRIVE_LETTER),)
GUESS_DRIVE_LETTER = $(firstword $(foreach drive_letter,d e f g h i j k l m n o p q r s t u v w x y z,$(if $(wildcard $(drive_letter):/zImage),$(drive_letter))))
SD_DRIVE_LETTER = $(GUESS_DRIVE_LETTER)
endif # SD_DRIVE_LETTER == <empty>
SDCARD ?= $(if $(SD_DRIVE_LETTER),-d $(SD_DRIVE_LETTER),$(error ERROR: SD_DRIVE_LETTER not specified. Try "make $(MAKECMDGOALS) SD_DRIVE_LETTER=[sd_card_windows_drive_letter]"))
endif # SDCARD == <empty>

else # if not a Windows Host

SDCARD ?= $(error ERROR: SD Card not specified. Try "make $(MAKECMDGOALS) SDCARD=/dev/sdX", where X represents your target SD Card device)

endif

PRELOADER_BIN ?= $(PRELOADER_DIR)/preloader-mkpimage.bin

.PHONY: sd-update-preloader
sd-update-preloader: $(PRELOADER_BIN)
	$(ALT_BOOT_DISK_UTIL) -p $< -a write $(SDCARD)

NEXTSTAGE_BIN ?= $(PRELOADER_DIR)/uboot-socfpga/u-boot.img

.PHONY: sd-update-uboot
sd-update-uboot: $(NEXTSTAGE_BIN)
	$(ALT_BOOT_DISK_UTIL) -b $< -a write $(SDCARD)

sd-update-preloader-uboot: sd-update-preloader sd-update-uboot

################################################


################################################
# Device Tree

DTS.SOPC2DTS := sopc2dts
DTS.DTC := dtc

DTS.BOARDINFO ?= $(QSYS_BASE)_board_info.xml
DTS.COMMON ?= hps_common_board_info.xml

DTS.EXTRA_DEPS += $(DTS.BOARDINFO) $(DTS.COMMON)

DTS.SOPC2DTS_ARGS += $(if $(DTS.BOARDINFO),--board $(DTS.BOARDINFO))
DTS.SOPC2DTS_ARGS += $(if $(DTS.COMMON),--board $(DTS.COMMON))
DTS.SOPC2DTS_ARGS += --bridge-removal all
DTS.SOPC2DTS_ARGS += --clocks

define dts.sopc2dts
$(if $(DTS.BOARDINFO),,$(warning WARNING: DTS BoardInfo file was not specified or found))
$(DTS.SOPC2DTS) --input $1 --output $2 $3 $(DTS.SOPC2DTS_ARGS)
endef


# Device Tree Source (dts)
DEVICE_TREE_SOURCE := $(patsubst %.sopcinfo,%.dts,$(QSYS_SOPCINFO))

HELP_TARGETS += dts
dts.HELP := Generate a device tree for this qsys design

.PHONY: dts
dts: $(DEVICE_TREE_SOURCE)

ifeq ($(HAVE_QSYS),1)
$(DEVICE_TREE_SOURCE): $(QSYS_STAMP)
endif

$(DEVICE_TREE_SOURCE): %.dts: %.sopcinfo $(DTS.EXTRA_DEPS)
	$(call dts.sopc2dts,$<,$@)


# Device Tree Blob (dtb)
DEVICE_TREE_BLOB := $(patsubst %.sopcinfo,%.dtb,$(QSYS_SOPCINFO))

HELP_TARGETS += dtb
dtb.HELP := Generate a device tree blob for this qsys design

.PHONY: dtb
dtb: $(DEVICE_TREE_BLOB)

ifeq ($(HAVE_QSYS),1)
$(DEVICE_TREE_BLOB): $(QSYS_STAMP)
endif

$(DEVICE_TREE_BLOB): %.dtb: %.dts
	$(DTS.DTC) -I dts -O dtb -o $@ $<

SCRUB_CLEAN_FILES += $(DEVICE_TREE_SOURCE) $(DEVICE_TREE_BLOB)

################################################


################################################
boot.script: Makefile
	@$(RM) $@
	@$(ECHO) "Generating $@"
	@$(ECHO) "fatload mmc 0:1 \$$fpgadata $(QUARTUS_RBF);" >>$@
	@$(ECHO) "fpga load 0 \$$fpgadata \$$filesize;" >>$@
	@$(ECHO) "setenv fdtimage $(DEVICE_TREE_BLOB);" >>$@
	@$(ECHO) "run bridge_enable_handoff;" >>$@
	@$(ECHO) "run mmcload;" >>$@
	@$(ECHO) "run mmcboot;" >>$@

ifeq ($(wildcard $(UBOOT_MKIMAGE)),)
$(UBOOT_MKIMAGE): $(PRELOADER_STAMP)
endif

u-boot.scr: boot.script $(UBOOT_MKIMAGE)
	$(UBOOT_MKIMAGE) -A arm -O linux -T script -C none -a 0 -e 0 -n "bootscript" -d $< $@

SD_FAT_TGZ ?= sd_fat.tar.gz
SD_FAT_TGZ_DEPS += u-boot.scr boot.script $(QUARTUS_RBF) $(DEVICE_TREE_BLOB)

$(SD_FAT_TGZ): $(SD_FAT_TGZ_DEPS)
	@$(RM) $@
	@$(MKDIR) $(@D)
	$(TAR) -czf $@ $^

.PHONY: sd-fat
sd-fat: $(SD_FAT_TGZ)

AR_FILES += $(wildcard $(SD_FAT_TGZ))

SCRUB_CLEAN_FILES += $(SD_FAT_TGZ)

################################################


################################################
# Clean-up and Archive

AR_FILES += $(filter-out $(AR_FILTER_OUT),$(wildcard $(AR_REGEX)))

CLEAN_FILES += $(filter-out $(AR_DIR) $(AR_FILES),$(wildcard *))

HELP_TARGETS += tgz
tgz.HELP := Create a tarball with the barebones source files that comprise this design

.PHONY: tarball tgz
tarball tgz: $(AR_FILE)

$(AR_FILE):
	@$(MKDIR) $(@D)
	@$(if $(wildcard $(@D)/*.tar.gz),$(MKDIR) $(@D)/.archive;$(MV) $(@D)/*.tar.gz $(@D)/.archive)
	@$(ECHO) "Generating $@..."
	@$(TAR) -czf $@ $(AR_FILES)

SCRUB_CLEAN_FILES += $(CLEAN_FILES)

HELP_TARGETS += scrub_clean
scrub_clean.HELP := Restore design to its barebones state

.PHONY: scrub scrub_clean
scrub scrub_clean:
	$(if $(strip $(wildcard $(SCRUB_CLEAN_FILES))),$(RM) $(wildcard $(SCRUB_CLEAN_FILES)),@$(ECHO) "You're already as clean as it gets!")

.PHONY: tgz_scrub_clean
tgz_scrub_clean:
	$(FIND) $(SOFTWARE_DIR) \( -name '*.o' -o -name '.depend*' -o -name '*.d' -o -name '*.dep' \) -delete || true
	$(MAKE) tgz AR_FILE=$(AR_FILE)
	$(MAKE) -s scrub_clean
	$(TAR) -xzf $(AR_FILE)

################################################


################################################
# Running Batch Jobs
ifneq ($(BATCH_TARGETS),)

BATCH_DIR := $(if $(TMP),$(TMP)/)batch/$(AR_TIMESTAMP)

.PHONY: $(patsubst %,batch-%,$(BATCH_TARGETS))
$(patsubst %,batch-%,$(BATCH_TARGETS)): batch-%: $(AR_FILE)
	@$(RM) $(BATCH_DIR)
	@$(MKDIR) $(BATCH_DIR)
	$(CP) $< $(BATCH_DIR) 
	$(CD) $(BATCH_DIR) && $(TAR) -xzf $(notdir $<) && $(CHMOD) -R 755 *
	$(MAKE) -C $(BATCH_DIR) $*

endif # BATCH_TARGETS != <empty>
################################################


################################################
# Help system

HELP_TARGETS += help
help.HELP := Displays this info (i.e. the available targets)

.PHONY: help
help: help-init help-targets help-fini

HELP_TARGETS_X := $(patsubst %,help-%,$(sort $(HELP_TARGETS)))
.PHONY: $(HELP_TARGETS_X)
help-targets: $(HELP_TARGETS_X)
$(HELP_TARGETS_X): help-%:
	@$(ECHO) "*********************"
	@$(ECHO) "* Target: $*"
	@$(ECHO) "*   $($*.HELP)"

.PHONY: help-init
help-init:
	@$(ECHO) "*****************************************"
	@$(ECHO) "*                                       *"
	@$(ECHO) "* Manage QuartusII/QSys design          *"
	@$(ECHO) "*                                       *"
	@$(ECHO) "*     Copyright (c) 2016                *"
	@$(ECHO) "*     All Rights Reserved               *"
	@$(ECHO) "*                                       *"
	@$(ECHO) "*****************************************"
	@$(ECHO) ""

.PHONY: help-fini
help-fini:
	@$(ECHO) "*********************"

################################################
