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

// This file generates pcore assembly instructions based on AST tree
//
// pcores has a VLIW SIMD architecture
//
// Refer to https://github.com/ztachip/ztachip/blob/master/Documentation/vliw_design.md for pcore instruction
// description.
//
// At each clock, 1 VLIW instruction can execute 1 vector operation + 1 scalar operation and 1 branching instruction
// branching instruction is based on result value Y in the scalar operation
// pcore has a throughput of 1 VLIW instruction per clock. 

// pcore assembly has the following format
// 
//  MU : Instruction for the vector ALU, it has 3 input (X1,X1,ACCUMULATOR) and 1 output.
//     OPCODE     [5 bit ] opcode for vector unit
//     Y_TYPE     [1 bit ] 1 means Y is a accumulator,0 means Y is a word (12bit) 
//     ACC_VECTOR [1 bit ] Accumulator input is vector
//     ACC        [12 bit] Accumulator input identifier
//     ACC_ATTR   [4 bit ] Accumulator input attribute. ACC and ACC_ATTR uniquely identifies which accumulator register
//     X1_VECTOR  [1 bit ] X1 input is vector
//     X1         [12 bit] X1 input identifier
//     X1_ATTR    [4 bit ] X1 input attribute. X1 and X1_ATTR uniquely identifies X1 memory address 
//     X2_VECTOR  [1 bit ] X2 input is vector
//     X2         [12 bit] X2 input identifier
//     X2_ATTR    [4 bit ] X2 input attribute. X2 and X2_ATTR uniquely identifies X2 memory address 
//     Y_VECTOR   [1 bit ] Y output is vector
//     Y          [12 bit] Y output identifier
//     Y_ATTR     [4 bit ] Y output attribute. Y and Y_ATTR uniquely identifies Y memory address 
// IMU : Instruction to scalar ALU unit
//     OPCODE     [5 bit ] Scalar ALU opcode
//     X1         [4 bit ] X1 identifier
//     X2         [4 bit ] X2 identifier
//     Y          [4 bit ] Y identifier
//     Constant   [13 bit] Constant field
// CTRL
//     OPCODE     [5 bit ] Control opcode
//     Address    [11 bit] Address to jump to if opcode condition is met. Condition is applied to Y value of scalar instruction above.
//
// Vector ALU parameter attibute options are:
//    11xx  Pointer with index
//    1011  Pointer no index
//    1000  Shared no index
//    1001  Private no index
//    1010  Constant
//    00xx  Share with index
//    01xx  Private with index
// 
// Scalar ALU parameter attribute options are:
//    1010   Zero value
//    1011   Constant from IMU instruction constant field 
//    1100   Thread id
//    1101   PID id
//    1110   RESULT from previous MU operation
//    1000   LANE register. To enable/disable a vector lane
//    Others Register value (0-7)
// 

#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <vector>
#include <string>
#include "../base/zta.h"
#include "ast.h"
#include "util.h"
#include "ident.h"
#include "const.h"
#include "instruction.h"
#include "gen.h"
#include "config.h"
#include "mcore.h"

extern bool M_VERBOSE;

#define RC_FAIL   -1
#define RC_FAIL_CONT -2
#define RC_OK_LAST   0
#define RC_OK_CONT   1

#define INSTRUCTION_TYPE_MU      0
#define INSTRUCTION_TYPE_IMU     1
#define INSTRUCTION_TYPE_CONTROL 2

// Instruction field format

#define MU_INSTRUCTION_Y_ATTR_LO     0
#define MU_INSTRUCTION_Y_ATTR_HI     3
#define MU_INSTRUCTION_Y_LO          (MU_INSTRUCTION_Y_ATTR_HI+1)
#define MU_INSTRUCTION_Y_HI          (MU_INSTRUCTION_Y_LO+LOCAL_ADDR_DEPTH-1)
#define MU_INSTRUCTION_Y_VECTOR      (MU_INSTRUCTION_Y_HI+1)
#define MU_INSTRUCTION_X2_ATTR_LO    (MU_INSTRUCTION_Y_VECTOR+1)
#define MU_INSTRUCTION_X2_ATTR_HI    (MU_INSTRUCTION_X2_ATTR_LO+3)
#define MU_INSTRUCTION_X2_LO         (MU_INSTRUCTION_X2_ATTR_HI+1)
#define MU_INSTRUCTION_X2_HI         (MU_INSTRUCTION_X2_LO+LOCAL_ADDR_DEPTH-1)
#define MU_INSTRUCTION_X2_VECTOR     (MU_INSTRUCTION_X2_HI+1)
#define MU_INSTRUCTION_X1_ATTR_LO    (MU_INSTRUCTION_X2_VECTOR+1)
#define MU_INSTRUCTION_X1_ATTR_HI    (MU_INSTRUCTION_X1_ATTR_LO+3)
#define MU_INSTRUCTION_X1_LO         (MU_INSTRUCTION_X1_ATTR_HI+1)
#define MU_INSTRUCTION_X1_HI         (MU_INSTRUCTION_X1_LO+LOCAL_ADDR_DEPTH-1)
#define MU_INSTRUCTION_X1_VECTOR     (MU_INSTRUCTION_X1_HI+1)
#define MU_INSTRUCTION_XACC_ATTR_LO  (MU_INSTRUCTION_X1_VECTOR+1)
#define MU_INSTRUCTION_XACC_ATTR_HI  (MU_INSTRUCTION_XACC_ATTR_LO+3)
#define MU_INSTRUCTION_XACC_LO       (MU_INSTRUCTION_XACC_ATTR_HI+1)
#define MU_INSTRUCTION_XACC_HI       (MU_INSTRUCTION_XACC_LO+LOCAL_ADDR_DEPTH-1)
#define MU_INSTRUCTION_XACC_VECTOR   (MU_INSTRUCTION_XACC_HI+1)
#define MU_INSTRUCTION_TYPE_SAVE     (INSTRUCTION_MU_WIDTH-6)
#define MU_INSTRUCTION_OC_LO         (INSTRUCTION_MU_WIDTH-5)
#define MU_INSTRUCTION_OC_HI         (INSTRUCTION_MU_WIDTH-1)

#define IMU_INSTRUCTION_OC_LO         (INSTRUCTION_IMU_WIDTH-5)
#define IMU_INSTRUCTION_OC_HI         (INSTRUCTION_IMU_WIDTH-1)

#define CTRL_INSTRUCTION_OC_LO         (INSTRUCTION_CTRL_WIDTH-5)
#define CTRL_INSTRUCTION_OC_HI         (INSTRUCTION_CTRL_WIDTH-1)


// Class for each instruction
cInstruction::cInstruction(cAstNode *node)
{
   m_alu1.oc=-1;
   m_alu1.x1=0;
   m_alu1.x2=0;
   m_alu1.y=0;
   m_alu1.xacc=0;
   m_alu2.oc=-1;
   m_alu2.x1=0;
   m_alu2.x2=0;
   m_alu2.y=0;
   m_alu2.xacc=0;
   m_imu.oc=-1;
   m_imu.x1=0;
   m_imu.x2=0;
   m_imu.y=0;
   m_control.oc=-1;
   m_control.jumpInstruction=0;
   m_jumpDestination=false;
   m_beginFunc=0;
   m_maxNumThreads=0;
   m_dataModel=0;
   m_node=node;
   m_y_stack=0;
}

cInstruction::~cInstruction()
{
}

// Create an IMU (integer) instruction
RETCODE cInstruction::createIMU(int _oc,cTerm_IMU *_x1,cTerm_IMU *_x2,cTerm_IMU *_y)
{
   // Do paramter check

   m_imu.oc=_oc;
   m_imu.x1=_x1;
   m_imu.x2=_x2;
   m_imu.y=_y;
   return OK;
}

// Create a uncondition jump instruction

RETCODE cInstruction::createUnconditionalJump(int _oc,cInstruction *_jumpInstruction,bool _jumpAfter)
{
   m_control.oc=_oc;
   m_control.jumpInstruction=_jumpInstruction;
   m_control.jumpAfter=_jumpAfter;
   return OK;
}

// Create a conditional jump instruction
RETCODE cInstruction::createConditionalJump(int _control_oc,int _oc,cTerm_IMU *_x1,cTerm_IMU *_x2,cTerm_IMU *y,
                                             cInstruction *_jumpInstruction,bool _jumpAfter)
{
   m_imu.oc=_oc;
   m_imu.x1=_x1;
   m_imu.x2=_x2;
   m_imu.y=y?y:new cTerm_IMU_Null();
   m_control.oc=_control_oc;
   m_control.jumpInstruction=_jumpInstruction;
   m_control.jumpAfter=_jumpAfter;
   return OK;
}

RETCODE cInstruction::createFunctionJump(char *_func,int _stackSize,cIdentifierVector *x_stack,cIdentifier *y_stack)
{
   m_imu.oc=cConfig::IOPCODE_ADD;
   m_imu.x1=new cTerm_IMU_Stack();
   m_imu.x2=new cTerm_IMU_Constant(_stackSize);
   m_imu.y=new cTerm_IMU_Stack();
   m_control.oc=cConfig::OPCODE_FUNC;
   m_control.jumpFunction=_func;
   m_control.jumpAfter=false;
   m_x_stack.clone(x_stack);
   m_y_stack=y_stack;
   return OK;
}

RETCODE cInstruction::updateStackInfo(int _stackSize)
{
   if(m_control.oc != cConfig::OPCODE_FUNC)
      return FAIL;
   CAST(cTerm_IMU_Constant,m_imu.x2)->m_c=_stackSize;
   return OK;
}

RETCODE cInstruction::updateConditionalJump(int _control_oc,cInstruction *_jumpInstruction,bool _jumpAfter)
{
   if(m_imu.oc <= 0)
      return FAIL;
   m_control.oc=_control_oc;
   m_control.jumpInstruction=_jumpInstruction;
   m_control.jumpAfter=_jumpAfter;
   return OK;
}

// Create a MU opcode instruction

RETCODE cInstruction::createMU(int oc,cTerm_MU *x1,cTerm_MU *x2,cTerm_MU *y,cTerm_MU *xacc)
{
   cConfig::eMuOpcodeDefAlu which_alu;
   which_alu=cConfig::GetMuOpcodeDef(oc)->alu;
   // Check if opcode parameters are valid
   if(!isMuParmValid(oc,cConfig::GetMuOpcodeDef(oc)->x1_type,x1))
      error(m_node->m_lineNo,"Invalid parameter");
   if(!isMuParmValid(oc,cConfig::GetMuOpcodeDef(oc)->x2_type,x2))
      error(m_node->m_lineNo,"Invalid parameter");
   if(which_alu==cConfig::eMuOpcodeDefAlu2)
   {
      m_alu2.oc=oc; 
      m_alu2.which_alu=which_alu;
      m_alu2.x1=x1;
      m_alu2.x2=x2;
      m_alu2.y=y;
      m_alu2.xacc=xacc;
   }
   else
   {
      m_alu1.oc=oc; 
      m_alu1.which_alu=which_alu;
      m_alu1.x1=x1;
      m_alu1.x2=x2;
      m_alu1.y=y;
      m_alu1.xacc=xacc;
   }
   return OK;
}

// Is instruction a NOP

bool cInstruction::isNull()
{
   if(m_alu1.oc <= 0 && m_alu2.oc <= 0 && m_imu.oc <= 0 && m_control.oc <= 0)
      return true;
   else
      return false;
}

// Is instruction included a MU operation

bool cInstruction::isMU()
{
   if(m_alu1.oc > 0 || m_alu2.oc > 0)
      return true;
   else
      return false;
}

// Validate parameter to MU operation
bool cInstruction::isMuParmValid(int oc,cConfig::eMuOpcodeDefDataType dataType,cTerm *x)
{
   if(!x->isKindOf(cTerm_MU::getCLID()))
      return false;
#if 0
   if(oc != cConfig::OPCODE_CONV && oc != cConfig::OPCODE_ASSIGN_RAW)
   {
      if(x->isKindOf(cTerm_MU_Integer::getCLID()))
      {
         return false;
      }
   }
#endif
   if(dataType==cConfig::eMuOpcodeDefDataTypeFloat)
   {
      if(x->isKindOf(cTerm_MU_Null::getCLID()))
         return false;
      if( //x->isKindOf(cTerm_MU_Integer::getCLID()) ||
         x->isKindOf(cTerm_MU_Result::getCLID()) ||
         x->isKindOf(cTerm_MU_TID::getCLID()) ||
         (x->isKindOf(cTerm_MU_Constant::getCLID()) && !CAST(cTerm_MU_Constant,x)->m_float))
         return false;
   }
   else if(dataType==cConfig::eMuOpcodeDefDataTypeInt)
   {
      if(x->isKindOf(cTerm_MU_Null::getCLID()))
         return false;
      if(!x->isKindOf(cTerm_MU_Integer::getCLID()) &&
         !x->isKindOf(cTerm_MU_Result::getCLID()) &&
         !x->isKindOf(cTerm_MU_TID::getCLID()) &&
         !(x->isKindOf(cTerm_MU_Constant::getCLID()) && !CAST(cTerm_MU_Constant,x)->m_float))
         return false;
   }
   else if(dataType==cConfig::eMuOpcodeDefDataTypeNull)
   {
      if(!x->isKindOf(cTerm_MU_Null::getCLID()))
         return false;
   }
   else if(dataType==cConfig::eMuOpcodeDefDataTypeRaw)
      return true;
   else
   {
      assert(0);
   }
   return true;
}

