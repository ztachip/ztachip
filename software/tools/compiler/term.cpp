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

// These are classes described the parameters of all instruction opcodes
#include <assert.h>
#include <vector>
#include "zta.h"
#include "util.h"
#include "instruction.h"
#include "term.h"
#include "ident.h"
#include "const.h"

// Base class for all TERM objects
INSTANTIATE_OBJECT(cTerm);
cTerm::cTerm()
{
}

// Return the list of identifiers used by this TERM
void cTerm::getUse(cIdentifierVector *lst)
{
}

// Return the list of identifiers referenced by this TERM
void cTerm::getDef(cIdentifierVector *lst)
{
}



// Check if both TERM reference the same thing
bool cTerm::operator==(cTerm &other)
{
   if(other.isKindOf(cTerm_MU::getCLID()))
   {
      if(!isKindOf(cTerm_MU::getCLID()))
      {
         if(isKindOf(cTerm_IMU_Result::getCLID()) && other.isKindOf(cTerm_MU_Result::getCLID()))
            return true;
         else if(isKindOf(cTerm_IMU_Constant::getCLID()) && other.isKindOf(cTerm_MU_Constant::getCLID()) &&
            CAST(cTerm_IMU_Constant,this)->getConstant()==(int)CAST(cTerm_MU_Constant,&other)->getConstant() &&
            !CAST(cTerm_MU_Constant,&other)->m_float)
            return true;
         else
            return false;
      }
      if(other.isKindOf(cTerm_MU_Null::getCLID()))
      {
         return isKindOf(cTerm_MU_Null::getCLID()) || isKindOf(cTerm_IMU_Null::getCLID());
      }
      else if(other.isKindOf(cTerm_MU_Constant::getCLID()))
      {
         if(isKindOf(cTerm_MU_Constant::getCLID()) &&
            (CAST(cTerm_MU_Constant,&other)->m_c==CAST(cTerm_MU_Constant,this)->m_c))
            return true;
         else if(isKindOf(cTerm_IMU_Constant::getCLID()) &&
            (CAST(cTerm_MU_Constant,&other)->m_c==(float)CAST(cTerm_IMU_Constant,this)->m_c))
            return true;
         else
            return false;
      }
      else if(other.isKindOf(cTerm_MU_TID::getCLID()))
      {
         return isKindOf(cTerm_MU_TID::getCLID()) || isKindOf(cTerm_IMU_TID::getCLID());
      }
      else if(other.isKindOf(cTerm_MU_PointerWithoutIndex::getCLID()))
      {
         if(isKindOf(cTerm_MU_PointerWithoutIndex::getCLID()) &&
            (CAST(cTerm_MU_PointerWithoutIndex,&other)->m_baseId==CAST(cTerm_MU_PointerWithoutIndex,this)->m_baseId) &&
            (CAST(cTerm_MU_PointerWithoutIndex,&other)->m_offset==CAST(cTerm_MU_PointerWithoutIndex,this)->m_offset) 
            )
            return true;
         else
            return false;
      }
      else if(other.isKindOf(cTerm_MU_PointerWithIndex::getCLID()))
      {
         if(isKindOf(cTerm_MU_PointerWithIndex::getCLID()) &&
            (CAST(cTerm_MU_PointerWithIndex,&other)->m_baseId==CAST(cTerm_MU_PointerWithIndex,this)->m_baseId) &&
            (CAST(cTerm_MU_PointerWithIndex,&other)->m_indexId==CAST(cTerm_MU_PointerWithIndex,this)->m_indexId) &&
            (CAST(cTerm_MU_PointerWithIndex,&other)->m_offset==CAST(cTerm_MU_PointerWithIndex,this)->m_offset)
            )
            return true;
         else
            return false;
      }
      else if(other.isKindOf(cTerm_MU_Storage::getCLID()))
      {
         if(isKindOf(cTerm_MU_Storage::getCLID()) &&
            (CAST(cTerm_MU_Storage,&other)->m_id==CAST(cTerm_MU_Storage,this)->m_id) &&
            (CAST(cTerm_MU_Storage,&other)->m_offset==CAST(cTerm_MU_Storage,this)->m_offset) &&
            (CAST(cTerm_MU_Storage,&other)->m_subVector==CAST(cTerm_MU_Storage,this)->m_subVector)
            )
            return true;
         else
            return false;
      }
      else if(other.isKindOf(cTerm_MU_StorageWithIndex::getCLID()))
      {
         if(isKindOf(cTerm_MU_StorageWithIndex::getCLID()) &&
            (CAST(cTerm_MU_StorageWithIndex,&other)->m_id==CAST(cTerm_MU_StorageWithIndex,this)->m_id) &&
            (CAST(cTerm_MU_StorageWithIndex,&other)->m_offset==CAST(cTerm_MU_StorageWithIndex,this)->m_offset) &&
            (CAST(cTerm_MU_StorageWithIndex,&other)->m_indexId==CAST(cTerm_MU_StorageWithIndex,this)->m_indexId) &&
            (CAST(cTerm_MU_StorageWithIndex,&other)->m_subVector==CAST(cTerm_MU_StorageWithIndex,this)->m_subVector)
            )
            return true;
         else
            return false;
      }
      else if(other.isKindOf(cTerm_MU_Result::getCLID()))
      {
         return isKindOf(cTerm_MU_Result::getCLID()) || isKindOf(cTerm_IMU_Result::getCLID());
      }
      else if(other.isKindOf(cTerm_MU_Integer::getCLID()))
      {
         if(isKindOf(cTerm_MU_Integer::getCLID()) &&
            (CAST(cTerm_MU_Integer,&other)->m_id==CAST(cTerm_MU_Integer,this)->m_id))
            return true;
         else if(isKindOf(cTerm_IMU_Integer::getCLID()) &&
            (CAST(cTerm_MU_Integer,&other)->m_id==CAST(cTerm_IMU_Integer,this)->m_id))
            return true;
         else
            return false;
      }
      else
      {
         assert(0);
      }
   }
   else if(other.isKindOf(cTerm_IMU::getCLID()))
   {
      if(!isKindOf(cTerm_IMU::getCLID()))
      {
         if(isKindOf(cTerm_MU_Result::getCLID()) && other.isKindOf(cTerm_IMU_Result::getCLID()))
            return true;
         else if(isKindOf(cTerm_MU_Constant::getCLID()) && other.isKindOf(cTerm_IMU_Constant::getCLID()) &&
            CAST(cTerm_MU_Constant,this)->getConstant()==CAST(cTerm_IMU_Constant,&other)->getConstant() &&
            !CAST(cTerm_MU_Constant,this)->m_float)
            return true;
         else
            return false;
      }
      if(isKindOf(cTerm_IMU_Integer::getCLID()))
      {
         if (other.isKindOf(cTerm_IMU_Integer::getCLID()) &&
            (CAST(cTerm_IMU_Integer,&other)->m_id==CAST(cTerm_IMU_Integer,this)->m_id))
            return true;
         else if (other.isKindOf(cTerm_MU_Integer::getCLID()) &&
            (CAST(cTerm_MU_Integer,&other)->m_id==CAST(cTerm_IMU_Integer,this)->m_id))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_Pointer::getCLID()))
      {
         if (other.isKindOf(cTerm_IMU_Pointer::getCLID()) &&
            (CAST(cTerm_IMU_Pointer,&other)->m_id==CAST(cTerm_IMU_Pointer,this)->m_id))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_Result::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_Result::getCLID()))
            return true;
         else if(other.isKindOf(cTerm_MU_Result::getCLID()))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_Stack::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_Stack::getCLID()))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_Lane::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_Lane::getCLID()))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_Zero::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_Zero::getCLID()))
            return true;
         else if(other.isKindOf(cTerm_IMU_Constant::getCLID()) && CAST(cTerm_IMU_Constant,&other)->getConstant()==0)
            return true;
         else if(other.isKindOf(cTerm_MU_Constant::getCLID()) && CAST(cTerm_MU_Constant,&other)->getConstant()==0)
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_Null::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_Null::getCLID()))
            return true;
         else if(other.isKindOf(cTerm_MU_Null::getCLID()))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_TID::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_TID::getCLID()))
            return true;
         else if(other.isKindOf(cTerm_MU_TID::getCLID()))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_PID::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_PID::getCLID()))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_SharedPointerConstant::getCLID()))
      {
         if (other.isKindOf(cTerm_IMU_SharedPointerConstant::getCLID()) &&
            (CAST(cTerm_IMU_SharedPointerConstant,&other)->m_id==CAST(cTerm_IMU_SharedPointerConstant,this)->m_id) &&
            (CAST(cTerm_IMU_SharedPointerConstant,&other)->m_offset==CAST(cTerm_IMU_SharedPointerConstant,this)->m_offset))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_ConstPointerConstant::getCLID()))
      {
         if (other.isKindOf(cTerm_IMU_ConstPointerConstant::getCLID()) &&
            (CAST(cTerm_IMU_ConstPointerConstant,&other)->m_id==CAST(cTerm_IMU_ConstPointerConstant,this)->m_id) &&
            (CAST(cTerm_IMU_ConstPointerConstant,&other)->m_offset==CAST(cTerm_IMU_ConstPointerConstant,this)->m_offset))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID()))
      {
         if (other.isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID()) &&
            (CAST(cTerm_IMU_PrivatePointerConstant,&other)->m_id==CAST(cTerm_IMU_PrivatePointerConstant,this)->m_id) &&
            (CAST(cTerm_IMU_PrivatePointerConstant,&other)->m_offset==CAST(cTerm_IMU_PrivatePointerConstant,this)->m_offset))
            return true;
         else
            return false;
      }
      else if(isKindOf(cTerm_IMU_Constant::getCLID()))
      {
         if(other.isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID()) ||
            other.isKindOf(cTerm_IMU_SharedPointerConstant::getCLID()) ||
            other.isKindOf(cTerm_IMU_ConstPointerConstant::getCLID()))
            return false;
         if (other.isKindOf(cTerm_IMU_Constant::getCLID()) &&
            (CAST(cTerm_IMU_Constant,&other)->m_c==CAST(cTerm_IMU_Constant,this)->m_c))
            return true;
         else if (other.isKindOf(cTerm_IMU_Zero::getCLID()) &&
            (CAST(cTerm_IMU_Constant,this)->m_c==0))
            return true;
         else if (other.isKindOf(cTerm_MU_Constant::getCLID()) &&
            (CAST(cTerm_MU_Constant,&other)->m_c==(float)CAST(cTerm_IMU_Constant,this)->m_c))
            return true;
         else
            return false;
      }
      else
      {
         assert(0);
      }
   }
   else
   {
      assert(0);
   }
   return true;
}

