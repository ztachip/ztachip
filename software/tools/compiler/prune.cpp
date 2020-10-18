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

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <assert.h>
#include <string.h>
#include <assert.h>
#include <stdarg.h>
#include <vector>
#include "zta.h"
#include "ast.h"
#include "util.h"
#include "ident.h"

// Perform calculation on AST tree if possible
bool calc(cAstNode *node,float *result,bool *isFloat)
{
   float result1,result2;
   cAstNode *node1,*node2;
   bool isFloat1,isFloat2;
   node1=(cAstNode *)node->getChildList();
   if(node1)
      node2=(cAstNode *)node->getChildList()->getNext();
   else
      node2=0;
   switch(node->getID())
   {
   case eTOKEN_I_CONSTANT:
      *result=(float)(CAST(cAstIntNode,node)->getIntValue());
      *isFloat=false;
      return true;
   case eTOKEN_F_CONSTANT:
      *result=(float)(CAST(cAstFloatNode,node)->getFloatValue());
      *isFloat=true;
      return true;
   case eTOKEN_unary_expression:
      if(node1->getID()==eTOKEN_unary_operator && strcmp(CAST(cAstStringNode,node1)->getStringValue(),"-")==0)
      {
         if(calc(node2,&result2,&isFloat2))
         {
            *result=-result2;
            *isFloat=isFloat2;
            return true;
         }
         else
            return false;
      }
      else
         return false;
   case eTOKEN_additive_expression_add:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         *result=result1+result2;
         if(isFloat1 || isFloat2)
            *isFloat=true;
         else
            *isFloat=false;
         return true;
      }
      else
         return false;
   case eTOKEN_additive_expression_sub:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         *result=result1-result2;
         if(isFloat1 || isFloat2)
            *isFloat=true;
         else
            *isFloat=false;
         return true;
      }
      else
         return false;
   case eTOKEN_multiplicative_expression_mul:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         *result=result1*result2;
         if(isFloat1 || isFloat2)
            *isFloat=true;
         else
            *isFloat=false;
         return true;
      }
      else
         return false;
   case eTOKEN_multiplicative_expression_div:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         *result=result1/result2;
         if(isFloat1 || isFloat2)
            *isFloat=true;
         else
            *isFloat=false;
         return true;
      }
      else
         return false;
   case eTOKEN_multiplicative_expression_mod:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         if(isFloat1 || isFloat2)
            return false;
         else
         {
            *result=(float)((int)result1%(int)result2);
            *isFloat=false;
            return true;
         }
      }
      else
         return false;
   case eTOKEN_shift_expression_shl:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         if(isFloat1 || isFloat2)
            return false;
         else
         {
            *result=(float)((int)result1<<(int)result2);
            *isFloat=false;
            return true;
         }
      }
      else
         return false;
   case eTOKEN_shift_expression_shr:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         if(isFloat1 || isFloat2)
            return false;
         else
         {
            *result=(float)((int)result1>>(int)result2);
            *isFloat=false;
            return true;
         }
      }
      else
         return false;
   case eTOKEN_inclusive_or_expression:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         if(isFloat1 || isFloat2)
            return false;
         else
         {
            *result=(float)((int)result1 | (int)result2);
            *isFloat=false;
            return true;
         }
      }
      else
         return false;
   case eTOKEN_exclusive_or_expression:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         if(isFloat1 || isFloat2)
            return false;
         else
         {
            *result=(float)((int)result1 ^ (int)result2);
            *isFloat=false;
            return true;
         }
      }
      else
         return false;
   case eTOKEN_and_expression:
      assert(node1 && node2);
      if(calc(node1,&result1,&isFloat1) && calc(node2,&result2,&isFloat2))
      {
         if(isFloat1 || isFloat2)
            return false;
         else
         {
            *result=(float)((int)result1 & (int)result2);
            *isFloat=false;
            return true;
         }
      }
      else
         return false;
   default:
      return false;
   }
}

//----------------------------------------------------------------------
// Determine the size of an item. Item can be an array or variable
// This is called primarily from sizeof.
//----------------------------------------------------------------------
static int calc_sizeof(cAstNode *node)
{
   cIdentifier *attr=0;
   cAstNode *node2,*node3,*tmp;
   int product=1;
   int i;
   int num_dim=0;

   if(node->getID()==eTOKEN_IDENTIFIER)
   {
      attr=CAST(cAstIdentifierNode,node)->getIdentifier();
      num_dim=0;
   }
   else if(node->getID()==eTOKEN_postfix_expression2)
   {
      tmp=node;
      node=(cAstNode *)node->getChildList();
      if(!node)
         error(tmp->m_lineNo,"This C-syntax is not supported by this compiler");
      attr=CAST(cAstIdentifierNode,node)->getIdentifier();
      if(!attr)
         error(node->m_lineNo,"This C-syntax is not supported by this compiler");
      node2=(cAstNode *)node->getNext();
      num_dim=0;
      while(node2)
      {
         if(node2->getID() != eTOKEN_expression)
            error(node2->m_lineNo,"Invalid array index");
         node3=(cAstNode *)node2->getChildList();
         if(!node3)
            error(node2->m_lineNo,"This C-syntax is not supported by this compiler");
         if(node3->getID() != eTOKEN_I_CONSTANT)
            error(node3->m_lineNo,"This C-syntax is not supported by this compiler");
         num_dim++;
         node2=(cAstNode *)node2->getNext();
      }
   }
   else
      error(node->m_lineNo,"This C-syntax is not supported by this compiler");
   if(num_dim > attr->getNumDim())
      error(node->m_lineNo,"This C-syntax is not supported by this compiler");
   product=1;
   for(i=num_dim;i < attr->getNumDim();i++)
      product=product*attr->getDim(i);
   return product;
}

