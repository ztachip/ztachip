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

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <assert.h>
#include <string.h>
#include <assert.h>
#include <stdarg.h>
#include <vector>
#include "../base/zta.h"
#include "ast.h"
#include "ident.h"
#include "instruction.h"
#include "gen.h"

#define MAX_STACK_SIZE  32

// Array of identifiers

static cIdentifierShared *M_SHARE=0;

void cIdentifier::Init()
{
   // This identifier points to the whole memory space
   M_SHARE = new cIdentifierShared(0,0,0,0,0);
   M_SHARE->allocate(0);
   M_SHARE->m_num_dim=1;
   M_SHARE->m_dim[0] = ((1 << REGISTER_FILE_DEPTH));
   M_SHARE->m_len=((1 << REGISTER_FILE_DEPTH));
}

cIdentifierVector::cIdentifierVector() :
std::vector<cIdentifier *>()
{
}

cIdentifierVector::~cIdentifierVector()
{
}

// Append a identifers to the list
void cIdentifierVector::append(cIdentifier *_id)
{
   if(!exist(_id))
      push_back(_id);
}

// Duplicate this list of identifiers
void cIdentifierVector::clone(cIdentifierVector *x)
{
   size_t i;
   clear();
   for(i=0;i < x->size();i++)
      append(x->at(i));
}

// y=y UNION x
void cIdentifierVector::vector_union(cIdentifierVector *x)
{
   size_t i;
   for(i=0;i < x->size();i++)
   {
      if(!exist(x->at(i)))
         append(x->at(i));
   }
}

// y=y MINUS x
void cIdentifierVector::vector_minus(cIdentifierVector *x)
{
   cIdentifierVector temp;
   cIdentifier *ele;
   size_t i;
   for(i=0;i < size();i++)
   {
      ele=at(i);
      if(!x->exist(ele))
         temp.append(at(i));
   }
   clone(&temp);
}

// Check if 2 vectors have overlap elements
bool cIdentifierVector::isOverlap(cIdentifierVector *x)
{
   cIdentifierVector temp;
   cIdentifier *ele;
   size_t i;
   for(i=0;i < size();i++)
   {
      ele=at(i);
      if(x->exist(ele))
         return true;
   }
   return false;
}

// Check of 2 identifier vectors are the same
bool cIdentifierVector::equal(cIdentifierVector *x)
{
   size_t i;
   if(x->size() != size())
      return false;
   for(i=0;i < x->size();i++)
   {
      if(!exist(x->at(i)))
         return false;
   }
   return true;
}

// Check if an identifier is included in this list
bool cIdentifierVector::exist(cIdentifier *x)
{
   size_t i;
   for(i=0;i < size();i++)
   {
      if(at(i)==x)
         return true;
   }
   return false;
}

// Check is any item in one list is included in another list
bool cIdentifierVector::exist(cIdentifierVector *v)
{
   int i;
   for(i=0;i < (int)v->size();i++)
   {
      if(exist(v->at(i)))
         return true;
   }
   return false;
}

// Base class for all identifiers

int cIdentifier::M_id=0;

INSTANTIATE_OBJECT(cIdentifier);
cIdentifier::cIdentifier(cAstNode *owner,cAstNode *parent,cAstNode *type)
{
   cAstNode *node;

   m_id=M_id++;
   m_type=type;
   m_offset=-1;
   m_byteOffset=-1;
   m_num_dim=0;
   m_interference=0;
   m_color=0;
   m_defCount=0;
   m_useCount=0;
   m_owner=owner;
   if(!parent)
   {
      // This is a temporary variable
      m_num_dim=0;
      m_len=1;
      m_name.clear(); 
      m_context.clear();
   }
   else
   {
      // This is a declared variable
      node=(cAstNode *)parent->getChild(1,eTOKEN_direct_declarator11);
      if(node)
      {
         // Array
         node=(cAstNode *)node->getChildList();
         if(node->getID()!=eTOKEN_IDENTIFIER)
            error(node->m_lineNo,"Invalid variable declaration");
         else
         {
            if(ParseName(CAST(cAstStringNode,node)->getStringValue(),&m_name,&m_context))
               error(parent->m_lineNo,"Invalid variable name");
               
            m_len=1;
            CAST(cAstIdentifierNode,node)->setIdentifier(this);
            node=(cAstNode *)node->getNext();
            while(node)
            {
               if(m_num_dim >= MAX_VAR_DIM)
                  error(parent->m_lineNo,"Exceed max array dimension allowed");
               if(!node->isKindOf(cAstIntNode::getCLID()))
                  error(parent->m_lineNo,"Invalid array definition");
               m_len *= CAST(cAstIntNode,node)->getIntValue();
               m_dim[m_num_dim]=CAST(cAstIntNode,node)->getIntValue();
               if(m_dim[m_num_dim] <= 0)
                  error(parent->m_lineNo,"Invalid array definition");
               m_num_dim++;
               node=(cAstNode *)node->getNext();
            }
         }
      }
      else
      {
         node=(cAstNode *)parent->getChild(1,eTOKEN_IDENTIFIER);
         assert(node!=0);
         // Scalar
         m_num_dim=0;
         m_len=1;     
         if(ParseName(CAST(cAstStringNode,node)->getStringValue(),&m_name,&m_context))
            error(parent->m_lineNo,"Invalid variable name");
      }
   }
   if(owner)
   {
      if(cIdentifier::isReservedName((char *)m_name.c_str()))
         error(parent->m_lineNo,"Variable name is a reserved name");
      if(!CAST(cAstCodeBlockNode,owner)->setIdentifierList(this))
         error(parent->m_lineNo,"Variable already defined");
   }
}


