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

#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <vector>
#include "../base/zta.h"
#include "ast.h"
#include "util.h"
#include "config.h"
#include "ident.h"
#include "class.h"
#include "instruction.h"
#include "gen.h"

extern bool calc(cAstNode *node,float *result,bool *isFloat);


// Check if an expression is float or integer
bool cGEN::expressionIsMU(cAstNode *node)
{
   cIdentifier *id;
   if(node->isKindOf(cAstIdentifierNode::getCLID()))
   {
      id=CAST(cAstIdentifierNode,node)->getIdentifier();
      if(!id)
         error(node->m_lineNo,"Undefined variable");
      if(id->isKindOf(cIdentifierFloat::getCLID()))
         return true;
   }
   else if(node->isKindOf(cAstFloatNode::getCLID()))
      return true;
   else if(node->getID()==eTOKEN_postfix_expression4)
   {
      int oc;
      cAstNode *oc_node;
      oc_node=node->getChild(1,eTOKEN_IDENTIFIER);
      if(cConfig::decode_mu_oc(CAST(cAstStringNode,oc_node)->getStringValue(),&oc))
      {
         if(cConfig::GetMuOpcodeDef(oc)->y_type==cConfig::eMuOpcodeDefDataTypeFloat)
            return true;
      }
   }
   else
   {
      cAstNode *node2;
      node2=node->getChildList();
      while(node2)
      {
         if(expressionIsMU(node2))
            return true;
         node2=(cAstNode *)node2->getNext();
      }
   }
   return false;
}

// Parse an array reference
// For example A[2*i+6]
// The array is then referenced by an integer + constant
int cGEN::decode_array(cInstructions *instructions,cAstNode *_root,cAstNode *_func,
                        cIdentifier *_id,cAstNode *node,
                        cIdentifierInteger **_i,int *_c,bool *_subVector)
{
   cInstruction *instruction2;
   cIdentifier *id,*id2;
   cIdentifier *id3,*id4;
   cAstNode *node2,*node3,*node4,*node5;
   cTerm *term;
   int num_dim;
   int dim_size;
   bool subVector;
   float calcVal;
   bool isFloat;
   assert(node->getID()==eTOKEN_postfix_expression2);
   *_subVector=false;
   // Array notation....
   node2=node;
   node=(cAstNode *)node->getChildList();
   if(!node)
   {
      error(node2->m_lineNo,"This C-syntax is not supported by this compiler");
      return -1;
   }
   id=CAST(cAstIdentifierNode,node)->getIdentifier();
   if(!id->isKindOf(cIdentifierStorage::getCLID()) && 
      !id->isKindOf(cIdentifierConst::getCLID()))
   {
      error(node->m_lineNo,"Invalid array");
      return -1;
   }

   node2=(cAstNode *)node->getNext();
   num_dim=0;
   while(node2)
   {
      num_dim++;
      node2=(cAstNode *)node2->getNext();
   }
   if(num_dim > id->getNumDim())
   {
      if(num_dim != (id->getNumDim()+1))
         error(node->m_lineNo,"Invalid array reference");
      if(!id->isKindOf(cIdentifierStorage::getCLID()))
         error(node->m_lineNo,"Invalid array reference");
      if(CAST(cIdentifierStorage,id)->m_w == 0)
        error(node->m_lineNo,"Invalid array reference");
      subVector=true;
   }
   else
      subVector=false;

   node2=(cAstNode *)node->getNext();
   num_dim=0;
   *_i=0;
   *_c=0;
   while(node2)
   {
//      if(num_dim >= id->getNumDim())
//      {
//         if(!subVector)
//            error(node2->m_lineNo,"Invalid array reference");
//      }
      if(num_dim < id->getNumDim())
      {
         if(subVector)
            dim_size=id->getDimSize(num_dim)*VECTOR_WIDTH;
         else
            dim_size=id->getDimSize(num_dim);
      }
      else
         dim_size=1;
      if(node2->getID() != eTOKEN_expression)
      {
         error(node2->m_lineNo,"Invalid array index");
         return -1;
      }
      node3=(cAstNode *)node2->getChildList();
      if(!node3)
         error(node2->m_lineNo,"Invalid array indexing");
      node4=node3->getChildList();
      node5=node4?(cAstNode *)node4->getNext():0;
      if(calc(node3,&calcVal,&isFloat))
      {
         if(isFloat)
            error(node3->m_lineNo,"Invalid array indexing");
         *_c += dim_size*((int)calcVal);
      }
      else if(node3->getID() == eTOKEN_I_CONSTANT)
      {
         *_c += dim_size*CAST(cAstIntNode,node3)->getIntValue();
      }
      else
      {
         if(node3->getID() == eTOKEN_additive_expression_add &&
            (node5->getID()==eTOKEN_I_CONSTANT))
         {
            if(node4->getID()==eTOKEN_IDENTIFIER)
            {
               if(!(id3=CAST(cAstIdentifierNode,node4)->getIdentifier()))
                  error(node4->m_lineNo,"Undefined variable");
            }
            else
            {
               term=genTerm(instructions,_root,_func,node4,false,false,false);
               if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
                  error(node4->m_lineNo,"Invalid array indexing");
               id3=CAST(cTerm_IMU_Integer,term)->m_id;
            }
            *_c += dim_size*CAST(cAstIntNode,node5)->getIntValue();
         }
         else if(node3->getID() == eTOKEN_additive_expression_add &&
                (node4->getID()==eTOKEN_I_CONSTANT))
         {
            if(node5->getID()==eTOKEN_IDENTIFIER)
            {
               if(!(id3=CAST(cAstIdentifierNode,node5)->getIdentifier()))
                  error(node5->m_lineNo,"Undefined variable");
            }
            else
            {
               term=genTerm(instructions,_root,_func,node5,false,false,false);
               if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
                  error(node5->m_lineNo,"Invalid array indexing");
               id3=CAST(cTerm_IMU_Integer,term)->m_id;
            }
            *_c += dim_size*CAST(cAstIntNode,node4)->getIntValue();
         }
         else if(node3->getID() == eTOKEN_additive_expression_sub &&
            (node5->getID()==eTOKEN_I_CONSTANT))
         {
            if(node4->getID()==eTOKEN_IDENTIFIER)
            {
               if(!(id3=CAST(cAstIdentifierNode,node4)->getIdentifier()))
                  error(node4->m_lineNo,"Undefined variable");
            }
            else
            {
               term=genTerm(instructions,_root,_func,node4,false,false,false);
               if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
                  error(node4->m_lineNo,"Invalid array indexing");
               id3=CAST(cTerm_IMU_Integer,term)->m_id;
            }
            *_c -= dim_size*CAST(cAstIntNode,node5)->getIntValue();
         }
         else
         {
            term=genTerm(instructions,_root,_func,node3,false,false,false);
            if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
               error(node3->m_lineNo,"Invalid array indexing");
            id3=CAST(cTerm_IMU_Integer,term)->m_id;
         }
         if(*_i)
         {
            if(dim_size==1)
            {
               instruction2=new cInstruction(node);
               id4=new cIdentifierInteger(_func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
               instruction2->createIMU(cConfig::IOPCODE_ADD,
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id3)),
                  new cTerm_IMU_Integer(*_i),
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id4)));
               *_i=CAST(cIdentifierInteger,id4);
               instructions->append(instruction2);
            }
            else
            {
               instruction2=new cInstruction(node);
               id2=new cIdentifierInteger(_func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
               instruction2->createIMU(cConfig::IOPCODE_MUL,
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id3)),
                  new cTerm_IMU_Constant(dim_size),
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id2)));
               instructions->append(instruction2);
               instruction2=new cInstruction(node);
               id4=new cIdentifierInteger(_func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
               instruction2->createIMU(cConfig::IOPCODE_ADD,
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id2)),
                  new cTerm_IMU_Integer(*_i),
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id4)));
               *_i=CAST(cIdentifierInteger,id4);
               instructions->append(instruction2);
            }
         }
         else
         {
            if(dim_size==1)
            {
               *_i=CAST(cIdentifierInteger,id3);
            }
            else
            {
               instruction2=new cInstruction(node);
               *_i=new cIdentifierInteger(_func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
               instruction2->createIMU(cConfig::IOPCODE_MUL,
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id3)),
                  new cTerm_IMU_Constant(dim_size),
                  new cTerm_IMU_Integer(*_i));
               instructions->append(instruction2);            
            }
         }
      }
      num_dim++;
      node2=(cAstNode *)node2->getNext();
   }
#if 1
   if((*_i)==0)
   {
//      if(*_c < 0 || *_c >= id->getLen())
//         error(node->m_lineNo,"Array reference out of bound");
      if((*_c < MIN_POINTER_OFFSET || *_c > MAX_POINTER_OFFSET) &&
         !(_id->isKindOf(cIdentifierShared::getCLID()) || _id->isKindOf(cIdentifierPrivate::getCLID())))
      {
         instruction2=new cInstruction(node);
         id4=new cIdentifierInteger(_func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
                  new cTerm_IMU_Constant(*_c),
                  new cTerm_IMU_Zero(),
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id4)));
         *_i=CAST(cIdentifierInteger,id4);
         instructions->append(instruction2);
         *_c=0;
      }
   }
   else
   {
      if(*_c < MIN_POINTER_OFFSET || *_c > MAX_POINTER_OFFSET)
      {
         // This constant is out of bound. But it is not necessary out of bound
         // after adding to index integer. So combine the constant with the index integer
         // to be safe....
         instruction2=new cInstruction(node);
         id4=new cIdentifierInteger(_func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
                  new cTerm_IMU_Integer(*_i),
                  new cTerm_IMU_Constant(*_c),
                  new cTerm_IMU_Integer(CAST(cIdentifierInteger,id4)));
         *_i=CAST(cIdentifierInteger,id4);
         instructions->append(instruction2);
         *_c=0;
      }
   }
#endif
   *_subVector=subVector;
   return num_dim;
}

// Generate conditional expression
// For example x=(i==0)?y:z;

cTerm *cGEN::genTermConditionalExpression(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cInstruction *instruction2;
   cInstruction *end_instruction;
   cInstruction *jump_instruction;
   cAstNode *cond_node,*true_node,*false_node;
   cTerm *term1;
   cTerm *term;

   cond_node=node->getChildList();
   true_node=(cAstNode *)cond_node->getNext();
   false_node=(cAstNode *)true_node->getNext();
   end_instruction=new cInstruction(node);
   jump_instruction=new cInstruction(node);

   genStatement(instructions,_root,func,cond_node,0,true,0,0,jump_instruction,true,0,0,true); // false_instruction
   term1=genTerm(instructions,_root,func,true_node,false,false,_isMU);
   if(!_y)
   {
      if(_isMU)
         term=new cTerm_MU_Storage(new cIdentifierPrivate(func->getChild(1,eTOKEN_block_item_list),0,0,CAST(cTerm_MU,term1)->getVectorWidth()),0);
      else
         term=new cTerm_IMU_Integer(new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1));
   }
   else
      term=_y;
   if(_isMU)
   {
      instruction2=new cInstruction(node);
      instruction2->createMU(cConfig::OPCODE_ASSIGN,
         CAST(cTerm_MU,term1),
         new cTerm_MU_Null(),
         CAST(cTerm_MU,term));
      instructions->append(instruction2);
   }
   else
   {
      instruction2=new cInstruction(node);
      instruction2->createIMU(cConfig::IOPCODE_ADD,
         CAST(cTerm_IMU,term1),
         new cTerm_IMU_Zero(),
         CAST(cTerm_IMU,term));
      instructions->append(instruction2);
   }
   jump_instruction->createUnconditionalJump(cConfig::OPCODE_JUMP,end_instruction,false); // -- end instruction
   instructions->append(jump_instruction);
   term1=genTerm(instructions,_root,func,false_node,false,false,_isMU);
   if(_isMU)
   {
      instruction2=new cInstruction(node);
      instruction2->createMU(cConfig::OPCODE_ASSIGN,
         CAST(cTerm_MU,term1),
         new cTerm_MU_Null(),
         CAST(cTerm_MU,term));
      instructions->append(instruction2);
   }
   else
   {
      instruction2=new cInstruction(node);
      instruction2->createIMU(cConfig::IOPCODE_ADD,
         CAST(cTerm_IMU,term1),
         new cTerm_IMU_Zero(),
         CAST(cTerm_IMU,term));
      instructions->append(instruction2);
   }
   instructions->append(end_instruction);
   return term;
}

// Generate assignment expression
// Example: x=y+z;

cIdentifier *cGEN::findIdentifier(cAstNode *node,CLASSID clid)
{
   cIdentifier *id;
   cAstNode *node2;
   if(node->isKindOf(cAstIdentifierNode::getCLID()))
   {
      if(CAST(cAstIdentifierNode,node)->m_id->isKindOf(clid))
         return CAST(cAstIdentifierNode,node)->m_id;
   }
   node2=(cAstNode *)node->getChildList();
   while(node2)
   {
      if(node2->isKindOf(cAstIdentifierNode::getCLID()))
      {
         if(CAST(cAstIdentifierNode,node2)->m_id->isKindOf(clid))
            return CAST(cAstIdentifierNode,node2)->m_id;
      }
      else
      {
         id=findIdentifier(node2,clid);
         if(id)
            return id;
      }
      node2=(cAstNode *)node2->getNext();
   }
   return 0;
}

