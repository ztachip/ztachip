
################################################################
# This is a generated script based on design: crossbar
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source crossbar_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name crossbar

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set APB_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:apb_rtl:1.0 APB_0 ]

  set CAMERA_IN [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 CAMERA_IN ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {25000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $CAMERA_IN

  set DBUS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 DBUS ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {166000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {1} \
   CONFIG.MAX_BURST_LENGTH {16} \
   CONFIG.NUM_READ_OUTSTANDING {64} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {64} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $DBUS

  set IBUS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 IBUS ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {166000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {1} \
   CONFIG.MAX_BURST_LENGTH {16} \
   CONFIG.NUM_READ_OUTSTANDING {64} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {64} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_ONLY} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $IBUS

  set SDRAM [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 SDRAM ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.CLK_DOMAIN {crossbar_SDRAM_CLOCK} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {166000000} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {64} \
   CONFIG.NUM_WRITE_OUTSTANDING {64} \
   CONFIG.PROTOCOL {AXI4} \
   ] $SDRAM

  set VIDEO_OUT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 VIDEO_OUT ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {25000000} \
   ] $VIDEO_OUT

  set ZTA_CONTROL [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 ZTA_CONTROL ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {166000000} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {64} \
   CONFIG.NUM_WRITE_OUTSTANDING {64} \
   CONFIG.PROTOCOL {AXI4} \
   ] $ZTA_CONTROL

  set ZTA_DATA [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 ZTA_DATA ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {166000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {1} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {64} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {64} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $ZTA_DATA


  # Create ports
  set ARESETN [ create_bd_port -dir I -type rst ARESETN ]
  set CAMERA_CLOCK_IN [ create_bd_port -dir I -type clk -freq_hz 25000000 CAMERA_CLOCK_IN ]
  set CLOCK [ create_bd_port -dir I -type clk -freq_hz 166000000 CLOCK ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {IBUS:DBUS:ZTA_CONTROL:ZTA_DATA} \
 ] $CLOCK
  set SDRAM_CLOCK [ create_bd_port -dir I -type clk -freq_hz 166000000 SDRAM_CLOCK ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {SDRAM} \
   CONFIG.CLK_DOMAIN {crossbar_SDRAM_CLOCK} \
 ] $SDRAM_CLOCK
  set VIDEO_CLOCK [ create_bd_port -dir I -type clk -freq_hz 25000000 VIDEO_CLOCK ]

  # Create instance: axi_apb_bridge_0, and set properties
  set axi_apb_bridge_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_apb_bridge:3.0 axi_apb_bridge_0 ]
  set_property -dict [ list \
   CONFIG.C_APB_NUM_SLAVES {1} \
 ] $axi_apb_bridge_0

  # Create instance: axi_vdma_0, and set properties
  set axi_vdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.3 axi_vdma_0 ]
  set_property -dict [ list \
   CONFIG.c_m_axi_mm2s_data_width {32} \
   CONFIG.c_m_axi_s2mm_data_width {32} \
   CONFIG.c_mm2s_genlock_mode {0} \
   CONFIG.c_mm2s_linebuffer_depth {2048} \
   CONFIG.c_mm2s_max_burst_length {8} \
   CONFIG.c_num_fstores {8} \
   CONFIG.c_s2mm_genlock_mode {0} \
   CONFIG.c_s2mm_linebuffer_depth {1024} \
   CONFIG.c_use_s2mm_fsync {0} \
 ] $axi_vdma_0

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_MI {4} \
   CONFIG.NUM_SI {5} \
 ] $smartconnect_0

  # Create interface connections
  connect_bd_intf_net -intf_net CAMERA_IN_1 [get_bd_intf_ports CAMERA_IN] [get_bd_intf_pins axi_vdma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net DBUS_1 [get_bd_intf_ports DBUS] [get_bd_intf_pins smartconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net IBUS_1 [get_bd_intf_ports IBUS] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net ZTA_DATA_1 [get_bd_intf_ports ZTA_DATA] [get_bd_intf_pins smartconnect_0/S04_AXI]
  connect_bd_intf_net -intf_net axi_apb_bridge_0_APB_M [get_bd_intf_ports APB_0] [get_bd_intf_pins axi_apb_bridge_0/APB_M]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXIS_MM2S [get_bd_intf_ports VIDEO_OUT] [get_bd_intf_pins axi_vdma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_MM2S [get_bd_intf_pins axi_vdma_0/M_AXI_MM2S] [get_bd_intf_pins smartconnect_0/S02_AXI]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_S2MM [get_bd_intf_pins axi_vdma_0/M_AXI_S2MM] [get_bd_intf_pins smartconnect_0/S03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_ports SDRAM] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins axi_apb_bridge_0/AXI4_LITE] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins axi_vdma_0/S_AXI_LITE] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_ports ZTA_CONTROL] [get_bd_intf_pins smartconnect_0/M03_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_ports ARESETN] [get_bd_pins axi_apb_bridge_0/s_axi_aresetn] [get_bd_pins axi_vdma_0/axi_resetn] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net CAMERA_CLOCK_IN_1 [get_bd_ports CAMERA_CLOCK_IN] [get_bd_pins axi_vdma_0/s_axis_s2mm_aclk]
  connect_bd_net -net CLOCK_1 [get_bd_ports CLOCK] [get_bd_pins axi_apb_bridge_0/s_axi_aclk] [get_bd_pins axi_vdma_0/m_axi_mm2s_aclk] [get_bd_pins axi_vdma_0/m_axi_s2mm_aclk] [get_bd_pins axi_vdma_0/s_axi_lite_aclk] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net SDRAM_CLOCK_1 [get_bd_ports SDRAM_CLOCK] [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net VIDEO_CLOCK_1 [get_bd_ports VIDEO_CLOCK] [get_bd_pins axi_vdma_0/m_axis_mm2s_aclk]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_MM2S] [get_bd_addr_segs SDRAM/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_S2MM] [get_bd_addr_segs SDRAM/Reg] -force
  assign_bd_address -offset 0xF4000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DBUS] [get_bd_addr_segs APB_0/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces IBUS] [get_bd_addr_segs SDRAM/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces DBUS] [get_bd_addr_segs SDRAM/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces ZTA_DATA] [get_bd_addr_segs SDRAM/Reg] -force
  assign_bd_address -offset 0xF2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DBUS] [get_bd_addr_segs ZTA_CONTROL/Reg] -force
  assign_bd_address -offset 0xF1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DBUS] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0xF4000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces IBUS] [get_bd_addr_segs APB_0/Reg]
  exclude_bd_addr_seg -offset 0xF2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces IBUS] [get_bd_addr_segs ZTA_CONTROL/Reg]
  exclude_bd_addr_seg -offset 0xF1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces IBUS] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0xF4000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZTA_DATA] [get_bd_addr_segs APB_0/Reg]
  exclude_bd_addr_seg -offset 0xF2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZTA_DATA] [get_bd_addr_segs ZTA_CONTROL/Reg]
  exclude_bd_addr_seg -offset 0xF1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ZTA_DATA] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0xF4000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_MM2S] [get_bd_addr_segs APB_0/Reg]
  exclude_bd_addr_seg -offset 0xF2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_MM2S] [get_bd_addr_segs ZTA_CONTROL/Reg]
  exclude_bd_addr_seg -offset 0xF1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_MM2S] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg]
  exclude_bd_addr_seg -offset 0xF4000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_S2MM] [get_bd_addr_segs APB_0/Reg]
  exclude_bd_addr_seg -offset 0xF2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_S2MM] [get_bd_addr_segs ZTA_CONTROL/Reg]
  exclude_bd_addr_seg -offset 0xF1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces axi_vdma_0/Data_S2MM] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