cIdentifier::~cIdentifier()
{
}

// Return if there is an alias identifier associated

cIdentifier *cIdentifier::getAlias()
{
   if(isKindOf(cIdentifierParameter::getCLID()))
      return CAST(cIdentifierParameter,this)->m_alias;
   else if(isKindOf(cIdentifierShared::getCLID()))
      return CAST(cIdentifierShared,this)->m_alias;
   else
      return 0;
}

// Return if this identifier is associated with parameter list

bool cIdentifier::isParameter() 
{
   return isKindOf(cIdentifierParameter::getCLID()) || 
         isKindOf(cIdentifierShared::getCLID()) || 
         (isKindOf(cIdentifierFixed::getCLID()) && CAST(cIdentifierFixed,this)->m_persistentIndex >= 0) ||
         isKindOf(cIdentifierReturnValue::getCLID());
}

// Return if this identifier is a stack variable

bool cIdentifier::isStack()
{
   return isKindOf(cIdentifierStack::getCLID());
}

// Check if this identifier is persistent and fixed in allocation
bool cIdentifier::isFixed() 
{
   if(isParameter())
      return true;
   if(isStack())
      return true;
   if(isKindOf(cIdentifierFixed::getCLID()) && CAST(cIdentifierFixed,this)->m_persistent)
      return true;
   if(isKindOf(cIdentifierExReg::getCLID()) && CAST(cIdentifierExReg,this)->m_persistent)
      return true;
   return false; 
}


// Is the name reserved name?

bool cIdentifier::isReservedName(char *name)
{
   int oc;
   if(!name)
      return false;
   if(strcasecmp(name,"tid")==0 || 
      strcasecmp(name,"pid")==0 ||
      strcasecmp(name,"_VMASK")==0)
      return true;
   if(cConfig::decode_mu_oc(name,&oc))
      return true;
   return false;
}

bool cIdentifier::isSameContext(cAstNode *func)
{
   cAstNode *node3;
   char *funcName;
   node3=func->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_IDENTIFIER);
   if(!node3)
      node3=func->getChild(2,eTOKEN_declarator,eTOKEN_IDENTIFIER);
   assert(node3!=0);
   funcName=CAST(cAstIdentifierNode,node3)->getStringValue();
   if(m_context.length()==0 || 
      (memcmp(m_context.c_str(),funcName,m_context.length())==0 && memcmp(&funcName[m_context.length()],"::",2)==0) ||
      (!strstr(funcName,"::") &&  memcmp(m_context.c_str(),funcName,m_context.length())==0))
      return true;
   else
      return false;
}

// Return number of parameters defined in a function parameter list
int cIdentifier::getFuncParameterCount(cAstNode *owner)
{
   cIdentifier *id;
   int count=0;
   id=CAST(cAstCodeBlockNode,owner)->getIdentifierList();
   while(id)
   {
      if(id->isKindOf(cIdentifierParameter::getCLID()) ||
         id->isKindOf(cIdentifierShared::getCLID()))
      {
         count++;
      }
      id=(cIdentifier *)id->getNext();
   }
   return count;
}

// Return identifier associated with a function parameter
cIdentifier *cIdentifier::getFuncParameter(cAstNode *owner,int index)
{
   cIdentifier *id;
   int count=0;
   id=CAST(cAstCodeBlockNode,owner)->getIdentifierList();
   while(id)
   {
      if(id->isKindOf(cIdentifierParameter::getCLID()) ||
         id->isKindOf(cIdentifierShared::getCLID()))
      {
         if(count==index)
            return id;
         count++;
      }
      id=(cIdentifier *)id->getNext();
   }
   return 0;
}

