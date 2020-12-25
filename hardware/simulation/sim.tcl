############################################################################
## Copyright [2014] [Ztachip Technologies Inc]
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
############################################################################

################################################################################################
#
# This module provides the necessary interface to run ztachip in simulation
# API procedures:
#    - ztaInit          : Calls this procedure to initialize ztachip
#    - ztaMemWriteInt   :  Write an integer value to simulated DDR memory
#    - ztaMemWriteFloat : Write a float to simulated DDR memory
#    - ztaMemReadInt    : Read an integer from simulated DDR memory
#    - ztaMemReadFloat  : Read a float from simulated DDR memory
#    - ztaMsgWriteInt   : Put an integer to the message queue
#    - ztaMsgWriteFloat : Put a float to the message queue
#    - ztaMsgReadInt    : Read an integer from the message queue. Keep on polling if not available
#    - ztaMsgReadFloat  : Read a float from the message queue. Keep on polling if not available
#
################################################################################################

#### Global constants

set CLOCK_PERIOD        100
set AVALON_BUS_WIDTH    17
set REGISTER_SIZE       32

#### Register ID #######

set REG_SOFT_RESET          15
set REG_MSGQ_READ           16
set REG_MSGQ_READ_AVAIL     17
set REG_MSGQ_WRITE          18
set REG_MSGQ_WRITE_AVAIL    19
set REG_SWDL_COMPLETE_READ  20
set REG_SWDL_COMPLETE_CLEAR 21
set REG_SERIAL_READ         26
set REG_SERIAL_READ_AVAIL   28 
set REG_LOOKUP_ADDR         6
set REG_LOOKUP_VALUE        7  
set REG_LOOKUP_COEFFICIENT  4   



#### ztachip memory map 

## pcode code space
proc PROG_PCODE {addr} {
	variable AVALON_BUS_WIDTH
	return [expr (1 << [expr $AVALON_BUS_WIDTH-2])+$addr]
}

## mcore code space
proc PROG_MCODE {addr} {
	variable AVALON_BUS_WIDTH
	return [expr (2 << [expr $AVALON_BUS_WIDTH-2])+$addr]
}

## mcore data space
proc PROG_MDATA {addr} {
	variable AVALON_BUS_WIDTH
	return [expr (3 << [expr $AVALON_BUS_WIDTH-2])+$addr]
}

## registers
proc GREG {subreg reg} {
	variable AVALON_BUS_WIDTH
	return [expr (0 << [expr $AVALON_BUS_WIDTH-2])+($subreg << 5) + $reg]
}

##### Utilities to convert between binary and integer/float #######

proc dec2bin {num count} {
    #returns a string, e.g. dec2bin 10 => 1010 
    set res {} 
	for {set i 0} {$i < $count} {incr i} {
        set res [expr {$num%2}]$res
        set num [expr {$num/2}]
    }
    if {$res == {}} {set res 0}
    return $res
}

proc bin2dec {bin} {
    if {$bin == 0} {
        return 0 
    } elseif  {[string match -* $bin]} {
        set sign -
        set bin [string range $bin 1 end]
    } else {
        set sign {}
    }
    if {[string map [list 1 {} 0 {}] $bin] ne {}} {
        error "argument is not in base 2: $bin"
    }
    set r 0
    foreach d [split $bin {}] {
        incr r $r
        incr r $d
    }
    return $sign$r
}

proc __reverse__ {s} {
    for {set i [string length $s]} {$i >= 0} {incr i -1} {
        append sr [string index $s $i]
    }
    return $sr
}

proc float2bin {d} {
    binary scan [binary format d $d] b* v
    set v [__reverse__ $v]
    set sign [string index $v 0]
    set exponent [string range $v 1 1][string range $v 5 11]
    set mantissa [string range $v 12 34]
    return $sign$exponent$mantissa
}

proc bin2float {bin} {
    set sign [string index $bin 0]
    set lead_exponent [string range $bin 1 1]
    set exponent [string range $bin 2 8]
    set mantissa [string range $bin 9 31]
    if {[string index $bin 2] == "0"} {
        set exponent_ext "000"
    } else {
        set exponent_ext "111"
    }
    set mantissa_ext "00000000000000000000000000000"

    set v [binary format b64 [__reverse__ $sign$lead_exponent$exponent_ext$exponent$mantissa$mantissa_ext]]
    binary scan $v d v
    return $v
}

##### Utilities to read/write to avalon bus

