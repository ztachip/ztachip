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

#ifndef _ZTA_NN_CONCAT_H_
#define _ZTA_NN_CONCAT_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn.h"

class NeuralNetLayerConcat : public NeuralNetLayer {
public:
   NeuralNetLayerConcat(NeuralNet *nn,NeuralNetOperatorDef *def);
   ~NeuralNetLayerConcat();
   ZtaStatus Prepare();
   ZtaStatus Evaluate(int queue);
   LayerIoType GetIoType() {return LayerIoTypeInInterleaveOutInterleave;}
private:
   static float SpuEval(float _in,void *pparm,uint32_t index,uint32_t parm2);
public:
   uint32_t m_outerSize;
   std::vector<size_t> m_copySize;
   std::vector<ZTA_SHARED_MEM> m_shmSpu;
private:
   uint32_t m_func;
};

#endif