// Convert parameter to format suitable for MU operation
cTerm *cTerm::Convert2MU(cInstructions *instructions,cAstNode *func,cAstNode *node,cTerm *x)
{
   if(x->isKindOf(cTerm_MU::getCLID()))
      return x; // Same type. No conversion required
   if(x->isKindOf(cTerm_IMU_Integer::getCLID()))
   {
      // This is referenced integer. Conversion is possible
      return new cTerm_MU_Integer(CAST(cTerm_IMU_Integer,x)->m_id);
   }
   else if(x->isKindOf(cTerm_IMU_Result::getCLID()))
   {
      // This is referenced RESULT register. Conversion is possible
      return new cTerm_MU_Result();
   }
   else if(x->isKindOf(cTerm_IMU_TID::getCLID()))
   {
      // This is TID. Conversion is possible
      cInstruction *instruction2;
      cTerm *term,*term2;
      cIdentifierInteger *id2;
      
      if(!instructions)
         return 0;
      instruction2=new cInstruction(node);
      term=new cTerm_IMU_TID();
      id2=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,true,false,-1);
      term2=new cTerm_IMU_Integer(id2);
      instruction2->createIMU(cConfig::IOPCODE_ADD,
               CAST(cTerm_IMU,term),
               new cTerm_IMU_Zero(),
               CAST(cTerm_IMU,term2));
      instructions->append(instruction2);
      return new cTerm_MU_Integer(id2);
   }
   else if(x->isKindOf(cTerm_IMU_PID::getCLID()))
   {
      cInstruction *instruction2;
      cTerm *term,*term2;
      cIdentifierInteger *id2;
      
      if(!instructions)
         return 0;
      instruction2=new cInstruction(node);
      term=new cTerm_IMU_PID();
      id2=new cIdentifierInteger(func->getChild(1,eTOKEN_block_item_list),0,0,true,false,-1);
      term2=new cTerm_IMU_Integer(id2);
      instruction2->createIMU(cConfig::IOPCODE_ADD,
               CAST(cTerm_IMU,term),
               new cTerm_IMU_Zero(),
               CAST(cTerm_IMU,term2));
      instructions->append(instruction2);
      return new cTerm_MU_Integer(id2);
   }
   else if(x->isKindOf(cTerm_IMU_Constant::getCLID()))
   {
      // This is constant. It's possible to convert from integer to float
      return new cTerm_MU_Constant(float(CAST(cTerm_IMU_Constant,x)->getConstant()));
   }
   else
   {
      // Conversion is not possible
      return 0;
   }
}