// Simplify the IMU opcode
bool cInstruction::simplifyIMU(Instruction_ialu *_imu,Instruction_control *_control)
{
   bool rc=false;
   if(_imu->oc > 0 && _control->oc <= 0)
   {
      // Integer arithmetic operation...

      if(_imu->x1->isKindOf(cTerm_IMU_Constant::getCLID()) &&
         !_imu->x1->isKindOf(cTerm_IMU_AddressConstant::getCLID()) &&
         _imu->x2->isKindOf(cTerm_IMU_Constant::getCLID()) &&
         !_imu->x2->isKindOf(cTerm_IMU_AddressConstant::getCLID())  )
      {
         // Both parameters are constant. Compute now....
         switch(_imu->oc)
         {
         case cConfig::IOPCODE_ADD:
            // Add the 2 constants
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant()+_imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_SUB:
            // Subtract the 2 constants
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant()-_imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_MUL:
            // Mutiply the 2 constants
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant()*_imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_SHL:
            // x1 << x2
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant() << _imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_SHR:
            // x1 >> x2
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant() >> _imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_LSHR:
            // x1 >> x2 (No sign extension)
            _imu->x1=new cTerm_IMU_Constant((unsigned)_imu->x1->getConstant() >> (unsigned)_imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_OR:
             // x1 | x2
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant() | _imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_AND:
            // x1 & x2
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant() & _imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         case cConfig::IOPCODE_XOR:
            // x1 ^ x2
            _imu->x1=new cTerm_IMU_Constant(_imu->x1->getConstant() ^ _imu->x2->getConstant());
            _imu->x2=new cTerm_IMU_Zero();
            _imu->oc=cConfig::IOPCODE_ADD;
            rc=true;
            break;
         default:
            assert(0);
         }
      }
      else if(_imu->oc==cConfig::IOPCODE_ADD &&
         _imu->x1->isKindOf(cTerm_IMU_Constant::getCLID()) &&
         _imu->x1->getConstant()==0 &&
         *_imu->y==*_imu->x2)
      {
         // Add zero has no effect. This can be turned to a NOP
         _imu->oc=-1;
         rc=true;
      }
      else if(_imu->oc==cConfig::IOPCODE_ADD &&
         _imu->x2->isKindOf(cTerm_IMU_Constant::getCLID()) &&
         _imu->x2->getConstant()==0 &&
         *_imu->y==*_imu->x1)
      {
         // Add zero has no effect. This can be turned to a NOP
         _imu->oc=-1;
         rc=true;
      }
      else if(_imu->oc==cConfig::IOPCODE_ADD &&
         _imu->x1->isKindOf(cTerm_IMU_Zero::getCLID()) &&
         *_imu->y==*_imu->x2)
      {
         // Add zero has no effect. This can be turned to a NOP
         _imu->oc=-1;
         rc=true;
      }
      else if(_imu->oc==cConfig::IOPCODE_ADD &&
         _imu->x2->isKindOf(cTerm_IMU_Zero::getCLID()) &&
         *_imu->y==*_imu->x1)
      {
         // Add zero has no effect. This can be turned to a NOP
         _imu->oc=-1;
         rc=true;
      }
   }
   else if(_imu->oc > 0 && _control->oc > 0)
   {
      // This is a control code
      // Is condition can be computed now, change instruction to unconditional
      // jump or nop
      if(((_imu->x1->isKindOf(cTerm_IMU_Constant::getCLID()) && !_imu->x1->isKindOf(cTerm_IMU_AddressConstant::getCLID())) || _imu->x1->isKindOf(cTerm_IMU_Zero::getCLID()) ) &&
         ((_imu->x2->isKindOf(cTerm_IMU_Constant::getCLID()) && !_imu->x2->isKindOf(cTerm_IMU_AddressConstant::getCLID())) || _imu->x2->isKindOf(cTerm_IMU_Zero::getCLID())))
      {
         int result;
         rc=true;
         switch(_imu->oc)
         {
         case cConfig::IOPCODE_ADD:
            result=_imu->x1->getConstant()+_imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_SUB:
            result=_imu->x1->getConstant()-_imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_MUL:
            result=_imu->x1->getConstant()*_imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_SHL:
            result=_imu->x1->getConstant() << _imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_SHR:
            result=_imu->x1->getConstant() >> _imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_LSHR:
            result=(unsigned)_imu->x1->getConstant() >> (unsigned)_imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_OR:
            result=_imu->x1->getConstant() | _imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_AND:
            result=_imu->x1->getConstant() & _imu->x2->getConstant();
            break;
         case cConfig::IOPCODE_XOR:
            result=_imu->x1->getConstant() ^ _imu->x2->getConstant();
            break;
         default:
            assert(0);
         }
         _imu->oc=-1;
         switch(_control->oc)
         {
         case cConfig::OPCODE_RETURN:
            assert(0);
         case cConfig::OPCODE_JUMP_LT:
            if(result < 0)
               _control->oc=cConfig::OPCODE_JUMP;
            else
               _control->oc=-1;
            break;
         case cConfig::OPCODE_JUMP_LE:
            if(result <= 0)
               _control->oc=cConfig::OPCODE_JUMP;
            else
               _control->oc=-1;
            break;
         case cConfig::OPCODE_JUMP_GT:
            if(result > 0)
               _control->oc=cConfig::OPCODE_JUMP;
            else
               _control->oc=-1;
            break;
         case cConfig::OPCODE_JUMP_GE:
            if(result >= 0)
               _control->oc=cConfig::OPCODE_JUMP;
            else
               _control->oc=-1;
            break;
         case cConfig::OPCODE_JUMP_EQ:
            if(result == 0)
               _control->oc=cConfig::OPCODE_JUMP;
            else
               _control->oc=-1;
            break;
         case cConfig::OPCODE_JUMP_NE:
            if(result != 0)
               _control->oc=cConfig::OPCODE_JUMP;
            else
               _control->oc=-1;
            break;
         case cConfig::OPCODE_JUMP:
            assert(0);
         case cConfig::OPCODE_FUNC:
            assert(0);
         default:
            assert(0);
         }
      }
   }
   return rc;
}

// Simplify MU opcode is possible

bool cInstruction::simplifyMU(Instruction_alu *_mu)
{
   bool rc=false;
   int result;
   if(_mu->oc > 0 && 
      _mu->x1->isKindOf(cTerm_MU_Constant::getCLID()) &&
      _mu->x2->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      // Both parameters are constants
      switch(_mu->oc)
      {
      case cConfig::OPCODE_NULL:
         break;
      case cConfig::OPCODE_ADD:
         // x1+x2
         _mu->x1 = new cTerm_MU_Constant(_mu->x1->getConstant()+_mu->x2->getConstant());
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN;
         rc=true;
         break;
      case cConfig::OPCODE_SUB:
         // x1-x2
         _mu->x1 = new cTerm_MU_Constant(_mu->x1->getConstant()-_mu->x2->getConstant());
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN;
         rc=true;
         break;
      case cConfig::OPCODE_MUL:
         // x1*x2
         _mu->x1 = new cTerm_MU_Constant(_mu->x1->getConstant()*_mu->x2->getConstant());
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN;
         rc=true;
         break;
      case cConfig::OPCODE_ASSIGN:
         assert(0);
         break;
      case cConfig::OPCODE_CONV:
         assert(0);
         break;
      case cConfig::OPCODE_CMP_LT:
         // x1 < x2
         result=(_mu->x1->getConstant() < _mu->x2->getConstant())?1:0;
         _mu->x1 = new cTerm_MU_Constant(result);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN_RAW;
         rc=true;
         break;
      case cConfig::OPCODE_CMP_LE:
         // x1 <= x2
         result=(_mu->x1->getConstant() <= _mu->x2->getConstant())?1:0;
         _mu->x1 = new cTerm_MU_Constant(result);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN_RAW;
         rc=true;
         break;
      case cConfig::OPCODE_CMP_GT:
         // x1 > x2
         result=(_mu->x1->getConstant() > _mu->x2->getConstant())?1:0;
         _mu->x1 = new cTerm_MU_Constant(result);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN_RAW;
         rc=true;
         break;
      case cConfig::OPCODE_CMP_GE:
         // x1 >= x2
         result=(_mu->x1->getConstant() >= _mu->x2->getConstant())?1:0;
         _mu->x1 = new cTerm_MU_Constant(result);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN_RAW;
         rc=true;
         break;
      case cConfig::OPCODE_CMP_EQ:
         // x1 == x2
         result=(_mu->x1->getConstant() == _mu->x2->getConstant())?1:0;
         _mu->x1 = new cTerm_MU_Constant(result);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN_RAW;
         rc=true;
         break;
      case cConfig::OPCODE_CMP_NE:
         // x1 != x2
         result=(_mu->x1->getConstant() != _mu->x2->getConstant())?1:0;
         _mu->x1 = new cTerm_MU_Constant(result);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN_RAW;
         rc=true;
         break;
      case cConfig::OPCODE_ASSIGN_RAW:
         assert(0);
         break;
      case cConfig::OPCODE_FMA:
      case cConfig::OPCODE_FMS:
      case cConfig::OPCODE_FNMA:
      case cConfig::OPCODE_FNMS:
      case cConfig::OPCODE_FMA2:
      case cConfig::OPCODE_FMS2:
      case cConfig::OPCODE_FNMA2:
      case cConfig::OPCODE_FNMS2:
         //TODO Replace with ACC_ADD operation
         assert(0);
         break;
      case cConfig::OPCODE_GET_MANTISSA:
         assert(0);
         break;
      case cConfig::OPCODE_GET_EXPONENT:
         assert(0);
         break;
      case cConfig::OPCODE_SET_EXPONENT:
         {
         float v=(float)_mu->x1->getConstant();
         unsigned int v2=*((unsigned int *)&v);
         float v3;
         int ival=(int)(_mu->x2->getConstant());
         v2 = (v2&(~0x7f800000))|((ival&0xff) << 23);
         v3 = *((float *)&v2);
         _mu->x1 = new cTerm_MU_Constant((float)v3);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN;
         }
         rc=true;
         break;
      case cConfig::OPCODE_SET_FLOAT:
         {
         unsigned int v;
         float v2;
         int mantissa=(int)_mu->x1->getConstant();
         int exp=(int)_mu->x2->getConstant();
         exp=(exp+127)&0xff;
         v = (exp << 23)| ((mantissa & ((1<<(IREGISTER_WIDTH-1))-1)) << (23-IREGISTER_WIDTH+1));
         if(mantissa & (1<<(IREGISTER_WIDTH-1)))
            v |= 0x80000000;
         v2 = *((float *)&v);
         _mu->x1 = new cTerm_MU_Constant((float)v2);
         _mu->x2 = new cTerm_MU_Null();
         _mu->oc = cConfig::OPCODE_ASSIGN;
         }
         break;
      default:
         assert(0);
      }
   }
   else if(_mu->oc == cConfig::OPCODE_ADD &&
      _mu->x1->isKindOf(cTerm_MU_Constant::getCLID()) &&
      _mu->x1->getConstant()==0 &&
      *_mu->y==*_mu->x2)
   {
      // Add variables with zero has no effect. 
      // Turn this instruction into a NOP
      _mu->oc=-1;
      rc=true;
   }
   else if(_mu->oc == cConfig::OPCODE_ADD &&
      _mu->x2->isKindOf(cTerm_MU_Constant::getCLID()) &&
      _mu->x2->getConstant()==0 &&
      *_mu->y==*_mu->x1)
   {
      // Add variables with zero has no effect. 
      // Turn this instruction into a NOP
      _mu->oc=-1;
      rc=true;
   }
   return rc;
}

// Try to simply an instruction if possible...
bool cInstruction::simplify()
{
   bool rc=false;
   if(simplifyMU(&m_alu1))
      rc=true;
   if(simplifyMU(&m_alu2))
      rc=true;
   if(simplifyIMU(&m_imu,&m_control))
      rc=true;
   return rc;
}

bool cInstruction::resolveConstantConflict(cInstruction *begin)
{
   cAstNode *func;
   cAstNode *node;
   cInstruction *instruction;
   cInstruction *end;

   end=GetFunctionEnd(begin);
   
   func=begin->getBeginFunc();
   node=begin->getBeginFunc()->getChild(1,eTOKEN_block_item_list);

   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
   if(instruction->m_alu1.oc > 0 &&
      ((instruction->m_alu1.x1->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID()) && CAST(cTerm_MU_PointerWithoutIndex,instruction->m_alu1.x1)->m_baseId->isConst()) ||
      (instruction->m_alu1.x1->isKindOf(cTerm_MU_PointerWithIndex::getCLID()) && CAST(cTerm_MU_PointerWithIndex,instruction->m_alu1.x1)->m_baseId->isConst())))
   {
      if((instruction->m_alu1.x2->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID()) && CAST(cTerm_MU_PointerWithoutIndex,instruction->m_alu1.x2)->m_baseId->isConst()) ||
         (instruction->m_alu1.x2->isKindOf(cTerm_MU_PointerWithIndex::getCLID()) && CAST(cTerm_MU_PointerWithIndex,instruction->m_alu1.x2)->m_baseId->isConst()))
      {
         cInstruction *instruction2,*beforeInstruction;
         cIdentifier *temp;
         cTerm_MU *term;
         
         beforeInstruction=(cInstruction *)instruction->getPrev();
         instruction2 = new cInstruction(node);
         cList::remove(instruction);
         *instruction2=*instruction;
         temp=new cIdentifierPrivate(func->getChild(1,eTOKEN_block_item_list),0,0,instruction2->m_alu1.x2->getVectorWidth());
         if(!temp)
            error(node->m_lineNo,"Out of variable space");
         term=new cTerm_MU_Storage(CAST(cIdentifierPrivate,temp),0);
         instruction->createMU(
                              cConfig::OPCODE_ASSIGN,
                              instruction2->m_alu1.x2,
                              new cTerm_MU_Null(),
                              term);
         instruction2->m_alu1.x2=term;
         PROGRAM.insert(instruction,beforeInstruction);
         PROGRAM.insert(instruction2,instruction);
      }
   }
   }
   return true;
}