cTerm *cGEN::genTermAssignmentExpression(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cAstNode *node2;
   cTerm *x1=0;
   cTerm *x2=0;
   cTerm *y=0;
   int oc=0;

   cAstNode *y_node,*assignment;
   cInstruction *instruction;
   bool isMU;
   y_node=(cAstNode *)node->getChildList();
   if(!y_node)
      error(node->m_lineNo,"\n Invalid parameter\n");
   assignment=(cAstNode *)y_node->getNext();
   node2=(cAstNode *)y_node->getNext()->getNext();
   if(!(y=genTerm(instructions,_root,func,y_node,false,false,false)))
      error(y_node->m_lineNo,"\nInvalid parameter\n");
   isMU=(y->isKindOf(cTerm_MU::getCLID()))?true:false;
   _isMU=isMU;
   if(assignment->getID()==eTOKEN_assignment_operator)
   {
      x2=genTerm(instructions,_root,func,node2,y->isDouble(),false,isMU,y);
   }
   else
      x2=genTerm(instructions,_root,func,node2,false,false,isMU,y);
   if(y->isKindOf(cTerm_IMU_Pointer::getCLID()))
   {
      bool flag=false;
      cIdentifier *id;
      // This is a pointer assignment

      if((id=findIdentifier(node2,cIdentifierConst::getCLID())))
      {
         if(!CAST(cTerm_IMU_Pointer,y)->m_id->isConst())
            error(y_node->m_lineNo,"Invalid assignment of non-const pointer");
         flag=true;
         CAST(cTerm_IMU_Pointer,y)->m_id->m_scope.append(id);
      }
      if((id=findIdentifier(node2,cIdentifierPointer::getCLID())))
      {
         // This is a pointer alias assignment...
         if(flag)
            error(y_node->m_lineNo,"Invalid pointer assigment");
         flag=true;
         if(CAST(cTerm_IMU_Pointer,y)->m_id->isConst())
            error(y_node->m_lineNo,"Invalid assignment of const pointer");
         CAST(cTerm_IMU_Pointer,y)->m_id->m_scope.append(id);
      }
      if((id=findIdentifier(node2,cIdentifierShared::getCLID())))
      {
         if(flag)
            error(y_node->m_lineNo,"Invalid pointer assigment");
         flag=true;
         if(CAST(cTerm_IMU_Pointer,y)->m_id->isConst())
            error(y_node->m_lineNo,"Invalid assignment of const pointer");
         CAST(cTerm_IMU_Pointer,y)->m_id->m_scope.append(id);
      }
      if((id=findIdentifier(node2,cIdentifierPrivate::getCLID())))
      {
         if(flag)
            error(y_node->m_lineNo,"Invalid pointer assigment");
         flag=true;
         if(CAST(cTerm_IMU_Pointer,y)->m_id->isConst())
            error(y_node->m_lineNo,"Invalid assignment of const pointer");
         CAST(cTerm_IMU_Pointer,y)->m_id->m_scope.append(id);
      }
   }
   if(assignment->getID()==eTOKEN_ADD_ASSIGN)
   {
      x1=y;
      if(isMU)
         oc=cConfig::OPCODE_ADD;
      else
         oc=cConfig::IOPCODE_ADD;
   }
   else if(assignment->getID()==eTOKEN_SUB_ASSIGN)
   {
      x1=y;
      if(isMU)
         oc=cConfig::OPCODE_SUB;
      else
         oc=cConfig::IOPCODE_SUB;
   }
   else if(assignment->getID()==eTOKEN_MUL_ASSIGN)
   {
      x1=y;
      if(isMU)
         oc=cConfig::OPCODE_MUL;
      else
         oc=cConfig::IOPCODE_MUL;
   }
   else if(assignment->getID()==eTOKEN_LEFT_ASSIGN)
   {
      if(isMU)
         error(node2->m_lineNo,"Invalid floating point operation");
      x1=y;
      oc=cConfig::IOPCODE_SHL;
   }
   else if(assignment->getID()==eTOKEN_RIGHT_ASSIGN)
   {
      if(isMU)
         error(node2->m_lineNo,"Invalid floating point operation");
      x1=y;
      oc=cConfig::IOPCODE_SHR;
   }   
   else if(assignment->getID()==eTOKEN_OR_ASSIGN)
   {
      if(isMU)
         error(node2->m_lineNo,"Invalid floating point operation");
      x1=y;
      oc=cConfig::IOPCODE_OR;
   }   
   else if(assignment->getID()==eTOKEN_AND_ASSIGN)
   {
      if(isMU)
         error(node2->m_lineNo,"Invalid floating point operation");
      x1=y;
      oc=cConfig::IOPCODE_AND;
   }
   else if(assignment->getID()==eTOKEN_XOR_ASSIGN)
   {
      if(isMU)
         error(node2->m_lineNo,"Invalid floating point operation");
      x1=y;
      oc=cConfig::IOPCODE_XOR;
   }
   else if(assignment->getID()==eTOKEN_assignment_operator)
   {
      if(x2 != y)
      {
         if(isMU)
         {
            x1=x2;
            x2=new cTerm_MU_Null();
            oc=cConfig::OPCODE_ASSIGN;
         }
         else
         {
            x1=new cTerm_IMU_Zero();
            oc=cConfig::IOPCODE_ADD;
         }
      }
      else
      {
         oc=0;
      }
   }
   else
      error(node2->m_lineNo,"Invalid assignment");
   if(oc > 0)
   {
      instruction= new cInstruction(node);
      if(isMU)
         instruction->createMU(oc,CAST(cTerm_MU,x1),CAST(cTerm_MU,x2),CAST(cTerm_MU,y));
      else
         instruction->createIMU(oc,CAST(cTerm_IMU,x1),CAST(cTerm_IMU,x2),CAST(cTerm_IMU,y));
      instructions->append(instruction);
   }
   return y;
}

// Generate post increment/decrement
// For example: i++  i--

cTerm *cGEN::genTermPostIncrementDecrement(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cIdentifier *id;
   cInstruction *instruction;
   cAstNode *oc_node;
   int oc;
   cAstNode *y_node;
   y_node=(cAstNode *)node->getChildList();
   oc_node=(cAstNode *)y_node->getNext();
   if(oc_node->getID()==eTOKEN_INC_OP || oc_node->getID()==eTOKEN_DEC_OP)
   {
      cTerm *x1,*x2,*y,*y2=0;
      if(expressionIsMU(y_node))
         error(y_node->m_lineNo,"Not valid operation for floating point");
      if(oc_node->getID()==eTOKEN_INC_OP)
         oc=cConfig::IOPCODE_ADD;
      else
         oc=cConfig::IOPCODE_SUB;
      if(!y_node->isKindOf(cAstIdentifierNode::getCLID()))
         error(y_node->m_lineNo,"This C-syntax is not supported by this compiler");
      id=CAST(cAstIdentifierNode,y_node)->m_id;
      instruction=new cInstruction(node);
      if(id->isKindOf(cIdentifierInteger::getCLID()))
      {
         y2=new cTerm_IMU_Integer(new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1));
         instruction->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_Integer(CAST(cIdentifierInteger,id)),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,y2));
      }
      else if(id->isKindOf(cIdentifierPointer::getCLID()))
      {
         y2=new cTerm_IMU_Integer(new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1));
         instruction->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_Pointer(CAST(cIdentifierPointer,id)),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,y2));
      }
      else
         error(y_node->m_lineNo,"This C-syntax is not supported by this compiler");
      instructions->append(instruction);
      if(!id->isKindOf(cIdentifierInteger::getCLID()) && !id->isKindOf(cIdentifierPointer::getCLID()))
         error(y_node->m_lineNo,"This C-syntax is not supported by this compiler");
      if(!(y=genTerm(instructions,_root,func,y_node,false,false,false)))
         error(y_node->m_lineNo,"\nInvalid parameter\n");
      if(!(x1=genTerm(instructions,_root,func,y_node,false,false,false)))
         error(y_node->m_lineNo,"\nInvalid parameter\n");
      x2=new cTerm_IMU_Constant(1);
      instruction= new cInstruction(node);
      instruction->createIMU(oc,CAST(cTerm_IMU,x1),CAST(cTerm_IMU,x2),CAST(cTerm_IMU,y));   
      instructions->append(instruction);
      return y2;
   }
   else
   {
      error(oc_node->m_lineNo,"Unsupported C syntax");
      return 0;
   }
}

cTerm *cGEN::genTermFunctionCall(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
                        bool _isMU,cTerm *_y)
{
   // This is a function call
   cIdentifier *id;
   cAstNode *node2,*oc_node;
   cTerm *term;
   int pos[VECTOR_DEPTH+1];
   int count=0;
   cIdentifierVector stackVar;
   cAstNode *x1_node;
   cInstruction *instruction;
   cIdentifierVector x_stack;
   cIdentifier *y_stack=0;
   cAstNode *func2;
   cIdentifier *parm;
   cIdentifierReturnValue *rvid;
   cInstructions lst;
   int w,w2;
   int inc;
   int i;
   oc_node=node->getChild(1,eTOKEN_IDENTIFIER);

   // Find the function definition
   func2=cAstNode::GetFunction(_root,CAST(cAstStringNode,oc_node)->getStringValue());
   if(!func2)
      error(oc_node->m_lineNo,"Function undefined");
   rvid=cIdentifier::getReturnValue(func2->getChild(1,eTOKEN_block_item_list));

   for(i=0;i <= VECTOR_DEPTH;i++)
      pos[i]=0;
   for(w=VECTOR_DEPTH;w >= 0;w--)
   {
   count=0;
   node2=node->getChild(1,eTOKEN_argument_expression_list);
   x1_node=(cAstNode *)node2->getChildList();
   while(x1_node)
   {
      parm=cIdentifier::getFuncParameter(func2->getChild(1,eTOKEN_block_item_list),count);
      if(!parm)
         error(oc_node->m_lineNo,"Function parameter unexpected");
      if(parm->getNumDim() > 0)
         error(oc_node->m_lineNo,"Function parameter must be scalar");
      if(CAST(cIdentifierParameter,parm)->m_w != w)
      {
         x1_node=(cAstNode *)(x1_node->getNext());
         count++;
         continue;
      }
      if(parm->isKindOf(cIdentifierParameter::getCLID()) && !CAST(cIdentifierParameter,parm)->m_alias)
      {
         // This is a float parameter
         id=cIdentifier::getStackVariable(func->getChild(1,eTOKEN_block_item_list),pos[w],w);
         x_stack.append(id);
         term=genTerm(instructions,_root,func,x1_node,false,false,true);
         if(!term->isKindOf(cTerm_MU::getCLID()) ||
            term->isKindOf(cTerm_MU_Integer::getCLID()))
            error(oc_node->m_lineNo,"Function parameter mismatched");
         if(CAST(cTerm_MU,term)->getVectorWidth() != w)
            error(oc_node->m_lineNo,"Function parameter mismatched");
         instruction=new cInstruction(node);
         instruction->createMU(cConfig::OPCODE_ASSIGN,
                  CAST(cTerm_MU,term),
                  new cTerm_MU_Null(),
                  new cTerm_MU_Storage(CAST(cIdentifierPrivate,id),0));
         lst.append(instruction);
//         instructions->append(instruction);
         x1_node=(cAstNode *)(x1_node->getNext());
         for(w2=w,inc=1;w2 >= 0;w2--)
         {
            pos[w2] += inc;
            inc=inc*2;
         }
         count++;
      }
      else if(parm->isKindOf(cIdentifierParameter::getCLID()) && CAST(cIdentifierParameter,parm)->m_alias)
      {
         // This is a integer parameter
         id=cIdentifier::getStackVariable(func->getChild(1,eTOKEN_block_item_list),pos[w],w);
         x_stack.append(id);
         term=genTerm(instructions,_root,func,x1_node,false,false,false);
         term=cTerm::Convert2MU(instructions,func,node,term);
         if(term->isKindOf(cTerm_MU_Constant::getCLID()))
         {
            CAST(cTerm_MU_Constant,term)->m_float=false;
         }
         else if(!term->isKindOf(cTerm_MU_Integer::getCLID()))
            error(oc_node->m_lineNo,"Function parameter mismatched");
         instruction=new cInstruction(node);
         instruction->createMU(cConfig::OPCODE_ASSIGN_RAW,
                  CAST(cTerm_MU,term),
                  new cTerm_MU_Null(),
                  new cTerm_MU_Storage(CAST(cIdentifierPrivate,id),0));
         lst.append(instruction);
//         instructions->append(instruction);
         x1_node=(cAstNode *)(x1_node->getNext());
         for(w2=w,inc=1;w2 >= 0;w2--)
         {
            pos[w2] += inc;
            inc=inc*2;
         }
         count++;
      }
      else
      {
         error(oc_node->m_lineNo,"Invalid parameter type");
      }
   }
   if(cIdentifier::getFuncParameterCount(func2->getChild(1,eTOKEN_block_item_list)) != count)
      error(oc_node->m_lineNo,"Function parameter mismatched");
   if(rvid && rvid->m_w==w)
   {
      y_stack=cIdentifier::getStackVariable(func->getChild(1,eTOKEN_block_item_list),pos[rvid->m_w],rvid->m_w);
      for(w2=w,inc=1;w2 >= 0;w2--)
      {
         pos[w2] += inc;
         inc=inc*2;
      }
   }
   }
   instructions->append(&lst);
   instruction=new cInstruction(node);
   instruction->createFunctionJump(CAST(cAstStringNode,oc_node)->getStringValue(),0,&x_stack,y_stack);
   instructions->append(instruction);
   if(_isMU )
   {
      if(!y_stack)
         return new cTerm_MU_Null();
      else
      {
         if(CAST(cIdentifierReturnValue,rvid)->m_float)
         {
            cTerm *term;
            term=new cTerm_MU_Storage(new cIdentifierPrivate(func->getChild(1,eTOKEN_block_item_list),0,0,CAST(cIdentifierStack,y_stack)->m_w),0);
            instruction=new cInstruction(node);
            instruction->createMU(cConfig::OPCODE_ASSIGN,
                  new cTerm_MU_Storage(CAST(cIdentifierPrivate,y_stack),0),
                  new cTerm_MU_Null(),
                  CAST(cTerm_MU,term)
                  );
            instructions->append(instruction);
            return term;
         }
         else
         {
            error(oc_node->m_lineNo,"Mismatched data type for return value");
            return 0;
         }
      }
   }
   else
   {
      if(!y_stack)
         return new cTerm_IMU_Null();
      else
      {
         if(!CAST(cIdentifierReturnValue,rvid)->m_float)
         {
            instruction= new cInstruction(node);
            instruction->createMU(
                                 cConfig::OPCODE_ASSIGN_RAW,
                                 new cTerm_MU_Storage(CAST(cIdentifierPrivate,y_stack),0),
                                 new cTerm_MU_Null(),
                                 new cTerm_MU_Result());
            instructions->append(instruction);
            instruction= new cInstruction(node);
            term=new cTerm_IMU_Integer(new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1));
            instruction->createIMU(cConfig::IOPCODE_ADD,
                                   new cTerm_IMU_Result(),
                                   new cTerm_IMU_Zero(),
                                   CAST(cTerm_IMU,term));
            instructions->append(instruction);
            return term;
         }
         else
         {
            error(oc_node->m_lineNo,"Mismatched data type for return value");
            return 0;
         }
      }
   }
}

// Generate function call
// For example CONV(x)