// Convert to parameter suitable for IMU operation
cTerm *cTerm::Convert2IMU(cTerm *x)
{
   if(x->isKindOf(cTerm_IMU::getCLID()))
      return x; // Same type. No conversion required
   if(x->isKindOf(cTerm_MU_Integer::getCLID()))
   {
      // This is integer. Conversion is possible
      return new cTerm_IMU_Integer(CAST(cTerm_MU_Integer,x)->m_id);
   }
   else if(x->isKindOf(cTerm_MU_Result::getCLID()))
   {
      // This is RESULT register. Conversion is possible
      return new cTerm_IMU_Result();
   }
   else if(x->isKindOf(cTerm_MU_TID::getCLID()))
   {
      // This is TID. Conversion is possible
      return new cTerm_IMU_TID();
   }
   else if(x->isKindOf(cTerm_MU_Constant::getCLID()))
   {
      // This is constant. Conversion is only possible if constant is not float.
      if(!CAST(cTerm_MU_Constant,x)->m_float)
         return new cTerm_IMU_Constant((int)CAST(cTerm_MU_Constant,x)->getConstant());
      else
         return 0;
   }
   else
      return 0;
}

// Substitute identifier to another one.
void cTerm::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
}

// Display information about the term
void cTerm::print()
{
}

//VUONG
bool cTerm::isDouble()
{
   cIdentifierVector lst;
   getDef(&lst);
   if(lst.size()==1)
   {
      if(lst[0] && lst[0]->isKindOf(cIdentifierExReg::getCLID()))
         return true;
      else
         return false;
   }
   else
      return false;
}

// Base class for class represents parameters in an IMU operation
INSTANTIATE_OBJECT(cTerm_IMU);
cTerm_IMU::cTerm_IMU()
{
}

// Return attribute field used when generated the binary for the instruction
int cTerm_IMU::getAttr()
{
   return IATTR_I0;
}

// Return constant field used when generated the binary for the instruction
int cTerm_IMU::getConstant()
{
   return 0;
}

cTerm_IMU::~cTerm_IMU()
{
}

bool cTerm_IMU::isUnsigned()
{
   return m_isUnsigned;
}

// Class represent IMU parameter of an integer
INSTANTIATE_OBJECT(cTerm_IMU_Integer);
cTerm_IMU_Integer::cTerm_IMU_Integer(cIdentifierInteger *_id)
{
   m_id=_id;
   m_isUnsigned=_id->m_isUnsigned;
}

int cTerm_IMU_Integer::getAttr()
{
   return IATTR_I0+m_id->getOffset();
}