// Get the branch instruction
cInstruction *cInstruction::getBranch()
{
   if(m_control.oc <= 0)
      return 0;
   switch(m_control.oc)
   {
      case cConfig::OPCODE_RETURN: 
         return 0;
      case cConfig::OPCODE_JUMP_LT:
      case cConfig::OPCODE_JUMP_LE:
      case cConfig::OPCODE_JUMP_GT:
      case cConfig::OPCODE_JUMP_GE:
      case cConfig::OPCODE_JUMP_EQ:
      case cConfig::OPCODE_JUMP_NE:
      case cConfig::OPCODE_JUMP:
         return m_control.jumpAfter?(cInstruction *)m_control.jumpInstruction->getNext():m_control.jumpInstruction;
      case cConfig::OPCODE_FUNC:
          return 0;
      default:
         assert(0);
         return false;
   }
}

int cInstruction::reverseLogic(int oc)
{
   if(oc <= 0)
      return oc;
   switch(oc)
   {
      case cConfig::OPCODE_RETURN: 
         return cConfig::OPCODE_RETURN;
      case cConfig::OPCODE_JUMP_LT:
         return cConfig::OPCODE_JUMP_GE; 
      case cConfig::OPCODE_JUMP_LE:
         return cConfig::OPCODE_JUMP_GT;
      case cConfig::OPCODE_JUMP_GT:
         return cConfig::OPCODE_JUMP_LE;
      case cConfig::OPCODE_JUMP_GE:
         return cConfig::OPCODE_JUMP_LT;
      case cConfig::OPCODE_JUMP_EQ:
         return cConfig::OPCODE_JUMP_NE;
      case cConfig::OPCODE_JUMP_NE:
         return cConfig::OPCODE_JUMP_EQ;
      case cConfig::OPCODE_JUMP:
         return cConfig::OPCODE_JUMP;
      case cConfig::OPCODE_FUNC:
         return cConfig::OPCODE_FUNC;
      default:
         assert(0);
         return false;
   }
}

// Mark this instruction as the begin of a function
void cInstruction::setBeginFunc(cAstNode *_func)
{
   m_beginFunc=_func;
}

// Assign a label to this instruction
void cInstruction::setLabel(char *_label)
{
   if(!_label)
   {
      m_label.clear();
      return;
   }
   m_label=_label;
}

// Turn this instruction into a nop
void cInstruction::setNOP()
{
   m_alu1.oc=-1;
   m_alu2.oc=-1;
   m_imu.oc=-1;
   m_control.oc=-1;
}

// Get list of identifiers that are referenced in the evaluation of an instruction
void cInstruction::getUse(cIdentifierVector *lst)
{
   lst->clear();
   if(m_control.oc==cConfig::OPCODE_FUNC)
   {
      lst->clone(&m_x_stack);
      return;
   }
   if(m_alu1.oc > 0)
   {
      if(m_alu1.y)
      {
         m_alu1.y->getUse(lst);
         if(m_alu1.y->getVectorWidth() >= 1)
            lst->append(&cIdentifierLane::M_singleInstance);
      }
      m_alu1.x1->getUse(lst);
      m_alu1.x1->getDef(lst);
      m_alu1.x2->getUse(lst);
      m_alu1.x2->getDef(lst);
      if(m_alu1.xacc)
      {
         m_alu1.xacc->getUse(lst);
         m_alu1.xacc->getDef(lst);
      }
   }
   if(m_alu2.oc > 0)
   {
      if(m_alu2.y)
         m_alu2.y->getUse(lst);
      m_alu2.x1->getUse(lst);
      m_alu2.x1->getDef(lst);
      m_alu2.x2->getUse(lst);
      m_alu2.x2->getDef(lst);
      if(m_alu2.xacc)
      {
         m_alu2.xacc->getUse(lst);
         m_alu2.xacc->getDef(lst);
      }
   }
   if(m_imu.oc > 0)
   {
      if(m_imu.y)
         m_imu.y->getUse(lst);
      m_imu.x1->getUse(lst);
      m_imu.x1->getDef(lst);
      m_imu.x2->getUse(lst);
      m_imu.x2->getDef(lst);
   }
}

// Get list of identifiers that are defined by this instruction operation
void cInstruction::getDef(cIdentifierVector *lst)
{
   cIdentifier *id;
   cInstruction *instruction2;
   lst->clear();
   if(m_control.oc==cConfig::OPCODE_FUNC)
   {
      if(m_y_stack)
         lst->append(m_y_stack);
      instruction2=this;
      while(!instruction2->m_beginFunc)
      {
         instruction2=(cInstruction *)instruction2->getPrev();
      }
      id=CAST(cAstCodeBlockNode,instruction2->m_beginFunc->getChild(1,eTOKEN_block_item_list))->getIdentifierList();
      while(id)
      {
         if(id->isKindOf(cIdentifierStack::getCLID()))
            lst->append(id);
         id=(cIdentifier *)id->getNext();
      }
      lst->append(&cIdentifierResult::M_singleInstance);
      return;
   }
   if(m_alu1.oc > 0 && m_alu1.y)
      m_alu1.y->getDef(lst);
   if(m_alu2.oc > 0 && m_alu2.y)
      m_alu2.y->getDef(lst);
   if(m_imu.oc > 0 && m_imu.y)
      m_imu.y->getDef(lst);
}

// Substitute an identifier for another one used in an instruction

void cInstruction::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_alu1.oc > 0)
   {
      if(m_alu1.y)
         m_alu1.y->updateIdentifier(_old,_new);
      if(m_alu1.x1)
         m_alu1.x1->updateIdentifier(_old,_new);
      if(m_alu1.x2)
         m_alu1.x2->updateIdentifier(_old,_new);
   }
   if(m_alu2.oc > 0)
   {
      if(m_alu2.y)
         m_alu2.y->updateIdentifier(_old,_new);
      if(m_alu2.x1)
         m_alu2.x1->updateIdentifier(_old,_new);
      if(m_alu2.x2)
         m_alu2.x2->updateIdentifier(_old,_new);
   }
   if(m_imu.oc > 0)
   {
      if(m_imu.y)
         m_imu.y->updateIdentifier(_old,_new);
      if(m_imu.x1)
         m_imu.x1->updateIdentifier(_old,_new);
      if(m_imu.x2)
         m_imu.x2->updateIdentifier(_old,_new);
   }
}

bool cInstruction::isCommon(cInstruction *other,cTerm **_term,cTerm **_otherTerm)
{
   *_term=0;
   *_otherTerm=0;

   if(m_alu1.oc > 0 && other->m_alu1.oc > 0 && m_alu1.oc==other->m_alu1.oc)
   {
      if(*m_alu1.x1==*other->m_alu1.x1 && *m_alu1.x2==*other->m_alu1.x2)
      {
         *_term=m_alu1.y;
         *_otherTerm=other->m_alu1.y;
         return true;
      }
      else
      {
         if(cConfig::IsMuCommutative(m_alu1.oc))
         {
            if(*m_alu1.x1==*other->m_alu1.x2 && *m_alu1.x2==*other->m_alu1.x1)
            {
               *_term=m_alu1.y;
               *_otherTerm=other->m_alu1.y;
               return true;
            }
            else
               return false;
         }
         else
            return false;
      }
   }
   else if(m_alu2.oc > 0 && other->m_alu2.oc > 0 && m_alu2.oc==other->m_alu2.oc)
   {
      if(*m_alu2.x1==*other->m_alu2.x1 && *m_alu2.x2==*other->m_alu2.x2)
      {
         *_term=m_alu2.y;
         *_otherTerm=other->m_alu2.y;
         return true;
      }
      else
      {
         if(cConfig::IsMuCommutative(m_alu2.oc))
         {
            if(*m_alu2.x1==*other->m_alu2.x2 && *m_alu2.x2==*other->m_alu2.x1)
            {
               *_term=m_alu2.y;
               *_otherTerm=other->m_alu2.y;
               return true;
            }
            else
               return false;
         }
         else
            return false;
      }
   }
   else if(m_control.oc <= 0 && m_imu.oc > 0 && other->m_imu.oc > 0 && m_imu.oc==other->m_imu.oc)
   {
      if(*m_imu.x1==*other->m_imu.x1 && *m_imu.x2==*other->m_imu.x2)
      {
         *_term=m_imu.y;
         *_otherTerm=other->m_imu.y;
         return true;
      }
      else
      {
         if(cConfig::IsImuCommutative(m_imu.oc))
         {
            if(*m_imu.x1==*other->m_imu.x2 && *m_imu.x2==*other->m_imu.x1)
            {
               *_term=m_imu.y;
               *_otherTerm=other->m_imu.y;
               return true;
            }
            else
               return false;
         }
         else
            return false;
      }
   }
   else
      return false;
}

// Get the instruction block where their is one entry point and one exit point

cInstruction *cInstruction::getInstructionBlock(cInstruction *begin,cInstruction *end,cInstruction *curr)
{
   cInstruction *instruction,*branch,*endBlock;
   cInstruction *instruction2,*instruction3;
   int seq=0;

   // First, number of the instructions
   for(instruction3=begin,seq=0;instruction3;instruction3=(instruction3==end)?0:(cInstruction *)instruction3->getNext())
   {
      instruction3->m_seq=seq++;
   }

   endBlock=curr;
   for(instruction=curr;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      branch=instruction->getBranch();
      if(branch==instruction)
         continue;
      if(branch && branch->m_seq < curr->m_seq)
         return 0;
      if(instruction->m_seq > endBlock->m_seq)
         endBlock=instruction;
      if(branch && endBlock->m_seq < branch->m_seq)
         endBlock=branch;
      for(instruction2=begin;instruction2;instruction2=(instruction2==end)?0:(cInstruction *)instruction2->getNext())
      {  
         if(instruction2->m_seq >= curr->m_seq && instruction2->m_seq <= endBlock->m_seq)
            continue;
         branch=instruction2->getBranch();
         if(branch && branch->m_seq >= curr->m_seq && branch->m_seq <= endBlock->m_seq)
            break;
      }
      if(!instruction2)
      {
         if(instruction==endBlock)
            return endBlock;
      }
   }
   return 0;
}

// Check if this instruction is a assignment operation to a constant

bool cInstruction::getConstantAssignment(cTerm **_y,cTerm **_c)
{
   *_y=0;
   *_c=0;
   if(m_alu1.oc == cConfig::OPCODE_ASSIGN && m_alu1.x1->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      *_y=m_alu1.y;
      *_c=m_alu1.x1;
      return true;
   }
   else if(m_alu1.oc == cConfig::OPCODE_ASSIGN_RAW && m_alu1.x1->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      *_y=m_alu1.y;
      *_c=m_alu1.x1;
      return true;
   }
   else if(m_alu2.oc == cConfig::OPCODE_ASSIGN && m_alu2.x1->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      *_y=m_alu2.y;
      *_c=m_alu2.x1;
      return true;
   }
   else if(m_alu2.oc == cConfig::OPCODE_ASSIGN_RAW && m_alu2.x1->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      *_y=m_alu2.y;
      *_c=m_alu2.x1;
      return true;
   }
   else if(m_imu.oc == cConfig::IOPCODE_ADD && m_control.oc <= 0)
   {
      if(m_imu.x2->isKindOf(cTerm_IMU_Zero::getCLID()))
      {
         if(m_imu.x1->isKindOf(cTerm_IMU_Constant::getCLID()) &&
            !m_imu.x1->isKindOf(cTerm_IMU_AddressConstant::getCLID()))
         {
            *_y=m_imu.y;
            *_c=m_imu.x1;
            return true;
         }
         else
            return false;
      } 
      else if(m_imu.x1->isKindOf(cTerm_IMU_Zero::getCLID()))
      {
         if(m_imu.x2->isKindOf(cTerm_IMU_Constant::getCLID()) &&
            !m_imu.x2->isKindOf(cTerm_IMU_AddressConstant::getCLID()))
         {
            *_y=m_imu.y;
            *_c=m_imu.x2;
            return true;
         }
         else
            return false;
      }
   }
   return false;
}

