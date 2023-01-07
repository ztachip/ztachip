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

// This class performs register allocation using graph-coloring algirthm

#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <map>
#include <vector>
#include "../base/zta.h"
#include "ast.h"
#include "util.h"
#include "ident.h"
#include "class.h"
#include "instruction.h"
#include "gen.h"
#include "graph.h"
#include "const.h"

using namespace std;

static cAstNode *M_currFunc=0;
static std::vector<cGraphNode *> M_graph;
static cIdentifierVector M_intOnlyLst;
static cIdentifierVector M_regLst;
static std::vector<cGraphEdge *> M_edge;
static std::vector<cGraphColor *> M_intColor;
static std::vector<cGraphColor *> M_pointerColor;
static std::vector<cGraphColor *> M_sharedColor;
static std::vector<cGraphColor *> M_privateColor;
static std::vector<cGraphColor *> M_exregColor;

class CLINFO
{
public:
   CLINFO()
   {
      intSize=0;
      pointerSize=0;
      shareSize=0;
      privateSize=0;
      exregSize=0;
      pointerAvail=MAX_POINTER_SIZE;
   }
   ~CLINFO() {}
   int intSize;
   int pointerSize;
   int shareSize;
   int privateSize;
   int exregSize;
   int pointerAvail;
   std::vector<cIdentifier *> m_intLst;
   std::vector<cIdentifier *> m_pointerLst;
};

#define BOT2TOP 0
#define TOP2BOT 1

// Object to represent each color while doing register allocation
// using graph-coloring algorithm

cGraphColor::cGraphColor()
{
   m_offset=-1;
   m_len=0;
   m_flag=false;
   m_intOnly=false;
   m_vectorWidth=-1;
}

cGraphColor::~cGraphColor()
{
}

// Represent an edge that connects 2 cGraphColor

cGraphEdge::cGraphEdge(cIdentifier *id1,cIdentifier *id2)
{
   m_id1=id1;
   m_id2=id2;
}

cGraphEdge::~cGraphEdge()
{
}

// Object represents node in a non-directed graph used by
// graph-coloring alorithm
// Each instruction is presented by one of these nodes

cGraphNode::cGraphNode(cInstruction *instruction)
{
   m_instruction=instruction;
}

cGraphNode::~cGraphNode()
{
}

// Check if 2 identifiers are connected directed in the graph.

int cGraph::interference(CLASSID _clid,cIdentifier *id)
{
   int count=0;
   size_t i;
   for(i=0;i < M_edge.size();i++)
   {
      if((M_edge[i]->m_id1==id && M_edge[i]->m_id2->isKindOf(_clid) && !M_edge[i]->m_id2->isFixed()) || 
         (M_edge[i]->m_id2==id && M_edge[i]->m_id1->isKindOf(_clid) && !M_edge[i]->m_id1->isFixed()))
         count++;
   }
   return count;
}

// Color the graph using graph-coloring alogorithm

int cGraph::color(CLASSID _clid,std::vector<cGraphColor *> *_color,cIdentifier *id,cIdentifierVector *lst)
{
   int found;
   size_t i;
   cIdentifier *id2;

   for(i=0;i < _color->size();i++)
      _color->at(i)->m_flag=false;

   // Mark all colors used by this identifier
   // as not available
   for(i=0;i < M_edge.size();i++)
   {
      if(M_edge[i]->m_id1==id)
         id2=M_edge[i]->m_id2;
      else if(M_edge[i]->m_id2==id)
         id2=M_edge[i]->m_id1;
      else
         continue;
      if(!lst->exist(id2))
         continue;
      id2->m_color->m_flag=true;
   }
   found=-1;
   for(i=0;i < _color->size();i++)
   {
      if(!_color->at(i)->m_flag)
      {
         // Find an available color (largest possible)
         if((found < 0) || (_color->at(i)->m_len > _color->at(found)->m_len))
            found=i;
      }
   }
   if(found < 0)
   {
      // No available color can be found. Create a new color
      found=_color->size();
      _color->push_back(new cGraphColor);
      _color->at(found)->m_len=id->getLen();
   }
   // The color has to be large enough to hold the largest identifier assigned
   // to the color
   _color->at(found)->m_len=MAX(_color->at(found)->m_len,id->getLen());
   if(id->isKindOf(cIdentifierStorage::getCLID()))
      _color->at(found)->m_vectorWidth=MAX(_color->at(found)->m_vectorWidth,CAST(cIdentifierStorage,id)->m_w);
   id->m_color=_color->at(found);
   if(_clid==cIdentifierInteger::getCLID() && M_intOnlyLst.exist(id))
   {
      // If one of the Identifier allocated to a color is integer only (not pointer), 
      // then the color is also integer only
      id->m_color->m_intOnly=true;
   }
   return 0;
}

