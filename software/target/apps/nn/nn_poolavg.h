#ifndef _ZTA_NN_POOLAVG_H_
#define _ZTA_NN_POOLAVG_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn.h"

class NeuralNetLayerPoolAvg : public NeuralNetLayer {
public:
   NeuralNetLayerPoolAvg(NeuralNet *nn,NeuralNetOperatorDef *def);
   ~NeuralNetLayerPoolAvg();
   ZtaStatus Prepare();
   ZtaStatus Evaluate(int queue);
   LayerIoType GetIoType() {return LayerIoTypeInFlatOutFlat;}
private:
   static float SpuAvgPool(float _in,void *pparm,uint32_t parm);
public:
   ZTA_SHARED_MEM m_shmSpu;
   int32_t m_outputShift;
private:
   uint32_t m_func;
};

#endif