void cTerm_IMU_Integer::getDef(cIdentifierVector *lst)
{
   lst->append(m_id);
}
void cTerm_IMU_Integer::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
      m_id=CAST(cIdentifierInteger,_new);
}
void cTerm_IMU_Integer::print()
{
   char temp[100];
   printf("int:%s",m_id->getPrintName(temp));
}

// Class represents IMU parameter for a pointer
INSTANTIATE_OBJECT(cTerm_IMU_Pointer);
cTerm_IMU_Pointer::cTerm_IMU_Pointer(cIdentifierPointer *_id)
{
   m_id=_id;
}
int cTerm_IMU_Pointer::getAttr()
{
   return IATTR_P0+m_id->getOffset();
}
void cTerm_IMU_Pointer::getDef(cIdentifierVector *lst)
{
   return lst->append(m_id);
}
void cTerm_IMU_Pointer::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
      m_id=CAST(cIdentifierPointer,_new);
}
void cTerm_IMU_Pointer::print()
{
   char temp[100];
   printf("pointer:%s",m_id->getPrintName(temp));
}

// Class represents IMU parameter of a RESULT register.
INSTANTIATE_OBJECT(cTerm_IMU_Result);
cTerm_IMU_Result::cTerm_IMU_Result()
{
}
int cTerm_IMU_Result::getAttr()
{
   return IATTR_RESULT1;
}
void cTerm_IMU_Result::getDef(cIdentifierVector *lst)
{
   lst->append(&cIdentifierResult::M_singleInstance);
}
void cTerm_IMU_Result::print()
{
   printf("RESULT");
}

// Class represents IMU parameter of zero
INSTANTIATE_OBJECT(cTerm_IMU_Zero);
cTerm_IMU_Zero::cTerm_IMU_Zero()
{
}
int cTerm_IMU_Zero::getAttr()
{
   return IATTR_ZERO;
}
void cTerm_IMU_Zero::print()
{
   printf("ZERO");
}

// Class represents IMU parameter of stack
INSTANTIATE_OBJECT(cTerm_IMU_Stack);
cTerm_IMU_Stack::cTerm_IMU_Stack()
{
}
int cTerm_IMU_Stack::getAttr()
{
   return IATTR_STACK;
}
void cTerm_IMU_Stack::print()
{
   printf("STACK");
}

// Class represents IMU parameter of lane control
INSTANTIATE_OBJECT(cTerm_IMU_Lane);
cTerm_IMU_Lane::cTerm_IMU_Lane()
{
}
int cTerm_IMU_Lane::getAttr()
{
   return IATTR_LANE;
}
void cTerm_IMU_Lane::print()
{
   printf("LANE");
}
void cTerm_IMU_Lane::getDef(cIdentifierVector *lst)
{
   lst->append(&cIdentifierLane::M_singleInstance);
}

// Class represents IMU parameter of a null field
INSTANTIATE_OBJECT(cTerm_IMU_Null);
cTerm_IMU_Null::cTerm_IMU_Null()
{
}
int cTerm_IMU_Null::getAttr()
{
   return IATTR_ZERO;
}
void cTerm_IMU_Null::print()
{
   printf("Null");
}

// Class represents IMU parameter of a constant
INSTANTIATE_OBJECT(cTerm_IMU_Constant);
cTerm_IMU_Constant::cTerm_IMU_Constant(int _c,bool isUnsigned)
{
   m_c=_c;
   m_isUnsigned=isUnsigned;
}

int cTerm_IMU_Constant::getAttr()
{
   return IATTR_CONST;
}
int cTerm_IMU_Constant::getConstant()
{
   return m_c;
}
void cTerm_IMU_Constant::print()
{
   printf("%d",m_c);
}

// Class represents IMU parameter of TID (thread-id)
INSTANTIATE_OBJECT(cTerm_IMU_TID);
cTerm_IMU_TID::cTerm_IMU_TID()
{
}
int cTerm_IMU_TID::getAttr()
{
   return IATTR_TID;
}
void cTerm_IMU_TID::print()
{
   printf("TID");
}

// Class represents IMU parameter of PID (processor-id)
INSTANTIATE_OBJECT(cTerm_IMU_PID);
cTerm_IMU_PID::cTerm_IMU_PID()
{
}
int cTerm_IMU_PID::getAttr()
{
   return IATTR_PID;
}
void cTerm_IMU_PID::print()
{
   printf("PID");
}

// Based class for constant represents address
INSTANTIATE_OBJECT(cTerm_IMU_AddressConstant);
cTerm_IMU_AddressConstant::cTerm_IMU_AddressConstant(int _c) :
    cTerm_IMU_Constant(_c)
{
}

bool cTerm_IMU_AddressConstant::isValid()
{
   return false;
}

// Class represents IMU parameter of an address constant pointing to shared memory region
INSTANTIATE_OBJECT(cTerm_IMU_SharedPointerConstant);
cTerm_IMU_SharedPointerConstant::cTerm_IMU_SharedPointerConstant(cIdentifier *_id,int _offset,bool _subVector) :
    cTerm_IMU_AddressConstant(_offset|(1 << (IREGISTER_WIDTH-1)))
{
   m_id=_id;
   m_offset=_offset;
   m_subVector=_subVector;
}