cTerm *cGEN::genTermFunction(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cAstNode *x1_node,*x2_node,*x3_node,*temp_node;
   bool swap=false;
   cAstNode *oc_node,*node2;
   cTerm *x1=0,*x2=0,*y,*y_ret;
   int oc;
   cInstruction *instruction;
   oc_node=node->getChild(1,eTOKEN_IDENTIFIER);
   if(!cConfig::decode_mu_oc(CAST(cAstStringNode,oc_node)->getStringValue(),&oc))
   {
      return genTermFunctionCall(instructions,_root,func,node,ref,_isMU,_y);
   }
   node2=node->getChild(1,eTOKEN_argument_expression_list);
   x1_node=(cAstNode *)node2->getChildList();
   if(!x1_node)
      error(node2->m_lineNo,"\nInvalid parameter\n");
   x2_node=(cAstNode *)(x1_node->getNext());
   if(x2_node)
      x3_node=(cAstNode *)(x2_node->getNext());
   else
      x3_node=0;
   if(oc >= cConfig::OPCODE_FM && oc <= (cConfig::OPCODE_FM+7))
   {
      if(!x1_node || !x2_node || !x3_node)
      {
         error(node2->m_lineNo,"Invalid parameters");
      }
      if(x1_node->getID()==eTOKEN_IDENTIFIER && strcasecmp(CAST(cAstStringNode,x1_node)->getStringValue(),"_A")==0)
      {
         error(node2->m_lineNo,"Invalid parameter");
      }
      if(x2_node->getID()==eTOKEN_IDENTIFIER && strcasecmp(CAST(cAstStringNode,x2_node)->getStringValue(),"_A")==0)
      {
         if(x3_node->getID()==eTOKEN_IDENTIFIER && strcasecmp(CAST(cAstStringNode,x3_node)->getStringValue(),"_A")==0)
            error(node2->m_lineNo,"Invalid parameter");
         temp_node=x2_node;
         x2_node=x3_node;
         x3_node=temp_node;
         swap=true;
      }
      if(x3_node->getID()==eTOKEN_IDENTIFIER && strcasecmp(CAST(cAstStringNode,x3_node)->getStringValue(),"_A")==0)
      {
         if(x2_node->getID()==eTOKEN_IDENTIFIER && strcasecmp(CAST(cAstStringNode,x2_node)->getStringValue(),"_A")==0)
            error(node2->m_lineNo,"Invalid parameter");
      }
   }

   instruction= new cInstruction(node);
   if(cConfig::GetMuOpcodeDef(oc)->x1_type==cConfig::eMuOpcodeDefDataTypeFloat)
   {
      x1=genTerm(instructions,_root,func,x1_node,false,false,true);
   }
   else if(cConfig::GetMuOpcodeDef(oc)->x1_type==cConfig::eMuOpcodeDefDataTypeInt)
   {
      x1=genTerm(instructions,_root,func,x1_node,false,false,false);
      if(x1->isKindOf(cTerm_IMU_Result::getCLID()))
      {
         cInstruction *instruction2;
         cIdentifier *temp;
         temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         if(!temp)
            error(x1_node->m_lineNo,"Out of variable space");
         x1=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
         instruction2=new cInstruction(node);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_Result(),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,x1));
         instructions->append(instruction2);
      }
      else if(x1->isKindOf(cTerm_IMU_TID::getCLID()))
      {
         cInstruction *instruction2;
         cIdentifier *temp;
         temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         if(!temp)
            error(x1_node->m_lineNo,"Out of variable space");
         x1=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
         instruction2=new cInstruction(node);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_TID(),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,x1));
         instructions->append(instruction2);
      }
      else if(x1->isKindOf(cTerm_IMU_PID::getCLID()))
      {
         cInstruction *instruction2;
         cIdentifier *temp;
         temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         if(!temp)
            error(x1_node->m_lineNo,"Out of variable space");
         x1=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
         instruction2=new cInstruction(node);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_PID(),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,x1));
         instructions->append(instruction2);
      }
      x1=cTerm::Convert2MU(0,0,0,x1);
      if(!x1)
         error(x1_node->m_lineNo,"Invalid opcode parameter");
   }
   else
      error(oc_node->m_lineNo,"Invalid opcode");
   if(cConfig::GetMuOpcodeDef(oc)->x2_type==cConfig::eMuOpcodeDefDataTypeFloat)    
   {
      if(!x2_node)
         error(x1_node->m_lineNo,"Too few parameter");
      x2=genTerm(instructions,_root,func,x2_node,false,false,true);
   }
   else if(cConfig::GetMuOpcodeDef(oc)->x2_type==cConfig::eMuOpcodeDefDataTypeInt) 
   {
      if(!x2_node)
         error(x1_node->m_lineNo,"Too few parameter");
      x2=genTerm(instructions,_root,func,x2_node,false,false,false);
      if(x2->isKindOf(cTerm_IMU_Result::getCLID()))
      {
         cInstruction *instruction2;
         cIdentifier *temp;
         temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         if(!temp)
            error(x2_node->m_lineNo,"Out of variable space");
         x2=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
         instruction2=new cInstruction(node);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_Result(),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,x2));
         instructions->append(instruction2);
      }
      else if(x2->isKindOf(cTerm_IMU_TID::getCLID()))
      {
         cInstruction *instruction2;
         cIdentifier *temp;
         temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         if(!temp)
            error(x2_node->m_lineNo,"Out of variable space");
         x2=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
         instruction2=new cInstruction(node);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_TID(),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,x2));
         instructions->append(instruction2);
      }
      else if(x2->isKindOf(cTerm_IMU_PID::getCLID()))
      {
         cInstruction *instruction2;
         cIdentifier *temp;
         temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
         if(!temp)
            error(x2_node->m_lineNo,"Out of variable space");
         x2=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
         instruction2=new cInstruction(node);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_PID(),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,x2));
         instructions->append(instruction2);
      }
      x2=cTerm::Convert2MU(instructions,func,node,x2);
      if(!x2)
         error(x2_node->m_lineNo,"Invalid opcode parameter");
   }
   else
   {
      if(x2_node)
         error(x2_node->m_lineNo,"Too many parameters");
      x2=new cTerm_MU_Null();
   }

   if(x1 && x1->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      if(cConfig::GetMuOpcodeDef(oc)->x1_type==cConfig::eMuOpcodeDefDataTypeFloat)
         CAST(cTerm_MU_Constant,x1)->m_float=true;
      else
      {
         if(CAST(cTerm_MU_Constant,x1)->m_float)
         {
//            yyerror("Invalid parameter");
         }
         CAST(cTerm_MU_Constant,x1)->m_float=false;
      }
   }
   if(x2 && x2->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      if(cConfig::GetMuOpcodeDef(oc)->x2_type==cConfig::eMuOpcodeDefDataTypeFloat)
         CAST(cTerm_MU_Constant,x2)->m_float=true;
      else
      {
         if(CAST(cTerm_MU_Constant,x2)->m_float)
         {
//            yyerror("Invalid parameter");
         }
         CAST(cTerm_MU_Constant,x2)->m_float=false;
      }
   }

   if(x1 && !cInstruction::isMuParmValid(oc,cConfig::GetMuOpcodeDef(oc)->x1_type,x1))
      error(x1_node->m_lineNo,"Invalid parameter");
   if(x2 && x2_node && !cInstruction::isMuParmValid(oc,cConfig::GetMuOpcodeDef(oc)->x2_type,x2))
      error(x2_node->m_lineNo,"Invalid parameter");

   if(cConfig::GetMuOpcodeDef(oc)->y_type==cConfig::eMuOpcodeDefDataTypeInt)
   {
      y=new cTerm_MU_Result();
      y_ret=y;
   }
   else if(cConfig::GetMuOpcodeDef(oc)->y_type==cConfig::eMuOpcodeDefDataTypeFloat)
   {
      cIdentifier *temp;
      temp=new cIdentifierPrivate(func->getChild(1,eTOKEN_block_item_list),0,0,cConfig::GetMuOpcodeDef(oc)->y_vector?VECTOR_DEPTH:0);
      if(!temp)
         error(oc_node->m_lineNo,"Out of variable space");
      y=new cTerm_MU_Storage(CAST(cIdentifierPrivate,temp),0);
      y_ret=y;
   }
   else
   {
      y=new cTerm_MU_Null();
      y_ret=y;         
   }
   instruction->createMU(
      swap?oc+4:oc,
      CAST(cTerm_MU,x1),
      CAST(cTerm_MU,x2),
      CAST(cTerm_MU,y)
      );
   instructions->append(instruction);
   if(y->isKindOf(cTerm_MU_Result::getCLID()))
   {
      cInstruction *instruction2;
      cIdentifier *temp;
      temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
      y=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
      instruction2=new cInstruction(node);
      instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_Result(),
            new cTerm_IMU_Zero(),
            CAST(cTerm_IMU,y));
      instructions->append(instruction2);
      y_ret=y;
   }
   if(!_isMU)
      return cTerm::Convert2IMU(y_ret);
   else
      return y_ret;
}

// Generate pre increment/decrement
// For example: ++x , --x

cTerm *cGEN::genTermPreIncrementDecrement(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cTerm *x1,*x2,*y;
   cAstNode *y_node,*oc_node;
   int oc=0;
   cInstruction *instruction;
   oc_node=(cAstNode *)node->getChildList();
   if(!oc_node)
      error(node->m_lineNo,"Unsupported C syntax");
   y_node=(cAstNode *)oc_node->getNext();
   if(!y_node)
      error(oc_node->m_lineNo,"Unsupported C syntax");
   if(oc_node->getID()==eTOKEN_unary_operator)
   {
      if(strcmp(CAST(cAstStringNode,oc_node)->getStringValue(),"-")==0)
      {
         if(!_isMU)
         {
            cIdentifierInteger *id;
            id=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
            y=new cTerm_IMU_Integer(CAST(cIdentifierInteger,id));
            if(!(x1=genTerm(instructions,_root,func,y_node,false,ref,_isMU)))
               error(y_node->m_lineNo,"\nInvalid parameter\n");
            instruction= new cInstruction(node);
            instruction->createIMU(cConfig::IOPCODE_SUB,new cTerm_IMU_Zero(),CAST(cTerm_IMU,x1),CAST(cTerm_IMU,y));
            instructions->append(instruction);
            return y;
         }
         else
         {
            cIdentifierPrivate *id;
            if(!(x1=genTerm(instructions,_root,func,y_node,false,ref,_isMU)))
               error(y_node->m_lineNo,"\nInvalid parameter\n");
            id=new cIdentifierPrivate(func->getChild(1,eTOKEN_block_item_list),0,0,CAST(cTerm_MU,x1)->getVectorWidth());
            y=new cTerm_MU_Storage(CAST(cIdentifierPrivate,id),0);
            instruction= new cInstruction(node);
            instruction->createMU(cConfig::OPCODE_SUB,new cTerm_MU_Constant((float)0.0),CAST(cTerm_MU,x1),CAST(cTerm_MU,y));
            instructions->append(instruction);
            return y;
         }
      }
      else if(strcmp(CAST(cAstStringNode,oc_node)->getStringValue(),"+")==0)
      {
         if(!(x1=genTerm(instructions,_root,func,y_node,false,ref,_isMU)))
            error(y_node->m_lineNo,"\nInvalid parameter\n");
         return x1;
      }
      else
      {
         error(oc_node->m_lineNo,"Unsupported C syntax");
         return 0;
      }
   }
   else
   {
   if(oc_node->getID()==eTOKEN_DEC_OP)
      oc=cConfig::IOPCODE_SUB;
   else if(oc_node->getID()==eTOKEN_INC_OP)
      oc=cConfig::IOPCODE_ADD;
   else
      error(oc_node->m_lineNo,"Unsupported C syntax");
   if(!(y=genTerm(instructions,_root,func,y_node,false,false,false)))
      error(y_node->m_lineNo,"\nInvalid parameter\n");
   if(!(x1=genTerm(instructions,_root,func,y_node,false,false,false)))
      error(y_node->m_lineNo,"\nInvalid parameter\n");
   x2=new cTerm_IMU_Constant(1);
   instruction= new cInstruction(node);
   instruction->createIMU(oc,CAST(cTerm_IMU,x1),CAST(cTerm_IMU,x2),CAST(cTerm_IMU,y));
   instructions->append(instruction);
   return y;
   }
}

// Generate calculation result
// For example:   (x+y)*z

