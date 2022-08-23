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

#ifndef _TERM_H_
#define _TERM_H_
#include "object.h"
#include "gen.h"
#include "ident.h"

// Type of memory reference
typedef enum
{
   eTermMemoryReferenceShared=0,
   eTermMemoryReferencePrivate,
   eTermMemoryReferenceConst,
   eTermMemoryReferencePointer
} eTermMemoryReference;

class cInstructions;
class cTerm
{
   DECLARE_ROOT_OBJECT(cTerm);
public:
   cTerm();
   virtual ~cTerm() {}
   virtual bool independent(cTerm *y)=0;
   virtual bool operator==(cTerm &other);
   static cTerm *Convert2MU(cInstructions *instructions,cAstNode *func,cAstNode *node,cTerm *x);
   static cTerm *Convert2IMU(cTerm *x);
   virtual void getUse(cIdentifierVector *lst);
   virtual void getDef(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
   bool isDouble();
};

class cTerm_IMU : public cTerm
{
   DECLARE_OBJECT(cTerm_IMU,cTerm);
public:
   cTerm_IMU();
   virtual ~cTerm_IMU();
   virtual int getAttr();
   virtual int getConstant();
   bool isUnsigned();
   bool m_isUnsigned;
};

class cTerm_IMU_Integer : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Integer,cTerm_IMU);
public:
   cTerm_IMU_Integer(cIdentifierInteger *_id);
   virtual ~cTerm_IMU_Integer() {}
   virtual int getAttr();
   virtual bool independent(cTerm *y);
   virtual void getDef(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
public:
   cIdentifierInteger *m_id;
};

class cTerm_IMU_Pointer : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Pointer,cTerm_IMU);
public:
   cTerm_IMU_Pointer(cIdentifierPointer *_id);
   virtual ~cTerm_IMU_Pointer() {}
   virtual int getAttr();
   virtual bool independent(cTerm *y);
   virtual void getDef(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
public:
   cIdentifierPointer *m_id;
};

class cTerm_IMU_Result : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Result,cTerm_IMU);
public:
   cTerm_IMU_Result();
   virtual ~cTerm_IMU_Result() {}
   virtual int getAttr();
   void getDef(cIdentifierVector *lst);
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_IMU_Zero : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Zero,cTerm_IMU);
public:
   cTerm_IMU_Zero();
   virtual ~cTerm_IMU_Zero() {}
   virtual int getAttr();
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_IMU_Stack : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Stack,cTerm_IMU);
public:
   cTerm_IMU_Stack();
   virtual ~cTerm_IMU_Stack() {}
   virtual int getAttr();
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_IMU_Lane : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Lane,cTerm_IMU);
public:
   cTerm_IMU_Lane();
   virtual ~cTerm_IMU_Lane() {}
   virtual int getAttr();
   virtual void getDef(cIdentifierVector *lst);
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_IMU_Null : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Null,cTerm_IMU);
public:
   cTerm_IMU_Null();
   virtual ~cTerm_IMU_Null() {}
   virtual int getAttr();
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_IMU_Constant : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_Constant,cTerm_IMU);
public:
   cTerm_IMU_Constant(int _c,bool isUnsigned=false);
   virtual ~cTerm_IMU_Constant() {}
   virtual int getAttr();
   virtual int getConstant();
   virtual bool independent(cTerm *y);
   virtual void print();
public:
   int m_c;
};

class cTerm_IMU_TID : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_TID,cTerm_IMU);
public:
   cTerm_IMU_TID();
   virtual ~cTerm_IMU_TID() {}
   virtual int getAttr();
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_IMU_PID : public cTerm_IMU
{
   DECLARE_OBJECT(cTerm_IMU_PID,cTerm_IMU);
public:
   cTerm_IMU_PID();
   virtual ~cTerm_IMU_PID() {}
   virtual int getAttr();
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_IMU_AddressConstant : public cTerm_IMU_Constant
{
   DECLARE_OBJECT(cTerm_IMU_AddressConstant,cTerm_IMU_Constant);
public:
   cTerm_IMU_AddressConstant(int _c);
   virtual ~cTerm_IMU_AddressConstant() {}
   virtual bool isValid();
};

class cTerm_IMU_SharedPointerConstant : public cTerm_IMU_AddressConstant
{
   DECLARE_OBJECT(cTerm_IMU_SharedPointerConstant,cTerm_IMU_AddressConstant);
public:
   cTerm_IMU_SharedPointerConstant(cIdentifier *_id,int _offset,bool _subVector);
   virtual ~cTerm_IMU_SharedPointerConstant() {}
   virtual int getConstant();
   virtual bool independent(cTerm *y);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
   virtual bool isValid();
public:
   cIdentifier *m_id;
   int m_offset;
   bool m_subVector;
};

class cTerm_IMU_ConstPointerConstant : public cTerm_IMU_AddressConstant
{
   DECLARE_OBJECT(cTerm_IMU_ConstPointerConstant,cTerm_IMU_AddressConstant);
public:
   cTerm_IMU_ConstPointerConstant(cIdentifier *_id,int _offset);
   virtual ~cTerm_IMU_ConstPointerConstant() {}
   virtual int getConstant();
   virtual bool independent(cTerm *y);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
   virtual bool isValid();
public:
   cIdentifier *m_id;
   int m_offset;
};

class cTerm_IMU_PrivatePointerConstant : public cTerm_IMU_AddressConstant
{
   DECLARE_OBJECT(cTerm_IMU_PrivatePointerConstant,cTerm_IMU_AddressConstant);
public:
   cTerm_IMU_PrivatePointerConstant(cIdentifier *_id,int _offset,bool _subVector);
   virtual ~cTerm_IMU_PrivatePointerConstant() {}
   virtual int getConstant();
   virtual bool independent(cTerm *y);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
   virtual bool isValid();
public:
   cIdentifier *m_id;
   int m_offset;
   bool m_subVector;
};

class cTerm_MU : public cTerm
{
   DECLARE_OBJECT(cTerm_MU,cTerm);
public:
   cTerm_MU();
   ~cTerm_MU();
   int getExtAttr();
   virtual int getAttr();
   virtual int getOffset();
   virtual int getIndex();
   virtual float getConstant();
   virtual int getVectorWidth();
};

class cTerm_MU_Null : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_Null,cTerm_MU);
public:
   cTerm_MU_Null();
   virtual ~cTerm_MU_Null() {}
   virtual int getAttr();
   virtual int getOffset();
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_MU_Constant : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_Constant,cTerm_MU);
public:
   cTerm_MU_Constant(float _c,int _slot=0);
   cTerm_MU_Constant(int _c,int _slot=0);
   virtual ~cTerm_MU_Constant() {}
   virtual int getAttr();
   virtual int getOffset(); 
   virtual float getConstant(); 
   virtual int getVectorWidth();
   virtual bool independent(cTerm *y);
   void setSlot(int _slot);
   virtual void print();
