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
   static float SpuEval(float _in,void *pparm,uint32_t index);
public:
   uint32_t m_outerSize;
   std::vector<size_t> m_copySize;
   std::vector<ZTA_SHARED_MEM> m_shmSpu;
private:
   uint32_t m_func;
};

#endif