cTerm *cGEN::genTermCalculation(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool _isExReg,bool ref,
   bool _isMU,cTerm *_y)
{
   cAstNode *x1_node,*x2_node,*node2;
   cInstruction *instruction;
   cTerm *x1,*x2,*y,*xacc;
   int oc=0;
   y=0;
   node2=node;
   x1_node=(cAstNode *)node2->getChildList();
   for(;;)
   {
      x2_node=(cAstNode *)x1_node->getNext();
      if(!x2_node)
         break;
      if(y)
         x1=y;
      else
      {
         if(!(x1=genTerm(instructions,_root,func,x1_node,false,false,_isMU)))
            error(x1_node->m_lineNo,"\nInvalid parameter\n");
      }
      if(!(x2=genTerm(instructions,_root,func,x2_node,false,false,_isMU)))
         error(x2_node->m_lineNo,"\nInvalid parameter\n");
      xacc=0;
      switch(node2->getID())
      {
      case eTOKEN_additive_expression_add:
         if(!_isMU)
            oc=cConfig::IOPCODE_ADD;
         else
            oc=cConfig::OPCODE_ADD;
         break;
      case eTOKEN_additive_expression_sub:
         if(!_isMU)
            oc=cConfig::IOPCODE_SUB;
         else
            oc=cConfig::OPCODE_SUB;
         break;
      case eTOKEN_multiplicative_expression_mul:
         if(!_isMU)
            oc=cConfig::IOPCODE_MUL;
         else
            oc=cConfig::OPCODE_MUL;
         break;
      case eTOKEN_shift_expression_shl:
         if(!_isMU)
            oc=cConfig::IOPCODE_SHL;
         else
         {
            if (x1->isDouble())
            {
               oc=cConfig::OPCODE_SHLA;
               xacc=x1;
               x1=x2;
               x2=new cTerm_MU_Null();
            }
            else
            {
               cTerm *temp=x1;
               x1=x2;
               x2=temp;
               oc=cConfig::OPCODE_SHL;
            }
         }
         break;
      case eTOKEN_shift_expression_shr:
         if(!_isMU)
         {
            if(CAST(cTerm_IMU,x1)->isUnsigned())
               oc=cConfig::IOPCODE_LSHR;
            else
               oc=cConfig::IOPCODE_SHR;
         }
         else
         {
            if (x1->isDouble())
            {
               oc = cConfig::OPCODE_SHRA;
               xacc=x1;
               x1 = x2;
               x2 = new cTerm_MU_Null();
            }
            else
            {
               cTerm *temp=x1;
               x1=x2;
               x2=temp;
               oc = cConfig::OPCODE_SHR;
            }
         }
         break;
      case eTOKEN_inclusive_or_expression:
         if(!_isMU)
            oc=cConfig::IOPCODE_OR;
         else
            error(node2->m_lineNo,"Operation not supported for floating point");
         break;
      case eTOKEN_and_expression:
         if(!_isMU)
            oc=cConfig::IOPCODE_AND;
         else
            error(node2->m_lineNo,"Operation not supported for floating point");
         break;
      case eTOKEN_exclusive_or_expression:
         if(!_isMU)
            oc=cConfig::IOPCODE_XOR;
         else
            error(node2->m_lineNo,"Operation not supported for floating point");
         break;
      default:
         error(node2->m_lineNo,"Invalid operator");
         break;
      }

      if(!_isMU)
      {
         cIdentifier *temp;
         if((temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1)))
         {  
            y=new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp));
         }
         else
            error(node2->m_lineNo,"Out of variable space for temporary variables");
      }
      else
      {
         cIdentifier *temp;
         bool vector;
         if(CAST(cTerm_MU,x1)->getVectorWidth() > 0 ||
            CAST(cTerm_MU,x2)->getVectorWidth() > 0)
            vector=true;
         else
            vector=false;

         if(_isExReg)
         {
            y = new cTerm_MU_Storage(new cIdentifierExReg(func->getChild(1,eTOKEN_block_item_list),0,0,VECTOR_DEPTH,false),0);
         }
         else if((temp=new cIdentifierPrivate(func->getChild(1,eTOKEN_block_item_list),0,0,vector?VECTOR_DEPTH:0)))
         {
            y=new cTerm_MU_Storage(CAST(cIdentifierPrivate,temp),0);
         }
         else
            error(node2->m_lineNo,"Out of variable space for temporary variables");
      }
      instruction=new cInstruction(node);
      if(!_isMU)
      {
         if(!x1->isKindOf(cTerm_IMU::getCLID()) || 
            !x2->isKindOf(cTerm_IMU::getCLID()) ||
            !y->isKindOf(cTerm_IMU::getCLID()))
            error(node2->m_lineNo,"Invalid mix for floating point and integer");
         instruction->createIMU(oc,CAST(cTerm_IMU,x1),CAST(cTerm_IMU,x2),CAST(cTerm_IMU,y));
      }
      else
      {
         if(!x1->isKindOf(cTerm_MU::getCLID()) || 
            !x2->isKindOf(cTerm_MU::getCLID()) ||
            !y->isKindOf(cTerm_MU::getCLID()))
            error(node2->m_lineNo,"Invalid mix for floating point and integer");
         if((oc==cConfig::OPCODE_SHRA || oc==cConfig::OPCODE_SHLA) && x1->isKindOf(cTerm_MU_Integer::getCLID()))
         {
            // Do inline expansion. Repease shift instruction because each shift instruction can only do upto MAX_SHIFT_DISTANCE 
            // For now inline expansion only available for y=_A << i where i is an integer type variable
            cInstruction *lastInstruction,*instruction2,*instruction3;
            cIdentifierInteger *id,*temp;
            cTerm *tterm;

            delete instruction;
            instruction=0;
            id=CAST(cTerm_MU_Integer,x1)->m_id;
            temp=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1);
            lastInstruction=new cInstruction(node);

            tterm=xacc;

            // _A = _A << i
            instruction2=new cInstruction(node);
            instruction2->createMU(oc,
                                   new cTerm_MU_Integer(id),
                                   CAST(cTerm_MU,x2),
                                   CAST(cTerm_MU,tterm),
                                   CAST(cTerm_MU,xacc));
            instructions->append(instruction2);

            // temp=i=3; if (temp <= 0) goto exit 
            instruction2= new cInstruction(node);
            instruction2->createConditionalJump(cConfig::OPCODE_JUMP_LE,cConfig::IOPCODE_SUB,
                                               new cTerm_IMU_Integer(CAST(cIdentifierInteger,id)),
                                               new cTerm_IMU_Constant(MAX_SHIFT_DISTANCE),
                                               new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp)),
                                               lastInstruction,
                                               false);
            instructions->append(instruction2);
            id=temp;

            // _A=_A << temp
            instruction2=new cInstruction(node);
            instruction2->createMU(oc,
                                   new cTerm_MU_Integer(id),
                                   CAST(cTerm_MU,x2),
                                   CAST(cTerm_MU,tterm),
                                   CAST(cTerm_MU,tterm));
            instructions->append(instruction2);

            // if (temp > 0) goto repeat 
            instruction3= new cInstruction(node);
            instruction3->createConditionalJump(cConfig::OPCODE_JUMP_GT,cConfig::IOPCODE_SUB,
                                               new cTerm_IMU_Integer(CAST(cIdentifierInteger,id)),
                                               new cTerm_IMU_Constant(MAX_SHIFT_DISTANCE),
                                               new cTerm_IMU_Integer(CAST(cIdentifierInteger,temp)),
                                               instruction2,
                                               false);
            instructions->append(instruction3);
            
            // Copy TEMP to final variable.

             lastInstruction->createMU(oc,
                                      new cTerm_MU_Integer(id),
                                      CAST(cTerm_MU,x2),
                                      CAST(cTerm_MU,y),
                                      CAST(cTerm_MU,tterm));
            instructions->append(lastInstruction);
         }
         else if((oc==cConfig::OPCODE_SHRA || oc==cConfig::OPCODE_SHLA) && x1->isKindOf(cTerm_MU_Constant::getCLID())) {
            int shift=(int)CAST(cTerm_MU_Constant,x1)->m_c;
            if(shift <= MAX_SHIFT_DISTANCE) {
               instruction->createMU(oc,CAST(cTerm_MU,x1),CAST(cTerm_MU,x2),CAST(cTerm_MU,y),xacc?CAST(cTerm_MU,xacc):0);
            } else {
               cInstruction *instruction2;
               delete instruction;
               instruction=0;
               while(shift > 0) {
                  instruction2=new cInstruction(node);
                  if(shift > MAX_SHIFT_DISTANCE) {
                     instruction2->createMU(oc,
                                         new cTerm_MU_Constant((float)((shift>MAX_SHIFT_DISTANCE)?MAX_SHIFT_DISTANCE:shift)),
                                         CAST(cTerm_MU,x2),
                                         CAST(cTerm_MU,xacc),
                                         CAST(cTerm_MU,xacc));
                  } else {
                     instruction2->createMU(oc,
                                         new cTerm_MU_Constant((float)((shift>MAX_SHIFT_DISTANCE)?MAX_SHIFT_DISTANCE:shift)),
                                         CAST(cTerm_MU,x2),
                                         CAST(cTerm_MU,y),
                                         CAST(cTerm_MU,xacc));
                  }
                  instructions->append(instruction2);
                  shift -= MAX_SHIFT_DISTANCE;
               }
            }
         }
         else if((oc==cConfig::OPCODE_SHR || oc==cConfig::OPCODE_SHL) && x1 && x1->isKindOf(cTerm_MU_Constant::getCLID())) {
            int shift=(int)CAST(cTerm_MU_Constant,x1)->m_c;
            if(shift <= MAX_SHIFT_DISTANCE) {
               instruction->createMU(oc,CAST(cTerm_MU,x1),CAST(cTerm_MU,x2),CAST(cTerm_MU,y),xacc?CAST(cTerm_MU,xacc):0);
            } else {
               cInstruction *instruction2;
               bool first=true;
               int oc2;
               if(oc==cConfig::OPCODE_SHR)
                  oc2=cConfig::OPCODE_SHRA;
               else 
                  oc2=cConfig::OPCODE_SHLA;
               delete instruction;
               instruction=0;
               while(shift > 0) {
                  instruction2=new cInstruction(node);
                  if(first)
                     instruction2->createMU(oc,
                                         new cTerm_MU_Constant((float)((shift>MAX_SHIFT_DISTANCE)?MAX_SHIFT_DISTANCE:shift)),
                                         CAST(cTerm_MU,x2),
                                         CAST(cTerm_MU,y),
                                         0);
                  else
                  {
                     if(y->isDouble())
                        instruction2->createMU(oc2,
                                            new cTerm_MU_Constant((float)((shift>MAX_SHIFT_DISTANCE)?MAX_SHIFT_DISTANCE:shift)),
                                            new cTerm_MU_Null(),
                                            CAST(cTerm_MU,y),
                                            CAST(cTerm_MU,y));
                     else
                        instruction2->createMU(oc,
                                            new cTerm_MU_Constant((float)((shift>MAX_SHIFT_DISTANCE)?MAX_SHIFT_DISTANCE:shift)),
                                            CAST(cTerm_MU,y),
                                            CAST(cTerm_MU,y),
                                            0);
                  }
                  instructions->append(instruction2);
                  shift -= MAX_SHIFT_DISTANCE;
                  first=false;
               }
            }
         }
         else 
         {
            instruction->createMU(oc,CAST(cTerm_MU,x1),CAST(cTerm_MU,x2),CAST(cTerm_MU,y),xacc?CAST(cTerm_MU,xacc):0);
         }
      }
      if(instruction)
         instructions->append(instruction);
      x1_node=x2_node;
   }
   return y;
}

// Generate code for identifier or pre-defined identifier

cTerm *cGEN::genTermIdentifier(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cIdentifier *id;
   if(strcasecmp(CAST(cAstStringNode,node)->getStringValue(),"tid")==0)
   {
      if(_isMU)
         error(node->m_lineNo,"Invalid mix between integer and float values");
      else
         return new cTerm_IMU_TID();
   }
   else if(strcasecmp(CAST(cAstStringNode,node)->getStringValue(),"_VMASK")==0)
   {
      if(_isMU)
         error(node->m_lineNo,"Invalid mix between integer and float values");
      else
         return new cTerm_IMU_Lane();
   }
   else if(strcasecmp(CAST(cAstStringNode,node)->getStringValue(),"pid")==0)
   {
      if(_isMU)
      {
         error(node->m_lineNo,"Invalid mix between integer and float values");
      }
      else
         return new cTerm_IMU_PID();
   }

   if(!(id=CAST(cAstIdentifierNode,node)->getIdentifier()))
      error(node->m_lineNo,"Undefined variable");
   if(ref || id->getNumDim() > 0)
   {
      if(_y )
      {
         if(!_y->isKindOf(cTerm_IMU_Pointer::getCLID()))
            error(node->m_lineNo,"Invalid pointer assignment");
         cTerm_IMU_Pointer *term2=CAST(cTerm_IMU_Pointer,_y);
         if(CAST(cIdentifierPointer,term2->m_id)->m_width > 0)
         {
            if(!id->isKindOf(cIdentifierStorage::getCLID()) ||
               CAST(cIdentifierStorage,id)->m_w==0 )
            {
               error(node->m_lineNo,"Invalid pointer assignment");
            }
         }
         else
         {
            if(id->isKindOf(cIdentifierStorage::getCLID()) &&
               (CAST(cIdentifierStorage,id)->m_w > 0))
            {
               error(node->m_lineNo,"Invalid pointer assignment");
            }
         }
      }

      // This is a pointer reference to a variable
      if(id->isKindOf(cIdentifierShared::getCLID()))
      {
         return new cTerm_IMU_SharedPointerConstant(id,0,false);
      }
      else if(id->isKindOf(cIdentifierPrivate::getCLID()))
      {
         return new cTerm_IMU_PrivatePointerConstant(id,0,false);
      }
      else if(id->isKindOf(cIdentifierConst::getCLID()))
      {
         return new cTerm_IMU_ConstPointerConstant(id,0);
      }
      else
         error(node->m_lineNo,"Invalid pointer reference");
   }
   else
   {
      if(id->isKindOf(cIdentifierShared::getCLID()))
         return new cTerm_MU_Storage(CAST(cIdentifierStorage,id),0);
      else if(id->isKindOf(cIdentifierPrivate::getCLID()))
         return new cTerm_MU_Storage(CAST(cIdentifierStorage,id),0);
      else if(id->isKindOf(cIdentifierExReg::getCLID()))
         return new cTerm_MU_Storage(CAST(cIdentifierStorage,id),0);
      else if(id->isKindOf(cIdentifierInteger::getCLID()))
      {
         if(_isMU)
            return new cTerm_MU_Integer(CAST(cIdentifierInteger,id));
         else
            return new cTerm_IMU_Integer(CAST(cIdentifierInteger,id));
      }
      else if(id->isKindOf(cIdentifierPointer::getCLID()))
         return new cTerm_IMU_Pointer(CAST(cIdentifierPointer,id));
      else if(id->isKindOf(cIdentifierConst::getCLID()))
      {
         cInstruction *instruction2;
         cTerm *term,*term2;
         cIdentifierPointer *id2;
         term=new cTerm_IMU_ConstPointerConstant(id,0);
         instruction2=new cInstruction(node);
         id2=new cIdentifierPointer(func->getChild(1,eTOKEN_block_item_list),0,0,true,0);
         CAST(cIdentifierPointer,id2)->m_scope.append(id);
         term2=new cTerm_IMU_Pointer(id2);
         instruction2->createIMU(cConfig::IOPCODE_ADD,
                  CAST(cTerm_IMU,term),
                  new cTerm_IMU_Zero(),
                  CAST(cTerm_IMU,term2));
         instructions->append(instruction2);
         return new cTerm_MU_PointerWithoutIndex(CAST(cIdentifierPointer,id2),0);
      }
      else
      {
         error(node->m_lineNo,"Invalid data type");
         return 0;
      }
   }
   return 0;
}


// Generate code for direct array indexing reference
// For example  x[i+2]