public:
   bool m_float;
   float m_c;
   int m_slot;
};

class cTerm_MU_TID : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_TID,cTerm_MU);
public:
   cTerm_MU_TID();
   virtual ~cTerm_MU_TID() {}
   virtual int getAttr();
   virtual int getOffset();
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_MU_PointerWithoutIndex : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_PointerWithoutIndex,cTerm_MU);
public:
   cTerm_MU_PointerWithoutIndex(cIdentifierPointer *_baseId,int _offset);
   virtual ~cTerm_MU_PointerWithoutIndex() {}
   virtual int getAttr();
   virtual int getOffset();
   virtual int getVectorWidth();
   virtual bool independent(cTerm *y);
   virtual void getDef(cIdentifierVector *lst);
   virtual void getUse(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
public:
   cIdentifierPointer *m_baseId;
   int m_offset;
};

class cTerm_MU_PointerWithIndex : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_PointerWithIndex,cTerm_MU);
public:
   cTerm_MU_PointerWithIndex(cIdentifierPointer *_baseId,cIdentifierInteger *_indexId,int _offset);
   virtual ~cTerm_MU_PointerWithIndex() {}
   virtual int getAttr();
   virtual int getOffset();
   virtual int getIndex();
   virtual int getVectorWidth();
   virtual bool independent(cTerm *y);
   virtual void getDef(cIdentifierVector *lst);
   virtual void getUse(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
public:
   cIdentifierPointer *m_baseId;
   cIdentifierInteger *m_indexId;
   int m_offset;
};

class cTerm_MU_Storage : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_Storage,cTerm_MU);
public:
   cTerm_MU_Storage(cIdentifierStorage *_id,int _offset,bool _subVector=false);
   virtual ~cTerm_MU_Storage() {}
   virtual int getAttr();
   virtual int getOffset();
   virtual int getVectorWidth();
   virtual bool independent(cTerm *y);
   virtual void getDef(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
public:
   cIdentifierStorage *m_id;
   int m_offset;
   bool m_subVector;
};

class cTerm_MU_StorageWithIndex : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_StorageWithIndex,cTerm_MU);
public:
   cTerm_MU_StorageWithIndex(cIdentifierStorage *_id,cIdentifierInteger *_indexId,int _offset,bool _subVector=false);
   virtual ~cTerm_MU_StorageWithIndex() {}
   virtual int getAttr();
   virtual int getOffset();
   virtual int getIndex();
   virtual int getVectorWidth();
   virtual bool independent(cTerm *y);
   virtual void getDef(cIdentifierVector *lst);
   virtual void getUse(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
public:
   cIdentifierStorage *m_id;
   cIdentifierInteger *m_indexId;
   int m_offset;
   bool m_subVector;
};

class cTerm_MU_Result : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_Result,cTerm_MU);
public:
   cTerm_MU_Result();
   virtual ~cTerm_MU_Result() {}
   virtual int getAttr();
   virtual int getOffset();
   void getDef(cIdentifierVector *lst);
   virtual bool independent(cTerm *y);
   virtual void print();
};

class cTerm_MU_Integer : public cTerm_MU
{
   DECLARE_OBJECT(cTerm_MU_Integer,cTerm_MU);
public:
   cTerm_MU_Integer(cIdentifierInteger *_id);
   virtual ~cTerm_MU_Integer() {}
   virtual int getAttr();
   virtual int getOffset();
   virtual int getIndex();
   virtual bool independent(cTerm *y);
   virtual void getDef(cIdentifierVector *lst);
   virtual void updateIdentifier(cIdentifier *_old,cIdentifier *_new);
   virtual void print();
public:
   cIdentifierInteger *m_id;
};

#endif

