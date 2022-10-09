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
#include "class.h"

std::vector<cClass *> cClass::M_list;

cClass::cClass(char *_name,int _maxThreads)
{
   m_name=_name;
   m_maxThreads=_maxThreads;
}

cClass::~cClass()
{
}

int cClass::scan(cAstNode *_root)
{
   // Class is now self-declared.
#if 0
   cAstNode *node,*node2;
   char *className;
   int nthreads=16;

   if(_root->getID()==eTOKEN_block_item_list)
   {
      node=(cAstNode *)_root->getChildList();
      while(node)
      {
         cClass::scan(node);
         node=(cAstNode *)node->getNext();
      }
      return 0;
   }
   node=(cAstNode *)_root->getChildList();
   while(node)
   {
      if(node->getID()==eTOKEN_class_declaration)
      {
         node2=node->getChildList();
         if(!node2)
            error(node->m_lineNo,"Invalid class declaration");
         switch(node2->getID())
         {
            case eTOKEN_NT1:
               nthreads=1;
               break;
            case eTOKEN_NT2:
               nthreads=2;
               break;
            case eTOKEN_NT4:
               nthreads=4;
               break;
            case eTOKEN_NT8:
               nthreads=8;
               break;
            case eTOKEN_NT16:
               nthreads=16;
               break;
            default:
               error(node->m_lineNo,"Invalid class declaration");
               break;
         }
         // Got a class declaration
         node2=(cAstNode *)node2->getNext();
         if(!node2)
            error(node->m_lineNo,"Invalid class declaration");
         if(node2->getID()==eTOKEN_class_declaration_list)
         {
            node2=node2->getChildList();
            while(node2)
            {
               if(node2->getID()==eTOKEN_IDENTIFIER)
               {
                  // Class defined
                  className=CAST(cAstStringNode,node2)->getStringValue();
                  if(Find(className))
                     error(node->m_lineNo,"Class is already defined");               
                  M_list.push_back(new cClass(className,nthreads));
               }
               else
                  error(node->m_lineNo,"Invalid class declaration");
               node2=(cAstNode *)node2->getNext();
            }
         }
         else if(node2->getID()==eTOKEN_IDENTIFIER)
         {
            // Class defined
            className=CAST(cAstStringNode,node2)->getStringValue();
            if(Find(className))
               error(node->m_lineNo,"Class is already defined");               
            M_list.push_back(new cClass(className,nthreads));
         }
         else
            error(node->m_lineNo,"Invalid class declaration");
      }
      node=(cAstNode *)node->getNext();
   }
#endif
   return 0;
}

cClass *cClass::Find(char *className)
{
   int i;
   char *p;
   char temp[MAX_STRING_LEN];
   if(strstr(className,"::"))
   {
      strcpy(temp,className);
      p=strstr(temp,"::");
      *p=0;
      className=temp;
   }
   for(i=0;i < (int)M_list.size();i++)
   {
      if(strcmp(M_list[i]->m_name.c_str(),className)==0)
         return M_list[i];
   }
   cClass *newClass=new cClass(className,NUM_THREAD_PER_CORE);
   M_list.push_back(newClass);
   return newClass;
}