cTerm *cGEN::genTermDirectIndexing(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cAstNode *node2;
   cAstNode *arrayNode;
   cIdentifier *id;
   cIdentifierInteger *array_i;
   int array_c;
   int num_dim;
   bool subVector;

   arrayNode=node;
   node2=node;
   node=(cAstNode *)node->getChildList();
   if(!node)
      error(node2->m_lineNo,"This C-syntax is not supported by this compiler");

   id=CAST(cAstIdentifierNode,node)->getIdentifier();

   num_dim=decode_array(instructions,_root,func,id,arrayNode,&array_i,&array_c,&subVector);
   if((num_dim==id->getNumDim() || subVector) && !ref)
   {
      // This is an array reference
      if(!array_i)
      {
         if(array_c >= id->getLen())
            error(arrayNode->m_lineNo,"Array indexing exceeds array size");
         if(id->isKindOf(cIdentifierStorage::getCLID()))
            return new cTerm_MU_Storage(CAST(cIdentifierStorage,id),array_c,subVector);
         else if(id->isKindOf(cIdentifierConst::getCLID()))
         {
            cInstruction *instruction2;
            cTerm *term,*term2;
            cIdentifierPointer *id2;
            term=new cTerm_IMU_ConstPointerConstant(id,0);
            instruction2=new cInstruction(node);
            id2=new cIdentifierPointer(func->getChild(1,eTOKEN_block_item_list),0,0,true,0);
            CAST(cIdentifierPointer,id2)->m_scope.append(id);
            term2=new cTerm_IMU_Pointer(id2);
            instruction2->createIMU(cConfig::IOPCODE_ADD,
                  CAST(cTerm_IMU,term),
                  new cTerm_IMU_Zero(),
                  CAST(cTerm_IMU,term2));
            instructions->append(instruction2);
            return new cTerm_MU_PointerWithoutIndex(CAST(cIdentifierPointer,id2),array_c);
         }
         else
            error(arrayNode->m_lineNo,"Invalid pointer reference");
      }
      else
      {
         if(array_c >= id->getLen())
            error(arrayNode->m_lineNo,"Array indexing exceeds array size");
         if(id->isKindOf(cIdentifierStorage::getCLID()))
            return new cTerm_MU_StorageWithIndex(CAST(cIdentifierStorage,id),CAST(cIdentifierInteger,array_i),array_c,subVector);
         else if(id->isKindOf(cIdentifierConst::getCLID()))
         {         
            cInstruction *instruction2;
            cTerm *term,*term2;
            cIdentifierPointer *id2;
            term=new cTerm_IMU_ConstPointerConstant(id,0);
            instruction2=new cInstruction(node);
            id2=new cIdentifierPointer(func->getChild(1,eTOKEN_block_item_list),0,0,true,0);
            CAST(cIdentifierPointer,id2)->m_scope.append(id);
            term2=new cTerm_IMU_Pointer(id2);
            instruction2->createIMU(cConfig::IOPCODE_ADD,
                  CAST(cTerm_IMU,term),
                  new cTerm_IMU_Zero(),
                  CAST(cTerm_IMU,term2));
            instructions->append(instruction2);
            return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id2),array_i,array_c);
         }
         else
            error(arrayNode->m_lineNo,"Invalid pointer reference");
      }
   }
   else
   {
      cTerm_IMU *term=0,*term2;
      cInstruction *instruction2;
      if(num_dim>=id->getNumDim())
      { 
         // All dimention are specified. This must be a reference 
         if(!ref)
            error(arrayNode->m_lineNo,"Syntax error");
      }
      else
      {
         if(!id->isKindOf(cIdentifierPrivate::getCLID()) && 
            !id->isKindOf(cIdentifierShared::getCLID()))
            error(arrayNode->m_lineNo,"Invalid variable reference");
      }
      if(_y )
      {
         if(!_y->isKindOf(cTerm_IMU_Pointer::getCLID()))
            error(arrayNode->m_lineNo,"Invalid pointer assignment");
         cTerm_IMU_Pointer *term2=CAST(cTerm_IMU_Pointer,_y);
         if(CAST(cIdentifierPointer,term2->m_id)->m_width > 0)
         {
            if(!id->isKindOf(cIdentifierStorage::getCLID()) ||
               CAST(cIdentifierStorage,id)->m_w==0 || 
               subVector)
            {
               error(arrayNode->m_lineNo,"Invalid pointer assignment");
            }
         }
         else
         {
            if(id->isKindOf(cIdentifierStorage::getCLID()) &&
               (CAST(cIdentifierStorage,id)->m_w > 0 && !subVector))
            {
               error(arrayNode->m_lineNo,"Invalid pointer assignment");
            }
         }
      }
      if(id->isKindOf(cIdentifierShared::getCLID()))
         term= new cTerm_IMU_SharedPointerConstant(id,array_c,subVector);
      else if(id->isKindOf(cIdentifierPrivate::getCLID()))
         term= new cTerm_IMU_PrivatePointerConstant(id,array_c,subVector);
      else if(id->isKindOf(cIdentifierConst::getCLID()))
         term= new cTerm_IMU_ConstPointerConstant(id,array_c);
      else
         error(arrayNode->m_lineNo,"Invalid pointer reference");
      if(array_i)
      {
         instruction2=new cInstruction(node);
         term2=new cTerm_IMU_Integer(new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1));
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            term,
            new cTerm_IMU_Integer(CAST(cIdentifierInteger,array_i)),
            term2);
         instructions->append(instruction2);
         return term2;
      }
      else
         return term;
   }
   return 0;
}

// Generate code for memory reference via use of pointer
// For example:  p[i+6] where p is of type (float *)

cTerm *cGEN::genTermPointerIndexing(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool ref,
   bool _isMU,cTerm *_y)
{
   cAstNode *arrayNode;
   cAstNode *node2,*node3,*node4;
   cIdentifier *id;
   arrayNode=node;
   node=(cAstNode *)node->getChildList();
   if(!node)
      error(arrayNode->m_lineNo,"This C-syntax is not supported by this compiler");
   id=CAST(cAstIdentifierNode,node)->getIdentifier();
   node2=(cAstNode *)node->getNext();
   if(!node2)
      error(node->m_lineNo,"This C-syntax is not supported by this compiler");
   if(node2->getNext())
      error(node2->m_lineNo,"Pointer reference must be single dimension");
   if(node2->getID() != eTOKEN_expression)
   {
      error(node2->m_lineNo,"Invalid array index");
      return 0;
   }
   node3=(cAstNode *)node2->getChildList();
   if(!node3)
      error(node2->m_lineNo,"Invalid array indexing");
   if(node3->getID() == eTOKEN_I_CONSTANT)
   {
      int ival;
      cInstruction *instruction2;
      ival=CAST(cAstIntNode,node3)->getIntValue();
      if(ival >= MIN_POINTER_OFFSET && ival <= MAX_POINTER_OFFSET)
         return new cTerm_MU_PointerWithoutIndex(CAST(cIdentifierPointer,id),ival);
      else
      {
         cTerm_IMU *term2;
         instruction2=new cInstruction(node);
         term2=new cTerm_IMU_Integer(new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,false,false,-1));
         instruction2->createIMU(cConfig::IOPCODE_ADD,
            new cTerm_IMU_Constant(ival),
            new cTerm_IMU_Zero(),
            term2);
         instructions->append(instruction2);
         return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cTerm_IMU_Integer,term2)->m_id,0);
      }
   }
   else if(node3->getID() == eTOKEN_additive_expression_sub)
   {
      cAstNode *sub_node=node3;
      node4=(cAstNode *)node3->getChildList();
      node3=(cAstNode *)node4->getNext();
      if(((cAstNode *)node3)->getID()==eTOKEN_I_CONSTANT)
      {
         cIdentifier *id2;
         int c=-CAST(cAstIntNode,node3)->getIntValue();
         if(c >= MIN_POINTER_OFFSET && c <= MAX_POINTER_OFFSET)
         {
            if(node4->getID()==eTOKEN_IDENTIFIER)
               id2=CAST(cAstIdentifierNode,node4)->getIdentifier();
            else
            {
               cTerm *term;
               term=genTerm(instructions,_root,func,node4,false,false,false);
               if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
                  error(node3->m_lineNo,"Invalid array indexing");
               id2=CAST(cTerm_IMU_Integer,term)->m_id;
            }
            if(!id2->isKindOf(cIdentifierInteger::getCLID()))
               error(node3->m_lineNo,"Pointer index must be of integer type");
            return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),c);
         }
         else
         {
            cTerm *term;
            term=genTerm(instructions,_root,func,sub_node,false,false,false);
            if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
               error(node3->m_lineNo,"Invalid array indexing");
            id2=CAST(cTerm_IMU_Integer,term)->m_id;
            return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),0);
         }
      }
      else
      {
         cTerm *term;
         cIdentifier *id2;
         term=genTerm(instructions,_root,func,sub_node,false,false,false);
         if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
            error(node3->m_lineNo,"Invalid array indexing");
         id2=CAST(cTerm_IMU_Integer,term)->m_id;
         return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),0);
      }
   }
   else if(node3->getID() == eTOKEN_additive_expression_add)
   {
      cIdentifier *id2;
      cAstNode *add_node=node3;
      if(((cAstNode *)node3->getChildList())->getID()==eTOKEN_I_CONSTANT)
      {
         node3=(cAstNode *)node3->getChildList();
         node4=(cAstNode *)node3->getNext();
      }
      else
      {
         node4=(cAstNode *)node3->getChildList();
         node3=(cAstNode *)node4->getNext();
      }
      if(node3->getID()==eTOKEN_I_CONSTANT)
      {
         int c=CAST(cAstIntNode,node3)->getIntValue();
         if(c >= MIN_POINTER_OFFSET && c <= MAX_POINTER_OFFSET)
         {
            if(node4->getID()==eTOKEN_IDENTIFIER)
               id2=CAST(cAstIdentifierNode,node4)->getIdentifier();
            else
            {
               cTerm *term;
               term=genTerm(instructions,_root,func,node4,false,false,false);
               if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
                  error(node3->m_lineNo,"Invalid array indexing");
               id2=CAST(cTerm_IMU_Integer,term)->m_id;
            }
            if(!id2->isKindOf(cIdentifierInteger::getCLID()))
               error(node4->m_lineNo,"Pointer index must be of integer type");
            return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),c);
         }
         else
         {
            cTerm *term;
            term=genTerm(instructions,_root,func,add_node,false,false,false);
            if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
               error(add_node->m_lineNo,"Invalid array indexing");
            id2=CAST(cTerm_IMU_Integer,term)->m_id;
            return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),0);
         }
      }
      else
      {
         cTerm *term;
         term=genTerm(instructions,_root,func,add_node,false,false,false);
         if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
            error(add_node->m_lineNo,"Invalid array indexing");
         id2=CAST(cTerm_IMU_Integer,term)->m_id;
         return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),0);
      }
   }
   else if(node3->getID()==eTOKEN_IDENTIFIER)
   {
      cIdentifier *id2;
      id2=CAST(cAstIdentifierNode,node3)->getIdentifier();
      if(!id2->isKindOf(cIdentifierInteger::getCLID()))
         error(node3->m_lineNo,"Pointer index must be of integer type");
      return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),0);
   }
   else
   {
      cTerm *term;
      cIdentifier *id2;
      term=genTerm(instructions,_root,func,node3,false,false,false);
      if(!term->isKindOf(cTerm_IMU_Integer::getCLID()))
         error(node3->m_lineNo,"Invalid array indexing");
      id2=CAST(cTerm_IMU_Integer,term)->m_id;
      return new cTerm_MU_PointerWithIndex(CAST(cIdentifierPointer,id),CAST(cIdentifierInteger,id2),0);
   }
}

// Generate code with result is a term

cTerm *cGEN::genTerm(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,bool _isExReg,bool ref,
                     bool _isMU,cTerm *_y)
{
   cAstNode *node2;
   cAstNode *arrayNode;
   cIdentifier *id;

   if(!node)
   {
      if(_isMU)
         return new cTerm_MU_Null();
      else
         return new cTerm_IMU_Null();
   }
   switch(node->getID())
   {
   case eTOKEN_conditional_expression:
      return genTermConditionalExpression(instructions,_root,func,node,ref,_isMU,_y);
   case eTOKEN_assignment_expression:
      return genTermAssignmentExpression(instructions,_root,func,node,ref,_isMU,_y);
   case eTOKEN_postfix_expression7:
   case eTOKEN_postfix_expression8:
     return genTermPostIncrementDecrement(instructions,_root,func,node,ref,_isMU,_y);
   case eTOKEN_postfix_expression4:
      return genTermFunction(instructions,_root,func,node,ref,_isMU,_y);
   case eTOKEN_unary_expression:
      // &var
      // Return the address of a variable
      node2=node->getChild(1,eTOKEN_unary_operator);
      if(node2 && strcmp(CAST(cAstStringNode,node2)->getStringValue(),"&") == 0)
         return genTerm(instructions,_root,func,(cAstNode *)node2->getNext(),false,true,_isMU,_y);
      else if(node2 && strcmp(CAST(cAstStringNode,node2)->getStringValue(),"*") == 0)
         error(node2->m_lineNo,"Unsupported pointer reference syntax. Use array notation instead");
      else
         return genTermPreIncrementDecrement(instructions,_root,func,node,ref,_isMU,_y);
   case eTOKEN_expression:
      return genTerm(instructions,_root,func,node->getChildList(),false,ref,_isMU,_y);
   case eTOKEN_additive_expression_add:
   case eTOKEN_additive_expression_sub:
   case eTOKEN_multiplicative_expression_mul:
   case eTOKEN_shift_expression_shl:
   case eTOKEN_shift_expression_shr:
   case eTOKEN_inclusive_or_expression:
   case eTOKEN_and_expression:
   case eTOKEN_exclusive_or_expression:
      return genTermCalculation(instructions,_root,func,node,_isExReg,ref,_isMU,_y);
   case eTOKEN_IDENTIFIER:
      return genTermIdentifier(instructions,_root,func,node,ref,_isMU,_y);
   case eTOKEN_I_CONSTANT:
      if(_isMU)
         return new cTerm_MU_Constant(float(CAST(cAstIntNode,node)->getIntValue()));
      else
         return new cTerm_IMU_Constant(CAST(cAstIntNode,node)->getIntValue(),true);
   case eTOKEN_F_CONSTANT:
      if(_isMU)
         return new cTerm_MU_Constant(CAST(cAstFloatNode,node)->getFloatValue());
      else
         error(node->m_lineNo,"Invalid constant type");
   case eTOKEN_postfix_expression2:
      // Array notation....
      arrayNode=node;
      node=(cAstNode *)node->getChildList();
      if(!node)
         error(arrayNode->m_lineNo,"This C-syntax is not supported by this compiler");
      id=CAST(cAstIdentifierNode,node)->getIdentifier();
      if(id->isKindOf(cIdentifierStorage::getCLID()) || 
         id->isKindOf(cIdentifierConst::getCLID()))
      {
         return genTermDirectIndexing(instructions,_root,func,arrayNode,ref,_isMU,_y);
      }
      else if(id->isKindOf(cIdentifierPointer::getCLID()))
      {
         return genTermPointerIndexing(instructions,_root,func,arrayNode,ref,_isMU,_y);
      }
      else 
      {
         error(node->m_lineNo,"Invalid array indexing");
      }
      break;
   case eTOKEN_multiplicative_expression_div:
      error(node->m_lineNo,"Divide operation is not supported");
      break;
   case eTOKEN_multiplicative_expression_mod:
      error(node->m_lineNo,"Modulor operation is not supported");
      break;
   default:
      error(node->m_lineNo,"This C-syntax is not supported by this compiler");
      break;
   }
   return 0;
}

// Generate instructions for a switch statement

