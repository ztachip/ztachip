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

#ifndef _CONST_H_
#define _CONST_H_
#include <vector>
#include "object.h"
#include "gen.h"
#include "ident.h"

class cConstant
{
public:
   static int Init();
   static RETCODE Allocate(cAstNode *_root);
   static int Find(float constant);
   static int Add(float constant);
   static int Size();
   static void Gen(FILE *fp,std::vector<uint16_t> &img);

   static std::vector<float> M_space;
};

#endif