bool cTerm_IMU_SharedPointerConstant::isValid()
{
   return m_id->getOffset() >= 0;
}

int cTerm_IMU_SharedPointerConstant::getConstant()
{
   int offset;

   offset=m_id->getOffset();
   if(offset < 0)
      offset=(int)m_id;
   if(m_subVector && CAST(cIdentifierShared,m_id)->m_w > 0)
      return ((offset << VECTOR_DEPTH)+m_offset)|(1 << (IREGISTER_WIDTH-1));
   else
      return (offset+m_offset)|(1 << (IREGISTER_WIDTH-1));
}

void cTerm_IMU_SharedPointerConstant::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
      m_id=_new;
}
void cTerm_IMU_SharedPointerConstant::print()
{
   char temp[100];
   printf("P_SHARED_CONSTANT:&%s[%d]",m_id->getPrintName(temp),m_offset);
   if(CAST(cIdentifierShared,m_id)->m_w > 0 && !m_subVector)
      printf(" (v)");
}

// Class represents IMU parameter of an address constant pointing to constant memory region
INSTANTIATE_OBJECT(cTerm_IMU_ConstPointerConstant);
cTerm_IMU_ConstPointerConstant::cTerm_IMU_ConstPointerConstant(cIdentifier *_id,int _offset) :
    cTerm_IMU_AddressConstant(_offset|(1 << (IREGISTER_WIDTH-1)))
{
   m_id=_id;
   m_offset=_offset;
}

bool cTerm_IMU_ConstPointerConstant::isValid()
{
   return m_id->getOffset() >= 0;
}

int cTerm_IMU_ConstPointerConstant::getConstant()
{
   if(m_id->getOffset() >= 0)
      return (m_id->getOffset()+m_offset)|(1 << (IREGISTER_WIDTH-1));
   else
      return (int)m_id+m_offset;
}

void cTerm_IMU_ConstPointerConstant::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
      m_id=_new;
}
void cTerm_IMU_ConstPointerConstant::print()
{
   char temp[100];
   printf("P_CONST_CONSTANT:&%s[%d]",m_id->getPrintName(temp),m_offset);
}

// Class represents IMU parameter of a address constant pointing to a private memory region.
INSTANTIATE_OBJECT(cTerm_IMU_PrivatePointerConstant);
cTerm_IMU_PrivatePointerConstant::cTerm_IMU_PrivatePointerConstant(cIdentifier *_id,int _offset,bool _subVector) :
    cTerm_IMU_AddressConstant(_offset)
{
   m_id=_id;
   m_offset=_offset;
   m_subVector=_subVector;
}

bool cTerm_IMU_PrivatePointerConstant::isValid()
{
   return m_id->getOffset() >= 0;
}

int cTerm_IMU_PrivatePointerConstant::getConstant()
{
   int offset;

   offset=m_id->getOffset();
   if(offset < 0)
      offset=(int)m_id;
   if(m_subVector && CAST(cIdentifierPrivate,m_id)->m_w > 0)
      return (offset << VECTOR_DEPTH)+m_offset;
   else
      return offset+m_offset;
}

void cTerm_IMU_PrivatePointerConstant::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
      m_id=_new;
}
void cTerm_IMU_PrivatePointerConstant::print()
{
   char temp[100];
   printf("P_PRIV_CONSTANT:&%s[%d]",m_id->getPrintName(temp),m_offset);
   if(CAST(cIdentifierPrivate,m_id)->m_w > 0 && !m_subVector)
      printf(" (v)");
}

// Class represents parameters in a MU operation
INSTANTIATE_OBJECT(cTerm_MU);
cTerm_MU::cTerm_MU()
{
}

cTerm_MU::~cTerm_MU()
{
}

// Return attribute field used to generate the binary for this instruction
int cTerm_MU::getAttr() 
{
   return eTermMemoryReferenceShared;
}
// Return offset field used to generate the binary for this instruction
int cTerm_MU::getOffset() 
{
   return 0;
}
// Return index field used to generate the binary for this instruction
int cTerm_MU::getIndex() 
{
   return -1;
}
// Return constant field used to generate the binary for this instruction
float cTerm_MU::getConstant() 
{
   return 0;
}

// Default for vector width 
int cTerm_MU::getVectorWidth()
{
   return -1;
}


// Return attribute field when generating the binary for the instruction
// 11xx   pointer with index
// 1011   pointer no index
// 1000   share no index
// 1001   private no index
// 1010   constant
// 00xx   share with index
// 01xx   private with index
int cTerm_MU::getExtAttr()
{
   switch(getAttr())
   {
      case eTermMemoryReferencePointer:
         if(getIndex() < 0)
         {
            // Pointer[C]
            return INSTRUCTION_ATTR_POINTER;
         }
         else
         {
            // Pointer[I+C]
            return INSTRUCTION_ATTR_POINTER_N_INDEX+getIndex();
         }
         break;
      case eTermMemoryReferenceConst:
         return INSTRUCTION_ATTR_CONST;
      case eTermMemoryReferenceShared:
         if(getIndex() < 0)
         {
            // PRIVATE[C]
            return INSTRUCTION_ATTR_SHARE;
         }
         else
         {
            // PRIVATE[I+C]
            return INSTRUCTION_ATTR_SHARE_N_INDEX+getIndex();
         }
         break;
      case eTermMemoryReferencePrivate:
         if(getIndex() < 0)
         {
            // SHARE[C]
            return INSTRUCTION_ATTR_PRIVATE;
         }
         else
         {
            // SHARE[I+C]
            return INSTRUCTION_ATTR_PRIVATE_N_INDEX+getIndex();
         }
         break;
      default:
         assert(0);
         return 0;
   }
}