// Return return value parameter variable associated with a function
cIdentifierReturnValue *cIdentifier::getReturnValue(cAstNode *owner)
{
   cIdentifier *id;
   id=CAST(cAstCodeBlockNode,owner)->getIdentifierList();
   while(id)
   {
      if(id->isKindOf(cIdentifierReturnValue::getCLID()))
      {
         return CAST(cIdentifierReturnValue,id);
      }
      id=(cIdentifier *)id->getNext();
   }
   // Allocate new stack variable
   return 0;
}

// Return stack variable. Allocate if doesnot exist yet
cIdentifierStack *cIdentifier::getStackVariable(cAstNode *owner,int pos,int width)
{
   cIdentifier *id;
   id=CAST(cAstCodeBlockNode,owner)->getIdentifierList();
   while(id)
   {
      if(id->isStack())
      {
         if(CAST(cIdentifierStack,id)->m_pos==pos &&
            CAST(cIdentifierStack,id)->m_w==width)
            return CAST(cIdentifierStack,id); // Already defined...
      }
      id=(cIdentifier *)id->getNext();
   }
   // Allocate new stack variable
   return new cIdentifierStack(owner,0,0,pos,width);
}

// Extract initialization values declared with identifier declaration
void cIdentifier::setInitializer(cAstNode *init,int level,int *levelIndex)
{
   int index;
   int i;
   int vw;
   int num_dim;
   cAstNode *node;
   cAstNode *node2;
   assert(init==0 || init->getID()==eTOKEN_initializer);
   if(!init)
      return;
   node2=init->getChildList();

   num_dim=m_num_dim;
   if(isKindOf(cIdentifierStorage::getCLID()))
      vw=CAST(cIdentifierStorage,this)->m_w;
   else
      vw=-1;
   if(vw > 0)
      num_dim++;
   if(level > num_dim)
      error(init->m_lineNo,"Array too deep");
   if(node2->getID()==eTOKEN_initializer_list)
   {
      // Go to next nested level
      node=init->getChildList()->getChildList();
      index=0;
      while(node)
      {
         levelIndex[level]=index++;
         setInitializer(node,level+1,levelIndex);
         node=(cAstNode *)node->getNext();
      }
      if(level < m_num_dim && index != m_dim[level])
         error(init->m_lineNo,"Invalid array initialization");
      if(level >= m_num_dim && index != (1<<vw))
         error(init->m_lineNo,"Invalid array initialization");
   }
   else if(node2->getID()==eTOKEN_I_CONSTANT)
   {
      // Initializer is an integer
      if(level != num_dim)
         error(node2->m_lineNo,"Invalid array initialization");
//      printf("\n-->INT(%d)> %d >",level,CAST(cAstIntNode,node2)->getIntValue());
//      for(i=0;i < level;i++)
//         printf(" %d",levelIndex[i]);
//      printf("\n");
      m_init.push_back((float)CAST(cAstIntNode,node2)->getIntValue());
   }
   else if(node2->getID()==eTOKEN_F_CONSTANT)
   {
      // Initializer is a float
      if(level != num_dim)
         error(node2->m_lineNo,"Invalid array initialization");
      printf("\n-->FLOAT(%d)> %d \n",level,(int)CAST(cAstFloatNode,node2)->getFloatValue());
      for(i=0;i < level;i++)
         printf(" %d",levelIndex[i]);
      printf("\n");
      m_init.push_back((float)CAST(cAstFloatNode,node2)->getFloatValue());
   }
   else
   {
      error(node2->m_lineNo,"Invalid or unsupported variable auto-initialization");
   }
}

// Assign a space allocation for an identifier
void cIdentifier::allocate(int offset)
{
   m_offset=offset;
   m_byteOffset=offset;
   if(isKindOf(cIdentifierStorage::getCLID()))
   {
      if((m_offset & ((1<<CAST(cIdentifierStorage,this)->m_w)-1)))
         error(0,"Invalid address");
      m_byteOffset=m_offset;
      m_offset = m_offset/(1<<CAST(cIdentifierStorage,this)->m_w);
   }
}

int cIdentifier::getLen()
{
   if(isKindOf(cIdentifierStorage::getCLID()))
   {
      // This is a vector storage
      return m_len * (1<<CAST(cIdentifierStorage,this)->m_w);
   }
   else
      return m_len;
}

int cIdentifier::getVectorWidth()
{
   if(isKindOf(cIdentifierStorage::getCLID()))
      return CAST(cIdentifierStorage,this)->m_w;
   else
      return 0;
}

// Get a size for a array dimension
int cIdentifier::getDimSize(int index)
{
   int size=1;
   int i;
   assert(index < m_num_dim);
   for(i=index+1;i < m_num_dim;i++)
      size = size*m_dim[i];
//   if(isKindOf(cIdentifierStorage::getCLID()))
//      size = size*(1<<CAST(cIdentifierStorage,this)->m_w);
   return size;
} 

