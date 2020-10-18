//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
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

#ifndef _CONFIG_H_
#define _CONFIG_H_

#include "util.h"

#define MAX_NUM_OPCODE  256

// ---------------Instruction format ---------------------------------------------------
// Matrix has a VLIW instruction format
// Instructions are bundled in packets. There are a maximum of 4 instructions per packet
// There are 3 kinds of instructions
//     - ALU: For floating point
//     - IALU: Integer arithmetic
//     - CONTROL: Jump instructions
// ALU instrution format:
//     [opcode][Y-attr][Y-offset][X1-attr][X1-offset][X2-attr][X2-offset]
// Attribute field value in a ALU instruction
//     11xx  Pointer with index
//     1011  Pointer no index
//     1000  Shared no index
//     1001  Private no index
//     1010  Constant
//     00xx  Share with index
//     01xx  Private with index
// IALU instruction format:
//     [opcode][Y-attr][X1-attr][X2-attr][Immediate constant]
// Control instruction format
//     [opcode][jump address]
// There are 2 kinds of packet
//    Long packet: [ALU][ALU][IMU][CONTROL]
//    Short packet: [IMU][CONTROL]
// Slots for ALU can be assigned instead to hold immediate constants for ALU operation
// IALU has field to hold immediate constant for IALU operation
//---------------------------------------------------------------------------------------

// Max number of instructions per VLIW packet
#define MAX_CMD_PER_PACKET 4

// Max value for offset in a pointer reference
#define MAX_POINTER_OFFSET    7

// Min value for offset in a pointer reference
#define MIN_POINTER_OFFSET    0

// When attribute=Constant, offset field may hold the following
typedef enum
{
    ATTR_CONST_P0 = (1<<4),     // Constant in the first word of VLIW packet
    ATTR_CONST_NULL = (1<<5),     // Constant in the second word of VLIW packet
    ATTR_CONST_RESULT = (1<<6), // Hold result value from ALU 
    ATTR_CONST_TID = (1<<7), // Hold result value from ALU 
    ATTR_CONST_XREG = (1<<8)
} eOpcodeConstantType;

// Attribute field in a IALU instruction (integer)
typedef enum
{
    IATTR_I0 = 0,       // Integer#0
    IATTR_I1 = 1,       // Integer#1
    IATTR_I2 = 2,       // Integer#2
    IATTR_I3 = 3,       // Integer#3
    IATTR_P0 = 4,       // Pointer#0
    IATTR_P1 = 5,       // Pointer#1
    IATTR_P2 = 6,       // Pointer#2
    IATTR_P3 = 7,       // Pointer#3
    IATTR_LANE = 8,     // Lane control
    IATTR_ZERO = 10,    // ZERO constant
    IATTR_CONST = 11,   // Immediate constant defined in constant field
    IATTR_TID = 12,     // Current TID (thread id)
    IATTR_PID = 13,     // Current processor id
    IATTR_RESULT1 = 14, // Result from ALU
    IATTR_STACK = 15    // Stack variable
} eIOpcodeParameterAttribute;

// This class defines all the opcode definitions
class cConfig
{
public:
   enum eMuOpcodeDefAlu
   {
   eMuOpcodeDefAlu1=0,
   eMuOpcodeDefAlu2=1,
   eMuOpcodeDefAluBoth=2,
   eMuOpcodeDefAluInvalid=3
   };
   enum eMuOpcodeDefDataType
   {
   eMuOpcodeDefDataTypeFloat=0,
   eMuOpcodeDefDataTypeInt,
   eMuOpcodeDefDataTypeRaw,
   eMuOpcodeDefDataTypeNull,
   eMuOpcodeDefDataTypeInvalid
   };
   struct sMuOpcodeDef
   {
   int oc;
   char *component;
   const char *name;
   eMuOpcodeDefAlu alu;
   eMuOpcodeDefDataType y_type;
   bool y_vector;
   eMuOpcodeDefDataType x1_type;
   bool x1_vector;
   eMuOpcodeDefDataType x2_type;
   bool x2_vector;
   int latency;
   int tap;
   int x_latches;
   int group;
   };

   enum eMuOpcode
   {
   OPCODE_NULL=0,
   OPCODE_ASSIGN=1,
   OPCODE_ASSIGN_RAW=2,
   OPCODE_ADD=3,
   OPCODE_SUB=4,
   OPCODE_CONV=5,
   OPCODE_CMP_LT=6,
   OPCODE_CMP_LE=7,
   OPCODE_CMP_GT=8,
   OPCODE_CMP_GE=9,
   OPCODE_CMP_EQ=10,
   OPCODE_CMP_NE=11,
   OPCODE_MUL=12,
   OPCODE_GET_MANTISSA=15,
   OPCODE_GET_EXPONENT=16,
   OPCODE_SET_EXPONENT=17,
   OPCODE_SET_FLOAT=18,
   OPCODE_SHL=19,
   OPCODE_SHLA=20,
   OPCODE_SHR = 21,
   OPCODE_SHRA = 22,
   OPCODE_FM=24,
   OPCODE_FMS=24+0+0+0, // x1*x2-_A
   OPCODE_FMA=24+0+0+1, // x1*x2+_A
   OPCODE_FNMS=24+0+2+0, // -x1*x2-_A
   OPCODE_FNMA=24+0+2+1, // -x1*x2+_A
   OPCODE_FMS2=24+4+0+0, // x1*_A-x2
   OPCODE_FMA2=24+4+0+1, // x1*_A+x2
   OPCODE_FNMS2=24+4+2+0, // -x1*_A-x2
   OPCODE_FNMA2=24+4+2+1,
   OPCODE_FM_LAST=OPCODE_FNMA2
   };

   enum eImuOpcode
   {
   // IMU opcode
   IOPCODE_ADD=1,
   IOPCODE_SUB=2,
   IOPCODE_MUL=3,
   IOPCODE_SHL=4,
   IOPCODE_SHR=5,
   IOPCODE_OR=6,
   IOPCODE_AND=7,
   IOPCODE_XOR=8,
   IOPCODE_LSHR=9
   };

   enum eControlOpcode
   {
   // Control opcode
   OPCODE_RETURN=1,
   OPCODE_JUMP_LT=2,
   OPCODE_JUMP_LE=3,
   OPCODE_JUMP_GT=4,
   OPCODE_JUMP_GE=5,
   OPCODE_JUMP_EQ=6,
   OPCODE_JUMP_NE=7,
   OPCODE_JUMP=8,
   OPCODE_FUNC=9
   };

public:
   static int Load(char *fileName,char *fileNam2);
   static sMuOpcodeDef *GetMuOpcodeDef(int oc);
   static bool IsMuCommutative(int opcode);
   static bool IsImuCommutative(int opcode);
   static const char *GetMuOpcodeName(int oc);
   static int GetMuOpcode(int oc);
   static const char *GetImuOpcodeName(int oc);
   static const char *GetControlOpcodeName(int oc);
   static bool decode_mu_oc(char *oc_name,int *oc);
public:
   static int m_numPCORES;
   static int m_numInstruction;
   static int m_numReservedInstruction;
   static sMuOpcodeDef mu_opcode_def[MAX_NUM_OPCODE];
};

// TRUE if compilation is for floating point core
// FALSE if compilation is for integer code

extern bool M_ISFLOAT;

#endif