// Perform constant folding and propagration

bool cInstruction::constantFolding(cInstruction *begin,bool _global)
{
   int loop=0;
   cInstruction *endBlock;
   cIdentifierVector def,def2;
   cTerm *y,*c;
   bool cont,cont2;
   cInstruction *instruction,*instruction2,*instruction3;
   cInstruction *end;

   end=GetFunctionEnd(begin);
   cont=true;
   if(begin==end)
      return false;
   while(cont)
   {
      loop++;
      cont=false;
      // Precalculate operations that involve only constants
      for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
      {
         if(instruction->simplify())
            cont=true;
      }
      for(instruction=begin;instruction != end;instruction=(cInstruction *)instruction->getNext())
      {
         if(instruction->m_control.oc > 0)
            continue;
         if(!instruction->getConstantAssignment(&y,&c))
            continue;
         def.clear();
         y->getDef(&def);
         for(instruction2=(cInstruction *)instruction->getNext();instruction2;instruction2=(instruction2==end)?0:(cInstruction *)instruction2->getNext())
         {
            if(instruction2->m_jumpDestination)
               break;
            if(_global && instruction2->m_control.oc > 0)
               endBlock=getInstructionBlock(begin,end,instruction2);
            else
               endBlock=instruction2;
            if(!endBlock)
               break;
            cont2=true;
            for(instruction3=instruction2;;instruction3=(cInstruction *)instruction3->getNext())
            {
               instruction3->getDef(&def2);
               if(def2.exist(&def))
               {
                  cont2=false;
                  break;
               }
               if(instruction3==endBlock)
                  break;
            }
            if(!cont2)
               break;
            for(instruction3=instruction2;instruction3;instruction3=(instruction3==endBlock)?0:(cInstruction *)instruction3->getNext())
            {
               if(instruction3->m_alu1.oc > 0 && *y==*instruction3->m_alu1.x1)
               {
                  instruction3->m_alu1.x1=CAST(cTerm_MU,cTerm::Convert2MU(0,0,0,c));
                  cont=true;
               }
               if(instruction3->m_alu1.oc > 0 && *y==*instruction3->m_alu1.x2)
               {
                  instruction3->m_alu1.x2=CAST(cTerm_MU,cTerm::Convert2MU(0,0,0,c));
                  cont=true;
               }
               if(instruction3->m_alu2.oc > 0 && *y==*instruction3->m_alu2.x1)
               {
                  instruction3->m_alu2.x1=CAST(cTerm_MU,cTerm::Convert2MU(0,0,0,c));
                  cont=true;
               }
               if(instruction3->m_alu2.oc > 0 && *y==*instruction3->m_alu2.x2)
               {
                  instruction3->m_alu2.x2=CAST(cTerm_MU,cTerm::Convert2MU(0,0,0,c));
                  cont=true;
               }
               if(instruction3->m_imu.oc > 0 && *y==*instruction3->m_imu.x1)
               {
                  instruction3->m_imu.x1=CAST(cTerm_IMU,cTerm::Convert2IMU(c));
                  cont=true;
               }
               if(instruction3->m_imu.oc > 0 && *y==*instruction3->m_imu.x2)
               {
                  instruction3->m_imu.x2=CAST(cTerm_IMU,cTerm::Convert2IMU(c));
                  cont=true;
               }
            }
            if(!_global && instruction2->m_control.oc > 0)
               break;
            if(_global)
               instruction2=endBlock;
         }
      }
   }
   return (loop > 1);
}

// Normally integer result from MU are stored in a temporary integer 
// Remove result temporary assignment if not necessary

bool cInstruction::substituteAssignment(cInstruction *begin,bool _global)
{
   cInstruction *instruction,*instruction2,*instruction3;
   cIdentifier *id,*id2;
   int id_offset;
   int id2_offset;
   cInstruction *end;
   cInstruction *endBlock;
   bool rc=false;
   bool cont2;
   cIdentifierVector def2;

   // Remove redundent assigment for integer variables
   end=GetFunctionEnd(begin);
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(instruction->m_imu.oc==cConfig::IOPCODE_ADD && 
         (
         (
         instruction->m_imu.y->isKindOf(cTerm_IMU_Integer::getCLID()) &&
         instruction->m_imu.x1->isKindOf(cTerm_IMU_Result::getCLID()) &&
         instruction->m_imu.x2->isKindOf(cTerm_IMU_Zero::getCLID())
         ) 
         ||
         (
         instruction->m_imu.y->isKindOf(cTerm_IMU_Integer::getCLID()) &&
         instruction->m_imu.x2->isKindOf(cTerm_IMU_Result::getCLID()) &&
         instruction->m_imu.x1->isKindOf(cTerm_IMU_Zero::getCLID())
         ) 
         )
         &&
         instruction->m_control.oc <= 0)
      {
         // There is an X=RESULT assignment
         cIdentifierVector toLst;
         cIdentifierVector fromLst;
         // X=RESULT;
         instruction->getDef(&toLst); // should be=X
         instruction->getUse(&fromLst); // should be=RESULT
         id=CAST(cTerm_IMU_Integer,instruction->m_imu.y)->m_id;
         for(instruction2=(instruction==end)?0:(cInstruction *)instruction->getNext();
            instruction2;
            instruction2=(instruction2==end)?0:(cInstruction *)instruction2->getNext())
         {
            if(instruction2->m_jumpDestination)
               break;
            // Find the next block of codes (single entry and exit point)
            if(_global && instruction2->m_control.oc > 0)
               endBlock=getInstructionBlock(begin,end,instruction2);
            else
               endBlock=instruction2;
            if(!endBlock)
               break;
            cont2=true;
            for(instruction3=instruction2;;instruction3=(cInstruction *)instruction3->getNext())
            {
               // Check if RESULT and X are both not modified in this code block
               instruction3->getDef(&def2);
               if(def2.exist(&toLst))
               {
                  cont2=false;
                  break;
               }
               if(def2.exist(&fromLst))
               {
                  cont2=false;
                  break;
               }
               if(instruction3==endBlock)
                  break;
            }
            if(!cont2)
               break;
            for(instruction3=instruction2;;instruction3=(cInstruction *)instruction3->getNext())
            {
               // Substiture the use of X with RESULT
               if(instruction3->m_imu.oc > 0)
               {
                  if(instruction3->m_imu.x1->isKindOf(cTerm_IMU_Integer::getCLID()) &&
                     CAST(cTerm_IMU_Integer,instruction3->m_imu.x1)->m_id==id)
                  {
                     instruction3->m_imu.x1=new cTerm_IMU_Result();
                     rc=true;
                  }
                  if(instruction3->m_imu.x2->isKindOf(cTerm_IMU_Integer::getCLID()) &&
                     CAST(cTerm_IMU_Integer,instruction3->m_imu.x2)->m_id==id)
                  {
                     instruction3->m_imu.x2=new cTerm_IMU_Result();
                     rc=true;
                  }
               }
               if(instruction3 == endBlock)
                  break;
            }
            if(!_global && instruction2->m_control.oc > 0)
               break;
            if(_global)
               instruction2=endBlock;
         }
      }
   }

   // Remove redundent assigment for stack variables
#if 1
   end=GetFunctionEnd(begin);
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(instruction->m_alu1.oc > 0 &&
         instruction->m_alu1.y->isKindOf(cTerm_MU_Storage::getCLID()))
      {
         cIdentifierVector toLst;
         cIdentifierVector fromLst;
         bool selfMod;
         // X=RESULT;
         instruction->getDef(&toLst); // should be=X
         instruction->getUse(&fromLst); // should be=RESULT
         id=CAST(cTerm_MU_Storage,instruction->m_alu1.y)->m_id;
         id_offset=CAST(cTerm_MU_Storage,instruction->m_alu1.y)->m_offset;

         instruction->getDef(&def2);
         if(def2.exist(&fromLst))
            selfMod=true;
         else
            selfMod=false;


         for(instruction2=(instruction==end)?0:(cInstruction *)instruction->getNext();
            instruction2;
            instruction2=(instruction2==end)?0:(cInstruction *)instruction2->getNext())
         {
            if(instruction2->m_jumpDestination)
               break;
            // Find the next block of codes (single entry and exit point)
            if(_global && instruction2->m_control.oc > 0)
               endBlock=getInstructionBlock(begin,end,instruction2);
            else
               endBlock=instruction2;
            if(!endBlock)
               break;
            cont2=true;
            for(instruction3=instruction2;;instruction3=(cInstruction *)instruction3->getNext())
            {
               // Check if RESULT and X are both not modified in this code block
               instruction3->getDef(&def2);
               if(def2.exist(&toLst))
               {
                  cont2=false;
                  break;
               }
               if(def2.exist(&fromLst))
               {
                  cont2=false;
                  break;
               }
               if(instruction3==endBlock)
                  break;
            }
            if(endBlock != instruction2)
            {
               if(!cont2)
                  break;
            }
            for(instruction3=instruction2;instruction3;instruction3=(instruction3==endBlock)?0:(cInstruction *)instruction3->getNext())
            {
               // Substiture the use of X with RESULT
               if(instruction->m_alu1.oc==cConfig::OPCODE_ASSIGN)
               {
                  if(!instruction->m_alu1.x1->isKindOf(cTerm_MU_Storage::getCLID()))
                     continue;
                  id2=CAST(cTerm_MU_Storage,instruction->m_alu1.x1)->m_id;
                  id2_offset=CAST(cTerm_MU_Storage,instruction->m_alu1.x1)->m_offset;
                  if(instruction3->m_alu1.oc > 0)
                  {
                     if(instruction3->m_alu1.x1->isKindOf(cTerm_MU_Storage::getCLID()) &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_id==id &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_offset==id_offset)
                     {
                        instruction3->m_alu1.x1=new cTerm_MU_Storage(CAST(cIdentifierStorage,id2),id2_offset);
                        rc=true;
                     }
                     if(instruction3->m_alu1.x2->isKindOf(cTerm_MU_Storage::getCLID()) &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x2)->m_id==id &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x2)->m_offset==id_offset)
                     {
                        instruction3->m_alu1.x2=new cTerm_MU_Storage(CAST(cIdentifierStorage,id2),id2_offset);
                        rc=true;
                     }
                     if(instruction3->m_alu1.oc==cConfig::OPCODE_ASSIGN && 
                        instruction3->m_alu1.x1->isKindOf(cTerm_MU_Storage::getCLID()) &&
                        instruction3->m_alu1.y->isKindOf(cTerm_MU_Storage::getCLID()) &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_id==CAST(cTerm_MU_Storage,instruction3->m_alu1.y)->m_id &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_offset==CAST(cTerm_MU_Storage,instruction3->m_alu1.y)->m_offset )
                     {
                        instruction3->setNOP();
                        rc=true;
                     }
                  }
               }
               else
               {
                  if(cConfig::GetMuOpcodeDef(instruction->m_alu1.oc)->group < 0 &&
                     instruction3->m_alu1.oc==cConfig::OPCODE_ASSIGN)
                  {
                     if(!instruction3->m_alu1.y->isKindOf(cTerm_MU_Storage::getCLID()) &&
                        !instruction3->m_alu1.y->isDouble())
                        continue;
                     if(instruction3->m_alu1.x1->isKindOf(cTerm_MU_Storage::getCLID()) &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_id==id &&
                        CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_offset==id_offset &&
                        !selfMod)
                     {
                        instruction3->m_alu1.oc=instruction->m_alu1.oc;
                        instruction3->m_alu1.x1=instruction->m_alu1.x1;
                        instruction3->m_alu1.x2=instruction->m_alu1.x2;
                        instruction3->m_alu1.xacc=instruction->m_alu1.xacc;
                        rc=true;
                        if(instruction3->m_alu1.oc==cConfig::OPCODE_ASSIGN && 
                           instruction3->m_alu1.x1->isKindOf(cTerm_MU_Storage::getCLID()) &&
                           instruction3->m_alu1.y->isKindOf(cTerm_MU_Storage::getCLID()) &&
                           CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_id==CAST(cTerm_MU_Storage,instruction3->m_alu1.y)->m_id &&
                           CAST(cTerm_MU_Storage,instruction3->m_alu1.x1)->m_offset==CAST(cTerm_MU_Storage,instruction3->m_alu1.y)->m_offset )
                        {
                           instruction3->setNOP();
                        }
                     }
                  }
               }
            }
            if(endBlock == instruction2)
            {
               if(!cont2)
                  break;
            }
            if(!_global && instruction2->m_control.oc > 0)
               break;
            if(_global)
               instruction2=endBlock;
         }
      }
   }