char *cIdentifier::getPrintName(char *buf)
{
   if(m_name.size()>0)
   {
      sprintf(buf,"%s@%d",m_name.c_str(),m_byteOffset);
      return buf;
   }
   else
   {
      if(isKindOf(cIdentifierExReg::getCLID()))
         sprintf(buf,"TD%d@%d",m_id,m_byteOffset);
      else
         sprintf(buf,"TS%d@%d",m_id,m_byteOffset);
      return buf;
   }
}

// Based class for floating point identifier
INSTANTIATE_OBJECT(cIdentifierFloat);
cIdentifierFloat::cIdentifierFloat(cAstNode *owner,cAstNode *parent,cAstNode *type)
   : cIdentifier(owner,parent,type)
{
}

cIdentifierFloat::~cIdentifierFloat()
{
}

// Based class for storage identifier
INSTANTIATE_OBJECT(cIdentifierStorage);
cIdentifierStorage::cIdentifierStorage(cAstNode *owner,cAstNode *parent,cAstNode *type,int _width)
   : cIdentifierFloat(owner,parent,type)
{
   m_w=_width;
}

cIdentifierStorage::~cIdentifierStorage()
{
}

// Floating point identifier in shared space
INSTANTIATE_OBJECT(cIdentifierShared);
cIdentifierShared::cIdentifierShared(cAstNode *owner,cAstNode *parent,cAstNode *type,cIdentifier *alias,int _width) :
   cIdentifierStorage(owner,parent,type,_width)
{
   m_alias=alias;
}

// Floating point identifier in private space
INSTANTIATE_OBJECT(cIdentifierPrivate);
cIdentifierPrivate::cIdentifierPrivate(cAstNode *owner,cAstNode *parent,cAstNode *type,int _width) :
   cIdentifierStorage(owner,parent,type,_width)
{
}

   // Floating point identifier in parameter variable
INSTANTIATE_OBJECT(cIdentifierParameter);
cIdentifierParameter::cIdentifierParameter(cAstNode *owner,cAstNode *parent,cAstNode *type,cIdentifier *alias,int _width) :
   cIdentifierPrivate(owner,parent,type,_width)
{
   m_alias=alias;
}

// Floating point identifier for a stack variable
INSTANTIATE_OBJECT(cIdentifierStack);
cIdentifierStack::cIdentifierStack(cAstNode *owner,cAstNode *parent,cAstNode *type,int pos,int _width) :
   cIdentifierPrivate(owner,parent,type,_width)
{
   m_pos=pos;
}

// Floating point identifier for a function return value
INSTANTIATE_OBJECT(cIdentifierReturnValue);
cIdentifierReturnValue::cIdentifierReturnValue(cAstNode *owner,cAstNode *parent,cAstNode *type,bool _isFloat,int _width) :
   cIdentifierPrivate(owner,parent,type,_width)
{
   m_float=_isFloat;
}


// Floating point identifier in constant space
INSTANTIATE_OBJECT(cIdentifierConst);
cIdentifierConst::cIdentifierConst(cAstNode *owner,cAstNode *parent,cAstNode *type) :
   cIdentifierFloat(owner,parent,type)
{
}

// Based class for integer identifier
INSTANTIATE_OBJECT(cIdentifierFixed);
cIdentifierFixed::cIdentifierFixed(cAstNode *owner,cAstNode *parent,cAstNode *type,bool persistent,int persistentIndex) :
   cIdentifier(owner,parent,type)
{
   if(m_num_dim > 0)
      error(parent->m_lineNo,"Array is not allowed for this variable type");
   m_persistent=persistent;
   m_persistentIndex=persistentIndex;
}

cIdentifierFixed::~cIdentifierFixed()
{
}

// Identifier for pointer variable
INSTANTIATE_OBJECT(cIdentifierPointer);
cIdentifierPointer::cIdentifierPointer(cAstNode *owner,cAstNode *parent,cAstNode *type,bool isConst,int _width,bool persistent) :
   cIdentifierFixed(owner,parent,type,persistent,-1)
{
   m_isConst=isConst;
   m_width=_width;
}

// Return list of variables that are referenced by this pointer
void cIdentifierPointer::getIdentifierScope(cIdentifierVector *lst)
{
    cIdentifierVector dirtyLst;
    _getIdentifierScope(lst,&dirtyLst);
}

// Return list of variables that are referenced by this pointer
// Do it recursively for pointer alias...
void cIdentifierPointer::_getIdentifierScope(cIdentifierVector *lst,cIdentifierVector *dirtyLst)
{
   int i;
   for(i=0;i < (int)m_scope.size();i++)
   {
      if(m_scope[i]->isKindOf(cIdentifierPointer::getCLID()))
      {
         if(!dirtyLst->exist(m_scope[i]))
         {
            dirtyLst->append(m_scope[i]);
            CAST(cIdentifierPointer,m_scope[i])->_getIdentifierScope(lst,dirtyLst);
         }
      }
      else
      {
         if(!lst->exist(m_scope[i]))
            lst->append(m_scope[i]);
      }
   }
}