// Class represents NULL parameter in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_Null);
cTerm_MU_Null::cTerm_MU_Null()
{
}
void cTerm_MU_Null::print()
{
   printf("Null");
}

int cTerm_MU_Null::getAttr() 
{
   return eTermMemoryReferenceConst;
}
int cTerm_MU_Null::getOffset() 
{
    return ATTR_CONST_NULL;
}

// Class represents a float constant parameter in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_Constant);
cTerm_MU_Constant::cTerm_MU_Constant(float _c,int _slot)
{
   m_c = _c;
   m_slot = _slot;
   m_float = true;
}

// Class represents a integer constant parameter in a MU operation
cTerm_MU_Constant::cTerm_MU_Constant(int _c,int _slot)
{
   m_c = (float)_c;
   m_slot = _slot;
   m_float = false;
   assert(m_slot==0);
}

int cTerm_MU_Constant::getAttr() 
{
   if(M_ISFLOAT)
      return eTermMemoryReferenceConst;
   else 
      return eTermMemoryReferenceShared;
}
int cTerm_MU_Constant::getOffset() 
{
   if(M_ISFLOAT)
      return ATTR_CONST_P0;
   else
   {
      int index;
      index=cConstant::Find(m_c);
      assert(index >= 0);
      return index;
   }
}

int cTerm_MU_Constant::getVectorWidth()
{
   return 0;
}

float cTerm_MU_Constant::getConstant() 
{
   return m_c;
}

void cTerm_MU_Constant::setSlot(int _slot) 
{
   m_slot=_slot;
   assert(m_slot==0);
}

void cTerm_MU_Constant::print()
{
   if(m_float)
      printf("%4.12f",(float)m_c);
   else
      printf("%d",(int)m_c);
}

// Class represents a TID parameter in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_TID);
cTerm_MU_TID::cTerm_MU_TID()
{
}
int cTerm_MU_TID::getAttr()
{
   return eTermMemoryReferenceConst;
}
int cTerm_MU_TID::getOffset()
{
   return ATTR_CONST_TID;
}
void cTerm_MU_TID::print()
{
   printf("TID");
}

// Class represents a pointer reference with index parameter in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_PointerWithIndex);
cTerm_MU_PointerWithIndex::cTerm_MU_PointerWithIndex(cIdentifierPointer *_baseId,cIdentifierInteger *_indexId,int _offset)
{
   m_baseId=_baseId;
   m_indexId=_indexId;
   m_offset=_offset;
   m_indexId->m_useForMuIndex=true;
}
int cTerm_MU_PointerWithIndex::getAttr()
{
   return eTermMemoryReferencePointer;
}
int cTerm_MU_PointerWithIndex::getOffset()
{
   if(m_offset >= 0)
      return ((m_baseId->getOffset() << 3)+m_offset);
   else
      return ((m_baseId->getOffset() << 3)+((unsigned int)(m_offset & 0x7)));
}
int cTerm_MU_PointerWithIndex::getIndex()
{
   return m_indexId->getOffset();
}

int cTerm_MU_PointerWithIndex::getVectorWidth()
{
   return m_baseId->m_width;
}

void cTerm_MU_PointerWithIndex::getDef(cIdentifierVector *lst)
{
   m_baseId->getIdentifierScope(lst);
}

void cTerm_MU_PointerWithIndex::getUse(cIdentifierVector *lst)
{
   lst->append(m_indexId);
   lst->append(m_baseId);
}

void cTerm_MU_PointerWithIndex::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_baseId==_old)
      m_baseId=CAST(cIdentifierPointer,_new);
   if(m_indexId==_old)
      m_indexId=CAST(cIdentifierInteger,_new);
}
void cTerm_MU_PointerWithIndex::print()
{
   char temp1[100],temp2[100];
   printf("p:%s[%s+%d]",m_baseId->getPrintName(temp1),m_indexId->getPrintName(temp2),m_offset);
}

// Class represents a pointer reference with index in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_PointerWithoutIndex);
cTerm_MU_PointerWithoutIndex::cTerm_MU_PointerWithoutIndex(cIdentifierPointer *_baseId,int _offset)
{
   m_baseId=_baseId;
   m_offset=_offset;
}
int cTerm_MU_PointerWithoutIndex::getAttr()
{
   return eTermMemoryReferencePointer;
}
int cTerm_MU_PointerWithoutIndex::getOffset()
{
   return ((m_baseId->getOffset() << 3)+m_offset);
}
int cTerm_MU_PointerWithoutIndex::getVectorWidth()
{
   return m_baseId->m_width;
}
void cTerm_MU_PointerWithoutIndex::getDef(cIdentifierVector *lst)
{
   m_baseId->getIdentifierScope(lst);
}

void cTerm_MU_PointerWithoutIndex::getUse(cIdentifierVector *lst)
{
   lst->append(m_baseId);
}

