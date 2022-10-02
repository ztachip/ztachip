//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

// This file holds all definition of the HDL core parameters
// This file has to be in synced with HDL implementations as defined in
// HW/src/ztachip_pkg.vhd

#ifndef _ZTA_H_
#define _ZTA_H_

#define NUM_PCORE  4 // Number of PCORES: 4 or 8

#define MEM_MAP  0xF2000000 // ztachip address as mapped on AXI bus.

#define CID_DEPTH  3

#define PID_DEPTH  2

#define PID_MAX  (1<<PID_DEPTH)

#define DP_TEMPLATE_ID_WIDTH  4

#define BUSID_WIDTH  2

#define DATATYPE_WIDTH  2

#define DATAMODEL_WIDTH  2

#define DP_TEMPLATE_MAX  (1<<DP_TEMPLATE_ID_WIDTH)

#define DATA_BIT_WIDTH  12

// Max shift distance

#define MAX_SHIFT_DISTANCE  3

// Number of threads

#define TID_DEPTH  4

#define TID_MAX  (1<<TID_DEPTH)

// Max vector width 0=1,1=2,2=4

#define VECTOR_DEPTH  3

#define VECTOR_WIDTH  (1<<VECTOR_DEPTH)

// Number of address bits to access the register space

#define REGISTER_DEPTH  (5+VECTOR_DEPTH)

#define REGISTER_FILE_DEPTH  (REGISTER_DEPTH+TID_DEPTH)

// Actual size of register file...

#define REGISTER_ACTUAL_FILE_DEPTH (REGISTER_FILE_DEPTH-1)

// Max address range for private/shared access

#define LOCAL_ADDR_DEPTH  (REGISTER_FILE_DEPTH)

// Number of registers per thread.

#define REGISTER_SIZE  (1<<REGISTER_DEPTH)

// Number of address bits to access integer bank (4 integers+4 pointers)

#define IREGISTER_ADDR_WIDTH  3

// Integer data width

#define IREGISTER_WIDTH  13

// Number of PCORES per cell

#define PCORE_PER_CELL  4

// Max number of PCORES allowed

#define MAX_CELL  8

// Number PCORE per cell

#define PCORE_PER_CELL  4

// Max number of threads per core

#define NUM_THREAD_PER_CORE  16

// Minimum number of threads required for max efficiency

#define NUM_MIN_THREAD_FOR_MAX_EFFICIENCY  14

// Max number of accumulator per thread

#define MAX_NUM_ACCUMULATOR  8

// Max opcode value

#define OPCODE_MAX  31

// Opcode width

#define OPCODE_WIDTH  4

// Register width

#define REGISTER_WIDTH  32

// Max number of shared variables per thread

#define MAX_SHARE_SIZE  (NUM_THREAD_PER_CORE*LARGE_SHARE_PER_THREAD)

// Max number of private registers per thread

#define MAX_PRIVATE_SIZE  (REGISTER_SIZE)

// Max number of accumlators

#define MAX_EXREG_SIZE  (1<<(3+VECTOR_DEPTH))

// Max number of integer per thread

#define MAX_INT_SIZE  4

// Max number of pointer per thread

#define MAX_POINTER_SIZE  4

// Max number of integer result (hold integer return value from ALU) per thread

#define MAX_RESULT_SIZE  1

// Max number of auto iregisters

#define MAX_IREGISTER_AUTO_SIZE  2

// MCORE code instruction size (in number of 32 bit words)

#define MCORE_INSTRUCTION_DEPTH  14

#define MCORE_INSTRUCTION_SIZE  (1<<MCORE_INSTRUCTION_DEPTH);

// Shared mode: 
// 0=2 register per thread assigned for shared space
// 1=4 registers per thread assigned for shared space
// 2=8 registers per thread assigned for shared space

#define LARGE_SHARE_PER_THREAD  128

#define SMALL_SHARE_PER_THREAD  32

// PCORE page

#define PCORE_PAGE_PRIVATE  0

#define PCORE_PAGE_SHARE  1

#define PCORE_PAGE_SPU  2

#define PCORE_PAGE_PCORE_PROG  3

// Instruction attributes

