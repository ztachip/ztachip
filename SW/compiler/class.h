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

#ifndef _CLASS_H_
#define _CLASS_H_
#include <vector>
#include "util.h"
#include "object.h"
#include "ast.h"

class cClass
{
public:
   cClass(char *_name,int _maxThreads);
   ~cClass();
   static int scan(cAstNode *_root);
   static cClass *Find(char *className);
public:
   static std::vector<cClass *> M_list;
   std::string m_name;
   int m_maxThreads;
};


#endif
