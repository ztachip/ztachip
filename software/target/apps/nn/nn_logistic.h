#ifndef _ZTA_NN_LOGISTIC_H_
#define _ZTA_NN_LOGISTIC_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn.h"

class NeuralNetLayerLogistic : public NeuralNetLayer {
public:
   NeuralNetLayerLogistic(NeuralNet *nn,NeuralNetOperatorDef *def);
   ~NeuralNetLayerLogistic();
   ZtaStatus Prepare();
   ZtaStatus Evaluate(int queue);
   LayerIoType GetIoType() {return LayerIoTypeInOutSame;}
private:
   static float SpuEval(float _in,void *,uint32_t);
   static float SpuEvalScale(float _in,void *,uint32_t);
public:
   ZTA_SHARED_MEM m_shmSpu;
private:
   uint32_t m_func;
};

#endif