// Based class for integer valued variables 
INSTANTIATE_OBJECT(cIdentifierInteger);
cIdentifierInteger::cIdentifierInteger(cAstNode *owner,cAstNode *parent,cAstNode *type,bool isUnsigned,bool persistent,int persistentIndex) :
   cIdentifierFixed(owner,parent,type,persistent,persistentIndex)
{
   m_isUnsigned=isUnsigned;
   m_useForMuIndex=false;
}

// Check if this variable can be referenced the same variables referenced by a pointer
bool cIdentifier::isPointerOverlap(cIdentifier *pointer)
{
   assert(pointer->isKindOf(cIdentifierPointer::getCLID()));
   if(CAST(cIdentifierPointer,pointer)->m_scope.size() <= 0)
      error(pointer->m_type->m_lineNo,"Pointer is never initialized");
   if(isKindOf(cIdentifierPointer::getCLID()))
   {
      // If both are pointers then check if their scopes (list of referenced variables) are overlapped.
      assert(CAST(cIdentifierPointer,this)->m_scope.size() > 0);
      cIdentifierVector lst1,lst2;
      CAST(cIdentifierPointer,pointer)->getIdentifierScope(&lst1);
      CAST(cIdentifierPointer,this)->getIdentifierScope(&lst2);
      return lst1.isOverlap(&lst2);
   }
   else if(isKindOf(cIdentifierPrivate::getCLID()) || isKindOf(cIdentifierShared::getCLID()))
   {
      // Is the variable included in the pointer scope
      cIdentifierVector lst1;
      CAST(cIdentifierPointer,pointer)->getIdentifierScope(&lst1);
      return lst1.exist(this);
   }
   else
      return false;
}


// Identifier for RESULT variable (integer values returned by MU operation)
cIdentifierResult cIdentifierResult::M_singleInstance;
INSTANTIATE_OBJECT(cIdentifierResult);

cIdentifierResult::cIdentifierResult() :
   cIdentifierFixed(0,0,0,false,-1)
{
}

// Identifier for xregister variable (extended register)
INSTANTIATE_OBJECT(cIdentifierExReg);

cIdentifierExReg::cIdentifierExReg(cAstNode *owner,cAstNode *parent,cAstNode *type,int _width,bool _persistent) :
   cIdentifierStorage(owner,parent,type,_width)
{
   m_persistent=_persistent;
}

 // Identifier for LANE control register
cIdentifierLane cIdentifierLane::M_singleInstance;
INSTANTIATE_OBJECT(cIdentifierLane);

cIdentifierLane::cIdentifierLane() :
   cIdentifierFixed(0,0,0,false,-1)
{
}

// Find parameter given the function name and parameter name
cIdentifier *cIdentifier::lookupParm(cAstNode *_root,char *funcName,char *parmName)
{
   cIdentifier *attr;
   cAstNode *node,*node2,*node3,*func=0;
   char *name;

   if(strlen(funcName)>2 && strcmp(&funcName[strlen(funcName)-2],"::")==0)
   {
      // Only context is given
      char context[MAX_STRING_LEN];
      strcpy(context,funcName);
      context[strlen(context)-2]=0;
      
      // Find it in global variable list
      attr=CAST(cAstCodeBlockNode,_root)->getIdentifierList();
      while(attr)
      {
         if(strcmp(attr->m_name.c_str(),parmName)==0 && strcmp(attr->m_context.c_str(),context)==0)
            return attr;
         attr=(cIdentifier *)attr->getNext();
      }
      return 0;
   }
   if(strcasecmp(funcName,"root")==0)
   {
      if (strcasecmp(parmName, "constant")==0)
      {
         // This is special keyword to point to whole shared memory
         return M_SHARE;
      }
      else
         return 0;
   }
   node=(cAstNode *)_root->getChildList();
   while(node)
   {
      if(node->getID()==eTOKEN_function_definition2)
      {
         node3=node->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_IDENTIFIER);
         if(!node3)
            node3=node->getChild(2,eTOKEN_declarator,eTOKEN_IDENTIFIER);
         assert(node3!=0);
         if(strcmp(CAST(cAstIdentifierNode,node3)->getStringValue(),funcName)==0)
         {
            // This is a function...
            func=node;
            node2=node->getChild(1,eTOKEN_block_item_list);
            attr=CAST(cAstCodeBlockNode,node2)->getIdentifierList();
            while(attr)
            {
               if (attr->m_name.size()>0)
                  name = (char *)attr->m_name.c_str();
               else if (attr->isKindOf(cIdentifierParameter::getCLID()))
                  name = (char *)(CAST(cIdentifierParameter, attr)->m_alias->m_name.c_str());
               else if (attr->isKindOf(cIdentifierShared::getCLID()))
                  name = (char *)(CAST(cIdentifierShared, attr)->m_alias->m_name.c_str());
               else
                  name = 0;
               if(attr->isParameter() && name && strcmp(name,parmName)==0)
                  return attr;
               attr=(cIdentifier *)attr->getNext();
            }
            break;
         }
      }
      node=(cAstNode *)node->getNext();
   }
   if(!func)
      return 0;

   // Find it in global variable list
   attr=CAST(cAstCodeBlockNode,_root)->getIdentifierList();
   while(attr)
   {
      if(attr->m_name.size()>0 && strcmp(attr->m_name.c_str(),parmName)==0 && attr->isSameContext(func))
         return attr;
      attr=(cIdentifier *)attr->getNext();
   }
   return 0;
}

