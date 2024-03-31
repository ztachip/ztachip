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

#ifndef _ZTA_NN_OBJDETECT_H_
#define _ZTA_NN_OBJDETECT_H_

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztalib.h"
#include "nn.h"

#define dNnObjDetectThreshold ((float)0.5)

#define dNnObjDetectIouThreshold ((float)0.6)

#define dNnObjDetectMaxNumDetects 10

struct ObjDetectionResult {
   float xmin;
   float ymin;
   float xmax;
   float ymax;
   int detectClass;
   int score;
};

class NeuralNetLayerObjDetect : public NeuralNetLayer {
public:
   NeuralNetLayerObjDetect(NeuralNet *nn,NeuralNetOperatorDef *def);
   ~NeuralNetLayerObjDetect();
   ZtaStatus Prepare();
   ZtaStatus Evaluate(int queue);
   LayerIoType GetIoType() {return LayerIoTypeInInterleaveOutInterleave;}
   virtual bool RunAtHost() {return true;}
public:
   int m_maxNumDetects;
private:
   float m_lookup_score[256];
   float m_lookup_box_x[256];
   float m_lookup_box_y[256];
   float m_lookup_box_h[256];
   float m_lookup_box_w[256];
   size_t m_boxesSize;
   size_t m_classesSize;
   float *m_anchors;
   int m_score_threshold;
};

#endif