#endif
   return rc;
}

// Remove dead code (unreachable code)
void cInstruction::removeDeadCode2(cInstruction *instruction)
{
   cInstruction *branch;
   for(;;)
   {
      if(instruction->m_flag)
         break;
      instruction->m_flag=true;
      if(instruction->m_control.oc==cConfig::OPCODE_RETURN)
         break;
      branch=instruction->getBranch();
      if(branch && !branch->m_flag)
         removeDeadCode2(branch);
      if(instruction->m_control.oc==cConfig::OPCODE_JUMP)
         break;
      instruction=(cInstruction *)instruction->getNext();
   }
}

// Combine VMASK with some other instructions
// VMASK takes into effect at same instruction with MU
bool cInstruction::compress_vmask(cInstruction *begin)
{
   cInstruction *end,*instruction,*instruction2;
   bool rc=false;

   end=GetFunctionEnd(begin);
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(instruction->m_jumpDestination)
         continue;
      if(instruction->m_alu1.oc < 0 && instruction->m_alu2.oc < 0 && instruction->m_control.oc < 0 && 
         instruction->m_imu.oc >= 0 && instruction->m_imu.y->isKindOf(cTerm_IMU_Lane::getCLID()))
      {
         // This is the VMASK update. Can combine with next instruction is next instruction is a pure MU instruction

         for(instruction2=(instruction==end)?0:(cInstruction *)instruction->getNext();
             instruction2;
             instruction2=(instruction2==end)?0:(cInstruction *)instruction2->getNext())
         {
            // Scan forward
            if(instruction2->m_jumpDestination)
               break;
            if(instruction2->m_control.oc >= 0)
               break;
            if(instruction2->m_imu.oc >= 0 && instruction2->m_imu.x1->isKindOf(cTerm_IMU_Lane::getCLID()))
               break;
            if(instruction2->m_imu.oc >= 0 && instruction2->m_imu.x2->isKindOf(cTerm_IMU_Lane::getCLID()))
               break;
            if(instruction2->m_imu.oc >= 0 && instruction2->m_imu.y->isKindOf(cTerm_IMU_Lane::getCLID()))
               break;
         
            if(instruction2->m_alu1.oc >= 0 && instruction2->m_imu.oc < 0 && 
               instruction2->m_control.oc < 0 )
            {
               instruction2->m_imu=instruction->m_imu;
               instruction->setNOP();
               rc=true;
               break;
            }
         }
      }
   }
   return rc;
}

// Remove any dead code

void cInstruction::removeDeadCode(cInstruction *begin)
{
   cInstruction *instruction;
   cInstruction *end;
   end=GetFunctionEnd(begin);
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      instruction->m_flag=false;
   }
   removeDeadCode2(begin);
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(!instruction->m_flag)
         instruction->setNOP();
   }
}

// Calculate defined and usage count of all variables in a function

void cInstruction::UpdateVariableUsage(cInstruction *begin,cInstruction *end)
{
   cInstruction *instruction;
   cIdentifier *id;
   cIdentifierVector use,def;
   int i;

   id=CAST(cAstCodeBlockNode,begin->getBeginFunc()->getChild(1,eTOKEN_block_item_list))->getIdentifierList();
   while(id)
   {
      id->m_defCount=0;
      id->m_useCount=0;
      id=(cIdentifier *)id->getNext();
   }
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      instruction->getUse(&use);
      instruction->getDef(&def);
      for(i=0;i < (int)use.size();i++)
         use[i]->m_useCount++;
      for(i=0;i < (int)def.size();i++)
         def[i]->m_defCount++;
   }
}

// Do common expression substitution both local and global scope

bool cInstruction::findCommonExpression(cInstruction *begin)
{
   cInstruction *instruction,*instruction2,*instruction3;
   cIdentifierVector use,def,use2,def2,use3,def3;
   cInstruction *end;
   int i;
   cIdentifier *id;

   end=GetFunctionEnd(begin);
   if(begin==end)
      return true;
   // Get usage and definition count for each variables used in this function

   UpdateVariableUsage(begin,end);

   // Remove redundadent operation
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      instruction->simplify();
   }

   // Remove alias
   for(instruction=begin;instruction != end;instruction=(cInstruction *)instruction->getNext())
   {
      void *tempTerm,*tempTerm2;
      if(instruction->m_control.oc > 0)
         continue;
      if((instruction->m_alu1.oc > 0 && instruction->m_alu1.y->isKindOf(cTerm_MU_Storage::getCLID())))
         tempTerm=&instruction->m_alu1.y;
      else if(instruction->m_alu2.oc > 0 && instruction->m_alu2.y->isKindOf(cTerm_MU_Storage::getCLID()))
         tempTerm=&instruction->m_alu2.y;
      else if(instruction->m_imu.oc > 0 && instruction->m_control.oc <= 0 && instruction->m_imu.y->isKindOf(cTerm_IMU_Integer::getCLID()))
         tempTerm=&instruction->m_imu.y;
      else
         tempTerm=0;
      if(tempTerm)
      {
         instruction->getDef(&def);
         if(def.size()==1 && def[0]->m_useCount==1 && def[0]->m_defCount==1 && !def[0]->isFixed())
         {
            for(instruction2=(cInstruction *)instruction->getNext();
               instruction2;
               instruction2=(instruction2==end)?0:(cInstruction *)instruction2->getNext())
            {
               instruction2->getUse(&use2);
               instruction2->getDef(&def2);
               if(instruction2->m_jumpDestination)
                  break;
               if(instruction2->m_alu1.oc == cConfig::OPCODE_ASSIGN && instruction2->m_alu1.x1->isKindOf(cTerm_MU_Storage::getCLID()))
               {
                  id=CAST(cTerm_MU_Storage,instruction2->m_alu1.x1)->m_id;
                  tempTerm2=&instruction2->m_alu1.y;
               }
               else if(instruction2->m_alu2.oc == cConfig::OPCODE_ASSIGN && instruction2->m_alu2.x1->isKindOf(cTerm_MU_Storage::getCLID()))
               {
                  id=CAST(cTerm_MU_Storage,instruction2->m_alu2.x1)->m_id;
                  tempTerm2=&instruction2->m_alu2.y;
               }
               else if(instruction2->m_control.oc <= 0 && instruction2->m_imu.oc==cConfig::IOPCODE_ADD && instruction2->m_imu.x2->isKindOf(cTerm_IMU_Zero::getCLID())
                        && instruction2->m_imu.x1->isKindOf(cTerm_IMU_Integer::getCLID()))
               {
                  id=CAST(cTerm_IMU_Integer,instruction2->m_imu.x1)->m_id;
                  tempTerm2=&instruction2->m_imu.y;
               }
               else if(instruction2->m_control.oc <= 0 && instruction2->m_imu.oc==cConfig::IOPCODE_ADD && instruction2->m_imu.x1->isKindOf(cTerm_IMU_Zero::getCLID())
                        && instruction2->m_imu.x2->isKindOf(cTerm_IMU_Integer::getCLID()))
               {
                  id=CAST(cTerm_IMU_Integer,instruction2->m_imu.x2)->m_id;
                  tempTerm2=&instruction2->m_imu.y;
               }
               else
               {
                  id=0;
                  tempTerm2=0;
               }
               if(tempTerm2 && id==def[0])
               {
                  assert(def2.size()>0);
                  for(instruction3=(cInstruction *)instruction->getNext();
                     instruction3;
                     instruction3=(cInstruction *)instruction3->getNext())
                  {
                     if(instruction3==instruction2)
                        break;
                     instruction3->getDef(&def3);
                     instruction3->getDef(&use3);
                     if(def3.exist(&def2))
                        break;
                     if(use3.exist(&def2))
                        break;
                  }
                  if(instruction3==instruction2)
                  {
                     *((cTerm **)tempTerm)=*((cTerm **)tempTerm2);
                     instruction2->setNOP();
                  }
                  break;
               }
               if(instruction2->m_control.oc > 0)
                  break;
            }
         }
      }
   }

   // Remove unused variable

   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      instruction->getDef(&def);
      if(def.size()==1 && def[0]->m_useCount==0 && instruction->m_control.oc <= 0 && !def[0]->isFixed())
      {
         if(instruction->m_alu1.oc <= 0 || cConfig::GetMuOpcodeDef(instruction->m_alu1.oc)->group < 0)
            instruction->setNOP();
      }
      // Exit code is to save parameter variable. But if only set twice that means it's not being
      // modified. So no need for exit code...
      if(def.size()==1 && def[0]->getAlias() && def[0]->getAlias()->m_defCount==1)
         instruction->setNOP();
   }

   id=CAST(cAstCodeBlockNode,begin->getBeginFunc()->getChild(1,eTOKEN_block_item_list))->getIdentifierList();
   while(id)
   {
      id->m_defCount=0;
      id->m_useCount=0;
      id=(cIdentifier *)id->getNext();
   }

   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      instruction->getUse(&use);
      instruction->getDef(&def);
      for(i=0;i < (int)use.size();i++)
         use[i]->m_useCount++;
      for(i=0;i < (int)def.size();i++)
         def[i]->m_defCount++;
   }
   return true;
}

// Get default next instruction to execute
cInstruction *cInstruction::getNextInstruction()
{
   if(!getNext() || ((cInstruction *)getNext())->m_beginFunc)
      return 0;
   if(m_control.oc==cConfig::OPCODE_RETURN || m_control.oc==cConfig::OPCODE_JUMP)
      return 0;
   return (cInstruction *)getNext();
}

// Get jump instruction resulted from a control instruction
cInstruction *cInstruction::getJumpInstruction()
{
   cInstruction *next;
   if(m_control.oc > 0 && m_control.oc != cConfig::OPCODE_RETURN)
      next= m_control.jumpInstruction;
   else
      next=0;
   if(next && m_control.jumpAfter)
      next=(cInstruction *)next->getNext();
   if(next==getNextInstruction())
      next=0;
   return next;
}

// Advance jump destination as far as possible without changing behaviour.
// Skip NOP code.
bool cInstruction::compress_jump(cInstruction *begin)
{
   cInstruction *instruction;
   cInstruction *next;
   instruction=begin;
   bool rc=false;
   cInstruction *end;
   // Skip nop for jump destination
   end=GetFunctionEnd(begin);
   while(instruction)
   {
      instruction->m_jumpDestination=false;
      next=(instruction==end)?0:(cInstruction *)instruction->getNext();
      while(next && next->isNull())
         next=(next==end)?0:(cInstruction *)next->getNext();
      if(instruction->getJumpInstruction()  && !instruction->m_control.jumpAfter && instruction->getJumpInstruction()==next)
      {
         instruction->setNOP();
         rc=true;
      }
      else if(instruction->getJumpInstruction() && instruction->m_control.jumpAfter && instruction->getJumpInstruction()==instruction)
      {
         instruction->setNOP();
         rc=true;
      }
      if(instruction==end)
         break;
      instruction=(cInstruction *)instruction->getNext();
   }

   // Determine correct jump destination 
   instruction=begin;
   while(instruction)
   {
      if(instruction->m_control.oc > 0 && instruction->m_control.jumpInstruction)
      {
         if(instruction->m_control.jumpAfter)
         {
            for(;;)
            {
               if(instruction->m_control.jumpInstruction==end)
                  break;
               instruction->m_control.jumpInstruction=(cInstruction *)(instruction->m_control.jumpInstruction->getNext());
               if(!instruction->m_control.jumpInstruction->isNull())
                  break;
            }
            instruction->m_control.jumpAfter=false;
         }
         else
         {
            for(;;)
            {
               if(instruction->m_control.jumpInstruction==end)
                  break;
               if(!instruction->m_control.jumpInstruction->isNull())
                  break;
               instruction->m_control.jumpInstruction=(cInstruction *)(instruction->m_control.jumpInstruction->getNext());
            }
         }
         instruction->m_control.jumpInstruction->m_jumpDestination=true;
      }
      if(instruction==end)
         break;
      instruction=(cInstruction *)instruction->getNext();
   }

   // Optimize for single instruction if then... statement

   instruction=begin;
   while(instruction)
   {
      cInstruction *branch,*next,*nextnext;
      branch=instruction->getBranch();
      next=(instruction==end)?0:(cInstruction *)instruction->getNext();
      if(next)
         nextnext=(next==end)?0:(cInstruction *)next->getNext();
      else
         nextnext=0;
      while(nextnext && nextnext->isNull())
      {
         if(nextnext==end)
            break;
         nextnext=(cInstruction *)nextnext->getNext();
      }
      if(branch && 
         branch==nextnext && next && next->m_control.oc==cConfig::OPCODE_JUMP)
      {
         instruction->m_control.oc=cInstruction::reverseLogic(instruction->m_control.oc);
         instruction->m_control.jumpInstruction=next->m_control.jumpInstruction;
         next->setNOP();
         rc=true;
      }
      instruction=next;
   }

   // Optimize for unconditional loop
   instruction=begin;
   while(instruction)
   {
      cInstruction *branch;

      if(instruction->m_control.oc==cConfig::OPCODE_JUMP)
      {
         branch=instruction->m_control.jumpInstruction;
         if(branch->m_control.oc==cConfig::OPCODE_JUMP)
         {
            instruction->m_control.jumpInstruction=branch->m_control.jumpInstruction;
            rc=true;
         }
      }
      instruction=(instruction==end)?0:(cInstruction *)instruction->getNext();
   }
   return rc;
}