// Locate a variable from its definition list
// Variable declaration may be nested and multi-level. Search
// from the bottom level first

cIdentifier *cIdentifier::lookup(cAstNode *_root,cAstNode *func,char *name,cAstNode **stack,int stackSize)
{
   cIdentifier *item;
   cAstNode *node;
   int i;
   // Find it in local variable first

   assert(func!=0 && (func->getID()==eTOKEN_function_definition2));

   for(i=stackSize-1;i >= 0;i--)
   {
      node=stack[i];
      item=CAST(cAstCodeBlockNode,node)->getIdentifierList();
      while(item)
      {
         if(item->m_owner==stack[i] && item->m_name.size()>0 && strcmp(item->m_name.c_str(),name)==0)
            return item;
         item=(cIdentifier *)item->getNext();
      }
   }

   // Find it in global variable list
   item=CAST(cAstCodeBlockNode,_root)->getIdentifierList();
   while(item)
   {
      if(item->m_name.size()>0 && strcmp(item->m_name.c_str(),name)==0 && item->isSameContext(func))
         return item;
      item=(cIdentifier *)item->getNext();
   }
   return 0;
}

// Assign cIndentifier to each occurence of the IDENTIFIER in the AST tree.

void cIdentifier::assign(cAstNode *_root,cAstNode *func,cAstNode *node,cAstNode **stack,int stackSize)
{
   cAstNode *node2;
   cIdentifier *id;
   if(node->getID()==eTOKEN_block_item_list)
   {
      node->setCodeBlock((stackSize>0)?stack[stackSize-1]:0);
      assert(stackSize < MAX_STACK_SIZE);
      stack[stackSize++]=node;
   }
   node2=(cAstNode *)node->getChildList();
   while(node2)
   {
      node2->setCodeBlock(stack[stackSize-1]);
      if(node2->getID()==eTOKEN_IDENTIFIER)
      {
         id=cIdentifier::lookup(_root,func,CAST(cAstStringNode,node2)->getStringValue(),stack,stackSize);
         if(!id)
         {
            if(!cIdentifier::isReservedName(CAST(cAstStringNode,node2)->getStringValue()))
            {
               if(node->getID()!=eTOKEN_postfix_expression4)
                  error(node->m_lineNo,"Undefined variable");
            }
         }
         CAST(cAstIdentifierNode,node2)->setIdentifier(id);
      }
      else
         cIdentifier::assign(_root,func,node2,stack,stackSize);
      node2=(cAstNode *)node2->getNext();
   }
}

// Create a cIdentifier for each variable declarations
// The created cIdentifier class is then attached to the eAST_NodeTypeCodeBlock node where the variable is 
// defined

// Scan the AST tree for variable declarations inorder to create the variable definitions