#define INSTRUCTION_ATTR_POINTER  11

#define INSTRUCTION_ATTR_POINTER_N_INDEX  12

#define INSTRUCTION_ATTR_CONST  10

#define INSTRUCTION_ATTR_SHARE  8

#define INSTRUCTION_ATTR_SHARE_N_INDEX  0

#define INSTRUCTION_ATTR_PRIVATE  9

#define INSTRUCTION_ATTR_PRIVATE_N_INDEX  4

// Width of VLIW instruction fields

#define INSTRUCTION_MU_WIDTH  80

#define INSTRUCTION_IMU_WIDTH  32

#define INSTRUCTION_CTRL_WIDTH  16

#define INSTRUCTION_WIDTH  (INSTRUCTION_MU_WIDTH+INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH)

#define INSTRUCTION_BYTE_WIDTH  (INSTRUCTION_WIDTH/8)

// Address bits to access PCORE code space

#define INSTRUCTION_DEPTH  11

// Address bits to access SRAM space (scratch pad)

#define SRAM_DEPTH  15

// Max size for SRAM space (scratch pad)

#define SRAM_SIZE  (1<<SRAM_DEPTH)

// Address width of constant space

#define CONSTANT_DEPTH  8

// Max number of constants

#define CONSTANT_SIZE  (1<<CONSTANT_DEPTH)

// Number of address bits to access DDR space window

#define DP_ADDR_WIDTH  24

// Max size of DDR space window

#define MAX_DP_ADDR_SIZE  (1 << DP_ADDR_WIDTH)

#define MCAST_WIDTH  (1+CID_DEPTH+PID_DEPTH)

// TENSOR core instructions

#define DP_TRANSFER_CMD(oc,vm,a,b,c,d,f,g,h,ii,e)  (((oc)+((e)<<3)+((a)<<8)+((b)<<10)+((c)<<11)+((d)<<13)+((f)<<14)+((g)<<15)+((h)<<16))+((ii)<<17))

#define DP_EXE_CMD(lockstep,func,num_pcore,vm,p0,p1,num_tid,dataModel)  (DP_OPCODE_EXEC_VM1+((lockstep)<<23))+((func)<<7)+((num_pcore)<<18)+((p0)<<24)+((p1)<<25)+((num_tid)<<26)+((dataModel)<<30)

// TENSOR core Function field definition.

#define EXE_FUNC_FIELD(f)  ((f)>>(MAX_IREGISTER_AUTO_SIZE+DATAMODEL_WIDTH))

#define EXE_P0_FIELD(f)  ((f)&1)

#define EXE_P1_FIELD(f)  (((f)>>1)&1)

#define EXE_MODEL_FIELD(f)  (((f)>>MAX_IREGISTER_AUTO_SIZE)&((1<<DATAMODEL_WIDTH)-1))

// Macro to access ztachip registers

#define ZTAM_GREG(reg2,reg,vm)  (((volatile uint32_t *)MEM_MAP)[((reg2) << 5)+reg])

// ztachip register definitions

#define REG_STATUS  0

#define REG_DDR_BAR  1

#define REG_READ_LOG  2

#define REG_READ_LOG_TIME  3

#define REG_DP_RUN  5

#define REG_LOOKUP_SET_ADDR  6

#define REG_LOOKUP_SET_VAL  7

#define REG_LOOKUP_SET_COEF  4

#define REG_DP_TEMPLATE  8

#define REG_DP_READ_SYNC  10

#define REG_DP_READ_INDICATION  11

#define REG_DP_READ_INDICATION_AVAIL  12

#define REG_DP_INSTRUCTION_FIFO_AVAIL  14

#define REG_SOFT_RESET  15

#define REG_SWDL_COMPLETE_READ  20

#define REG_SWDL_COMPLETE_CLEAR  21

#define REG_MSGQ_READ  16

#define REG_MSGQ_READ_AVAIL  17

#define REG_MSGQ_WRITE  18

#define REG_MSGQ_WRITE_AVAIL  19

#define REG_DP_MAX_PCORE  22

#define REG_DP_INDICATION_PARM0  23

#define REG_DP_INDICATION_PARM1  24