// Check if in a instruction execution, X parameters are dependent on a result Y of 
// a previous instruction
bool cInstruction::check_independent(cTerm *y,cTerm *x)
{
   if(!y || !x )
      return true;
   return x->independent(y);
}

// Check if both instructions can be compressed in the same instruction
bool cInstruction::can_fit(cInstruction *instruction1,cInstruction *instruction2)
{
   // Check if combined instruction have enough slots to hold all the constants
   if(instruction1->m_alu1.oc > 0 && instruction2->m_alu1.oc > 0)
      return false;
   if(instruction1->m_control.oc > 0 && instruction2->m_control.oc > 0)
      return false;
   if(instruction1->m_imu.oc > 0 && instruction2->m_imu.oc > 0)
      return false;
   return true;
}


// Check for independent when trying to combining 2 instructions
// Check if opcode with x1,x2,y terms can be combined to instruction to
// Return 
//   -1 :FAIL
//   -2 :FAIL but continue
//   +0 :DONE
//   +1 :OK but continue
int cInstruction::combine(
   cInstruction *to, // Instruction to move the opcode to
   int type, // Type of opcode to be moved
   int oc, // Opcode to be moved
   int alu, // Which ALU for the opcode when type is MU operation
   cTerm *x1, // x1 parameter of the op to be moved
   cTerm *x2, // x2 parameters of the op to be moved
   cTerm *xacc, // accumulated input
   cTerm *y // y parameters of the op to be moved
   )
{
   bool last=false;

   if( oc > 0 && to->m_alu1.oc > 0 &&
       cConfig::GetMuOpcodeDef(oc)->group >= 0 &&
       cConfig::GetMuOpcodeDef(oc)->group == cConfig::GetMuOpcodeDef(to->m_alu1.oc)->group)
       return RC_FAIL;
 
   // Check for constant slot availability

   if(to->m_jumpDestination)
      last=true; // Can't moved to jump destination
   if(type==INSTRUCTION_TYPE_CONTROL && oc > 0)
      last=true; // Last chance to merge
   if(to->m_control.oc > 0)
      return RC_FAIL; // Can't move to an instruction where there may be a jump
   if(y&&y->isKindOf(cTerm_IMU_Lane::getCLID()))
      return RC_FAIL; // Cannot move a VMASK. This is done later...
   if(!check_independent(to->m_alu1.y,x1))
      return RC_FAIL; // Can't move because x1 has to be after y result
   if(!check_independent(to->m_alu1.y,x2))
      return RC_FAIL; // Can't move because x2 has to be after y result
   if(!check_independent(to->m_alu1.y,xacc))
      return RC_FAIL; // Can't move because xacc has to be after y result
   if(!check_independent(to->m_alu1.y,y))
      return RC_FAIL; // Can't move because there is conflict in y result
   if(!check_independent(to->m_alu2.y,x1))
      return RC_FAIL; // Can't move because x1 has to be after y result
   if(!check_independent(to->m_alu2.y,x2))
      return RC_FAIL; // Can't move because x2 has to be after y result
   if(!check_independent(to->m_alu2.y,xacc))
      return RC_FAIL; // Can't move because xacc has to be after y result
   if(!check_independent(to->m_alu2.y,y))
      return RC_FAIL; // Can't move because there is a conflict in y result
   if(!check_independent(to->m_imu.y,x1))
      return RC_FAIL; // Can't move because x1 has to be after y result
   if(!check_independent(to->m_imu.y,x2))
      return RC_FAIL; // Can't move because x2 has to be after y result
   if(!check_independent(to->m_imu.y,y))
      return RC_FAIL; // Can't move because there is a conflict with y result
   if(!check_independent(y,to->m_alu1.x1))
      last=true; // Can't move because x1 has to be after y result
   if(!check_independent(y,to->m_alu1.x2))
      last=true; // Can't move because x2 has to be after y result
   if(!check_independent(y,to->m_alu1.xacc))
      last=true; // Can't move because xacc has to be after y result
   if(!check_independent(y,to->m_alu1.y)) 
   {
      if(type==INSTRUCTION_TYPE_IMU)
         last=true; // this is the last chance to combine
      else
         return RC_FAIL;
   }
   if(!check_independent(y,to->m_alu2.x1)) 
      last=true; // this is the last chance to combine
   if(!check_independent(y,to->m_alu2.x2)) 
      last=true; // this is the last chance to combine
   if(!check_independent(y,to->m_alu2.xacc)) 
      last=true; // this is the last chance to combine
   if(!check_independent(y,to->m_alu2.y)) 
   {
      if(type==INSTRUCTION_TYPE_IMU)
         last=true; // this is the last chance to combine
      else
         return RC_FAIL;
   }
   if(!check_independent(y,to->m_imu.x1)) 
      last=true; // this is the last chance to combine
   if(!check_independent(y,to->m_imu.x2)) 
      last=true; // this is the last chance to combine
   if(!check_independent(y,to->m_imu.y))
      return RC_FAIL;
   switch(type)
   {
   case INSTRUCTION_TYPE_MU:
      if(alu==0)
      {
         if(to->m_alu1.oc > 0)
            return last?RC_FAIL:RC_FAIL_CONT;
      }
      else
      {
         if(to->m_alu2.oc > 0)
            return last?RC_FAIL:RC_FAIL_CONT;
      }
      break;
   case INSTRUCTION_TYPE_IMU:
      if(to->m_imu.oc > 0)
         return last?RC_FAIL:RC_FAIL_CONT;
      break;
   case INSTRUCTION_TYPE_CONTROL:
      if(to->m_control.oc > 0)
         return last?RC_FAIL:RC_FAIL_CONT;
      break;
   default:
      assert(0);
   }
   return last?RC_OK_LAST:RC_OK_CONT;
}

// Try to compress a instruction
// Traverse upward in the function to find an instruction to merge with....
bool cInstruction::compressInstruction(cInstruction *begin_of_func,cInstruction *instruction)
{
   cInstruction *curr;
   int index;
   int rc;
   int rc2[4];
   cInstruction *found=0;
   int type,oc;
   cTerm *x1,*x2,*xacc,*y;
   int alu;

   if(instruction->m_jumpDestination)
      return false;
   if(instruction==begin_of_func)
      return false;
   curr=(cInstruction *)(instruction->getPrev());
   for(;;)
   {
      for(index=0;index < 4;index++)
      {
         rc2[index]=1;
         if(index==0 && instruction->m_alu1.oc > 0)
         {
            // Try to merge MU opcode from ALU1
            type=INSTRUCTION_TYPE_MU;
            oc=instruction->m_alu1.oc;
            alu=0;
            x1=instruction->m_alu1.x1;
            x2=instruction->m_alu1.x2;
            xacc=instruction->m_alu1.xacc;
            y=instruction->m_alu1.y;
          }
         else if(index==1 && instruction->m_alu2.oc > 0)
         {
            // Try to merge MU opcode from ALU2
            type=INSTRUCTION_TYPE_MU;
            oc=instruction->m_alu2.oc;
            alu=1;
            x1=instruction->m_alu2.x1;
            x2=instruction->m_alu2.x2;
            xacc=instruction->m_alu2.xacc;
            y=instruction->m_alu2.y;
         }
         else if(index==2 && instruction->m_imu.oc > 0)
         {
            // Try to merge IMU opcode
            type=INSTRUCTION_TYPE_IMU;
            oc=instruction->m_imu.oc;
            alu=0;
            x1=instruction->m_imu.x1;
            x2=instruction->m_imu.x2;
            xacc=0;
            y=instruction->m_imu.y;
         }
         else if(index==3 && instruction->m_control.oc > 0)
         {
            type=INSTRUCTION_TYPE_CONTROL;
            oc=instruction->m_control.oc;
            alu=0;
            x1=0;
            x2=0;
            xacc=0;
            y=0;
         }
         else
            continue;
         rc2[index]=combine(curr,type,oc,alu,x1,x2,xacc,y);
      }

      // check for any failure
      // Can only merge if all slots can be merged the same time
      rc=1;
      for(index=0;index < 4;index++)
      {
         if(rc2[index]==RC_FAIL)
         {
            rc=RC_FAIL;
            break;
         }
      }
      if(index >= 4)
      {
         for(index=0;index < 4;index++)
         {
            if(rc2[index]==RC_FAIL_CONT)
            {
               rc=RC_FAIL_CONT;
               break;
            }
         }
         if(index >= 4)
         {
            for(index=0;index < 4;index++)
            {
               if(rc2[index]==RC_OK_LAST)
               {
                  rc=RC_OK_LAST;
                  break;
               }
            }
         }
         else
         {
            for(index=0;index < 4;index++)
            {
               if(rc2[index]==0)
               {
                  rc=RC_FAIL;
                  break;
               }
            }
         }
      }
#if 1
      if(curr->isNull())
      {
         if(rc==RC_OK_LAST)
            rc=RC_FAIL;
         else if(rc==RC_OK_CONT)
            rc=RC_FAIL_CONT;
      }
#endif
      if(rc==RC_OK_LAST)
      {
         if(!can_fit(instruction,curr))
            rc=RC_FAIL;
      }
      else if(rc==RC_OK_CONT)
      {
         if(!can_fit(instruction,curr))
            rc=RC_FAIL_CONT;
      }
      if(rc==RC_OK_LAST)
      {
         found=curr;
         break;
      }
      if(rc==RC_OK_CONT)
         found=curr;
      else if(rc==RC_FAIL)
         break;
      if(curr==begin_of_func)
         break;
      if(instruction->m_control.oc > 0)
         break;
      // Stop at first found....
      if(found)
         break;
      curr=(cInstruction *)curr->getPrev();
   }
   if(!found)
      return false;
   if(instruction->m_alu1.oc > 0)
   {
      found->m_alu1=instruction->m_alu1;
   }
   if(instruction->m_alu2.oc > 0)
      found->m_alu2=instruction->m_alu2;
   if(instruction->m_imu.oc > 0)
      found->m_imu=instruction->m_imu;
   if(instruction->m_control.oc > 0)
      found->m_control=instruction->m_control;
   assert(instruction != begin_of_func);
   cList::remove(instruction);
   return true;
}

// Compress instruction
// Try to combine instructions if this donot change the behaviour of the program

bool cInstruction::compressFunction(cInstruction *begin)
{
   bool cont;
   cInstruction *instruction;
   cInstruction *prev;
   cInstruction *end;

   end=GetFunctionEnd(begin);
   if(begin==end)
      return true;
   cont=true;
   while(cont)
   {
   cont=false;
   instruction=GetFunctionEnd(begin);
   while(instruction)
   {
      if(instruction==begin)
         break;
      else
         prev=(cInstruction *)instruction->getPrev();
      if(instruction->m_control.oc <= 0)
      {
         if(!compressInstruction(begin,instruction))
         {
            // Fail to compress. If this opcode can occupy on either MU then try to change ALU if possible
            // and then try to compress again
            if(instruction->m_alu1.oc > 0 && instruction->m_alu1.which_alu == 2 && instruction->m_alu2.oc < 0)
            {
               instruction->m_alu2=instruction->m_alu1;
               instruction->m_alu1.oc=-1;
               if(compressInstruction(begin,instruction))
                  cont=true;
            }
            else if(instruction->m_alu2.oc > 0 && instruction->m_alu2.which_alu==2 && instruction->m_alu1.oc <= 0)
            {
               instruction->m_alu1=instruction->m_alu2;
               instruction->m_alu2.oc=-1;
               if(compressInstruction(begin,instruction))
                  cont=true;
            }
         }
         else
            cont=true;
      }
      instruction=prev;
   }
   }
   instruction=GetFunctionEnd(begin);
   while(instruction)
   {
      if(instruction==begin)
         break;
      else
         prev=(cInstruction *)instruction->getPrev();
      if(instruction->m_control.oc > 0)
      {
         if(compressInstruction(begin,instruction))
            cont=true;
      }
      instruction=prev;
   }
   return true;
}

// Check if a range instructions represent a linear flow without any jump
bool cInstruction::InstructionsLinearFlow(cInstruction *begin,cInstruction *end,bool after,bool before)
{
   cInstruction *instruction;
   cIdentifierVector use;
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(instruction==begin && after)
         continue;
      if(instruction==end && before)
         continue;
      if(instruction->m_jumpDestination)
         return false;
      if(instruction->m_control.oc > 0)
         return false;
   }
   return true;
}

