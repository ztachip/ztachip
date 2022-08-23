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

#ifndef _GRAPH_H_
#define _GRAPH_H_

#include "util.h"
#include "ident.h"

class cGraphNode
{
public:
   cGraphNode(cInstruction *instruction);
   ~cGraphNode();
   cInstruction *m_instruction;
   cIdentifierVector m_in;
   cIdentifierVector m_out;
   cIdentifierVector m_in2;
   cIdentifierVector m_out2;
   std::vector<cGraphNode *> m_succ;
};

class cGraphEdge
{
public:
   cGraphEdge(cIdentifier *id1,cIdentifier *id2);
   ~cGraphEdge();
   cIdentifier *m_id1;
   cIdentifier *m_id2;
};

class cGraphColor
{
public:
   cGraphColor();
   ~cGraphColor();
   int m_offset;
   int m_len;
   bool m_flag;
   bool m_intOnly;
   bool m_vectorWidth;
};

class cGraph
{
public:
   static int Build(cInstruction *_func);
private:
   static int colorGraph(CLASSID _clid,std::vector<cGraphColor *> *_color);
   static int buildFunc(cInstruction *_func);
   static void allocateMem(cAstNode *node);
   static int interference(CLASSID _clid,cIdentifier *id);
   static int color(CLASSID _clid,std::vector<cGraphColor *> *_color,cIdentifier *id,cIdentifierVector *lst);
   static int allocateGraph(std::vector<cGraphColor *> *_color,int *_allocSize,int _maxAllocSize,bool _intOnly,int _vector_width,int _offset,int _reverseOffset);

};

#endif