#define REG_DP_READ_INDICATION_PARM  25

#define REG_SERIAL_READ  26

#define REG_SERIAL_WRITE  27

#define REG_SERIAL_READ_AVAIL  28

#define REG_SERIAL_WRITE_AVAIL  29

#define REG_DP_RESUME  30

#define REG_DP_RESTORE  13

#define REG_DP_VM_TOGGLE  9

// Sub function for REG_DP_SRC_TEMPLATE and REG_DP_DST_TEMPLATE

#define DPREG_STRIDE0  0

#define DPREG_STRIDE0_COUNT  1

#define DPREG_STRIDE1  2

#define DPREG_STRIDE1_COUNT  3

#define DPREG_BAR  4

#define DPREG_COUNT  5

#define DPREG_STRIDE2  6

#define DPREG_STRIDE2_COUNT  7

#define DPREG_BURST_STRIDE  8

#define DPREG_STRIDE0_MAX  9

#define DPREG_STRIDE1_MAX  10

#define DPREG_STRIDE2_MAX  11

#define DPREG_BURST_MAX  12

#define DPREG_BURST_MAX2  27

#define DPREG_STRIDE3  13

#define DPREG_STRIDE3_COUNT  14

#define DPREG_STRIDE3_MAX  15

#define DPREG_STRIDE4  16

#define DPREG_STRIDE4_COUNT  17

#define DPREG_STRIDE4_MAX  18

#define DPREG_MODE  19

#define DPREG_STRIDE0_MIN  20

#define DPREG_STRIDE1_MIN  21

#define DPREG_STRIDE2_MIN  22

#define DPREG_STRIDE3_MIN  23

#define DPREG_STRIDE4_MIN  24

#define DPREG_BURST_MIN  25

#define DPREG_TOTALCOUNT  26

#define DPREG_DATA  28

#define DPREG_FORK_STRIDE  29

#define DPREG_FORK_COUNT  30

#define DPREG_BUFSIZE  31

#define DPREG_BURST_MAX_INIT  32

#define DPREG_BURST_MAX_INDEX  33

#define DPREG_BURST_MAX_LEN  34

// Sub function for REG_DP_RUN

#define DP_OPCODE_NULL  0

#define DP_OPCODE_TRANSFER_SINGLE  1

#define DP_OPCODE_LOG_ON  2

#define DP_OPCODE_LOG_OFF  3

#define DP_OPCODE_EXEC_VM1  4

#define DP_OPCODE_EXEC_VM2  5

#define DP_OPCODE_INDICATION  6

#define DP_OPCODE_PRINT  7

// Condition associated with REG_DP_RUN command

#define DP_CONDITION_REGISTER_FLUSH  1  // Condition to wait for data transfers to/from register space be completed

#define DP_CONDITION_SRAM_FLUSH  2 // Condition to wait for data transfers to/from sram memory space of process 0 be completed

#define DP_CONDITION_DDR_FLUSH  8 // Condition to wait for data transfers to/from ddr memory space be completed

#define DP_CONDITION_ALL_FLUSH  11 // Condition to wait for all data transfers be completed

// Data type

#define INT16  3   // 16bit data type to encode 12-bit integer

#define FLOAT8  0   // 8bit float

#define INT8  2   // int8, sign extension for MSB

#define UINT8  4   // uint8, zero padded for MSB

#define UFLOAT8  6   // int8, sign extension for MSB

// DP template ID

#define DP_TEMPLATE_ID_SRC  (DP_TEMPLATE_MAX-2)   // DP Template is source

#define DP_TEMPLATE_ID_DEST  (DP_TEMPLATE_MAX-1)   // DP Template is destination

// Mask mode

#define MCAST_FILTER_MASK  1  // PCORE filtering is by address bit mask

#define MCAST_FILTER_RANGE  0  // PCORE filtering is by range

// SPU parameter

#define SPU_NUM_STREAM  4

#define SPU_SIZE  128

#define SPU_REMAINDER_LN  5

#define SPU_REMAINDER  (1<<SPU_REMAINDER_LN)

#define SPU_MAX  4

#define SPU_LOOKUP_SIZE  (2*SPU_SIZE)

#endif
