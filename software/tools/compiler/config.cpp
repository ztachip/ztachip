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

#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <vector>
#include "zta.h"
#include "config.h"
#include "ast.h"


// MU opcode definitions
cConfig::sMuOpcodeDef cConfig::mu_opcode_def[MAX_NUM_OPCODE]=
{
{0,0,   "NULL",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //OPCODE_NULL
{1,0,   "ASN",         cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //OPCODE_ASSIGN
{2,0,   "ASN_RAW",     cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,true,     cConfig::eMuOpcodeDefDataTypeFloat,true,     cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //OPCODE_ASSIGN_RAW
{3,0,   "ADD",         cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_ADD 
{4,0,   "SUB",         cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_SUB 
{5,0,   "CONV",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeInt,true,     cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //OPCODE_CONV
{6,0,   "LT",          cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,false,    cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_CMP_LT
{7,0,   "LE",          cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,false,    cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_CMP_LE
{8,0,   "GT",          cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,false,    cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_CMP_GT
{9,0,   "GE",          cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,false,    cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_CMP_GE
{10,0,  "EQ",          cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,false,    cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_CMP_EQ
{11,0,  "NE",          cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,false,    cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1},//OPCODE_CMP_NE
{12,0,  "MUL",         cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_MUL 
{13,0,   "NULL",        cConfig::eMuOpcodeDefAlu1,       cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //OPCODE_NULL
{14,0,   "NULL",        cConfig::eMuOpcodeDefAlu1,       cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //OPCODE_NULL
{15,0,  "GET_MANTISSA", cConfig::eMuOpcodeDefAlu1,       cConfig::eMuOpcodeDefDataTypeInt,true,     cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //Get mantissa+sign
{16,0,  "GET_EXP",     cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeInt,false,     cConfig::eMuOpcodeDefDataTypeFloat,false,   cConfig::eMuOpcodeDefDataTypeNull,false,       -1,0,0,-1}, //Get exponent
{17,0,  "SET_EXP",     cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,false,   cConfig::eMuOpcodeDefDataTypeFloat,false,   cConfig::eMuOpcodeDefDataTypeInt,false,        -1,0,0,-1}, //Set exponent
{18,0,  "SET_FLOAT",   cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,false,   cConfig::eMuOpcodeDefDataTypeInt,false,     cConfig::eMuOpcodeDefDataTypeInt,false,        -1,0,0,-1}, //Set float
#if 1
{19,0,   "SHL",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   -1,0,0,-1}, // Shift left
{20, 0,  "SHLA",       cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat, true,    cConfig::eMuOpcodeDefDataTypeFloat, true,  cConfig::eMuOpcodeDefDataTypeNull, true, -1, 0, 0, -1 }, // ACC shift left
{21, 0,  "SHR",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat, true,  cConfig::eMuOpcodeDefDataTypeFloat, true,  cConfig::eMuOpcodeDefDataTypeFloat, true,  -1, 0, 0, -1 }, // Right shift
{22, 0,  "SHRA",       cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat, true,  cConfig::eMuOpcodeDefDataTypeFloat, true,    cConfig::eMuOpcodeDefDataTypeNull, true, -1, 0, 0, -1 }, // ACC Right shift 
#endif
#if 0
{19,0,   "SHL",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeInt,true,   -1,0,0,-1}, // Shift left
{20, 0,  "SHLA",       cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat, true,    cConfig::eMuOpcodeDefDataTypeInt, true,  cConfig::eMuOpcodeDefDataTypeNull, true, -1, 0, 0, -1 }, // ACC shift left
{21, 0,  "SHR",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat, true,  cConfig::eMuOpcodeDefDataTypeFloat, true,  cConfig::eMuOpcodeDefDataTypeInt, true,  -1, 0, 0, -1 }, // Right shift
{22, 0,  "SHRA",       cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat, true,  cConfig::eMuOpcodeDefDataTypeInt, true,    cConfig::eMuOpcodeDefDataTypeNull, true, -1, 0, 0, -1 }, // ACC Right shift 
#endif
{23,0,   "NULL",       cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,    cConfig::eMuOpcodeDefDataTypeNull,true,       -1,0,0,-1}, //OPCODE_NULL
{24,0,  "FMS",        cConfig::eMuOpcodeDefAlu1,         cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FMS
{25,0,  "FMA",        cConfig::eMuOpcodeDefAlu1,         cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FMA
{26,0,  "FNMS",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FNMS
{27,0,  "FNMA",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FNMA
{28,0,  "FMS2",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FMS2
{29,0,  "FMA2",        cConfig::eMuOpcodeDefAlu1,        cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FMA2
{30,0,  "FNMS2",        cConfig::eMuOpcodeDefAlu1,       cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FNMS2
{31,0,  "FNMA2",        cConfig::eMuOpcodeDefAlu1,       cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,   cConfig::eMuOpcodeDefDataTypeFloat,true,      -1,0,0,-1}, //OPCODE_FNMA2
{0,0,   0,             cConfig::eMuOpcodeDefAluInvalid,  cConfig::eMuOpcodeDefDataTypeInvalid,true, cConfig::eMuOpcodeDefDataTypeInvalid,true, cConfig::eMuOpcodeDefDataTypeInvalid,true,    -1,0,0,-1} //END 
};
 
int cConfig::m_numPCORES=0;
int cConfig::m_numInstruction=0;
int cConfig::m_numReservedInstruction=0;

// String used as XML tags

#define STR_NUMPCORE    "NumberPCores"
#define STR_INSTRUCTION "instruction"
#define STR_COMPONENT   "component"
#define STR_ALU         "alu"
#define STR_ALU1        "alu1"
#define STR_ALU2        "alu2"
#define STR_BOTH        "both"
#define STR_NAME        "name"
#define STR_X1          "x1"
#define STR_X2          "x2"
#define STR_Y           "y"
#define STR_LATENCY     "Latency"
#define STR_INTEGER     "integer"
#define STR_FLOAT       "float"
#define STR_NULL        "null"

cConfig::sMuOpcodeDef *cConfig::GetMuOpcodeDef(int oc)
{
   return &mu_opcode_def[oc];
}

int cConfig::GetMuOpcode(int oc)
{
   return mu_opcode_def[oc].oc;
}

// Check if integer opcode is commutative. Which means X OP Y = Y OP X
bool cConfig::IsImuCommutative(int opcode)
{
   switch(opcode)
   {
   case cConfig::IOPCODE_ADD: return true;
   case cConfig::IOPCODE_SUB: return false;
   case cConfig::IOPCODE_MUL: return true;
   case cConfig::IOPCODE_SHL: return false;
   case cConfig::IOPCODE_SHR: return false;
   case cConfig::IOPCODE_LSHR: return false;
   case cConfig::IOPCODE_OR: return true;
   case cConfig::IOPCODE_AND: return true;
   case cConfig::IOPCODE_XOR: return true;
   default:
      assert(0);
      return false;
   }
}

// Check if the MU opcode is commutative. Which means X OP Y=Y OP X
bool cConfig::IsMuCommutative(int opcode)
{
   switch(opcode)
   {
   case cConfig::OPCODE_NULL: return false;
   case cConfig::OPCODE_ADD: return true;
   case cConfig::OPCODE_SUB: return false;
   case cConfig::OPCODE_MUL: return true;
   case cConfig::OPCODE_ASSIGN: return false;
   case cConfig::OPCODE_CONV: return false;
   case cConfig::OPCODE_CMP_LT: return false;
   case cConfig::OPCODE_CMP_LE: return false;
   case cConfig::OPCODE_CMP_GT: return false;
   case cConfig::OPCODE_CMP_GE: return false;
   case cConfig::OPCODE_CMP_EQ: return true;
   case cConfig::OPCODE_CMP_NE: return true;
   case cConfig::OPCODE_ASSIGN_RAW: return false;
   case cConfig::OPCODE_FMA: return true;
   case cConfig::OPCODE_FMS: return true;
   case cConfig::OPCODE_FNMA: return true;
   case cConfig::OPCODE_FNMS: return true;
   case cConfig::OPCODE_FMA2: return false;
   case cConfig::OPCODE_FMS2: return false;
   case cConfig::OPCODE_FNMA2: return false;
   case cConfig::OPCODE_FNMS2: return false;
   case OPCODE_GET_MANTISSA: return false;
   case OPCODE_GET_EXPONENT: return false;
   case OPCODE_SET_EXPONENT: return false;
   case OPCODE_SET_FLOAT: return false;
   case cConfig::OPCODE_SHL: return false;
   case cConfig::OPCODE_SHR: return false;
   case cConfig::OPCODE_SHLA: return false;
   case cConfig::OPCODE_SHRA: return false;
   default:
      assert(0);
      return false;
   }
}

const char *cConfig::GetMuOpcodeName(int oc)
{
   return mu_opcode_def[oc].name;
}

const char *cConfig::GetImuOpcodeName(int oc)
{
   static const char *ioc_string[]=
   {
      "NOP",
      "ADD",
      "SUB",
      "MUL",
      "SHL",
      "SHR",
      "OR",
      "AND",
      "XOR",
      "LSHR"
   };
   return ioc_string[oc];
}

const char *cConfig::GetControlOpcodeName(int oc)
{
   static const char *control_string[]=
   {
      "NOP",
      "***********RETURN****************",
      "OPCODE_JUMP_LT",
      "OPCODE_JUMP_LE",
      "OPCODE_JUMP_GT",
      "OPCODE_JUMP_GE",
      "OPCODE_JUMP_EQ",
      "OPCODE_JUMP_NE",
      "OPCODE_JUMP",
      "OPCODE_FUNC"
   };
   return control_string[oc];
}

//-----------------------------------------------------------------
// Decode the MU opcode.
// Look it up from the code configuration file.
// Determine the opcode and from which ALU unit (0 or 1)
//-----------------------------------------------------------------
bool cConfig::decode_mu_oc(char *oc_name,int *oc)
{
   int i;
   for(i=0;i < m_numInstruction;i++)
   {
      if(strcasecmp(mu_opcode_def[i].name,oc_name)==0)
      {
         *oc=i;
         return true;
      }
   }
   *oc=-1;
   return false;
}

int cConfig::Load(char *fileName,char *fileName2)
{
   m_numPCORES=8;
   m_numInstruction=0;
   while(mu_opcode_def[m_numInstruction].name)
      m_numInstruction++;
   m_numReservedInstruction=m_numInstruction;
   return 0;
}