void cTerm_MU_PointerWithoutIndex::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_baseId==_old)
      m_baseId=CAST(cIdentifierPointer,_new);
}
void cTerm_MU_PointerWithoutIndex::print()
{
   char temp[100];
   printf("p:%s[%d]",m_baseId->getPrintName(temp),m_offset);
}

// Class repesents a private memory parameter in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_Storage);
cTerm_MU_Storage::cTerm_MU_Storage(cIdentifierStorage *_id,int _offset,bool _subVector)
{
   assert(_offset < _id->getLen());
   m_id=_id;
   m_offset=_offset;
   m_subVector=_subVector;
}
int cTerm_MU_Storage::getAttr()
{
   if(m_id->isKindOf(cIdentifierShared::getCLID()))
      return eTermMemoryReferenceShared;
   else
      return eTermMemoryReferencePrivate;
}
int cTerm_MU_Storage::getOffset()
{
   if(m_subVector)
      return (m_id->getOffset() << VECTOR_DEPTH)+m_offset;
   else
      return m_id->getOffset()+m_offset;
}

void cTerm_MU_Storage::getDef(cIdentifierVector *lst)
{
   lst->append(m_id);
}

int cTerm_MU_Storage::getVectorWidth()
{
   if(!m_subVector)
      return m_id->m_w;
   else
      return 0;
}

void cTerm_MU_Storage::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
   {
      m_id=CAST(cIdentifierStorage,_new);
   }
}
void cTerm_MU_Storage::print()
{
   char temp[100];
   if(m_id->getNumDim() == 0 && !m_subVector)
      printf("%s",m_id->getPrintName(temp));
   else
      printf("%s[%d]",m_id->getPrintName(temp),m_offset);
}

// Class represents a private memory parameter with index in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_StorageWithIndex);
cTerm_MU_StorageWithIndex::cTerm_MU_StorageWithIndex(cIdentifierStorage *_id,cIdentifierInteger *_indexId,int _offset,bool _subVector)
{
   assert(_offset < _id->getLen());
   m_id=_id;
   m_offset=_offset;
   m_indexId=_indexId;
   m_subVector=_subVector;
   m_indexId->m_useForMuIndex=true;
}

int cTerm_MU_StorageWithIndex::getAttr()
{
   if(m_id->isKindOf(cIdentifierShared::getCLID()))
      return eTermMemoryReferenceShared;
   else
      return eTermMemoryReferencePrivate;
}

int cTerm_MU_StorageWithIndex::getOffset()
{
   if(!m_subVector)
      return m_id->getOffset()+m_offset;
   else
      return (m_id->getOffset() << VECTOR_DEPTH)+m_offset;
}

int cTerm_MU_StorageWithIndex::getIndex()
{
   return m_indexId->getOffset();
}

int cTerm_MU_StorageWithIndex::getVectorWidth()
{
   if(!m_subVector)
      return m_id->m_w;
   else
      return 0;
}

void cTerm_MU_StorageWithIndex::getDef(cIdentifierVector *lst)
{
   lst->append(m_id);
}

void cTerm_MU_StorageWithIndex::getUse(cIdentifierVector *lst)
{
   lst->append(m_indexId);
}

void cTerm_MU_StorageWithIndex::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
   {
      assert(_new->isKindOf(cIdentifierStorage::getCLID()));
      m_id=CAST(cIdentifierStorage,_new);
   }
   if(m_indexId==_old)
   {
      assert(_new->isKindOf(cIdentifierInteger::getCLID()));
      m_indexId=CAST(cIdentifierInteger,_new);
   }
}

void cTerm_MU_StorageWithIndex::print()
{
   char temp1[100],temp2[100];
   printf("%s[%s+%d]",m_id->getPrintName(temp1),m_indexId->getPrintName(temp2),m_offset);
}

// Class represents a RESULT parameter in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_Result);
cTerm_MU_Result::cTerm_MU_Result()
{
}
int cTerm_MU_Result::getAttr()
{
   return eTermMemoryReferenceConst;
}
int cTerm_MU_Result::getOffset()
{
   return ATTR_CONST_RESULT;
}
void cTerm_MU_Result::getDef(cIdentifierVector *lst)
{
   lst->append(&cIdentifierResult::M_singleInstance);
}
void cTerm_MU_Result::print()
{
   printf("RESULT");
}

// Class represents a integer parameter in a MU operation
INSTANTIATE_OBJECT(cTerm_MU_Integer);
cTerm_MU_Integer::cTerm_MU_Integer(cIdentifierInteger *_id)
{
   m_id=_id;
}
int cTerm_MU_Integer::getAttr()
{
   return eTermMemoryReferenceConst;
}
int cTerm_MU_Integer::getOffset()
{
   return (m_id->getOffset() << 3);
}
int cTerm_MU_Integer::getIndex()
{
   return -1;
}
void cTerm_MU_Integer::getDef(cIdentifierVector *lst)
{
   lst->append(m_id);
}
void cTerm_MU_Integer::updateIdentifier(cIdentifier *_old,cIdentifier *_new)
{
   if(m_id==_old)
      m_id=CAST(cIdentifierInteger,_new);
}
void cTerm_MU_Integer::print()
{
   char temp[100];
   printf("%s",m_id->getPrintName(temp));
}

// Check if y term result will affect this parameter
// Return true is it is not affected, false if they can affect each other
bool cTerm_IMU_Integer::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return ((cTerm_IMU_Integer *)y)->m_id != m_id;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}

