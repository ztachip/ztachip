#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "nn_reshape.h"

// Reshape layer. Nothing to do
NeuralNetLayerReshape::NeuralNetLayerReshape(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
}

NeuralNetLayerReshape::~NeuralNetLayerReshape() {
}

ZtaStatus NeuralNetLayerReshape::Prepare() {
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerReshape::Evaluate(int queue) {
   return ZtaStatusOk;
}