proc avalon_write {addr val} {
	variable AVALON_BUS_WIDTH
	force -deposit sim:/testbench/avalon_bus_addr_in [dec2bin $addr $AVALON_BUS_WIDTH]
	force -deposit sim:/testbench/avalon_bus_write_in 1
	force -deposit sim:/testbench/avalon_bus_writedata_in [dec2bin $val 32]
	run 100
	force -deposit sim:/testbench/avalon_bus_addr_in 00000000000000000
	force -deposit sim:/testbench/avalon_bus_write_in 0
	force -deposit sim:/testbench/avalon_bus_writedata_in 00000000000000000000000000000000
    run 600
}

proc avalon_write_float {addr val} {
	variable AVALON_BUS_WIDTH
	force -deposit sim:/testbench/avalon_bus_addr_in [dec2bin $addr $AVALON_BUS_WIDTH]
	force -deposit sim:/testbench/avalon_bus_write_in 1
	force -deposit sim:/testbench/avalon_bus_writedata_in [float2bin $val]
	run 100
	force -deposit sim:/testbench/avalon_bus_addr_in 00000000000000000
	force -deposit sim:/testbench/avalon_bus_write_in 0
	force -deposit sim:/testbench/avalon_bus_writedata_in 00000000000000000000000000000000
    run 500
}

proc avalon_read {addr} {
	variable AVALON_BUS_WIDTH
	variable now
	variable CLOCK_PERIOD
	force -deposit sim:/testbench/avalon_bus_addr_in [dec2bin $addr $AVALON_BUS_WIDTH]
	force -deposit sim:/testbench/avalon_bus_read_in 1
	run 1500
	force -deposit sim:/testbench/avalon_bus_read_in 0
	run 200
	set read_value [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/avalon_bus_readdata_out]
	force -deposit sim:/testbench/avalon_bus_addr_in 00000000000000000
	force -deposit sim:/testbench/avalon_bus_read_in 0
	return $read_value
}

######
## Load program to PCORE
######

proc program_pcore {filename} {
   puts "Program PCORE"
   set fp [open $filename r]
   gets $fp line

   while {$line != ".CONSTANT BEGIN"} {
      gets $fp line
   }
   gets $fp line
   set count 0
   set count2 0
   set i 4000
   while {$line != ".CONSTANT END"} {
      scan $line "%08x" v
      ztaMemWriteInt16 [expr ($i)] $v
      set i [expr $i+2]
      set count [expr $count+1]
      gets $fp line
   }
   close $fp

   ### DOWNLOAD PCORE ...
 
   set fp [open $filename r]
   set addr2 5000
   gets $fp line
   while {$line != ".CODE BEGIN"} {
      gets $fp line
   }
   gets $fp line

   while {$line != ""} {
      scan $line ":%02x%04x%02x%08x%02x" tag addr dummy1 instruction dummy2
      if {$tag==0} {
         break;
      }
      ztaMemWriteInt32 [expr $addr2] [expr $instruction]
      set addr2 [expr $addr2+4]
      set count2 [expr $count2+1]
      gets $fp line
   }
   close $fp

   ### Set message to MCORE
   ztaMsgWriteInt 0x4
   ztaMsgWriteInt 0
   ztaMsgWriteInt $count
   ztaMsgWriteInt [expr 4000]
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0

   ztaMsgWriteInt [expr ($count2*2)]
   ztaMsgWriteInt [expr 5000]
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt 0
   ztaMsgWriteInt [expr 0]
   puts "Program pcore done"
}

########
## Load program/data to MCORE
########