bool cTerm_IMU_Pointer::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return ((cTerm_IMU_Pointer *)y)->m_id != m_id;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}

bool cTerm_IMU_Result::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return false;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}

bool cTerm_IMU_Zero::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_Stack::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_Lane::independent(cTerm *y)
{
   if(y->isKindOf(cTerm_IMU_Lane::getCLID()))
      return false;
   else
      return true;
}

bool cTerm_IMU_Null::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_Constant::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_TID::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_PID::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_SharedPointerConstant::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_ConstPointerConstant::independent(cTerm *y)
{
   return true;
}

bool cTerm_IMU_PrivatePointerConstant::independent(cTerm *y)
{
   return true;
}

bool cTerm_MU_Null::independent(cTerm *y)
{
   return true;
}

bool cTerm_MU_Constant::independent(cTerm *y)
{
   return true;
}

bool cTerm_MU_TID::independent(cTerm *y)
{
   return true;
}

static bool ovl(int off1,int w1,int off2,int w2)
{
   int w,v1,v2;
   if(w1>w2)
      w=w1;
   else
      w=w2;
   v1=(off1 << w1);
   v2=(off2 << w2);
   return (v1 & (~((1<<w)-1)))==(v2 & (~((1<<w)-1)));
}

bool cTerm_MU_PointerWithoutIndex::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return ((cTerm_IMU_Pointer *)y)->m_id != m_baseId;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return getVectorWidth()<1;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return !m_baseId->isPointerOverlap(((cTerm_MU_PointerWithoutIndex *)y)->m_baseId);}
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return !m_baseId->isPointerOverlap(((cTerm_MU_PointerWithIndex *)y)->m_baseId);}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return !(CAST(cTerm_MU_Storage,y)->m_id->isPointerOverlap(m_baseId));}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return !(CAST(cTerm_MU_StorageWithIndex,y)->m_id->isPointerOverlap(m_baseId));}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}
 
bool cTerm_MU_PointerWithIndex::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return ((cTerm_IMU_Integer *)y)->m_id != m_indexId;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return ((cTerm_IMU_Pointer *)y)->m_id != m_baseId;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return getVectorWidth()<1;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return !m_baseId->isPointerOverlap(((cTerm_MU_PointerWithoutIndex *)y)->m_baseId);}
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return !m_baseId->isPointerOverlap(((cTerm_MU_PointerWithIndex *)y)->m_baseId);}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return !(CAST(cTerm_MU_Storage,y)->m_id->isPointerOverlap(m_baseId));}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return !(CAST(cTerm_MU_StorageWithIndex,y)->m_id->isPointerOverlap(m_baseId));}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}

bool cTerm_MU_Storage::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return getVectorWidth()<1;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return !(m_id->isPointerOverlap(((cTerm_MU_PointerWithoutIndex *)y)->m_baseId));}
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return !(m_id->isPointerOverlap(((cTerm_MU_PointerWithIndex *)y)->m_baseId));}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return ((m_id != CAST(cTerm_MU_Storage,y)->m_id) || !ovl(m_offset,getVectorWidth(),CAST(cTerm_MU_Storage,y)->m_offset,CAST(cTerm_MU_Storage,y)->getVectorWidth()));}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return (m_id != (CAST(cTerm_MU_StorageWithIndex,y)->m_id));}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}

bool cTerm_MU_StorageWithIndex::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return m_indexId != CAST(cTerm_IMU_Integer,y)->m_id;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return getVectorWidth()<1;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return !(m_id->isPointerOverlap(((cTerm_MU_PointerWithoutIndex *)y)->m_baseId));}
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return !(m_id->isPointerOverlap(((cTerm_MU_PointerWithIndex *)y)->m_baseId));}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return (m_id != (CAST(cTerm_MU_Storage,y)->m_id));}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return (m_id != (CAST(cTerm_MU_StorageWithIndex,y)->m_id) || (m_indexId==(CAST(cTerm_MU_StorageWithIndex,y)->m_indexId) && getVectorWidth()==CAST(cTerm_MU_StorageWithIndex,y)->getVectorWidth() && !ovl(m_offset,getVectorWidth(),CAST(cTerm_MU_StorageWithIndex,y)->m_offset,CAST(cTerm_MU_StorageWithIndex,y)->getVectorWidth())));}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}

bool cTerm_MU_Result::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return true;} 
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return false;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}
   
bool cTerm_MU_Integer::independent(cTerm *y)
{
if(y->isKindOf(cTerm_IMU_Integer::getCLID())) {return ((cTerm_IMU_Integer *)y)->m_id != m_id;}
else if(y->isKindOf(cTerm_IMU_Pointer::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Result::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Zero::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_Stack::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Lane::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_IMU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_SharedPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_ConstPointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_IMU_PrivatePointerConstant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_Null::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Constant::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_TID::getCLID())) {error(0,0);}
else if(y->isKindOf(cTerm_MU_PointerWithoutIndex::getCLID())) {return true;} 
else if(y->isKindOf(cTerm_MU_PointerWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Storage::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_StorageWithIndex::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Result::getCLID())) {return true;}
else if(y->isKindOf(cTerm_MU_Integer::getCLID())) {error(0,0);}
else {error(0,0);}
return true;
}