void cIdentifier::scan(cAstNode *_func,cAstNode *owner,cAstNode *parent,bool _global)
{
   cAstNode *node,*node2,*node3,*node4,*node5;
   cAstNode *init;
   cIdentifier *id=0;
   int levelIndex[MAX_VAR_DIM+1];

   if(parent->getID()==eTOKEN_block_item_list)
   {
      node=(cAstNode *)parent->getChildList();
      while(node)
      {
         cIdentifier::scan(_func,owner,node,_global);
         node=(cAstNode *)node->getNext();
      }
      return;
   }
   node=(cAstNode *)parent->getChildList();
   while(node)
   {
      if(node->getID()==eTOKEN_block_item_list)
      {
         cIdentifier::scan(_func,node,node,_global);
      }
      else if(node->getID()==eTOKEN_declaration)
      {
         // Got a declaration
         node2=node->getChild(1,eTOKEN_init_declarator_list);
         if(!node2)
            error(node->m_lineNo,"Invalid variable declaration");
         // List of variables
         node3=(cAstNode *)node2->getChildList();
         while(node3)
         {
            if(node3->getID()==eTOKEN_init_declarator)
            {
               node5=node3->getChildList();
               init=(cAstNode *)node5->getNext(); 
               assert(init->getID()==eTOKEN_initializer);
            }
            else
            {
               node5=node3;
               init=0;
            }
            assert(node5->getID()==eTOKEN_declarator);
            if(node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_SHARE))
            {
               if(!_global)
                  error(node->m_lineNo,"Share variable is only available for global variable");
               if((node4=node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_FLOAT))) 
               {
                  id=new cIdentifierShared(owner,node5,node4,0,CAST(cAstTokenNode,node4)->m_tokenParm);
               }
               else
                  error(node->m_lineNo,"Only float are supported for global variables");
            }
            else if(node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_STATIC))
            {
               error(node->m_lineNo,"Static variable not supported");
            }
            else if(node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_UNSIGNED))
            {
               if((node4=node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_INT)))
                  id=new cIdentifierInteger(owner,node5,node4,true,_global,-1);
               else
                  error(node->m_lineNo,"Static variable not supported");
            }
            else if(node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_CONST))
            {
                  error(node->m_lineNo,"Constant variables not supported");
            }
            else if((node4=node->getChild(1,eTOKEN_POINTER_SCOPE)))
            {
               assert(0);
//               id=new cIdentifierPointer(owner,node5,node4,false);
            }
            else if((node4=node->getChild(1,eTOKEN_INT)))
               id=new cIdentifierInteger(owner,node5,node4,false,_global,-1);
            else if((node4=node->getChild(1,eTOKEN_FLOAT)))
            {
               if(node5->getChild(1,eTOKEN_pointer))
                  id=new cIdentifierPointer(owner,node5,node4,false,CAST(cAstTokenNode,node4)->m_tokenParm,_global);
               else
               {
                  if(_global)
                     id=new cIdentifierParameter(owner,node5,node4,0,CAST(cAstTokenNode,node4)->m_tokenParm);
                  else
                     id=new cIdentifierPrivate(owner,node5,node4,CAST(cAstTokenNode,node4)->m_tokenParm);
               }
            }
            else if((node4=node->getChild(1,eTOKEN_DOUBLE)))
            {
               if(node5->getChild(1,eTOKEN_pointer))
               {
                  error(node->m_lineNo,"Pointer to double not supported");
               }
               else
               {
                  if(_global)
                     id=new cIdentifierExReg(owner,node5,node4,VECTOR_DEPTH,_global);
                  else
                     id=new cIdentifierExReg(owner,node5,node4,VECTOR_DEPTH,_global);
               }
            }
            else
               error(node->m_lineNo,"Unsupported variable type");
            assert(id!=0);
            id->setInitializer(init,0,levelIndex);
            node3=(cAstNode *)node3->getNext();
         }
      }
      node=(cAstNode *)node->getNext();
   }
}


// Scan for variable definitions in the function parameter list
// Note that if function variable is an integer, then we will need a shadow
// copy in the private/public space. This is required for MCORE to be able
// to read/write integer variables

void cIdentifier::scanParm(
                     cAstNode *func,
                     cAstNode *owner, // eTOKEN_function_definition2
                     cAstNode *parent // eTOKEN_parameter_list
)
{
   cAstNode *node,*node2,*node3;
   cIdentifier *id;
   int pos=0;
   int intParmIndex=0;
   int returnWidth=0;
   bool gotReturnValFloat=false;
   bool gotReturnValInt=false;
   node=(cAstNode *)parent->getChildList();
   
   if(func->getID()==eTOKEN_function_definition2)
   {
      node3=func->getChildList();
      assert(node3!=0);
      if(node3->getID()==eTOKEN_declaration_specifiers)
         node3=(cAstNode *)node3->getChildList()->getNext();
      if(node3->getID() == eTOKEN_FLOAT)
      {
         gotReturnValFloat=true;
         returnWidth=CAST(cAstTokenNode,node3)->m_tokenParm;
      }
      else if(node3->getID() == eTOKEN_INT)
      {
         gotReturnValInt=true;
         returnWidth=0;
      }
      else if(node3->getID() != eTOKEN_VOID)
      {
         error(func->m_lineNo,"Invalid return value for function");
      }
      if(func->getChild(2,eTOKEN_declarator,eTOKEN_pointer))
         error(func->m_lineNo,"Invalid function return value");
   }
   while(node)
   {
      if(node->getID()==eTOKEN_parameter_declaration)
      {
         node2=node->getChild(1,eTOKEN_declarator);
         if(!node2)
            error(node->m_lineNo,"This C-syntax is not supported by this compiler");
         if((node3=node->getChild(1,eTOKEN_INT)))
         {
            if(node2->getChild(1,eTOKEN_direct_declarator11))
               error(node->m_lineNo,"Integer parameter must be scalar");
//            id=new cIdentifierInteger(owner,node2,node3,false,true,intParmIndex++);
            id=new cIdentifierInteger(owner,node2,node3,false,false,-1);
            new cIdentifierParameter(owner,0,node3,id,0);
         }
         else if((node3=node->getChild(1,eTOKEN_FLOAT)))
         {
            if(node2->getChild(1,eTOKEN_pointer))
            {
               if(node2->getChild(1,eTOKEN_direct_declarator11))
                  error(node->m_lineNo,"Pointer parameter must be scalar");
               id=new cIdentifierPointer(owner,node2,node3,false,CAST(cAstTokenNode,node3)->m_tokenParm);
               new cIdentifierParameter(owner,0,node3,id,0);
            }
            else
               id=new cIdentifierParameter(owner,node2,node3,0,CAST(cAstTokenNode,node3)->m_tokenParm);
         }
#if 0
         // Not allowed shared variable in parameter list...
         else if(node3=node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_FLOAT))
         {
            if(node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_SHARE))
            {
               id=new cIdentifierShared(owner,node2,node3,0,CAST(cAstTokenNode,node3)->m_tokenParm);
            }
            else
               error(node->m_lineNo,"Invalid specifier");
         }
#endif
         else if((node3=node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_INT)))
         {
#if 0
            // Not allowed shared variable in parameter list...
            if(node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_SHARE))
            {
               if(node2->getChild(1,eTOKEN_direct_declarator11))
                  error(node->m_lineNo,"Integer parameter must be scalar");
//               id=new cIdentifierInteger(owner,node2,node3,false,true,intParmIndex++);
               id=new cIdentifierInteger(owner,node2,node3,false,false,-1);
               new cIdentifierShared(owner,0,node3,id,0);
            }
            else