proc program_mcore {filename} {
   variable REG_SOFT_RESET
   set fp [open $filename r]
   gets $fp line
   while {$line != ".MAIN BEGIN"} {
      gets $fp line
   }
   puts "Load mcore begin"
   gets $fp line
   set is_prog 0
   set base 0
   avalon_write [GREG 0 $REG_SOFT_RESET] 0
   run 1000

   avalon_write [PROG_MCODE 0] 0
   avalon_write [PROG_MCODE 1] 0
   avalon_write [PROG_MCODE 2] 0
   avalon_write [PROG_MCODE 3] 0

   while {$line != ""} {
      if {[string compare -length 3 $line ":00"]==0} 	{
         set count 0
         break;
      } elseif {[string compare -length 3 $line ":02"]==0} {
         scan $line ":%02x%04x%02x%04x%02x" tag addr dummy1 instruction1 dummy2
         set count 0
      } elseif {[string compare -length 3 $line ":04"]==0} {
         scan $line ":%02x%04x%02x%08x%02x" tag addr dummy1 instruction1 dummy2
         set count 1
      } elseif {[string compare -length 3 $line ":08"]==0} {
         scan $line ":%02x%04x%02x%08x%08x%02x" tag addr dummy1 instruction1 instruction2 dummy2
         set count 2
      } elseif {[string compare -length 3 $line ":0C"]==0} {
         scan $line ":%02x%04x%02x%08x%08x%08x%02x" tag addr dummy1 instruction1 instruction2 instruction3 dummy2
         set count 3
      } else {
         scan $line ":%02x%04x%02x%08x%08x%08x%08x%02x" tag addr dummy1 instruction1 instruction2 instruction3 instruction4 dummy2
         set count 4
      }
      if {$dummy1==0} {
         if {$is_prog==1} {
            if {$base < 0x00F8} {
               if {$count==1} {
                  avalon_write [PROG_MCODE $addr/4] $instruction1
               } elseif {$count==2} {
                  avalon_write [PROG_MCODE $addr/4] $instruction1
                  avalon_write [PROG_MCODE $addr/4+1] $instruction2
               } elseif {$count==3} {
                  avalon_write [PROG_MCODE $addr/4] $instruction1
                  avalon_write [PROG_MCODE $addr/4+1] $instruction2
                  avalon_write [PROG_MCODE $addr/4+2] $instruction3
               } elseif {$count==4} {
                  avalon_write [PROG_MCODE $addr/4] $instruction1
                  avalon_write [PROG_MCODE $addr/4+1] $instruction2
                  avalon_write [PROG_MCODE $addr/4+2] $instruction3
                  avalon_write [PROG_MCODE $addr/4+3] $instruction4
               }
            }
         } else {
            if {$count==1} {
               avalon_write [PROG_MDATA $addr/4] $instruction1
            } elseif {$count==2} {
               avalon_write [PROG_MDATA $addr/4] $instruction1
               avalon_write [PROG_MDATA $addr/4+1] $instruction2
            } elseif {$count==3} {
               avalon_write [PROG_MDATA $addr/4] $instruction1
               avalon_write [PROG_MDATA $addr/4+1] $instruction2
               avalon_write [PROG_MDATA $addr/4+2] $instruction3
            } elseif {$count==4} {
               avalon_write [PROG_MDATA $addr/4] $instruction1
               avalon_write [PROG_MDATA $addr/4+1] $instruction2
               avalon_write [PROG_MDATA $addr/4+2] $instruction3
               avalon_write [PROG_MDATA $addr/4+3] $instruction4
            }
         }
      } elseif {$dummy1==4} {
         set is_prog 1
         set base $instruction1
      }
      gets $fp line
   }
   close $fp
   puts "Program mcore done"
   run 1000
   avalon_write [GREG 0 $REG_SOFT_RESET] 1
   run 1000
}


###############################################################
# ztaInit
#   Calls this procedure to initialize ztachip
#   Download code to PCORE/MCORE
#   Do softreset
# Parameters:
#   mcore_fname: mcore hex file name
# Return value:
#   None
###############################################################