// Perform register allocation using the graph-coloring alogorithm 

int cGraph::colorGraph(CLASSID _clid,std::vector<cGraphColor *> *_color)
{
   int found;
   cIdentifier *id;
   size_t i;
   cIdentifierVector stack,stack2;
   
   for(i=0;i < M_regLst.size();i++)
   {
      if(!M_regLst[i]->isKindOf(_clid))
         continue;
      if(M_regLst[i]->isFixed())
         continue;
      M_regLst[i]->m_interference=cGraph::interference(_clid,M_regLst[i]);
      M_regLst[i]->m_color=0;
   }
   for(;;)
   {
      found=-1;
      // Push into the stack the node with least number of interference (graph edges)
      for(i=0;i < M_regLst.size();i++)
      {
         if(!M_regLst[i]->isKindOf(_clid))
            continue;
         if(M_regLst[i]->isFixed())
            continue;
         if(M_regLst[i]->m_interference < 0)
            continue;
         if(found < 0 || M_regLst[found]->m_interference > M_regLst[i]->m_interference)
            found=i;
      }
      if(found < 0)
         break;
      stack.append(M_regLst[found]);
      M_regLst[found]->m_interference=-1;
   }
   stack2.clear();
   // Pop the nodes out of the stack and start to color them
   for(i=0;i < stack.size();i++)
   {
      id=stack[i];
      if(color(_clid,_color,id,&stack2) < 0)
         return -1;
      stack2.append(id);
   }
   return 0;
}

// Allocate space for the color
int cGraph::allocateGraph(std::vector<cGraphColor *> *_color,int *_allocSize,int _maxAllocSize,bool _intOnly,int _vector_width,
                          int base,int direction)
{
   int i,offset,newOffset;
   for(i=0,offset=*_allocSize;i < (int)_color->size();i++)
   {
      if(_color->at(i)->m_offset >= 0)
         continue;
      if(_color->at(i)->m_vectorWidth != _vector_width)
         continue;
      if(_color->at(i)->m_intOnly != _intOnly)
         continue;
      newOffset = offset+_color->at(i)->m_len;
      if(newOffset > _maxAllocSize)
      {
//         error(M_currFunc->m_lineNo,"out of memory");
           return -1;
      }
      if(direction==TOP2BOT)
         _color->at(i)->m_offset=offset+base;
      else
         _color->at(i)->m_offset=base-offset;
      offset = newOffset;
   }
   *_allocSize=offset;
   return 0;
}

// Build the graph for each functions

int cGraph::Build(cInstruction *code)
{
   cInstruction *instruction;
   instruction=code;
   while(instruction)
   {
      if(instruction->getBeginFunc())
      {
         M_currFunc=instruction->getBeginFunc();
         if(buildFunc(instruction) < 0)
         {
            assert(0);
            return -1;
         }
      }
      instruction=(cInstruction *)instruction->getNext();
   }
   return 0;
}

// Allocate space for all identifiers within function.

void cGraph::allocateMem(cAstNode *node)
{
   cIdentifier *id;
   cAstNode *node2;
   if(node->getID()==eTOKEN_block_item_list)
   {
      id=CAST(cAstCodeBlockNode,node)->getIdentifierList();
      while(id)
      {
         if(!id->isFixed() && id->m_color)
         {
            id->allocate(id->m_color->m_offset);
         }
         id=(cIdentifier *)id->getNext();
      }
   }
   // We can have nested identifier declaration
   node2=node->getChildList();
   while(node2)
   {
      allocateMem(node2);
      node2=(cAstNode *)node2->getNext();
   }
}

// Build graph and do register allocation for a function