// Pruning the AST tree by compute constant expression
static void prune3(cAstNode *node)
{
   cAstNode *node2,*node3;
   float result;
   bool isFloat;
   node2=(cAstNode *)node->getChildList();
   while(node2)
   {
      if(calc(node2,&result,&isFloat))
      {
         if(!isFloat)
            node3=new cAstIntNode(eTOKEN_I_CONSTANT,(int)result);
         else
            node3=new cAstFloatNode(eTOKEN_F_CONSTANT,result);
         CAST(cAstCompositeNode,node)->setChildList(node3,node2);
         cList::remove(node2);
         node2=node3;
      }
      else
         prune3(node2);
      node2=(cAstNode *)node2->getNext();
   }
}

// Pruning AST tree by collapsing composite node of the same type
static cAstNode *prune2(cAstNode *node)
{
   cAstNode *node2,*childlst;
   node2=(cAstNode *)node->getChildList();
   while(node2)
   {
      childlst=prune2(node2);
      if(node2->isKindOf(cAstCompositeNode::getCLID()) && node2->getID()==node->getID())
      {
         CAST(cAstCompositeNode,node)->setChildrenList(childlst,node2);
         cList::remove(node2);
         node2=childlst;
      }
      else
         node2=(cAstNode *)node2->getNext();
   }
   return (cAstNode *)node->getChildList();
}

// Prune AST tree by collapsing composite node with only a single child.
// With the exceptions of some node tyoe defined in exceptionLst
static cAstNode *prune1(cAstNode *node)
{
   static eTOKEN exceptionLst[]=
   {
   eTOKEN_argument_expression_list,
   eTOKEN_block_item_list,
   eTOKEN_block_item,
   eTOKEN_expression,
   eTOKEN_declarator,
   eTOKEN_init_declarator_list,
   eTOKEN_jump_statement,
   eTOKEN_POINTER_SCOPE,
   eTOKEN_direct_declarator12,
   eTOKEN_parameter_list,
   eTOKEN_initializer_list,
   eTOKEN_initializer,
   (eTOKEN)-1
   };
   cAstNode *node2,*node3;
   int i;
   node2=(cAstNode *)node->getChildList();
   while(node2)
   {
      node3=prune1(node2);
      if(node3 != node2)
      {
         CAST(cAstCompositeNode,node)->setChildrenList(node3,node2);
         cList::remove(node2);
         node2=node3;
      }
      node2=(cAstNode *)node2->getNext();
   }
   if(node->isKindOf(cAstCompositeNode::getCLID()) && node->getChildList() && 
      !node->getChildList()->getNext())
   {
      i=0;
      while(exceptionLst[i] >= 0)
      {
         if(node->getID()==exceptionLst[i])
            break;
         i++;
      }
      if(exceptionLst[i] >= 0)
         return node;
      else
         return (cAstNode *)node->getChildList();
   }
   else
      return node;
}

//---------------------------------------------------------------------------
// Replace sizeof with an integer
//---------------------------------------------------------------------------
static bool prune_sizeof(cAstNode *_root,cAstNode *func,cAstNode *node)
{
   cAstNode *node2;
   cAstNode *newnode;
   cAstNode *parent;
   parent=node;
   node=(cAstNode *)node->getChildList();
   while(node)
   {
      if(node->getID()==eTOKEN_unary_expression && node->getChild(1,eTOKEN_SIZEOF))
      {
         node2=node->getChild(1,eTOKEN_expression);
         if(!node2)
         {
            error(node->m_lineNo,"Unsupported C statement");
            return false;
         }
         node2=(cAstNode *)node2->getChildList();
         newnode=new cAstIntNode(eTOKEN_I_CONSTANT,calc_sizeof(node2));
         CAST(cAstCompositeNode,parent)->setChildList(newnode,node);
         cList::remove(node);
         node=newnode;
      }
      else
      {
         if(!prune_sizeof(_root,func,node))
            return false;
      }
      node=(cAstNode *)node->getNext();
   }
   return true;
}

// Prune the AST tree
void prune(cAstNode *_root,bool full)
{
   cAstNode *node;
   if(full)
      prune1(_root);
   prune3(_root);
   if(full)
      prune2(_root);
   for(node=(cAstNode *)_root->getChildList();node;node=(cAstNode *)node->getNext())
   {
      if(node->getID()==eTOKEN_function_definition2)
         prune_sizeof(_root,node,node);
   }
}