proc ztaInit {fname} {
variable CLOCK_PERIOD
restart -f
delete wave *
add wave -position insertpoint  \
sim:/testbench/clock_in \
sim:/testbench/clock_x2_in \
sim:/testbench/ddr_error_r \
sim:/testbench/ztachip_i/dp_1_i/task_busy_in \
sim:/testbench/ztachip_i/dp_1_i/task_busy_in \
sim:/testbench/ztachip_i/dp_1_i/task_ready_in \
sim:/testbench/ztachip_i/dp_1_i/task_busy_out \
sim:/testbench/ztachip_i/dp_1_i/task \
sim:/testbench/ztachip_i/dp_1_i/task_out \
sim:/testbench/ztachip_i/ddr_read_wait_2 \
sim:/testbench/ztachip_i/ddr_read_wait \
sim:/testbench/ztachip_i/ddr_read_enable \
sim:/testbench/ztachip_i/ddr_data_ready \
sim:/testbench/ztachip_i/ddr_data_wait \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/ialu_i/x1_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/ialu_i/x2_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/ialu_i/y_out \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_en_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_en_out \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_x1_vector_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_x1_addr_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_x2_vector_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_x2_addr_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_x1_data_out \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/rd_x2_data_out \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/wr_en_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/wr_vector_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/wr_data_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/dp_rd_addr_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/dp_read_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/dp_readdata_out \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/dp_readena_out \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/dp_wr_addr_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/dp_write_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(0)/GEN1/pcore_i/register_bank_i/dp_writedata_in \
sim:/testbench/ztachip_i/core_i/GEN_CELL(0)/cell_i/GEN_REG(1)/GEN1/pcore_i/register_bank_i/dp_writedata_in \
sim:/testbench/ztachip_i/avalon_bus_addr_in \
sim:/testbench/ztachip_i/avalon_bus_write_in \
sim:/testbench/ztachip_i/avalon_bus_writedata_in \
sim:/testbench/ztachip_i/avalon_bus_readdata_out \
sim:/testbench/ztachip_i/avalon_bus_wait_request_out \
sim:/testbench/ztachip_i/avalon_bus_read_in \
sim:/testbench/address \
sim:/testbench/ddr_readdata \
sim:/testbench/ddr_writedata \
sim:/testbench/address2 \
sim:/testbench/ddr_write_in \
sim:/testbench/byteenable2 \
sim:/testbench/address \
sim:/testbench/burstbegin \
sim:/testbench/address \
sim:/testbench/address_r \
sim:/testbench/read_r \
sim:/testbench/write_r \
sim:/testbench/ztachip_i/avalon_bus_addr_in \
sim:/testbench/ztachip_i/avalon_bus_read_in \
sim:/testbench/ztachip_i/avalon_bus_readdata_out \
sim:/testbench/ztachip_i/avalon_bus_wait_request_out \
sim:/testbench/ztachip_i/avalon_bus_write_in \
sim:/testbench/ztachip_i/avalon_bus_writedata_in \
sim:/testbench/ztachip_i/indication_avail_out \
sim:/testbench/ztachip_i/dp_1_i/task_busy_in \
sim:/testbench/ztachip_i/dp_1_i/task_out \
sim:/testbench/ztachip_i/dp_1_i/task_pcore_out \
sim:/testbench/ztachip_i/dp_1_i/task_vm_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/task_busy_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_read_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_addr_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_burstlen_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_read_vector_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_readdatavalid_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_readdatavalid_vm_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_readdata_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster3_wait_request_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster3_write_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster3_write_vector_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster3_addr_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster3_writedata_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster3_wait_request_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster3_burstlen_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster2_read_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster2_read_vector_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster2_readdatavalid_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster2_readdatavalid_vm_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster2_readdata_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster2_wait_request_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster2_write_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster2_write_vector_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster2_write_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster2_addr_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster2_writedata_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster2_wait_request_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster2_burstlen_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_read_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_addr_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_read_data_flow_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_read_vector_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_read_scatter_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_readdatavalid_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_readdatavalid_vm_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_readdata_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/readmaster1_wait_request_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_wait_request_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_write_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_write_vector_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_write_scatter_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_write_data_flow_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_wait_request_in \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_writedata_out \
sim:/testbench/ztachip_i/dp_1_i/dp0_i/writemaster1_addr_out \
sim:/testbench/ztachip_i/core_i/dp_writedata_in \
sim:/testbench/ztachip_i/core_i/dp_write_in \
sim:/testbench/ztachip_i/core_i/dp_wr_addr_in \
sim:/testbench/ztachip_i/core_i/dp_read_data_flow_in \
sim:/testbench/ztachip_i/core_i/dp_read_data_flow \
sim:/testbench/ztachip_i/core_i/dp_read_data_flow_r \
sim:/testbench/ztachip_i/core_i/dp_read_data_type \
sim:/testbench/ztachip_i/core_i/dp_readdata2_r \
sim:/testbench/ztachip_i/core_i/dp_readdata \
sim:/testbench/ddr_writedata \
sim:/testbench/ddr_addr_in \
sim:/testbench/ddr_read_in \
sim:/testbench/ddr_readdata_out \
sim:/testbench/ddr_readdata \
sim:/testbench/ddr_write_in \
sim:/testbench/ddr_writedata_in 

force -deposit /avalon_bus_addr_in 00000000000000000
force -deposit /avalon_bus_write_in 0
force -deposit /avalon_bus_writedata_in 00000000000000000000000000000000
force -deposit /avalon_bus_read_in 0
force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
force -deposit sim:/testbench/ddr_write_in 0
force -deposit sim:/testbench/ddr_read_in 0

force -freeze sim:/clock_x2_in 1 0, 0 [expr $CLOCK_PERIOD/4] -r [expr $CLOCK_PERIOD/2]
force -freeze sim:/clock_in 1 0, 0 [expr $CLOCK_PERIOD/2] -r $CLOCK_PERIOD
run 1000
force -deposit /reset_in 0
run 1000
force -deposit /reset_in 1
run 1000

#### Start the test #############################


program_mcore $fname

run 1000

program_pcore $fname
}

