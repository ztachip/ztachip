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

#ifndef _IDENT_H_
#define _IDENT_H_

#include "util.h"
#include "object.h"
#include "ast.h"

class cIdentifierVector;
class cGraphColor;
class cIdentifier;
class cIdentifierStack;
class cIdentifierReturnValue;

class cIdentifierVector : public std::vector<cIdentifier *> 
{
public:
   cIdentifierVector();
   virtual ~cIdentifierVector();
   void append(cIdentifier *_id);
   void clone(cIdentifierVector *x);
   void vector_union(cIdentifierVector *x);
   void vector_minus(cIdentifierVector *x);
   bool equal(cIdentifierVector *x);
   bool exist(cIdentifier *x);
   bool exist(cIdentifierVector *v);
   bool isOverlap(cIdentifierVector *x);
};

class cIdentifierShared;
class cIdentifier : public cListItem
{
DECLARE_ROOT_OBJECT(cIdentifier);
public:
   cIdentifier(cAstNode *owner,cAstNode *parent,cAstNode *type);
   virtual ~cIdentifier();
   bool isPointerOverlap(cIdentifier *pointer);
   bool isTemp() {return (m_name.size()==0);}
   int getNumDim() {return m_num_dim;}
   int getDim(int index) {return m_dim[index];}
   int *getDim() {return m_dim;}
   int getDimSize(int index);
   int getOffset() {return m_offset;}
   int getByteOffset() {return m_byteOffset;}
   int getVectorWidth();
   int getLen();
   bool isParameter();
   bool isStack();
   bool isFixed();
   bool isSameContext(cAstNode *func);
   cIdentifier *getAlias();
   cAstNode *getType() {return m_type;}
   void allocate(int offset);
   void setInitializer(cAstNode *init,int level,int *levelIndex);
   static bool isReservedName(char *name);
   char *getPrintName(char *buf);
   static int M_id;
   int m_id;
public:
   static RETCODE Process(cAstNode *_root);
public:
   static cIdentifier *lookupParm(cAstNode *_root,char *funcName,char *parmName);
   static cIdentifierReturnValue *getReturnValue(cAstNode *owner);
   static int getFuncParameterCount(cAstNode *owner);
   static cIdentifier *getFuncParameter(cAstNode *owner,int index);
   static cIdentifierStack *getStackVariable(cAstNode *owner,int pos,int width);
private:
   static cIdentifier *lookup(cAstNode *_root,cAstNode *func,char *name,cAstNode **stack,int stackSize);
   static void assign(cAstNode *_root,cAstNode *func,cAstNode *node,cAstNode **stack,int stackSize);
   static void scan(cAstNode *_func,cAstNode *owner,cAstNode *parent,bool _global);
   static void scanParm(cAstNode *_func,cAstNode *owner,cAstNode *parent);
public:
   std::string m_name;
   std::string m_context;
public:
   cAstNode *m_owner;
   cAstNode *m_type;
   int m_len;
   int m_offset;
   int m_byteOffset;
   int m_num_dim;
   int m_dim[MAX_VAR_DIM];
public:
   int m_interference;
   cGraphColor *m_color;
   int m_defCount;
   int m_useCount;
   std::vector<float> m_init;
public:
   static void Init();
};


class cIdentifierFloat : public cIdentifier
{
DECLARE_OBJECT(cIdentifierFloat,cIdentifier);
public:
   cIdentifierFloat(cAstNode *owner,cAstNode *parent,cAstNode *type);
   virtual ~cIdentifierFloat();
};

class cIdentifierStorage: public cIdentifierFloat
{
DECLARE_OBJECT(cIdentifierStorage,cIdentifierFloat);
public:
   cIdentifierStorage(cAstNode *owner,cAstNode *parent,cAstNode *type,int width);
   virtual ~cIdentifierStorage();
public:
   int m_w;
};

class cIdentifierShared : public cIdentifierStorage
{
DECLARE_OBJECT(cIdentifierShared,cIdentifierStorage);
public:
   cIdentifierShared(cAstNode *owner,cAstNode *parent,cAstNode *type,cIdentifier *alias,int _width);
   virtual ~cIdentifierShared() {}
   cIdentifier *m_alias;
};