// Check if a range of instructions use any of the variables in lst
bool cInstruction::InstructionsUse(cInstruction *begin,cInstruction *end,bool after,bool before,cIdentifierVector *lst)
{
   cInstruction *instruction;
   cIdentifierVector use;
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(instruction==begin && after)
         continue;
      if(instruction==end && before)
         continue;
//      if(instruction->m_jumpDestination)
//         return true;
      instruction->getUse(&use);
      if(lst->exist(&use))
         return true;
   }
   return false;
}

// Check if a range of instructions define any of the variables in lst
bool cInstruction::InstructionsDef(cInstruction *begin,cInstruction *end,bool after,bool before,cIdentifierVector *lst)
{
   cInstruction *instruction;
   cIdentifierVector def;
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(instruction==begin && after)
         continue;
      if(instruction==end && before)
         continue;
      instruction->getDef(&def);
      if(lst->exist(&def))
         return true;
   }
   return false;
}

bool cInstruction::fm(cInstruction *begin)
{
   return fm_int(begin);
}

// Compress instructions into FMA,FMS,FNMA or FNMS if possible

bool cInstruction::fm_int(cInstruction *begin)
{
   cInstruction *instruction,*instruction2;
   cInstruction *invertInstruction;
   cInstruction *end;
   cTerm_MU *y;
   bool retval=false;

   end=GetFunctionEnd(begin);
   if(begin==end)
      return false;
   UpdateVariableUsage(begin,end);

   // Find usage pattern from FMXX instructions
   for(instruction=begin;instruction;instruction=(instruction==end)?0:(cInstruction *)instruction->getNext())
   {
      if(instruction->m_alu1.oc == cConfig::OPCODE_MUL)
      {
         // Check if we can combine a multiplication with an addition/subtraction with accumulator...
         invertInstruction=0;
         y=instruction->m_alu1.y;
         if(instruction->m_jumpDestination)
            continue;
         if(!y->isKindOf(cTerm_MU_Storage::getCLID()))
            continue;
         if(CAST(cTerm_MU_Storage,y)->m_id->m_useCount != 1 ||
            CAST(cTerm_MU_Storage,y)->m_id->m_defCount != 1)
            continue;
         for(instruction2=(instruction==end)?0:(cInstruction *)instruction->getNext();
             instruction2;
             instruction2=(instruction2==end)?0:(cInstruction *)instruction2->getNext())
         {
            if(instruction2->m_jumpDestination)
               break;
            if(instruction2->m_control.oc > 0)
               break;
            if(instruction2->m_alu1.oc==cConfig::OPCODE_SUB &&
               instruction2->m_alu1.x1->isKindOf(cTerm_MU_Constant::getCLID()) &&
               CAST(cTerm_MU_Constant,instruction2->m_alu1.x1)->getConstant()==0 &&
               *instruction2->m_alu1.x2==*y)
            {
               retval=true;
               invertInstruction=instruction2;
               y=invertInstruction->m_alu1.y;
               if(CAST(cTerm_MU_Storage,y)->m_id->m_useCount != 1 ||
                  CAST(cTerm_MU_Storage,y)->m_id->m_defCount != 1)
                  break;
            }
            else if(instruction2->m_alu1.oc==cConfig::OPCODE_ADD)
            {
               if((*instruction2->m_alu1.x1==*y && instruction2->m_alu1.x2->isDouble()) ||
                 (*instruction2->m_alu1.x2==*y && instruction2->m_alu1.x1->isDouble()))
               {
                  retval = true;
                  if(!invertInstruction)
                     instruction->m_alu1.oc=cConfig::OPCODE_FMA;
                  else
                  {
                     instruction->m_alu1.oc=cConfig::OPCODE_FNMA;
                  }
                  instruction->m_alu1.y=instruction2->m_alu1.y;
                  if(instruction2->m_alu1.x2->isDouble())
                  {
                     instruction->m_alu1.xacc=instruction2->m_alu1.x2;
                     instruction2->m_alu1.x2=0;
                  }
                  else
                  {
                     instruction->m_alu1.xacc=instruction2->m_alu1.x1;
                     instruction2->m_alu1.x1=0;
                  }
                  instruction2->setNOP();
                  if(invertInstruction)
                     invertInstruction->setNOP();
                  break;
               }
            }
            else if(instruction2->m_alu1.oc==cConfig::OPCODE_SUB)
            {
               if(*instruction2->m_alu1.x1==*y && instruction2->m_alu1.x2->isDouble())
               {
                  retval = true;
                  error(begin->getBeginFunc()->m_lineNo,"Illegal operation with accumulator");
                  if(!invertInstruction)
                     instruction->m_alu1.oc=cConfig::OPCODE_FMS;
                  else
                  {
                     instruction->m_alu1.oc=cConfig::OPCODE_FNMS;
                  }   
                  instruction->m_alu1.xacc=instruction2->m_alu1.x2;
                  instruction2->m_alu1.x2=0;
                  instruction->m_alu1.y=instruction2->m_alu1.y;
                  instruction2->setNOP();
                  if(invertInstruction)
                     invertInstruction->setNOP();
                  break;
               }
               else if(*instruction2->m_alu1.x2==*y && instruction2->m_alu1.x1->isDouble())
               {
                  retval = true;
                  if(!invertInstruction)
                  {
                     instruction->m_alu1.oc=cConfig::OPCODE_FNMA;
                  }
                  else
                     instruction->m_alu1.oc=cConfig::OPCODE_FMA;
                  instruction->m_alu1.xacc=instruction2->m_alu1.x1;
                  instruction2->m_alu1.x1=0;
                  instruction->m_alu1.y=instruction2->m_alu1.y;
                  instruction2->setNOP();
                  if(invertInstruction)
                     invertInstruction->setNOP();
                  break;
               }
            }
            if(instruction2->m_alu1.y && instruction2->m_alu1.y->isDouble())
               break;
         }
      }
   }
   return retval;
}


bool cInstruction::fm_post(cInstruction *begin)
{
   cInstruction *instruction,*end;

   end=GetFunctionEnd(begin);
   if(begin==end)
      return true;

#if 0
   // Remove all instructions _A=_A;
   for (instruction = begin; instruction; instruction = (instruction == end) ? 0 : (cInstruction *)instruction->getNext())
   {
      if (instruction->m_alu1.oc == cConfig::OPCODE_ASSIGN && 
         instruction->m_alu1.y->isDouble() && instruction->m_alu1.x1->isDouble() &&
         (CAST(cTerm_MU_Storage,instruction->m_alu1.y)->m_id==CAST(cTerm_MU_Storage,instruction->m_alu1.x1)->m_id))
      {
         retval = true;
         instruction->setNOP();
      }
   }
#endif

   cTerm_MU *x;
   cTerm_MU *x1,*x2,*xacc;

   // Substitute instructions with _A as parameters with FMXX instructions
   for (instruction = begin; instruction; instruction = (instruction == end) ? 0 : (cInstruction *)instruction->getNext())
   {
      if(instruction->m_alu1.oc <= 0)
         continue;
      x1=instruction->m_alu1.x1;
      x2=instruction->m_alu1.x2;
      if(x1&& x1->isDouble())
      {
         x=x2;
         xacc=x1;
      }
      else if(x2 && x2->isDouble())
      {
         x=x1;
         xacc=x2;
      }
      else
         continue;      
      if(x && x->isDouble())
         error(instruction->getBeginFunc()->m_lineNo,"Invalid operations involved double");
      if (instruction->m_alu1.oc == cConfig::OPCODE_ASSIGN)
      {
         if(!x->isKindOf(cTerm_MU_Null::getCLID()))
            error(instruction->getBeginFunc()->m_lineNo,"Invalid operations involved double");
         instruction->m_alu1.oc=cConfig::OPCODE_SHLA;
         instruction->m_alu1.x1=new cTerm_MU_Constant((int)0);
         instruction->m_alu1.x2= new cTerm_MU_Null();
         instruction->m_alu1.xacc=xacc;
      }
      else if(instruction->m_alu1.oc==cConfig::OPCODE_ADD)
      {
         instruction->m_alu1.oc=cConfig::OPCODE_FMA;
         instruction->m_alu1.x1=x;
         instruction->m_alu1.x2= new cTerm_MU_Constant((int)1);
         instruction->m_alu1.xacc = xacc;
      }
      else if(instruction->m_alu1.oc==cConfig::OPCODE_SUB)
      {
         if(x==instruction->m_alu1.x2)
         {
            // y=_A-x
            instruction->m_alu1.oc=cConfig::OPCODE_FNMA;
            instruction->m_alu1.x1=x;
            instruction->m_alu1.x2=new cTerm_MU_Constant((int)1);
            instruction->m_alu1.xacc=xacc;   
         }
         else
         {
            // y=x-_A;
            instruction->m_alu1.oc=cConfig::OPCODE_FMS;
            instruction->m_alu1.x1=x;
            instruction->m_alu1.x2=new cTerm_MU_Constant((int)1);   
            instruction->m_alu1.xacc=xacc;
         }
      }
      else if (instruction->m_alu1.oc == cConfig::OPCODE_SHLA || instruction->m_alu1.oc == cConfig::OPCODE_SHRA)
      {
         // Nothing to do...
      }
      else
         error(instruction->getBeginFunc()->m_lineNo,"Invalid operations involved double");                        
   }
   return true;
}

// Perform various instruction optimization 
int cInstruction::Optimize(cAstNode *_root)
{
   bool cont;
   cInstruction *begin;  
   cInstruction *instruction;
   begin=(cInstruction *)PROGRAM.getFirst();

   while(begin)
   {
      // Try to combine VMASK assignment with MU first. This is a special
      // case since VMASK takes effect on same instruction as MU

      // Compress A*B+C opeation to FMX instrucitons

      while(compress_jump(begin));
      fm(begin);

      while(compress_jump(begin));
      resolveConstantConflict(begin);
      cont=true;
      while(cont)
      {
         cont=false;
         while(compress_jump(begin))
            cont=true;
         if(substituteAssignment(begin,true))
            cont=true;
         while(compress_jump(begin))
            cont=true;
         if(substituteAssignment(begin,false))
            cont=true;
      }
      cont=true;
      while(cont)
      {
         cont=false;
         while(compress_jump(begin))
            cont=true;
         if(constantFolding(begin,true))
            cont=true;
         while(compress_jump(begin))
            cont=true;
         if(constantFolding(begin,false))
            cont=true;
      }
      while(compress_jump(begin));
      removeDeadCode(begin);
      while(compress_jump(begin));
      findCommonExpression(begin);
      if (M_ISFLOAT)
      {
         cont=true;
         while(cont)
         {
            cont=false;
            while(compress_jump(begin))
               cont=true;
            if(fm(begin))
               cont=true;
         }
      }
      while(compress_jump(begin));

      // Try to combine other instructions if possible...
      compressFunction(begin);

      // vmask is special. It's possible to combine vmask assignment with MU operation
      // since vmask can take into effect at the execution time of the MU.
      compress_vmask(begin);

      fm_post(begin);

      begin=(cInstruction *)GetFunctionEnd(begin)->getNext();
   }

   // Remove NOP instruction if it is the first instruction
   cInstruction *nextInstruction;
   instruction=(cInstruction *)PROGRAM.getFirst();
   while(instruction)
   {
      nextInstruction=(cInstruction *)instruction->getNext();
      if(instruction->getBeginFunc() && instruction->isNull() && !instruction->m_jumpDestination && nextInstruction)
      {
         nextInstruction->setBeginFunc(instruction->getBeginFunc());
         nextInstruction->setLabel(instruction->getLabel());
         cList::remove(instruction);
         delete instruction;
      }
      instruction=nextInstruction;
   }
   return 0;
}

// Do some preparation before generate binary
RETCODE cInstruction::genPreprocess()
{
   cInstruction *instruction;
   short addr;
   // Calculate code address
   instruction=(cInstruction *)PROGRAM.getFirst();
   addr=0;
   while(instruction)
   {
      instruction->m_addr=(int)addr;
      addr += 2;
      instruction=(cInstruction *)instruction->getNext();
   }
   return OK;
}

void cInstruction::genHex(FILE *fp,short addr,unsigned char *opcode)
{
   unsigned char checkSum;
   unsigned char *pp;
   checkSum=3;
   pp=(unsigned char *)&addr;
   checkSum += pp[0];
   checkSum += pp[1];
   pp=opcode;
   checkSum += pp[0];
   checkSum += pp[1];
   checkSum += pp[2]; 
   checkSum += pp[3]; 
   checkSum = ~checkSum;
   checkSum = checkSum+1;
   fprintf(fp,":03%04X00%02X%02X%02X%02X%02X\n",(int)addr,(int)opcode[0],(int)opcode[1],(int)opcode[2],(int)opcode[3],(int)checkSum);
}