#endif 
            if(node->getChild(2,eTOKEN_declaration_specifiers,eTOKEN_GLOBAL))
            {
               if(node2->getChild(1,eTOKEN_direct_declarator11))
                  error(node->m_lineNo,"Integer parameter must be scalar");
               id=new cIdentifierInteger(owner,node2,node3,false,true,intParmIndex++);
            }
            else
               error(node->m_lineNo,"Invalid specifier");
         }
         else
            error(node->m_lineNo,"Unsupported variable type");
         pos++;
      }
      node=(cAstNode *)node->getNext();
   }
   if(gotReturnValFloat)
   {
      new cIdentifierReturnValue(owner,0,0,true,returnWidth);
   }
   else if(gotReturnValInt)
   {
      new cIdentifierReturnValue(owner,0,0,false,returnWidth);
   }
}

// Perform variable processing tasks (scan/allocate) by walking the AST 

int cIdentifier::Process(cAstNode *_root)
{
   cIdentifier *attr;
   cAstNode *node,*node2;
   cAstNode *stack[MAX_STACK_SIZE];

   // Scan for global variables
   cIdentifier::scan(0,_root,_root,true);
   attr=CAST(cAstCodeBlockNode,_root)->getIdentifierList();
//   if(attr)
//      error(-1,"Global variables not allowed");
   while(attr)
   {
#if 0
      // All global variables must be shared. No integer allowed
      if(!attr->isKindOf(cIdentifierConst::getCLID()))
         error(attr->m_type->m_lineNo,"Global variables must be constant types");
      if(attr->m_init.size()==0)
         error(attr->m_type->m_lineNo,"Constant variables must have initialized values");
#endif
#if 0
      if(attr->isKindOf(cIdentifierPrivate::getCLID()))
         error(_root->m_lineNo,"Private variables cannot be global");
      else if(attr->isKindOf(cIdentifierInteger::getCLID()) || attr->isKindOf(cIdentifierPointer::getCLID()))
         error(_root->m_lineNo,"Integer type is not allowed for global variables");
#endif
      attr=(cIdentifier *)attr->getNext();
   }
   // Allocate space for global variables
   // Scan all private variables
   node=(cAstNode *)_root->getChildList();
   while(node)
   {
      if(node->getID()==eTOKEN_function_definition2)
      {
         node2=node->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_parameter_list);
         if(!node2)
            node2=node->getChild(2,eTOKEN_declarator,eTOKEN_direct_declarator12);
         if(node2)
         {
            cIdentifier::scanParm(node,node->getChild(1,eTOKEN_block_item_list),node2);
         }
//         else
//            error(node->m_lineNo,"Invalid function definition. No parameters defined");
         node2=node->getChild(1,eTOKEN_block_item_list);
         if(node2)
         {
            cIdentifier::scan(node,node->getChild(1,eTOKEN_block_item_list),node2,false);
         }
         cIdentifier::assign(_root,node,node2,stack,0);
      }
      node=(cAstNode *)node->getNext();
   }
   return 0;
}
