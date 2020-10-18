#ifndef _ZTA_NN_ADD_H_
#define _ZTA_NN_ADD_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn.h"

class NeuralNetLayerAdd : public NeuralNetLayer {
public:
   NeuralNetLayerAdd(NeuralNet *nn,NeuralNetOperatorDef *def);
   ~NeuralNetLayerAdd();
   ZtaStatus Prepare();
   ZtaStatus Evaluate(int queue);
   LayerIoType GetIoType() {return LayerIoTypeInFlatOutFlat;}
private:
   static float SpuInputEval(float _in,void *pparm,uint32_t parm);
   static float SpuOutputEval(float _in,void *pparm,uint32_t parm);
public:
   ZTA_SHARED_MEM m_shmSpu;
private:
   uint32_t m_func;
};

#endif