class cIdentifierPrivate : public cIdentifierStorage
{
DECLARE_OBJECT(cIdentifierPrivate,cIdentifierStorage);
public:
   cIdentifierPrivate(cAstNode *owner,cAstNode *parent,cAstNode *type,int _width);
   virtual ~cIdentifierPrivate() {}
};

class cIdentifierParameter : public cIdentifierPrivate
{
DECLARE_OBJECT(cIdentifierParameter,cIdentifierPrivate);
public:
   cIdentifierParameter(cAstNode *owner,cAstNode *parent,cAstNode *type,cIdentifier *alias,int _width);
   virtual ~cIdentifierParameter() {}
public:
   cIdentifier *m_alias;
};

class cIdentifierStack : public cIdentifierPrivate
{
DECLARE_OBJECT(cIdentifierStack,cIdentifierPrivate);
public:
   cIdentifierStack(cAstNode *owner,cAstNode *parent,cAstNode *type,int pos,int _width);
   virtual ~cIdentifierStack() {}
   int m_pos;
};

class cIdentifierReturnValue : public cIdentifierPrivate
{
DECLARE_OBJECT(cIdentifierReturnValue,cIdentifierPrivate);
public:
   cIdentifierReturnValue(cAstNode *owner,cAstNode *parent,cAstNode *type,bool _isFloat,int _width);
   virtual ~cIdentifierReturnValue() {}
   bool m_float;
};

class cIdentifierConst : public cIdentifierFloat
{
DECLARE_OBJECT(cIdentifierConst,cIdentifierFloat);
public:
   cIdentifierConst(cAstNode *owner,cAstNode *parent,cAstNode *type);
   virtual ~cIdentifierConst() {}
};

class cIdentifierFixed : public cIdentifier
{
DECLARE_OBJECT(cIdentifierFixed,cIdentifier);
public:
   cIdentifierFixed(cAstNode *owner,cAstNode *parent,cAstNode *type,bool persistent,int persistentIndex);
   virtual ~cIdentifierFixed();
public:
   bool m_persistent;
   int m_persistentIndex;
};

class cIdentifierPointer : public cIdentifierFixed
{
DECLARE_OBJECT(cIdentifierPointer,cIdentifierFixed);
public:
   cIdentifierPointer(cAstNode *owner,cAstNode *parent,cAstNode *type,bool isConst,int _width,bool persistent=false);
   virtual ~cIdentifierPointer() {}
   void getIdentifierScope(cIdentifierVector *lst);
   bool isConst() {return m_isConst;}
private:
   void _getIdentifierScope(cIdentifierVector *lst,cIdentifierVector *dirtyLst);
public:
   cIdentifierVector m_scope;
   bool m_isConst;
   int m_width;
};

class cIdentifierInteger : public cIdentifierFixed
{
DECLARE_OBJECT(cIdentifierInteger,cIdentifierFixed);
public:
   cIdentifierInteger(cAstNode *owner,cAstNode *parent,cAstNode *type,bool isUnsigned,bool persistent,int persistentIndex);
   virtual ~cIdentifierInteger() {}
   bool m_isUnsigned;
   bool m_useForMuIndex; 
};

class cIdentifierResult : public cIdentifierFixed
{
DECLARE_OBJECT(cIdentifierResult,cIdentifierFixed);
public:
   cIdentifierResult();
   static cIdentifierResult M_singleInstance;
};

class cIdentifierLane : public cIdentifierFixed
{
DECLARE_OBJECT(cIdentifierLane,cIdentifierFixed);
public:
   cIdentifierLane();
   static cIdentifierLane M_singleInstance;
};

class cIdentifierExReg : public cIdentifierStorage
{
DECLARE_OBJECT(cIdentifierExReg,cIdentifierStorage);
public:
   cIdentifierExReg(cAstNode *owner,cAstNode *parent,cAstNode *type,int _width,bool _persistent);
   bool m_persistent;
};



#endif