###############################################################
# ztaMemWriteInt
#   Provided testbench includes a simulated DDR memory region
#   Write an integer value to this DDR memory
# Parameters:
#   addr: byte address
#   val: Integer value to be written to DDR
# Return value:
#   None
###############################################################

proc ztaMemWriteInt {addr val} {
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 16 31]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 0000000000000000
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+2] 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 0 15]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 0000000000000000
	run 100
}

proc ztaMemWriteShort {addr val} {
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 16 31]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 0000000000000000
	run 100
}

###############################################################
# ztaMemWriteInt32
#   Provided testbench includes a simulated DDR memory region
#   Write an integer value to this DDR memory
# Parameters:
#   addr: byte address
#   val: Int16 value to be written to DDR. This is for INTEGER core
# Return value:
#   None
###############################################################

proc ztaMemWriteInt32 {addr val} {
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 24 31]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 00000000
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+1] 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 16 23]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 00000000
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+2] 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 8 15]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 00000000
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+3] 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 0 7]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 00000000
	run 100
}


###############################################################
# ztaMemWriteInt16
#   Provided testbench includes a simulated DDR memory region
#   Write an integer value to this DDR memory
# Parameters:
#   addr: byte address
#   val: Int16 value to be written to DDR. This is for INTEGER core
# Return value:
#   None
###############################################################

proc ztaMemWriteInt16 {addr val} {
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 24 31]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 00000000
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+1] 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 16 23]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 00000000
	run 100
}


###############################################################
# ztaMemWriteInt8
#   Provided testbench includes a simulated DDR memory region
#   Write an integer value to this DDR memory
# Parameters:
#   addr: byte address
#   val: Int8 value to be written to DDR. This is for INTEGER core
# Return value:
#   None
###############################################################

proc ztaMemWriteInt8 {addr val} {
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [dec2bin $val 32] 24 31]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 00000000
	run 100
}

###############################################################
# ztaMemWriteFloat
#   Provided testbench includes a simulated DDR memory region
#   Write a float value to this DDR memory
# Parameters:
#   addr: byte address
#   val: Float value to be written to DDR
# Return value:
#   None
###############################################################

proc ztaMemWriteFloat {addr val} {
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [float2bin $val] 16 31]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 0000000000000000
	run 100
	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+2] 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range [float2bin $val] 0 15]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 0000000000000000
	run 100
}

proc ztaMemWriteHalf {addr val} {
    set v [float2bin $val]
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_write_in 1
	force -deposit sim:/testbench/ddr_writedata_in [string range $v 0 1][string range $v 5 18]
	run 100
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_write_in 0
	force -deposit sim:/testbench/ddr_writedata_in 0000000000000000
	run 100
}

###############################################################
# ztaMemReadInt
#   Provided testbench includes a simulated DDR memory region
#   Read an integer value from this DDR memory
# Parameters:
#   addr: byte address
# Return value:
#   Integer value read
###############################################################

proc ztaMemReadInt {addr} {
	variable now
	variable CLOCK_PERIOD
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+2] 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value2 [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100

    return [bin2dec $read_value2$read_value]
}

proc ztaMemReadShort {addr} {
	variable now
	variable CLOCK_PERIOD
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100
    set v 0000000000000000
    return [bin2dec $v$read_value]
}

###############################################################
# ztaMemReadInt8/16
#   Provided testbench includes a simulated DDR memory region
#   Read an integer value from this DDR memory.
#   This is for INTEGER core...
# Parameters:
#   addr: byte address
# Return value:
#   Integer value read
###############################################################

proc ztaMemReadInt16 {addr} {
	variable now
	variable CLOCK_PERIOD
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+1] 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value2 [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100

    return [bin2dec $read_value2$read_value]
}

