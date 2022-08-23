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

#ifndef _INSTRUCTION_H_
#define _INSTRUCTION_H_

#include <vector>
#include "util.h"
#include "ident.h"
#include "config.h"


class cTerm;
class cTerm_MU;
class cTerm_IMU;
class cInstruction;
class cAstNode;

typedef struct
{
   int oc;
   int which_alu;
   cTerm_MU *x1;
   cTerm_MU *x2;
   cTerm_MU *y;
   cTerm_MU *xacc;
} Instruction_alu;

typedef struct
{
   int oc;
   cTerm_IMU *x1;
   cTerm_IMU *x2;
   cTerm_IMU *y;
} Instruction_ialu;

typedef struct
{
   int oc;
   cInstruction *jumpInstruction;
   std::string jumpFunction;
   bool jumpAfter;
} Instruction_control;

class cAstNode;
class cInstructions;
class cInstruction : public cListItem
{
public:
   cInstruction(cAstNode *node);
   ~cInstruction();
   RETCODE createIMU(int oc,cTerm_IMU *x1,cTerm_IMU *x2,cTerm_IMU *y);
   RETCODE createUnconditionalJump(int _oc,cInstruction *_jumpInstruction,bool _jumpAfter);
   RETCODE createConditionalJump(int _control_oc,int _oc,cTerm_IMU *_x1,cTerm_IMU *_x2,cTerm_IMU *y,
                                             cInstruction *_jumpInstruction,bool _jumpAfter);
   RETCODE createFunctionJump(char *_func,int _stackSize,cIdentifierVector *x_stack,cIdentifier *y_stack);
   RETCODE updateStackInfo(int _stackSize);
   RETCODE updateConditionalJump(int _control_oc,cInstruction *_jumpInstruction,bool _jumpAfter);
   RETCODE createMU(int oc,cTerm_MU *x1,cTerm_MU *x2,cTerm_MU *y,cTerm_MU *xacc=0);
   void setBeginFunc(cAstNode *_func);
   cAstNode *getBeginFunc() {return m_beginFunc;}
   std::string GetFunctionFullName();
   std::string GetFunctionClassName();
   uint32_t GetEncodedFunctionAddress();
   void setLabel(char *_label);
   char *getLabel() {return (m_label.size())>0?(char *)m_label.c_str():0;}
   int getAddr() {return m_addr;}
   bool isNull();
   bool isMU();
   bool simplify();
   bool simplifyMU(Instruction_alu *_mu);
   bool simplifyIMU(Instruction_ialu *_imu,Instruction_control *_control);
   cInstruction *getBranch();
   void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   bool isCommon(cInstruction *other,cTerm **_term,cTerm **_otherTerm);
   void setNOP();
   void getUse(cIdentifierVector *lst);
   void getDef(cIdentifierVector *lst);
   cInstruction *getNextInstruction();
   cInstruction *getJumpInstruction();
   bool getConstantAssignment(cTerm **_y,cTerm **_c);
   static cInstruction *GetFunctionBegin(char *funcName);
   static cInstruction *GetFunctionEnd(cInstruction *begin);
   static int GetFunctionGlobalAttr(cInstruction *begin);
   static void UpdateVariableUsage(cInstruction *begin,cInstruction *end);
   static bool InstructionsLinearFlow(cInstruction *begin,cInstruction *end,bool after,bool before);
   static bool InstructionsUse(cInstruction *begin,cInstruction *end,bool after,bool before,cIdentifierVector *lst);
   static bool InstructionsDef(cInstruction *begin,cInstruction *end,bool after,bool before,cIdentifierVector *lst);
   static int reverseLogic(int oc);
   static bool resolveConstantConflict(cInstruction *begin);
   static bool isMuParmValid(int oc,cConfig::eMuOpcodeDefDataType dataType,cTerm *x);
   static cInstruction *getInstructionBlock(cInstruction *begin,cInstruction *end,cInstruction *curr);
   static bool findCommonExpression(cInstruction *begin);
   static bool fm(cInstruction *begin);
   static int Optimize(cAstNode *_root);
   static RETCODE Generate(FILE *outfp,FILE *outfp2);
   static int GetFuncAddress(char *funcName);
   static void Print(cInstruction *instruction,short addr,unsigned char *oc);
private:
   static bool fm_int(cInstruction *begin);
   static bool fm_post(cInstruction *begin);
   static bool substituteAssignment(cInstruction *begin,bool _global);
   static void removeDeadCode(cInstruction *begin);
   static void removeDeadCode2(cInstruction *instruction);
   static bool constantFolding(cInstruction *begin,bool _global);
   static bool compress_vmask(cInstruction *begin);
   static bool compress_jump(cInstruction *begin);
   static bool check_independent(cTerm *y,cTerm *x);
   static bool can_fit(cInstruction *instruction1,cInstruction *instruction2);
   static int combine(cInstruction *to,int type,int oc,int alu,cTerm *x1,cTerm *x2,cTerm *xacc,cTerm *y);
   static bool compressInstruction(cInstruction *begin_of_func,cInstruction *instruction);
   static bool compressFunction(cInstruction *begin);
   static void genHex(FILE *fp,short addr,unsigned char *opcode);
   static int gen(FILE *fp,std::vector<uint8_t> &img);
   static void setField(unsigned char *oc, unsigned int val, int pos);
   static RETCODE genPreprocess();
public:
   Instruction_alu m_alu1;
   Instruction_alu m_alu2;
   Instruction_ialu m_imu;
   Instruction_control m_control;
public:
   cAstNode *m_node;
   int m_addr;
   int m_maxNumThreads;
   int m_dataModel;
private:
   std::string m_label;
   bool m_jumpDestination;
   cAstNode *m_beginFunc;
   bool m_seq;
   bool m_flag;
   cIdentifierVector m_x_stack;
   cIdentifier *m_y_stack;
};

class cInstructions : private cList
{
public:
   cInstructions() {}
   ~cInstructions() {}
   void insert(cInstructions *instructions,cInstruction *beforeItem) {cList::insert(instructions,beforeItem);}
   void append(cInstructions *instructions) {cList::append(instructions);}
   void insert(cInstruction *instruction,cInstruction *beforeItem) {cList::insert(instruction,beforeItem);}
   void append(cInstruction *instruction) {cList::append(instruction);}
   cInstruction *getFirst() {return (cInstruction *)cList::getFirst();}
   cInstruction *getLast() {return (cInstruction *)cList::getLast();}
};

#endif