int cGraph::buildFunc(cInstruction *_func)
{
   cInstruction *instruction;
   cGraphNode *node;
   size_t i,j,k;
   bool cont;
   cIdentifierVector lst,lst2,lst3;
   cGraphEdge *edge;
   cIdentifier *id;
   int intSize,pointerSize,shareSize,privateSize,exregSize;
   int v;
   int intParmSize;
   std::string className;
   static std::map<std::string,CLINFO> classes;
   CLINFO *classInfo;
   bool newClass;
   int availIntSize,availPointerSize;

   assert(_func->getBeginFunc()!=0);

   className=_func->GetFunctionClassName();

   if(classes.find(className) == classes.end())
   {
      classes.insert(std::make_pair(className,CLINFO()));
      newClass=true;
   }
   else
      newClass=false;
   classInfo=&classes[className]; 

   intSize=classInfo->intSize;
   pointerSize=classInfo->pointerSize;
   shareSize=classInfo->shareSize;
   privateSize=classInfo->privateSize;
   exregSize=classInfo->exregSize;

   _func->m_maxNumThreads=cClass::Find(_func->getLabel())->m_maxThreads;
   assert(DATAMODEL_WIDTH==2);
   if(_func->m_maxNumThreads==NUM_THREAD_PER_CORE)
      _func->m_dataModel=0;
   else if(_func->m_maxNumThreads==NUM_THREAD_PER_CORE/2)
      _func->m_dataModel=1;
   else if(_func->m_maxNumThreads==NUM_THREAD_PER_CORE/4)
      _func->m_dataModel=2;
   else if(_func->m_maxNumThreads==NUM_THREAD_PER_CORE/8)
      _func->m_dataModel=3;
   else
      error(M_currFunc->m_lineNo,"Unsupported function data model");

   // Build the graph tree...
   instruction=_func;
   for(i=0;i < M_graph.size();i++)
      delete M_graph[i];
   M_graph.clear();
   M_regLst.clear();
   M_intOnlyLst.clear();
   for(i=0;i < M_edge.size();i++)
      delete M_edge[i];
   M_edge.clear();
   for(i=0;i < M_intColor.size();i++)
      delete M_intColor[i];
   M_intColor.clear();
   for(i=0;i < M_pointerColor.size();i++)
      delete M_pointerColor[i];
   M_pointerColor.clear();
   for(i=0;i < M_sharedColor.size();i++)
      delete M_sharedColor[i];
   M_sharedColor.clear();
   for(i=0;i < M_privateColor.size();i++)
      delete M_privateColor[i];
   M_privateColor.clear();
   for(i=0;i < M_exregColor.size();i++)
      delete M_exregColor[i];
   M_exregColor.clear();

   for(;;)
   {
      node=new cGraphNode(instruction);
      M_graph.push_back(node);
      instruction->getDef(&lst);
      M_regLst.vector_union(&lst);
      instruction->getUse(&lst);
      M_regLst.vector_union(&lst);
      if(instruction->isMU())
      {
         // Integer that is used in a MU operation must be integer only
         for(i=0;i < lst.size();i++)
         {
            if(lst[i]->isKindOf(cIdentifierInteger::getCLID()) &&
               CAST(cIdentifierInteger,lst[i])->m_useForMuIndex)
            {
               M_intOnlyLst.append(lst[i]);
            }
         }
      }
      instruction=(cInstruction *)instruction->getNext();
      if(!instruction || instruction->getBeginFunc())
         break;
   }

   // Calculate successor for each node (including next and jump instructions)
   for(i=0;i < M_graph.size();i++)
   {
      node=M_graph[i];
      for(j=0;j < 2;j++)
      {
         if(j==0) // Next instruction
            instruction=node->m_instruction->getNextInstruction();
         else // Jump instruction
            instruction=node->m_instruction->getJumpInstruction();
         if(instruction)
         {
            for(k=0;k < M_graph.size();k++)
            {
               if(M_graph[k]->m_instruction==instruction)
                  break;
            }
            assert(k < M_graph.size());
            node->m_succ.push_back(M_graph[k]);
         }
      }
   }
   // Calculate live-in and live-out for each node

   cont=true;
   while(cont)
   {
      cont=false;
      for(i=0;i < M_graph.size();i++)
      {
         node=M_graph[i];
         node->m_in2.clone(&node->m_in);
         node->m_out2.clone(&node->m_out);

         node->m_out.clear();
         for(j=0;j < node->m_succ.size();j++)
            node->m_out.vector_union(&node->m_succ[j]->m_in);
         
         node->m_instruction->getUse(&node->m_in);
         node->m_instruction->getDef(&lst2);
         lst3.clone(&node->m_out);
         lst3.vector_minus(&lst2);   
         node->m_in.vector_union(&lst3);

         if(!node->m_in2.equal(&node->m_in) ||
            !node->m_out2.equal(&node->m_out))
            cont=true;
      }
   }
   // Determine node live overlap
   // Check against every possiblt pair if identifiers
   for(i=0;i < M_regLst.size();i++)
   {
      for(j=i+1;j < M_regLst.size();j++)
      {
         for(k=0;k < M_graph.size();k++)
         {
            node=M_graph[k];
            assert(node!=0);
            assert(node->m_instruction!=0);
            lst.clear();
            node->m_instruction->getDef(&lst);
            if(node->m_out.exist(M_regLst[i]) && node->m_out.exist(M_regLst[j]))
               break;
            if(node->m_out.exist(M_regLst[i]) && lst.exist(M_regLst[j]))
               break;
            if(node->m_out.exist(M_regLst[j]) && lst.exist(M_regLst[i]))
               break;
         }
         if(k < M_graph.size())
         {
            // Got an inteference
            // Creater an edge in the graph
            edge=new cGraphEdge(M_regLst[i],M_regLst[j]);
            M_edge.push_back(edge);
         }
      }
   }

  // -----------------------------------------
  // Allocate class scope variables... 
  // --------------------------------------------

  if(newClass)
  {
  shareSize = cConstant::Size();
  shareSize = ((shareSize+VECTOR_WIDTH-1)/VECTOR_WIDTH)*VECTOR_WIDTH;

  // Allocate global variables that are shared and in same context as the function
   for(v=VECTOR_DEPTH;v >= 0;v--)
   {
   id=CAST(cAstCodeBlockNode,root)->getIdentifierList();
   while(id)
   {
      if(id->isParameter() && id->isKindOf(cIdentifierStorage::getCLID()) && CAST(cIdentifierStorage,id)->m_w == v)
      {
         if(id->isSameContext(_func->getBeginFunc()))
         {
            if(id->isKindOf(cIdentifierShared::getCLID()))
            {
               id->allocate(shareSize);
               shareSize += id->getLen();
            }
         } 
      }
      id=(cIdentifier *)id->getNext();
   }
   }
   shareSize = ((shareSize+VECTOR_WIDTH-1)/VECTOR_WIDTH)*VECTOR_WIDTH;

  // Allocate global variables that are private and in same context as the function
   for(v=VECTOR_DEPTH;v >= 0;v--)
   {
   id=CAST(cAstCodeBlockNode,root)->getIdentifierList();
   while(id)
   {
      if(id->isParameter() && id->isKindOf(cIdentifierStorage::getCLID()) && CAST(cIdentifierStorage,id)->m_w == v)
      {
         if(id->isSameContext(_func->getBeginFunc()))
         {
            if(id->isKindOf(cIdentifierPrivate::getCLID()))
            {
               id->allocate(privateSize);
               privateSize += id->getLen();
            }
         } 
      }
      id=(cIdentifier *)id->getNext();
   }
   }

   // Allocate presistent global variables that are double and in same context as the function
   v=VECTOR_DEPTH;
   id=CAST(cAstCodeBlockNode,root)->getIdentifierList();
   while(id)
   {
      if(id->isSameContext(_func->getBeginFunc()))
      {
         if(id->isKindOf(cIdentifierExReg::getCLID()))
         {
            id->allocate(exregSize);
            exregSize += id->getLen();
         }
      } 
      id=(cIdentifier *)id->getNext();
   }

   // Allocate persistent interger variables.

   id = CAST(cAstCodeBlockNode, root)->getIdentifierList();
   while (id)
   {
      if (id->isSameContext(_func->getBeginFunc()))
      {
         if (id->isKindOf(cIdentifierFixed::getCLID()))
         {
            if (id->isKindOf(cIdentifierInteger::getCLID()))
            {
               id->allocate(intSize);
               intSize += id->getLen();
               classInfo->m_intLst.push_back(id);
            }
            else if (id->isKindOf(cIdentifierPointer::getCLID()))
            {
               id->allocate(pointerSize);
               pointerSize += id->getLen();
               classInfo->m_pointerLst.push_back(id);
            }
            else
            {
               assert(0);
            }
         }
      }
      id = (cIdentifier *)id->getNext();
   }
   classInfo->intSize=intSize;
   classInfo->pointerSize=pointerSize;
   classInfo->shareSize=shareSize;
   classInfo->privateSize=privateSize;
   classInfo->exregSize=exregSize;   
   }

   // ------------------------------------------
   // Allocate function parameter variables... 
   // --------------------------------------------

   privateSize = ((privateSize+VECTOR_WIDTH-1)/VECTOR_WIDTH)*VECTOR_WIDTH;

   // Allocate parameter variables that are private
   for(v=VECTOR_DEPTH;v >= 0;v--)
   {
   id=CAST(cAstCodeBlockNode,_func->getBeginFunc()->getChild(1,eTOKEN_block_item_list))->getIdentifierList();
   while(id)
   {
      if(id->isParameter() && id->isKindOf(cIdentifierStorage::getCLID()) && CAST(cIdentifierStorage,id)->m_w == v)
      {
         if(id->isKindOf(cIdentifierPrivate::getCLID()))
         {
            id->allocate(privateSize);
            privateSize += id->getLen();
         }
      }
      id=(cIdentifier *)id->getNext();
   }
   }

   // Allocate parameter variables that are integer

   intParmSize=0;
   id=CAST(cAstCodeBlockNode,_func->getBeginFunc()->getChild(1,eTOKEN_block_item_list))->getIdentifierList();
   while(id)
   {
      if(id->isKindOf(cIdentifierInteger::getCLID()) && CAST(cIdentifierFixed,id)->m_persistentIndex>=0)
      {
         id->allocate(MAX_INT_SIZE-CAST(cIdentifierFixed,id)->m_persistentIndex-1);
         intParmSize++;
      }
      id=(cIdentifier *)id->getNext();
   }
   if(intParmSize > MAX_IREGISTER_AUTO_SIZE)
   {
      error(M_currFunc->m_lineNo,"out of integer auto memory"); 
      return -1;
   }

   // Color the graph
   if(colorGraph(cIdentifierPointer::getCLID(),&M_pointerColor) < 0)
      return -1;
   if(colorGraph(cIdentifierInteger::getCLID(),&M_intColor) < 0)
      return -1;
   if(colorGraph(cIdentifierPrivate::getCLID(),&M_privateColor) < 0)
      return -1;
   if(colorGraph(cIdentifierShared::getCLID(),&M_sharedColor) < 0)
      return -1;
   if(colorGraph(cIdentifierExReg::getCLID(),&M_exregColor) < 0)
      return -1;

   availPointerSize=MAX_POINTER_SIZE-classInfo->pointerSize;
   availIntSize=MAX_INT_SIZE-classInfo->intSize-intParmSize;
   pointerSize=0;
   intSize=0;

   // Allocate space to each color
   // Allocate space for pointer variables
   if(allocateGraph(&M_pointerColor,&pointerSize,availPointerSize,false,-1,MAX_POINTER_SIZE-1,BOT2TOP) < 0)
   {
      error(M_currFunc->m_lineNo,"out of memory for pointer variables");
      return -1;
   }

   // Allocate using pointer space for integer variables that can be also assigned to pointer space
   if(allocateGraph(&M_intColor,&pointerSize,availPointerSize,false,-1,MAX_POINTER_SIZE+MAX_INT_SIZE-1,BOT2TOP) < 0)
   {
   }

   classInfo->pointerAvail=MIN(classInfo->pointerAvail,(availPointerSize-pointerSize));    

   // Allocate using integer space for integer variables that can also be assigned to pointer space
   if(allocateGraph(&M_intColor,&intSize,availIntSize,false,-1,MAX_INT_SIZE-intParmSize-1,BOT2TOP) < 0)
   {
      error(M_currFunc->m_lineNo,"out of memory for integer variables");
      return -1;
   }
   // Allocate using integer space for integer variables that can only be assigned in integer space

   if(allocateGraph(&M_intColor,&intSize,availIntSize,true,-1,MAX_INT_SIZE-intParmSize-1,BOT2TOP) < 0)
   {
      if(classInfo->pointerAvail > 0)
      {
         int i,j;
         cIdentifierInteger *id;
         // Check if we can transfer some integer space variable to pointer space variables
         // There is still some avail space in pointer space
         for(i=0;i < (int)classInfo->m_intLst.size();i++)
         {
            id=CAST(cIdentifierInteger,classInfo->m_intLst[i]);
            if(!id->m_useForMuIndex)
            {
               // If not used for variable index then can turn this to pointer space
               classInfo->m_intLst.erase(classInfo->m_intLst.begin()+i);
               for(j=0;j < (int)classInfo->m_intLst.size();j++) {
                  classInfo->m_intLst[j]->allocate(j);
               }
               id->allocate(MAX_INT_SIZE+classInfo->m_pointerLst.size());
               classInfo->m_pointerLst.push_back(id);
               classInfo->pointerAvail--;
               classInfo->intSize--;
               classInfo->pointerSize++;
               availIntSize++;
               availPointerSize--;
               break;
            }
         }
         // Try again...
         if(allocateGraph(&M_intColor,&intSize,availIntSize,true,-1,MAX_INT_SIZE-intParmSize-1,BOT2TOP) < 0)
            error(M_currFunc->m_lineNo,"out of memory for integer variables");
      }
      else
         error(M_currFunc->m_lineNo,"out of memory for integer variables");
   }

   // Stack variables have to alined to vector boundary
   privateSize = ((privateSize+VECTOR_WIDTH-1)/VECTOR_WIDTH)*VECTOR_WIDTH;

   for(v=VECTOR_DEPTH;v >= 0;v--)
   {
      if(allocateGraph(&M_privateColor,&privateSize,MAX_PRIVATE_SIZE,false,v,0,TOP2BOT) < 0)
      {
         error(M_currFunc->m_lineNo,"out of memory for private memory space");
         return -1;
      }
   }

   // Allocate accumulator space
   if(allocateGraph(&M_exregColor,&exregSize,MAX_EXREG_SIZE,false,VECTOR_DEPTH,0,TOP2BOT) < 0)
   {
      error(M_currFunc->m_lineNo,"out of memory for accumulator space");
      return -1;
   }

   // Assign space address to all identifiers...
   allocateMem(_func->getBeginFunc()->getChild(1,eTOKEN_block_item_list,-1));

   // Stack variables have to alined to vector boundary
   privateSize = ((privateSize+VECTOR_WIDTH-1)/VECTOR_WIDTH)*VECTOR_WIDTH;

   // Update stack information associated with function calls.
   instruction=_func;
   while(instruction)
   {
      instruction->updateStackInfo(privateSize);
      instruction=(cInstruction *)instruction->getNext();
      if(!instruction || instruction->getBeginFunc())
         break;
   }

   // Allocate space to stack parameters
   for(v=VECTOR_DEPTH;v >= 0;v--)
   {
   id=CAST(cAstCodeBlockNode,_func->getBeginFunc()->getChild(1,eTOKEN_block_item_list))->getIdentifierList();
   while(id)
   {
      if(id->isStack() && CAST(cIdentifierPrivate,id)->m_w==v)
      {
         if(id->isKindOf(cIdentifierPrivate::getCLID()))
         {
            id->allocate(privateSize+CAST(cIdentifierStack,id)->m_pos*(1<<v));
         }
         else if(id->isKindOf(cIdentifierShared::getCLID()))
         {
            error(0,"Invalid function parameter");
         } 
         else if(id->isKindOf(cIdentifierInteger::getCLID()))
         {
            error(0,"Invalid function parameter");
         } 
         else if(id->isKindOf(cIdentifierPointer::getCLID()))
         {
            error(0,"Invalid function parameter");
         }
         else
         {
            assert(0);
         }
      }
      id=(cIdentifier *)id->getNext();
   }
   }
   if((_func->m_maxNumThreads*ROUND(privateSize,VECTOR_WIDTH)+ROUND(shareSize,VECTOR_WIDTH)) > (1<<REGISTER_ACTUAL_FILE_DEPTH))
   {
      error(M_currFunc->m_lineNo,"out of memory for pcore memory space");
      return -1;
   }
   return 0;
}