proc ztaMemReadInt8 {addr} {
	variable now
	variable CLOCK_PERIOD
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100
   return [bin2dec $read_value]
}

###############################################################
# ztaMemReadFloat
#   Provided testbench includes a simulated DDR memory region
#   Read an float value from this DDR memory
# Parameters:
#   addr: byte address
# Return value:
#   Float value read
###############################################################

proc ztaMemReadFloat {addr} {
	variable now
	variable CLOCK_PERIOD
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100

	force -deposit sim:/testbench/ddr_addr_in [dec2bin [expr $addr+2] 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set read_value2 [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100

    return [bin2float $read_value2$read_value]
}

###############################################################
# ztaMemReadHalf
#   Provided testbench includes a simulated DDR memory region
#   Read an float value from this DDR memory
# Parameters:
#   addr: byte address
# Return value:
#   Float value read
###############################################################

proc ztaMemReadHalf {addr} {
	variable now
	variable CLOCK_PERIOD
	force -deposit sim:/testbench/ddr_addr_in [dec2bin $addr 32]
	force -deposit sim:/testbench/ddr_read_in 1
	run 100
	force -deposit sim:/testbench/ddr_read_in 0
	run 200
	set v [examine -value -time [expr $now-$CLOCK_PERIOD/2] sim:/testbench/ddr_readdata_out]
	force -deposit sim:/testbench/ddr_addr_in 00000000000000000000000000000000
	force -deposit sim:/testbench/ddr_read_in 0
	run 100
    set v2 000
    set v3 0000000000000
    return [bin2float [string range $v 0 0][string range $v 1 1]$v2[string range $v 2 15]$v3]
}


###############################################################
# ztaMsgWriteInt
#   Put an integer to the message queue 
# Parameters:
#   val: integer value to be put to message queue
# Return value:
#   None
###############################################################

proc ztaMsgWriteInt {val} {
    variable REG_MSGQ_WRITE
    variable REG_MSGQ_WRITE_AVAIL
    while {[avalon_read [GREG 0 $REG_MSGQ_WRITE_AVAIL]] == [dec2bin 0 32]} {
        run 10000
    }
    avalon_write [GREG 0 $REG_MSGQ_WRITE] $val
}

###############################################################
# ztaMsgWriteFloat
#   Put a float to the message queue 
# Parameters:
#   val: float value to be put to message queue
# Return value:
#   None
###############################################################

proc ztaMsgWriteFloat {val} {
    variable REG_MSGQ_WRITE
    variable REG_MSGQ_WRITE_AVAIL
    while {[avalon_read [GREG 0 $REG_MSGQ_WRITE_AVAIL]] == [dec2bin 0 32]} {
        run 10000
    }
    avalon_write_float [GREG 0 $REG_MSGQ_WRITE] $val
}

###############################################################
# ztaMsgReadInt
#   Retrieve an integer from the message queue. If no messages 
#   available to keep polling for it.... 
# Parameters:
#   None
# Return value:
#   Integer value read
###############################################################

proc ztaMsgReadInt {} {
    variable REG_MSGQ_READ
    variable REG_MSGQ_READ_AVAIL
    while {[avalon_read [GREG 0 $REG_MSGQ_READ_AVAIL]] == [dec2bin 0 32]} {
        run 10000
    }
    set result [avalon_read [GREG 0 $REG_MSGQ_READ]]
    return [bin2dec $result]
}

###############################################################
# ztaMsgReadFloat
#   Retrieve a float from the message queue. If no messages 
#   available to keep polling for it.... 
# Parameters:
#   None
# Return value:
#   Float value read
###############################################################

proc ztaMsgReadFloat {} {
    variable REG_MSGQ_READ
    variable REG_MSGQ_READ_AVAIL
    while {[avalon_read [GREG 0 $REG_MSGQ_READ_AVAIL]] == [dec2bin 0 32]} {
        run 10000
    }
    set result [avalon_read [GREG 0 $REG_MSGQ_READ]]
    return [bin2float $result]
}

#########################################################################
# Dump content on serial port
#########################################################################

proc ztaSerial {} {
    variable REG_SERIAL_READ
    variable REG_SERIAL_READ_AVAIL
    set result [avalon_read [GREG 0 $REG_SERIAL_READ_AVAIL]]
    set count [bin2dec $result]
	for {set i 0} {$i < $count} {incr i} {
        set ch [avalon_read [GREG 0 $REG_SERIAL_READ]]
        puts "$ch"
    }
}