cInstruction *cGEN::genSwitchStatement(cInstructions *instructions,cAstNode *_root,cAstNode *func,
   cAstNode *_node,
   bool hasExitCode,
   cInstruction *exitInstruction,
   cInstruction *blockExitInstruction,
   cInstruction *blockContInstruction)
{
   cInstruction *instruction;
   cInstruction *switchExitInstruction;
   cInstruction *nextInstruction=0;
   cInstruction *defaultInstruction=0;
   cAstNode *switchCaseNode;
   cAstNode *node;
   cAstNode *right;
   cTerm *term;
   bool isMU;
   float c_f=0.0;
   int c_i=0;
   int count;
   std::vector<cInstruction *> lst;
   switchExitInstruction=new cInstruction(_node);
   switchExitInstruction->setNOP();
   node=_node->getChild(2,eTOKEN_block_item_list,eTOKEN_block_item);
   isMU=expressionIsMU((cAstNode *)_node->getChildList());
   term=genTerm(instructions,_root,func,(cAstNode *)_node->getChildList(),false,false,isMU);
   nextInstruction=0;

   // Extract list of cases and create conditional statement for each case

   while(node)
   {
      switchCaseNode=node->getChild(1,eTOKEN_labeled_statement);
      nextInstruction=new cInstruction(_node);
      if(switchCaseNode && switchCaseNode->getChildList()->getID()==eTOKEN_DEFAULT)
      {
         if(defaultInstruction)
            error(switchCaseNode->m_lineNo,"More than one default case");
         defaultInstruction=nextInstruction;
      }
      else if(switchCaseNode)
      {
         right=(cAstNode *)switchCaseNode->getChildList();
         while(right->isKindOf(cAstIntNode::getCLID()) || right->isKindOf(cAstFloatNode::getCLID()))
         {
            if(isMU)
            {
               if(right->isKindOf(cAstFloatNode::getCLID()))
                  c_f=(float)CAST(cAstFloatNode,right)->getFloatValue();
               else if(right->isKindOf(cAstIntNode::getCLID()))
                  c_f=(float)CAST(cAstIntNode,right)->getIntValue();
               else
                  error(right->m_lineNo,"Invalid switch case");
            }
            else
            {
               if(right->isKindOf(cAstIntNode::getCLID()))
                  c_i=(int)CAST(cAstIntNode,right)->getIntValue();
               else
                  error(right->m_lineNo,"Invalid switch case value");
            }
            if(isMU)
            {
               instruction= new cInstruction(_node);
               instruction->createMU(cConfig::IOPCODE_SUB,
                  new cTerm_MU_Storage(CAST(cTerm_MU_Storage,term)->m_id,0),
                  new cTerm_MU_Constant(c_f),
                  new cTerm_MU_Result);
               instructions->append(instruction);
               instruction= new cInstruction(_node);
               instruction->createConditionalJump(cConfig::OPCODE_JUMP_NE,
                  cConfig::IOPCODE_SUB,
                  new cTerm_IMU_Result(),
                  new cTerm_IMU_Constant(0),
                  0,
                  nextInstruction,
                  false);
               instructions->append(instruction);
            }
            else
            {
               instruction= new cInstruction(_node);
               instruction->createConditionalJump(cConfig::OPCODE_JUMP_EQ,
                  cConfig::IOPCODE_SUB,
                  new cTerm_IMU_Integer(CAST(cTerm_IMU_Integer,term)->m_id),
                  new cTerm_IMU_Constant(c_i),
                  0,
                  nextInstruction,
                  false);
               instructions->append(instruction);
            }
            right=(cAstNode *)right->getNext();
         }
      }
      lst.push_back(nextInstruction);
      node=(cAstNode *)node->getNext();
   }
   nextInstruction=new cInstruction(_node);
   if(defaultInstruction)
      nextInstruction->createUnconditionalJump(cConfig::OPCODE_JUMP,defaultInstruction,false);
   else
      nextInstruction->createUnconditionalJump(cConfig::OPCODE_JUMP,switchExitInstruction,false);
   instructions->append(nextInstruction);

   // Generate code body for each case

   node=_node->getChild(2,eTOKEN_block_item_list,eTOKEN_block_item);
   count=0;
   while(node)
   {
      instructions->append(lst[count++]);
      switchCaseNode=node->getChild(1,eTOKEN_labeled_statement);
      if(switchCaseNode && switchCaseNode->getChildList()->getID()!=eTOKEN_DEFAULT)
      {
         right=(cAstNode *)switchCaseNode->getChildList();
         while(right->isKindOf(cAstIntNode::getCLID()) || right->isKindOf(cAstFloatNode::getCLID()))
         {
            right=(cAstNode *)right->getNext();
         }
         process_code_block(instructions,_root,func,right,hasExitCode,exitInstruction,
                       switchExitInstruction,blockContInstruction);
      }
      else
      {
         process_code_block(instructions,_root,func,(cAstNode *)node->getChildList(),hasExitCode,exitInstruction,
            switchExitInstruction,blockContInstruction);
      }
      node=(cAstNode *)node->getNext();
   }
   instructions->append(switchExitInstruction);
   return (cInstruction *)instructions->getLast();
}

// Entry point to generate code for a statement

cInstruction *cGEN::genStatement(cInstructions *instructions,cAstNode *_root,cAstNode *func,
   cAstNode *_node,
   cAstNode *_node2,
   bool reverseLogic,
   bool hasExitCode,
   cInstruction *exitInstruction,
   cInstruction *brInstruction,
   bool brAfter,
   cInstruction *blockExitInstruction,
   cInstruction *blockContInstruction,
   bool logicStatement)
{
   cInstruction *instruction=0;
   cAstNode *left,*right;
   cTerm *term;
   bool isMU;
   if(_node->getID()==eTOKEN_expression)
   {
      cInstruction *end=0;
      _node=(cAstNode *)_node->getChildList();
      while(_node)
      {
         end=genStatement(instructions,_root,func,_node,_node2,reverseLogic,hasExitCode,exitInstruction,
                      brInstruction,brAfter,blockExitInstruction,blockContInstruction,logicStatement);
         _node=(cAstNode *)_node->getNext();
      }
      return end;
   }
   switch(_node->getID())
   {
   case eTOKEN_jump_statement:
      if(_node->getChild(1,eTOKEN_GOTO))
      {
         error(_node->m_lineNo,"Unsupported C-statement");
      }
      else if(_node->getChild(1,eTOKEN_RETURN))
      {
         if(_node->getChild(1,eTOKEN_expression))
         {
            cIdentifierReturnValue *rvid;
//            error(_node->m_lineNo,"Kernel function has no return value");
            rvid=cIdentifier::getReturnValue(func->getChild(1,eTOKEN_block_item_list));
            if(!rvid)
               error(_node->m_lineNo,"No return value expected");
            cTerm *temp;
            instruction= new cInstruction(_node);
            if(rvid->m_float)
            {
               // Return value is a float
               temp=genTerm(instructions,_root,func,_node->getChild(1,eTOKEN_expression),false,false,true,0);
               if(!temp->isKindOf(cTerm_MU::getCLID()))
                  error(_node->m_lineNo,"Parameter data type mistmatched");
               instruction->createMU(
                                 cConfig::OPCODE_ASSIGN,
                                 CAST(cTerm_MU,temp),
                                 new cTerm_MU_Null(),
                                 new cTerm_MU_Storage(cIdentifier::getReturnValue(func->getChild(1,eTOKEN_block_item_list)),0));
            }
            else
            {
               // Return value is an integer....
               temp=genTerm(instructions,_root,func,_node->getChild(1,eTOKEN_expression),false,false,false,0);
               if(!temp->isKindOf(cTerm_IMU::getCLID()))
                  error(_node->m_lineNo,"Parameter data type mistmatched");
               temp=cTerm::Convert2MU(0,0,0,temp);
               if(temp->isKindOf(cTerm_MU_Constant::getCLID()))
                  CAST(cTerm_MU_Constant,temp)->m_float=false;
               instruction->createMU(
                                 cConfig::OPCODE_ASSIGN_RAW,
                                 CAST(cTerm_MU,temp),
                                 new cTerm_MU_Null(),
                                 new cTerm_MU_Storage(cIdentifier::getReturnValue(func->getChild(1,eTOKEN_block_item_list)),0));
            }
            instructions->append(instruction);
         }
         else
         {
            if(cIdentifier::getReturnValue(func->getChild(1,eTOKEN_block_item_list)))
               error(_node->m_lineNo,"Return value expected");
         }
         instruction= new cInstruction(_node);
         if(hasExitCode)
            instruction->createUnconditionalJump(cConfig::OPCODE_JUMP,exitInstruction,false);
         else
            instruction->createUnconditionalJump(cConfig::OPCODE_RETURN,0,false);
      }
      else if(_node->getChild(1,eTOKEN_BREAK))
      {
         instruction= new cInstruction(_node);
         if(!blockExitInstruction)
            error(_node->m_lineNo,"Invalid break");
         instruction->createUnconditionalJump(cConfig::OPCODE_JUMP,blockExitInstruction,false);
      }
      else if(_node->getChild(1,eTOKEN_CONTINUE))
      {
         instruction= new cInstruction(_node);
         if(!blockExitInstruction)
            error(_node->m_lineNo,"Invalid break");
         instruction->createUnconditionalJump(cConfig::OPCODE_JUMP,blockContInstruction,false);
      } 
      else
         error(_node->m_lineNo,"Invalid C-statement");
      break;
   case eTOKEN_logical_and_expression:
   case eTOKEN_logical_or_expression:
      {
         cAstNode *expression;
         cInstruction *instruction;
         if((_node->getID()==eTOKEN_logical_or_expression && !reverseLogic) ||
            (_node->getID()==eTOKEN_logical_and_expression && reverseLogic))
         {
            expression=_node->getChildList();
            while(expression)
            {
               genStatement(instructions,_root,func,expression,0,!reverseLogic?false:true,hasExitCode,
                  exitInstruction,brInstruction,brAfter,blockExitInstruction,blockContInstruction,true);
               expression=(cAstNode *)expression->getNext();
            }
         }
         else
         {
            instruction=new cInstruction(_node);
            expression=_node->getChildList();
            while(expression)
            {
               if(expression->getNext())
                  genStatement(instructions,_root,func,expression,0,!reverseLogic?true:false,hasExitCode,
                  exitInstruction,instruction,true,blockExitInstruction,blockContInstruction,true);
               else
                  genStatement(instructions,_root,func,expression,0,!reverseLogic?false:true,hasExitCode,
                  exitInstruction,brInstruction,brAfter,blockExitInstruction,blockContInstruction,true);
               expression=(cAstNode *)expression->getNext();
            }
            instructions->append(instruction);
         }
      }
      break;
   case eTOKEN_equality_expression_eq:
   case eTOKEN_equality_expression_ne:
   case eTOKEN_relational_expression_le:
   case eTOKEN_relational_expression_lt:
   case eTOKEN_relational_expression_ge:
   case eTOKEN_relational_expression_gt:
      {
         cTerm *x1,*x2,*y;
         int control_oc,oc;
         left=(cAstNode *)_node->getChildList();
         right=(cAstNode *)left->getNext();
         if(expressionIsMU(left) || expressionIsMU(right))
         {
            if(reverseLogic)
            {
               switch(_node->getID())
               {
               case eTOKEN_equality_expression_eq:
                  oc=cConfig::OPCODE_CMP_NE;
                  break;
               case eTOKEN_equality_expression_ne:
                  oc=cConfig::OPCODE_CMP_EQ;
                  break;
               case eTOKEN_relational_expression_le:
                  oc=cConfig::OPCODE_CMP_GT;
                  break;
               case eTOKEN_relational_expression_lt:
                  oc=cConfig::OPCODE_CMP_GE;
                  break;
               case eTOKEN_relational_expression_ge:
                  oc=cConfig::OPCODE_CMP_LT;
                  break;
               case eTOKEN_relational_expression_gt:
                  oc=cConfig::OPCODE_CMP_LE;
                  break;
               default:
                  assert(0);
               }
            }
            else
            {
               switch(_node->getID())
               {
               case eTOKEN_equality_expression_eq:
                  oc=cConfig::OPCODE_CMP_EQ;
                  break;
               case eTOKEN_equality_expression_ne:
                  oc=cConfig::OPCODE_CMP_NE;
                  break;
               case eTOKEN_relational_expression_le:
                  oc=cConfig::OPCODE_CMP_LE;
                  break;
               case eTOKEN_relational_expression_lt:
                  oc=cConfig::OPCODE_CMP_LT;
                  break;
               case eTOKEN_relational_expression_ge:
                  oc=cConfig::OPCODE_CMP_GE;
                  break;
               case eTOKEN_relational_expression_gt:
                  oc=cConfig::OPCODE_CMP_GT;
                  break;
               default:
                  assert(0);
               }
            }
            x1=genTerm(instructions,_root,func,left,false,false,true);
            x2=genTerm(instructions,_root,func,right,false,false,true);

            y=new cTerm_MU_Result();
            instruction= new cInstruction(_node);
            instruction->createMU(oc,CAST(cTerm_MU,x1),CAST(cTerm_MU,x2),CAST(cTerm_MU,y));
            instructions->append(instruction);
            instruction= new cInstruction(_node);
            instruction->createConditionalJump(cConfig::OPCODE_JUMP_NE,
               cConfig::IOPCODE_SUB,
               CAST(cTerm_IMU,cTerm::Convert2IMU(y)),
               new cTerm_IMU_Constant(0),
               0,
               brInstruction,
               brAfter);
         }
         else
         {
            if(reverseLogic)
            {
               switch(_node->getID())
               {
               case eTOKEN_equality_expression_eq:
                  control_oc=cConfig::OPCODE_JUMP_NE;
                  break;
               case eTOKEN_equality_expression_ne:
                  control_oc=cConfig::OPCODE_JUMP_EQ;
                  break;
               case eTOKEN_relational_expression_le:
                  control_oc=cConfig::OPCODE_JUMP_GT;
                  break;
               case eTOKEN_relational_expression_lt:
                  control_oc=cConfig::OPCODE_JUMP_GE;
                  break;
               case eTOKEN_relational_expression_ge:
                  control_oc=cConfig::OPCODE_JUMP_LT;
                  break;
               case eTOKEN_relational_expression_gt:
                  control_oc=cConfig::OPCODE_JUMP_LE;
                  break;
               default:
                  assert(0);
               }
            }
            else
            {
               switch(_node->getID())
               {
               case eTOKEN_equality_expression_eq:
                  control_oc=cConfig::OPCODE_JUMP_EQ;
                  break;
               case eTOKEN_equality_expression_ne:
                  control_oc=cConfig::OPCODE_JUMP_NE;
                  break;
               case eTOKEN_relational_expression_le:
                  control_oc=cConfig::OPCODE_JUMP_LE;
                  break;
               case eTOKEN_relational_expression_lt:
                  control_oc=cConfig::OPCODE_JUMP_LT;
                  break;
               case eTOKEN_relational_expression_ge:
                  control_oc=cConfig::OPCODE_JUMP_GE;
                  break;
               case eTOKEN_relational_expression_gt:
                  control_oc=cConfig::OPCODE_JUMP_GT;
                  break;
               default:
                  assert(0);
               }
            }
            oc=cConfig::IOPCODE_SUB;
            x1=genTerm(instructions,_root,func,left,false,false,false);
            x2=genTerm(instructions,_root,func,right,false,false,false);
            instruction= new cInstruction(_node);
            instruction->createConditionalJump(control_oc,oc,CAST(cTerm_IMU,x1),CAST(cTerm_IMU,x2),0,brInstruction,brAfter);
         }
      }
      break;
   default:
      if(logicStatement)
         isMU=expressionIsMU(_node);
      else
         isMU=false;
      if(logicStatement)
      {
         cAstNode *node2;
         node2=_node->getChild(1,eTOKEN_unary_operator);
         if(node2 && strcmp(CAST(cAstStringNode,node2)->getStringValue(),"!") == 0)
         {
            _node=(cAstNode *)node2->getNext();
            reverseLogic=!reverseLogic;
         }
      }
      term=genTerm(instructions,_root,func,_node,false,false,isMU);
      if(logicStatement)
      {
         if(term->isKindOf(cTerm_IMU::getCLID()))
         {
            if(term->isKindOf(cTerm_IMU_Integer::getCLID()) && CAST(cTerm_IMU_Integer,term)->m_id->isTemp())
            {
               // This is a temoporary result. So just combine it with conditional statement
               cInstruction *lastInstruction;
               lastInstruction=(cInstruction *)instructions->getLast();
               assert(lastInstruction->m_imu.y==term);
               assert(lastInstruction->m_imu.oc > 0);
               assert(lastInstruction->m_control.oc <= 0);
               instruction->m_imu.y=new cTerm_IMU_Null();
               instruction->updateConditionalJump(reverseLogic?cConfig::OPCODE_JUMP_EQ:cConfig::OPCODE_JUMP_NE,
                                                   brInstruction,brAfter);
            }
            else
            {
               instruction= new cInstruction(_node);
               instruction->createConditionalJump(reverseLogic?cConfig::OPCODE_JUMP_EQ:cConfig::OPCODE_JUMP_NE,
                  cConfig::IOPCODE_SUB,
                  CAST(cTerm_IMU,term),
                  new cTerm_IMU_Zero(),
                  0,
                  brInstruction,
                  brAfter);
            }
         }
         else
         {
            instruction= new cInstruction(_node);
            instruction->createMU(reverseLogic?cConfig::OPCODE_CMP_EQ:cConfig::OPCODE_CMP_NE,
                                 CAST(cTerm_MU,term),
                                 new cTerm_MU_Constant((float)0.0),
                                 new cTerm_MU_Result());
            instructions->append(instruction);
            instruction= new cInstruction(_node);
            instruction->createConditionalJump(cConfig::OPCODE_JUMP_NE,
               cConfig::IOPCODE_SUB,
               new cTerm_IMU_Result(),
               new cTerm_IMU_Constant(0),
               0,
               brInstruction,
               brAfter);
         }
      }
      break;
   }
   if(instruction)
      instructions->append(instruction);
   return instructions->getLast();
}