void cInstruction::setField(unsigned char *oc, unsigned int val, int pos)
{
   int i, byte, bit;
   for (i = 0; i < 32; i++)
   {
      if (val & (1 << i))
      {
         byte = (i + pos)/8;
         bit = (i + pos) % 8;
         if(byte < INSTRUCTION_BYTE_WIDTH)
            oc[INSTRUCTION_BYTE_WIDTH-1-byte] |= (1 << bit);
      }
   }
}

// Generate output binary to load to target...
int cInstruction::gen(FILE *fp,std::vector<uint8_t> &img)
{
   cInstruction *instruction;
   cTerm_MU *xacc;
   int jump_addr;
   short addr;
   int c,i;
   unsigned char oc[INSTRUCTION_BYTE_WIDTH];

   instruction=(cInstruction *)PROGRAM.getFirst();
   while(instruction)
   {
      addr=2*instruction->m_addr;
      memset(oc, 0, sizeof(oc));
      if(instruction->m_alu1.xacc)
         xacc=CAST(cTerm_MU,instruction->m_alu1.xacc);
      else
         xacc=0;
      if(instruction->m_alu1.y && instruction->m_alu1.y->isDouble())
         setField(oc,1,MU_INSTRUCTION_TYPE_SAVE+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
      if (instruction->m_alu1.oc > 0)
      {
         setField(oc,cConfig::GetMuOpcode(instruction->m_alu1.oc),MU_INSTRUCTION_OC_LO+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
         if (instruction->m_alu1.x1->getVectorWidth() >= 1)
           setField(oc,1,MU_INSTRUCTION_X1_VECTOR+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH)); // X1 vector mode
         setField(oc, (instruction->m_alu1.x1->getOffset()&((1 << LOCAL_ADDR_DEPTH) - 1)), MU_INSTRUCTION_X1_LO + (INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
         setField(oc,instruction->m_alu1.x1->getExtAttr(),MU_INSTRUCTION_X1_ATTR_LO+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
         if (instruction->m_alu1.x2->getVectorWidth() >= 1)
            setField(oc,1,MU_INSTRUCTION_X2_VECTOR+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH)); // X2 vector mode
         setField(oc,(instruction->m_alu1.x2->getOffset()&((1 << LOCAL_ADDR_DEPTH) - 1)), MU_INSTRUCTION_X2_LO + (INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
         setField(oc,instruction->m_alu1.x2->getExtAttr(),MU_INSTRUCTION_X2_ATTR_LO+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));

         if (instruction->m_alu1.y->getVectorWidth() >= 1)
            setField(oc,1,MU_INSTRUCTION_Y_VECTOR+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH)); // Y vector mode
         setField(oc, (instruction->m_alu1.y->getOffset()&((1 << LOCAL_ADDR_DEPTH) - 1)),MU_INSTRUCTION_Y_LO+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
         setField(oc,instruction->m_alu1.y->getExtAttr(),MU_INSTRUCTION_Y_ATTR_LO+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
      }

      setField(oc,1,MU_INSTRUCTION_XACC_VECTOR+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH)); // XACC vector mode
      if(xacc)
      {
         setField(oc, (xacc->getOffset()&((1 << LOCAL_ADDR_DEPTH) - 1)), MU_INSTRUCTION_XACC_LO + (INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
         setField(oc,xacc->getExtAttr(),MU_INSTRUCTION_XACC_ATTR_LO+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
      }
      else
      {
         setField(oc,INSTRUCTION_ATTR_PRIVATE,MU_INSTRUCTION_XACC_ATTR_LO+(INSTRUCTION_IMU_WIDTH+INSTRUCTION_CTRL_WIDTH));
      }
      if(instruction->m_imu.oc > 0)
      {
         if(instruction->m_imu.x1->isKindOf(cTerm_IMU_Constant::getCLID()))
            c=instruction->m_imu.x1->getConstant();
         else
            c=instruction->m_imu.x2->getConstant();
         setField(oc,instruction->m_imu.oc,IMU_INSTRUCTION_OC_LO+INSTRUCTION_CTRL_WIDTH);
         setField(oc, instruction->m_imu.x1->getAttr(), 23 + INSTRUCTION_CTRL_WIDTH);
         setField(oc, instruction->m_imu.x2->getAttr(), 19 + INSTRUCTION_CTRL_WIDTH);
         setField(oc, instruction->m_imu.y->getAttr(), 15 + INSTRUCTION_CTRL_WIDTH);
         setField(oc,(c & ((1 << IREGISTER_WIDTH)-1)),2+INSTRUCTION_CTRL_WIDTH);
      }

      if(instruction->m_control.oc > 0)
      {
         setField(oc,instruction->m_control.oc,CTRL_INSTRUCTION_OC_LO);
         if(instruction->m_control.jumpInstruction)
         {
            jump_addr=instruction->m_control.jumpInstruction->m_addr;
            if(instruction->m_control.jumpAfter)
            {
               jump_addr += 2;
            }
         }
         else if(instruction->m_control.jumpFunction.length() > 0)
         {
            jump_addr=GetFunctionBegin((char *)instruction->m_control.jumpFunction.c_str())->m_addr;
         }
         else
            jump_addr=0;
         setField(oc,jump_addr,0);
      }

      // Display assembly code...
      if(M_VERBOSE)
         cInstruction::Print(instruction,addr/2,oc);

      genHex(fp,addr,oc);
      addr++;
      genHex(fp,addr,&oc[4]);
      addr++;
      genHex(fp,addr,&oc[8]);
      addr++;
      genHex(fp,addr,&oc[12]);
      addr++;

      for(i=0;i < 16;i++)
         img.push_back(oc[i]);

      instruction=(cInstruction *)instruction->getNext();
	}
	fprintf(fp,":00000001FF\n"); 
   return OK;
}

// Generate the final binary

RETCODE cInstruction::Generate(FILE *fp,FILE *fp2)
{
   std::vector<uint8_t> pcore_image;
   std::vector<uint16_t> const_image;
   int i;
   genPreprocess();
   fprintf(fp,".CODE BEGIN\n");
   cInstruction::gen(fp,pcore_image);
   fprintf(fp,".CODE END\n");

   fprintf(fp,".CONSTANT BEGIN\n");
   cConstant::Gen(fp,const_image);
   fprintf(fp,".CONSTANT END\n");

   // Generate C-structure for the pcore image

   fprintf(fp2,"static unsigned short pcore_image[%d]={\n",(int)pcore_image.size()/2);
   for(i=0;i < (int)pcore_image.size();i+=4)
   {
      if(i != 0)
         fprintf(fp2,",");
      fprintf(fp2,"0x%02X%02X,0x%02X%02X",(int)pcore_image[i+2],(int)pcore_image[i+3],(int)pcore_image[i],(int)pcore_image[i+1]);
      if((i%16)==12)
         fprintf(fp2,"\n");
   }
   fprintf(fp2,"};\n");

   fprintf(fp2,"static unsigned short const_image[%d]={\n",(int)const_image.size());
   for(i=0;i < (int)const_image.size();i++)
   {
	  if(i != 0)
	     fprintf(fp2,",");
      fprintf(fp2,"0x%04X",(int)const_image[i]);
      if((i%16)==15)
         fprintf(fp2,"\n");
   }
   fprintf(fp2,"};\n");
   return OK;
}

// Return address of a function. Return -1 if function cannot be found

cInstruction *cInstruction::GetFunctionBegin(char *funcName)
{
   cInstruction *instruction;
   bool contextMatchOnly=false;
   if(strlen(funcName)>2 && memcmp(&funcName[strlen(funcName)-2],"::",2)==0)
      contextMatchOnly=true;
   instruction=(cInstruction *)PROGRAM.getFirst();
   while(instruction)
   {
      if(!contextMatchOnly)
      {
         if(instruction->m_label.size()>0 && strcmp(instruction->m_label.c_str(),funcName)==0)
            return instruction;
      }
      else
      {
         if(instruction->m_label.size()>0 && memcmp(instruction->m_label.c_str(),funcName,strlen(funcName))==0)
            return instruction;
      }
      instruction=(cInstruction *)instruction->getNext();
   }
   return 0;
}

// Get global scope attribute for the function

int cInstruction::GetFunctionGlobalAttr(cInstruction *begin)
{
   cAstNode *func;
   int attr=0;

   func=begin->getBeginFunc();
   if(func && func->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_KERNEL))
   {
      cIdentifier *id;
      int index;
      id=CAST(cAstCodeBlockNode,func->getChild(1,eTOKEN_block_item_list))->getIdentifierList();
      while(id)
      {
         if(id->isParameter() && id->isKindOf(cIdentifierFixed::getCLID()))
         {
            index=CAST(cIdentifierFixed,id)->m_persistentIndex;
            if(index >= 0)
               attr |= (1<<index);
         }
         id=(cIdentifier *)id->getNext();
      }
   }
   return attr;
}


cInstruction *cInstruction::GetFunctionEnd(cInstruction *begin)
{
   while((cInstruction *)begin->getNext() && !((cInstruction *)begin->getNext())->m_beginFunc)
      begin=(cInstruction *)begin->getNext();
   return begin;
}

std::string cInstruction::GetFunctionFullName()
{
   cAstNode *node3;
   cAstNode *_func;
   _func=getBeginFunc();
   node3=_func->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_IDENTIFIER);
   if(!node3)
      node3=_func->getChild(2,eTOKEN_declarator,eTOKEN_IDENTIFIER);
   assert(node3!=0);
   return CAST(cAstIdentifierNode,node3)->getStringValue();
}

std::string cInstruction::GetFunctionClassName()
{
   std::string fullName;
   char *p;
   fullName=GetFunctionFullName();
   p=strstr((char *)fullName.c_str(),"::");
   fullName.resize((int)((uintptr_t)p-(uintptr_t)fullName.c_str()));
   return fullName;
}

// Encode function address
uint32_t cInstruction::GetEncodedFunctionAddress()
{
   uint32_t addr;
   addr=getAddr()<<(MAX_IREGISTER_AUTO_SIZE+DATAMODEL_WIDTH);
   addr |= cInstruction::GetFunctionGlobalAttr(this);
   addr |= m_dataModel << MAX_IREGISTER_AUTO_SIZE;
   return addr;
}

// Decode and display the program instructions

void cInstruction::Print(cInstruction *instruction,short addr,unsigned char *oc)
{
   bool printAll = false;

   if (!instruction)
   {
      instruction = (cInstruction *)PROGRAM.getFirst();
      printAll = true;
   }
   while(instruction)
   {
      printf("\n");
      if(instruction->m_label.size()>0)
         printf("[%p] (%s)",instruction,instruction->m_label.c_str());
      else
         printf("[%p]",instruction);
      if(instruction->m_alu1.oc > 0)
      {
         printf("\n         MU> ");
         instruction->m_alu1.y->print();
         if(instruction->m_alu1.y->getVectorWidth() >= 1)
            printf("(v)");
         printf("=");
         instruction->m_alu1.x1->print();
         if(instruction->m_alu1.x1->getVectorWidth() >= 1)
            printf("(v)");
         printf(" %s ",cConfig::GetMuOpcodeName(instruction->m_alu1.oc));
         instruction->m_alu1.x2->print();
         if(instruction->m_alu1.x2->getVectorWidth() >= 1)
            printf("(v)");
         if(instruction->m_alu1.xacc && !instruction->m_alu1.xacc->isKindOf(cTerm_MU_Null::getCLID()))
         {
            printf(" [");
            instruction->m_alu1.xacc->print();
            if(instruction->m_alu1.xacc->getVectorWidth() >= 1)
               printf("(v)");
            printf("]");
         }
      }
      if(instruction->m_alu2.oc > 0)
      {
         printf("\n          MU> ");
         instruction->m_alu2.y->print();
         printf("=");
         instruction->m_alu2.x1->print();
         printf(" %s ",cConfig::GetMuOpcodeName(instruction->m_alu2.oc));
         instruction->m_alu2.x2->print();
      }
      if(instruction->m_imu.oc > 0)
      {
         printf("\n         IMU> ");
         instruction->m_imu.y->print();
         printf("=");
         instruction->m_imu.x1->print();
         printf(" %s ",cConfig::GetImuOpcodeName(instruction->m_imu.oc));
         instruction->m_imu.x2->print();
      }
      if(instruction->m_control.oc > 0)
      {
         if(instruction->m_control.jumpFunction.length() > 0)
         {
            printf("\n         CTL> %s %s",
               cConfig::GetControlOpcodeName(instruction->m_control.oc),
               (char *)instruction->m_control.jumpFunction.c_str());
         }
         else
         {
            printf("\n         CTL> %s after=%d addr=%p",
               cConfig::GetControlOpcodeName(instruction->m_control.oc),
               instruction->m_control.jumpAfter,instruction->m_control.jumpInstruction);
         }
      }
      if (printAll)
         instruction = (cInstruction *)instruction->getNext();
      else
         instruction = 0;
   }
}
