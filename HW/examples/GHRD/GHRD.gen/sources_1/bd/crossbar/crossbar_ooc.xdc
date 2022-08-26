################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name CLOCK -period 6.024 [get_ports CLOCK]
create_clock -name VIDEO_CLOCK -period 40 [get_ports VIDEO_CLOCK]
create_clock -name CAMERA_CLOCK_IN -period 40 [get_ports CAMERA_CLOCK_IN]
create_clock -name SDRAM_CLOCK -period 6.024 [get_ports SDRAM_CLOCK]

################################################################################