// Generate code for function entry code

bool cGEN::process_func_entry(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,cInstruction **_begin,cInstruction **_end,
                              bool *gotEntryCode,bool *gotExitCode)
{
   cIdentifier *attr;
   cInstruction *instruction;
   bool isKernel;

   if(func->getChildList()->getID()==eTOKEN_declaration_specifiers &&
      func->getChildList()->getChildList()->getID()==eTOKEN_KERNEL)
      isKernel=true;
   else
      isKernel=false;

   *gotEntryCode=false;
   *gotExitCode=false;
   assert(node->getID()==eTOKEN_block_item_list);
   attr=CAST(cAstCodeBlockNode,node)->getIdentifierList();
   while(attr)
   {
      if(attr->isParameter() && attr->getAlias())
      {
         assert(attr->isKindOf(cIdentifierStorage::getCLID()));
         *gotEntryCode=true;
         *gotExitCode=isKernel;
         instruction= new cInstruction(node);
         instruction->createMU(
                              cConfig::OPCODE_ASSIGN_RAW,
                              new cTerm_MU_Storage(CAST(cIdentifierStorage,attr),0),
                              new cTerm_MU_Null(),
                              new cTerm_MU_Result());
         instructions->append(instruction);
         if(_begin && *_begin==0)
            *_begin=instruction;
         if(_end)
            *_end=instruction;

         instruction= new cInstruction(node);
         if( attr->getAlias()->isKindOf(cIdentifierInteger::getCLID()))
         {
            instruction->createIMU(cConfig::IOPCODE_ADD,
                                   new cTerm_IMU_Result(),
                                   new cTerm_IMU_Zero(),
                                   new cTerm_IMU_Integer(CAST(cIdentifierInteger,attr->getAlias())));
         }
         else
         {
            instruction->createIMU(cConfig::IOPCODE_ADD,
                                   new cTerm_IMU_Result(),
                                   new cTerm_IMU_Zero(),
                                   new cTerm_IMU_Pointer(CAST(cIdentifierPointer,attr->getAlias())));
         }
         instructions->append(instruction);


         if(_begin && *_begin==0)
            *_begin=instruction;
         if(_end)
            *_end=instruction;
      }
      attr=(cIdentifier *)attr->getNext();
   }
   return true;
}

// Generate code for function exit code

cInstruction *cGEN::process_func_exit(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,
                        cInstruction *exitInstruction,bool hasExitCode)
{
   cInstruction *instruction;

   instruction=exitInstruction;
#if 0
   if(func->getChildList()->getID()==eTOKEN_declaration_specifiers &&
      func->getChildList()->getChildList()->getID()==eTOKEN_KERNEL)
   {
   attr=CAST(cAstCodeBlockNode,node)->getIdentifierList();
   while(attr)
   {
      if(attr->isParameter() && attr->getAlias())
      {
         if(!instruction)
            instruction=new cInstruction(node);
         if(attr->getAlias()->isKindOf(cIdentifierInteger::getCLID()))
         {
            instruction->createMU(cConfig::OPCODE_ASSIGN_RAW,
                                  new cTerm_MU_Integer(CAST(cIdentifierInteger,attr->getAlias())),
                                  new cTerm_MU_Null(),
                                  new cTerm_MU_Storage(CAST(cIdentifierPrivate,attr),0)
                                  );
         }
         instructions->append(instruction);
         instruction=0;
      }
      attr=(cIdentifier *)attr->getNext();
   }
   }
#endif
      // No exit code to generate. Just return
   if(!instruction)
      instruction=new cInstruction(node);
   instruction->createUnconditionalJump(cConfig::OPCODE_RETURN,0,false);
   instructions->append(instruction);
   return instructions->getLast();
}

// Generate code for variable auto-initialization
void cGEN::process_init(cInstructions *instructions,cAstNode *node)
{
   cInstruction *instruction;
   cIdentifier *attr;
   int i;
   bool subVector;

   if(!node->isKindOf(cAstCodeBlockNode::getCLID()))
      return;
   attr=CAST(cAstCodeBlockNode,node)->getIdentifierList();
   while(attr)
   {
      if(attr->isKindOf(cIdentifierStorage::getCLID()) && 
         CAST(cIdentifierStorage,attr)->m_w >= 1)
         subVector=true;
      else
         subVector=false;
      if(attr->m_init.size() > 0 && (attr->isKindOf(cIdentifierInteger::getCLID()) || attr->isKindOf(cIdentifierPrivate::getCLID())))
      {
         for(i=0;i < (int)attr->m_init.size();i++)
         {
            instruction= new cInstruction(node);
            if(attr->isKindOf(cIdentifierPrivate::getCLID()))
            {
               instruction->createMU(
                                 cConfig::OPCODE_ASSIGN,
                                 new cTerm_MU_Constant((float)attr->m_init[i]),
                                 new cTerm_MU_Null(),
                                 new cTerm_MU_Storage(CAST(cIdentifierPrivate,attr),i,subVector));
            }
            else
            {
               instruction->createIMU(
                                 cConfig::IOPCODE_ADD,
                                 new cTerm_IMU_Constant((int)attr->m_init[i]),
                                 new cTerm_IMU_Zero(),
                                 new cTerm_IMU_Integer(CAST(cIdentifierInteger,attr)));
            }
            instructions->append(instruction);
         }
      }
      attr=(cIdentifier *)attr->getNext();
   }
}

// Generate code selection statement (if then else...)

cInstruction *cGEN::genSelectionStatement(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,
                        bool hasExitCode,cInstruction *exitInstruction,cInstruction *blockExitInstruction,cInstruction *blockContInstruction)
{
   cAstNode *node5;
   cAstNode *sel_cond,*sel_true,*sel_false;
   cInstruction *end,*end2;
   cInstructions code;
   cInstruction *start=instructions->getLast();
   sel_cond=node;
   sel_true=(cAstNode *)sel_cond->getNext();
   sel_false=(cAstNode *)sel_true->getNext();

   end=process_code_block(instructions,_root,func,sel_true,hasExitCode,exitInstruction,blockExitInstruction,blockContInstruction);
   if(end==start && !sel_false)
      return (cInstruction *)instructions->getLast(); // This is an empty if statement
   if(sel_false)
   {
      if(!sel_false->getNext())
         end2=process_code_block(instructions,_root,func,sel_false,hasExitCode,exitInstruction,blockExitInstruction,blockContInstruction);
      else
         end2=genSelectionStatement(instructions,_root,func,sel_false,hasExitCode,exitInstruction,blockExitInstruction,blockContInstruction);
      cInstruction *instruction2;
      instruction2=new cInstruction(node);
      instruction2->createUnconditionalJump(cConfig::OPCODE_JUMP,end2,true);
      instructions->insert(instruction2,end);
      end=instruction2;
   }
   node5=(cAstNode *)sel_cond->getChildList();
   genStatement(&code,_root,func,node5,0,true,hasExitCode,exitInstruction,end,true,blockExitInstruction,blockContInstruction,true);
   instructions->insert(&code,start);
   return (cInstruction *)instructions->getLast();
}

bool cGEN::identifierIsMod(cAstNode *node,cIdentifier *id)
{
   cAstNode *node2;
   if(node->getID()==eTOKEN_assignment_expression ||
      node->getID()==eTOKEN_postfix_expression7 ||
      node->getID()==eTOKEN_postfix_expression8)
   {
      node2=node->getChildList();
      if(node2->getID()==eTOKEN_IDENTIFIER && 
         CAST(cAstIdentifierNode,node2)->getIdentifier()==id)
         return true;
   }
   else if(node->getID()==eTOKEN_unary_expression)
   {
      node2=(cAstNode *)node->getChildList()->getNext();
      if(node2->getID()==eTOKEN_IDENTIFIER && 
         CAST(cAstIdentifierNode,node2)->getIdentifier()==id)
         return true;
   }
   if(node->isKindOf(cAstCompositeNode::getCLID()))
   {
      node2=CAST(cAstCompositeNode,node)->getChildList();
      while(node2)
      {
         if(identifierIsMod(node2,id))
            return true;
         node2=(cAstNode *)node2->getNext();
      }
   }
   return false;
}


bool cGEN::loopUnroll(cAstNode *statement1,cAstNode *statement2,cAstNode *statement3,cAstNode *statement4,
                     int *_from,int *_to,int *_step,cIdentifierInteger **_id)
{
   cAstNode *node,*node2,*node3;
   cIdentifier *id1,*id2,*id3;
   int cmp,eq;
   int from,to;
   int step=1;

   if(!statement1 || !statement2 || !statement3)
   {
      if(statement1)
         warning(statement1->m_lineNo,"Cannot unroll for loop");
      else if(statement2)
         warning(statement2->m_lineNo,"Cannot unroll for loop");
      else if(statement3)
         warning(statement3->m_lineNo,"Cannot unroll for loop");
      else
         warning(-1,"Cannot unroll for loop");
      return false;
   }
   // i=0
   node=statement1->getChild(1,eTOKEN_assignment_expression);
   if(!node)
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   node=node->getChildList();
   if(node->getID() != eTOKEN_IDENTIFIER)
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   id1=CAST(cAstIdentifierNode,node)->getIdentifier();
   node=(cAstNode *)node->getNext();
   if(node->getID() != eTOKEN_assignment_operator)
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   node=(cAstNode *)node->getNext();
   if(node->getID() != eTOKEN_I_CONSTANT)
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   from=CAST(cAstIntNode,node)->getIntValue();

   // i < 4
   node=statement2->getChildList();
   node2=(cAstNode *)node->getChildList();
   if(node2->getID() != eTOKEN_IDENTIFIER)
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   id2=CAST(cAstIdentifierNode,node2)->getIdentifier();

   node2=(cAstNode *)node2->getNext();
   if(node2->getID() != eTOKEN_I_CONSTANT)
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   to=CAST(cAstIntNode,node2)->getIntValue();
   switch(node->getID())
   {
      case eTOKEN_relational_expression_lt:
         cmp=-1;
         eq=0;
         break;
      case eTOKEN_relational_expression_le:
         cmp=-1;
         eq=1;
         break;
      case eTOKEN_relational_expression_gt:
         cmp=+1;
         eq=0;
         break;
      case eTOKEN_relational_expression_ge:
         cmp=+1;
         eq=1;
         break;
      default:
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
   }

   if(statement3->getChild(2,eTOKEN_postfix_expression7,eTOKEN_INC_OP))
   {
      node2=statement3->getChild(2,eTOKEN_postfix_expression7,eTOKEN_IDENTIFIER);
      if(!node2)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
      step=1;
   }
   else if(statement3->getChild(2,eTOKEN_postfix_expression8,eTOKEN_DEC_OP))
   {
      node2=statement3->getChild(2,eTOKEN_postfix_expression8,eTOKEN_IDENTIFIER);
      if(!node2)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
      step=-1;
   }
   else if(statement3->getChild(2,eTOKEN_assignment_expression,eTOKEN_ADD_ASSIGN))
   {
      node2=statement3->getChild(2,eTOKEN_assignment_expression,eTOKEN_IDENTIFIER);
      if(!node2)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
      node3=statement3->getChild(2,eTOKEN_assignment_expression,eTOKEN_I_CONSTANT);
      step=CAST(cAstIntNode,node3)->getIntValue();
   }
   else if(statement3->getChild(2,eTOKEN_assignment_expression,eTOKEN_SUB_ASSIGN))
   {
      node2=statement3->getChild(2,eTOKEN_assignment_expression,eTOKEN_IDENTIFIER);
      if(node2->getID() != eTOKEN_IDENTIFIER)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
      node3=statement3->getChild(2,eTOKEN_assignment_expression,eTOKEN_I_CONSTANT);
      step=-CAST(cAstIntNode,node3)->getIntValue();
   }
   else
   {
      error(statement1->m_lineNo,"Invalid statement");
   }
   id3=CAST(cAstIdentifierNode,node2)->getIdentifier();

   if(id1 != id2 || id1 != id3)
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   if(!id1->isKindOf(cIdentifierInteger::getCLID()))
   {
      warning(statement1->m_lineNo,"Cannot unroll for loop");
      return false;
   }
   *_id=CAST(cIdentifierInteger,id1);
   *_from=from;
   *_step=step;
   *_to=from+((to-from)/step)*step;
   if(eq==0)
   {
      if(*_to==to)
         *_to -= step;
   }
   if(cmp > 0)
   {
      if(*_step >= 0)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
      if(*_to > *_from)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
   }
   if(cmp < 0)
   {
      if(*_step < 0)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
      if(*_to < *_from)
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
   }
   if(statement4)
   {
      if(identifierIsMod(statement4,*_id))
      {
         warning(statement1->m_lineNo,"Cannot unroll for loop");
         return false;
      }
   }
   return true;
}


