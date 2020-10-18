#ifndef _ZTA_NN_RESHAPE_H_
#define _ZTA_NN_RESHAPE_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn.h"

class NeuralNetLayerReshape : public NeuralNetLayer {
public:
   NeuralNetLayerReshape(NeuralNet *nn,NeuralNetOperatorDef *def);
   ~NeuralNetLayerReshape();
   ZtaStatus Prepare();
   ZtaStatus Evaluate(int queue);
   LayerIoType GetIoType() {return LayerIoPassthrough;}
};

#endif