void cGEN::substituteGenIdentifier(cAstCompositeNode *parent,cAstNode *node,cIdentifierInteger *for_id,int for_index)
{
   cAstIntNode *node2;
   cAstNode *next;
#if 0
   {
   int lvlFlag[32];
   // Print AST tree...
   if(!parent)
      cAstNode::Print(node,0,lvlFlag);
   }
#endif
   if(parent)
   {
      if(node->isKindOf(cAstIdentifierNode::getCLID()))
      {
         if(CAST(cAstIdentifierNode,node)->getIdentifier()==for_id)
         {
            node2=new cAstIntNode(eTOKEN_I_CONSTANT,for_index);
            node2->m_genIdentifier=for_id;
            parent->setChildList(node2,node);
            cList::remove(node);
         }
      }
      else if(node->isKindOf(cAstIntNode::getCLID()))
      {
         node2=CAST(cAstIntNode,node);
         if(node2->m_genIdentifier==for_id)
            node2->m_i=for_index;
      }
   }
   if(node->isKindOf(cAstCompositeNode::getCLID()))
   {
      parent=CAST(cAstCompositeNode,node);
      node=(cAstNode *)node->getChildList();
      while(node)
      {
         next=(cAstNode *)node->getNext();
         substituteGenIdentifier(parent,node,for_id,for_index);
         node=next;
      }
   }
}

// Generate code for block of code {....}
// Block of code is then composed of statements

cInstruction *cGEN::process_code_block(cInstructions *instructions,cAstNode *_root,cAstNode *func,cAstNode *node,
                        bool hasExitCode,cInstruction *exitInstruction,cInstruction *blockExitInstruction,cInstruction *blockContInstruction)
{
   cInstruction *instruction1_end;
   cInstruction *instruction2_end;
   cAstNode *node4,*node5;
   cAstNode *sel_cond;
   cAstNode *forNode,*statement1,*statement2,*statement3,*statement4;
   int fromIndex,toIndex,stepIndex;

   process_init(instructions,node);

   assert(node!=0);
   if(node->getID()==eTOKEN_block_item_list)
   {
      cAstNode *node3;
      node3=(cAstNode *)node->getChildList();
      while(node3)
      {
         assert(node3->getID()==eTOKEN_block_item);
         process_code_block(instructions,_root,func,(cAstNode *)node3->getChildList(),hasExitCode,exitInstruction,
                           blockExitInstruction,blockContInstruction);
         node3=(cAstNode *)node3->getNext();
      }
      return instructions->getLast();
   }
   if(node->getID()==eTOKEN_labeled_statement)
   {
      node4=(cAstNode *)node->getChildList()->getNext();
   }
   else
   {
      node4=node;
   }
   switch(node4->getID())
   {
   case eTOKEN_iteration_while_statement:
      // while(..) {...}
      {
      cInstruction *while_exit_instruction;
      cInstruction *while_cont_instruction;
      while_exit_instruction=new cInstruction(node);
      while_cont_instruction=new cInstruction(node);
      statement1=(cAstNode *)node4->getChildList();
      if(statement1)
         statement2=(cAstNode *)statement1->getNext();
      else
         statement2=0;
      if(!statement1 || !statement2)
         error(node4->m_lineNo,"Unsupported C syntax");
      instruction1_end=new cInstruction(node);
      instructions->append(instruction1_end);
      if(statement2)
         process_code_block(instructions,_root,func,statement2,hasExitCode,exitInstruction,
                           while_exit_instruction,while_cont_instruction);
      if(instructions->getLast() != instruction1_end)
         instruction1_end->createUnconditionalJump(cConfig::OPCODE_JUMP,instructions->getLast(),true);
      instructions->append(while_cont_instruction);
      instruction2_end=genStatement(instructions,_root,func,statement1,0,false,hasExitCode,
                                       exitInstruction,instruction1_end,true,
                                       while_exit_instruction,while_cont_instruction,true);
      instructions->append(while_exit_instruction);
      }
      break;
   case eTOKEN_iteration_do_while_statement:
      // do {...} while(...);
      {
      cInstruction *while_exit_instruction;
      cInstruction *while_cont_instruction;
      while_exit_instruction=new cInstruction(node);
      while_cont_instruction=new cInstruction(node);
      statement2=(cAstNode *)node4->getChildList();
      if(statement2)
         statement1=(cAstNode *)statement2->getNext();
      else
         statement1=0;
      if(!statement1 || !statement2)
         error(node4->m_lineNo,"Unsupported C syntax");
      instruction1_end=instructions->getLast();
      if(!instruction1_end)
      {
         instruction1_end=new cInstruction(node);
         instructions->append(instruction1_end);
      }
      if(statement2)
         process_code_block(instructions,_root,func,statement2,hasExitCode,exitInstruction,
                           while_exit_instruction,while_cont_instruction);
      instructions->append(while_cont_instruction);
      instruction2_end=genStatement(instructions,_root,func,statement1,0,false,hasExitCode,
                                       exitInstruction,instruction1_end,true,
//                                       blockExitInstruction,blockContInstruction,true);
                                       while_exit_instruction,while_cont_instruction,true);
      instructions->append(while_exit_instruction);
      }
      break;
   case eTOKEN_iteration_for_statement:
      // for(...) {...}
      {
      cInstruction *for_exit_instruction;
      cInstruction *for_cont_instruction;
      cIdentifierInteger *for_id;
      forNode=(cAstNode *)node4->getChildList();
      if(forNode)
         statement1=(cAstNode *)forNode->getNext();
      else
         statement1=0;
      if(statement1)
         statement2=(cAstNode *)statement1->getNext();
      else
         statement2=0;
      if(statement2)
         statement3=(cAstNode *)statement2->getNext();
      else
         statement3=0;
      if(statement3)
         statement4=(cAstNode *)statement3->getNext();
      else
         statement4=0;
      if(!statement4)
      {
         statement4=statement3;
         statement3=0;
      }
      if(strcasecmp(forNode->m_pragma.c_str(),"unroll")==0 && 
         loopUnroll(statement1,statement2,statement3,statement4,&fromIndex,&toIndex,&stepIndex,&for_id))
      {
         int index;
         for_exit_instruction=new cInstruction(node);
         index=fromIndex;
         for(;;)
         {
            for_cont_instruction=new cInstruction(node);
            if(statement4)
            {
               substituteGenIdentifier(0,statement4,for_id,index);
               process_code_block(instructions,_root,func,statement4,hasExitCode,exitInstruction,for_exit_instruction,for_cont_instruction);
            }
            instructions->append(for_cont_instruction);
            if(index==toIndex)
               break;
            index += stepIndex;
         }
         instructions->append(for_exit_instruction);
      }
      else
      {
         for_exit_instruction=new cInstruction(node);
         for_cont_instruction=new cInstruction(node);
         if(!statement1 || !statement1->getChildList())
            instruction1_end=instructions->getLast();
         else
            instruction1_end=genStatement(instructions,_root,func,statement1,0,true,hasExitCode,exitInstruction,0,false,
            for_exit_instruction,for_cont_instruction);
         instruction2_end=new cInstruction(node);
         instructions->append(instruction2_end);
         if(statement4)
            process_code_block(instructions,_root,func,statement4,hasExitCode,exitInstruction,for_exit_instruction,for_cont_instruction);
         instructions->append(for_cont_instruction);
         if(statement3)
            genStatement(instructions,_root,func,statement3,0,true,hasExitCode,exitInstruction,0,false,
                         for_exit_instruction,for_cont_instruction);
         instruction2_end->createUnconditionalJump(cConfig::OPCODE_JUMP,instructions->getLast(),true);
         if(!statement2 || !statement2->getChildList())
         {
            // ????
            cInstruction *instruction;
            instruction=new cInstruction(node);
            instruction->createUnconditionalJump(cConfig::OPCODE_JUMP,instruction2_end,true);
            instructions->append(instruction);
         }
         else
            genStatement(instructions,_root,func,statement2,0,false,hasExitCode,exitInstruction,instruction2_end,true,
                        for_exit_instruction,for_cont_instruction,true);
         instructions->append(for_exit_instruction);
      }
      } 
      break;
   case eTOKEN_declaration:
      break;
   case eTOKEN_expression:
   case eTOKEN_expression_statement:
   case eTOKEN_compound_statement:
      // Mutiple command execution
      node5=(cAstNode *)node4->getChildList();
      while(node5)
      {
         genStatement(instructions,_root,func,node5,0,true,hasExitCode,exitInstruction,0,false,
                      blockExitInstruction,blockContInstruction);
         node5=(cAstNode *)node5->getNext();
      }
      break;
   case eTOKEN_switch_statement:
      // switch(...) {case...}
      {
      genSwitchStatement(instructions,_root,func,node4,hasExitCode,exitInstruction,
                                          blockExitInstruction,blockContInstruction);
      }
      break;
   case eTOKEN_selection_statement:
      {
      // if(...) {...} else if(...) else {...}
      cInstructions code;
      sel_cond=node->getChild(1,eTOKEN_expression);
      genSelectionStatement(instructions,_root,func,sel_cond,hasExitCode,exitInstruction,blockExitInstruction,blockContInstruction);
      }
      break;
   case eTOKEN_jump_statement:
      // goto 
      genStatement(instructions,_root,func,node4,0,true,hasExitCode,exitInstruction,0,false,blockExitInstruction,blockContInstruction);
      break;
   default:
      error(node4->m_lineNo,"Unsupported C-statement");
      break;
   }
   return instructions->getLast();
}

// Begin of generate codes

int cGEN::gen(cAstNode *_root)
{
   cAstNode *node,*node2,*node3;
   cInstruction *begin;
   cInstruction *exitInstruction;
   bool hasEntryCode;
   bool hasExitCode;
   char *name,*name2;
   bool isKernel;

   node=(cAstNode *)_root->getChildList();
   while(node)
   {
      if(node->getID()==eTOKEN_function_definition2)
      {
         node3=node->getChildList();
         assert(node3!=0);
         if(node3->getID()==eTOKEN_declaration_specifiers)
         {
            if(node3->getChildList()->getID()==eTOKEN_KERNEL)
               isKernel=true;
            else
               isKernel=false;
            node3=(cAstNode *)node3->getChildList()->getNext();
         }
         else
            isKernel=false;
         if(!isKernel)
         {
            if(!(node3->getID() == eTOKEN_VOID || node3->getID()==eTOKEN_FLOAT || node3->getID()==eTOKEN_INT))
               error(node3->m_lineNo,"Functions must return void or float");
         }
         else
         {
            if(!(node3->getID() == eTOKEN_VOID))
               error(node3->m_lineNo,"Kernel function must return void");
         }
         node3=node->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_IDENTIFIER);
         if(!node3)
            node3=node->getChild(2,eTOKEN_declarator,eTOKEN_IDENTIFIER);
         assert(node3!=0);
         name=CAST(cAstStringNode,node3)->getStringValue();
         if(!IsValidScopedName(name))
            error(node3->m_lineNo,"Invalid function name");
         if(!cClass::Find(name))
            error(node3->m_lineNo,"Undeclared class for this function");
         node2=(cAstNode *)_root->getChildList();
         while(node2)
         {
            if(node2->getID()==eTOKEN_function_definition2)
            {
               node3=node2->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_IDENTIFIER);
               if(!node3)
                  node3=node2->getChild(2,eTOKEN_declarator,eTOKEN_IDENTIFIER);
               assert(node3!=0);
               name2=CAST(cAstStringNode,node3)->getStringValue();
               if(node2!=node)
               {
                  if(strcmp(name,name2)==0)
                     error(node3->m_lineNo,"Duplicate function name");
               }
            }
            node2=(cAstNode *)node2->getNext();
         }
      }
      node=(cAstNode *)node->getNext();
   }

   // Generate code

   node=(cAstNode *)_root->getChildList();
   while(node)
   {
      if(node->getID()==eTOKEN_function_definition2)
      {
         // This is a function...
         node2=node->getChild(1,eTOKEN_block_item_list);
         assert(node2!=0);
         begin=(cInstruction *)PROGRAM.getLast();
         PROGRAM.append(new cInstruction(node2)); // Start with a NOP
         process_func_entry(&PROGRAM,_root,node,node2,0,0,&hasEntryCode,&hasExitCode);
         exitInstruction=new cInstruction(node);
         process_code_block(&PROGRAM,_root,node,node2,hasExitCode,exitInstruction,0,0);
         process_func_exit(&PROGRAM,_root,node,node2,exitInstruction,hasExitCode);
         if(begin)
            begin=(cInstruction *)begin->getNext();
         else
            begin=(cInstruction *)PROGRAM.getFirst();
         begin->setBeginFunc(node);
         node3=node->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_IDENTIFIER);
         if(!node3)
            node3=node->getChild(2,eTOKEN_declarator,eTOKEN_IDENTIFIER);
         assert(node3!=0);
         begin->setLabel(CAST(cAstStringNode,node3)->getStringValue());
      } 
      node=(cAstNode *)node->getNext();
   }
   return 0;
}
