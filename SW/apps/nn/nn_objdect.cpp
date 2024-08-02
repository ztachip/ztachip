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

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <vector>
#include <algorithm>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztalib.h"
#include "../../src/soc.h"
#include "nn_objdetect.h"
#include "kernels/objdet.h"

// Do the SSD box detection pruning

NeuralNetLayerObjDetect::NeuralNetLayerObjDetect(NeuralNet *nn,NeuralNetOperatorDef* def) : NeuralNetLayer(nn,def) {
   m_anchors=0;
   m_scoreResult=0;
   m_classResult=0;
}

NeuralNetLayerObjDetect::~NeuralNetLayerObjDetect() {
   if(m_anchors)
      free(m_anchors);
   if(m_scoreResult)
      ztaFreeSharedMem(m_scoreResult);
   if(m_classResult)
      ztaFreeSharedMem(m_classResult);
}

ZtaStatus NeuralNetLayerObjDetect::Prepare() {
   NeuralNetOperatorDef* op=&m_def;
   int box_zero=op->u.detection.input_box.zero_point;
   float box_scale=op->u.detection.input_box.scale;
   int anchor_zero=op->u.detection.input_anchor.zero_point;
   float anchor_scale=op->u.detection.input_anchor.scale;
   int class_zero=op->u.detection.input_class.zero_point;
   float class_scale=op->u.detection.input_class.scale;
   float scale_x=op->u.detection.scale_x;
   float scale_y=op->u.detection.scale_y;
   float scale_w=op->u.detection.scale_w;
   float scale_h=op->u.detection.scale_h;
   m_score_threshold=-1;
   for(int i=0;i <=255;i++) {
      m_lookup_score[i]=m_nn->dequantize(i,class_zero,class_scale);
      m_lookup_box_x[i]=m_nn->dequantize(i,box_zero,box_scale)/scale_x;
      m_lookup_box_y[i]=m_nn->dequantize(i,box_zero,box_scale)/scale_y;
      m_lookup_box_h[i]=0.5f*static_cast<float>(exp(m_nn->dequantize(i,box_zero,box_scale)/scale_h));
      m_lookup_box_w[i]=0.5f*static_cast<float>(exp(m_nn->dequantize(i,box_zero,box_scale)/scale_w));
      if((m_lookup_score[i] >= dNnObjDetectThreshold) && 
         (m_score_threshold<0))
         m_score_threshold=i;
   }
   m_maxNumDetects=(*(op->input_shape)[0])[1];
   // Reshape the output for maximum number of detects
   // Box coordinate [xmin ymin xmax ymax]
   m_def.output_shape[0]->clear();
   m_def.output_shape[0]->push_back(1);
   m_def.output_shape[0]->push_back(m_maxNumDetects);
   m_def.output_shape[0]->push_back(4);
   // Class id
   m_def.output_shape[1]->clear();
   m_def.output_shape[1]->push_back(1);
   m_def.output_shape[1]->push_back(m_maxNumDetects);
   // Probability
   m_def.output_shape[2]->clear();
   m_def.output_shape[2]->push_back(1);
   m_def.output_shape[2]->push_back(m_maxNumDetects);
   // Number of detects
   m_def.output_shape[3]->clear();
   m_def.output_shape[3]->push_back(1);
   m_boxesSize=TENSOR::GetTensorSize(*(op->input_shape[0]));
   m_classesSize=TENSOR::GetTensorSize(*(op->input_shape[1]));
   uint8_t *anchors=op->u.detection.anchors;
   int numBoxes=(*(op->input_shape)[0])[1];
   m_anchors=static_cast<float*>(malloc(sizeof(float)*4*numBoxes));
   for(int i=0;i < numBoxes;i++) {
      m_anchors[4*i+0]=m_nn->dequantize(anchors[4*i+0],anchor_zero,anchor_scale);
      m_anchors[4*i+1]=m_nn->dequantize(anchors[4*i+1],anchor_zero,anchor_scale);
      m_anchors[4*i+2]=m_nn->dequantize(anchors[4*i+2],anchor_zero,anchor_scale);
      m_anchors[4*i+3]=m_nn->dequantize(anchors[4*i+3],anchor_zero,anchor_scale);
   }
   m_scoreResult=ztaAllocSharedMem(sizeof(uint8_t)*numBoxes+8);
   m_classResult=ztaAllocSharedMem(sizeof(uint8_t)*numBoxes+8);
   return ZtaStatusOk;
}

ZtaStatus NeuralNetLayerObjDetect::Evaluate(int queue) {
   NeuralNetOperatorDef *op=&m_def;
   int i,j;
   std::vector<int> *boxes_shape,*classes_shape;
   int score_threshold;
   int numBoxes;
   uint8_t *p,*p3,*p4;
   float *p2;
   float box_x,box_y;
   float anchor_x,anchor_y,anchor_w,anchor_h;
   uint8_t *boxes,*classes;
   int detectClass=0;
   struct ObjDetectionResult detects[dNnObjDetectMaxNumDetects];
   int numDetects;
   uint8_t *scoreResult;
   uint8_t *classResult;

//return ZtaStatusOk;
   score_threshold=m_score_threshold;
   boxes_shape=(op->input_shape)[0];
   classes_shape=(op->input_shape)[1];
   // Copy to cachable memory before processing the data
   boxes=(uint8_t *)ZTA_SHARED_MEM_VIRTUAL(m_nn->BufferGetInterleave(op->input[0]));
   classes=(uint8_t *)ZTA_SHARED_MEM_VIRTUAL(m_nn->BufferGetInterleave(op->input[1]));
   numBoxes=(*boxes_shape)[1];
   int max_score=0;
   int numClasses=(*classes_shape)[2];
   numDetects=0;
   ObjDetectionResult *d=detects;
   scoreResult=(uint8_t *)m_scoreResult;
   classResult=(uint8_t *)m_classResult;

   kernel_objdet_exe(
      0,
      (uint32_t)classes,
      (uint32_t)scoreResult,
      (uint32_t)classResult,
      numBoxes,
      numClasses
   );
   FLUSH_DATA_CACHE();

   for(i=0,p=boxes,p2=m_anchors,p3=scoreResult,p4=classResult;
      i < numBoxes;
      i++,p+=4,p2+=4,p3++,p4++) {
      max_score=p3[0];
      if(max_score < score_threshold)
         continue;
      detectClass=p4[0];
      d->detectClass=detectClass;
      d->score=max_score;
      box_y = m_lookup_box_y[p[0]];
      box_x = m_lookup_box_x[p[1]];
      anchor_y = p2[0];
      anchor_x = p2[1];
      anchor_h = p2[2];
      anchor_w = p2[3];
      float ycenter=box_y*anchor_h+anchor_y;
      float xcenter=box_x*anchor_w+anchor_x;
      float half_h = m_lookup_box_h[p[2]] * anchor_h;
      float half_w = m_lookup_box_w[p[3]] * anchor_w;
      d->ymin = ycenter - half_h;
      d->xmin = xcenter - half_w;
      d->ymax = ycenter + half_h;
      d->xmax = xcenter + half_w;
      d++;
      numDetects++;
      if(numDetects >= dNnObjDetectMaxNumDetects)
         break;
   }

   // Sort detect boxes by scores.
   for(i=0;i < numDetects-1;i++) {
      for(j=i+1;j < numDetects;j++) {
         if(detects[i].score < detects[j].score) {
            ObjDetectionResult temp;
            temp=detects[i];
            detects[i] = detects[j];
            detects[j]=temp;
         }
      }
   }
   // Prune boxes with high intersection vs union ratio
   d=detects;
   for(i=0;i < (int)numDetects-1;i++,d++) {
      if(d->detectClass < 0)
         continue;
      ObjDetectionResult *d2=&detects[i+1];
      for(j=i+1;j < (int)numDetects;j++,d2++) {
         if(d2->detectClass < 0)
            continue;
         float area_i=(d->ymax-d->ymin)*(d->xmax-d->xmin);
         float area_j=(d2->ymax-d2->ymin)*(d2->xmax-d2->xmin);
         if (area_i <= 0 || area_j <= 0) { 
         } else {
            float intersection_ymin = MAX(d->ymin, d2->ymin);
            float intersection_xmin = MAX(d->xmin, d2->xmin);
            float intersection_ymax = MIN(d->ymax, d2->ymax);
            float intersection_xmax = MIN(d->xmax, d2->xmax);
            float intersection_dx = intersection_xmax - intersection_xmin;
            intersection_dx = MAX(intersection_dx,(float)0.0);
            float intersection_dy = intersection_ymax - intersection_ymin;
            intersection_dy = MAX(intersection_dy,(float)0.0);
            const float intersection_area = intersection_dx*intersection_dy;
            if(intersection_area > (dNnObjDetectIouThreshold*(area_i+area_j-intersection_area)))
               d2->detectClass=-1;
         }
      }
   }
   int numReducedDetects=0;
   for(int i=0;i < numDetects;i++) {
      if(detects[i].detectClass >= 0) {
         detects[numReducedDetects++]=detects[i];
      }
   }
   numDetects=numReducedDetects;
   // Save results in format to be compatible with tflite
   float *box_p=(float *)ZTA_SHARED_MEM_VIRTUAL(m_nn->BufferGetInterleave(m_def.output[0]));
   float *classes_p=(float *)ZTA_SHARED_MEM_VIRTUAL(m_nn->BufferGetInterleave(m_def.output[1]));
   float *probabilty_p=(float *)ZTA_SHARED_MEM_VIRTUAL(m_nn->BufferGetInterleave(m_def.output[2]));
   float *numDetect_p=(float *)ZTA_SHARED_MEM_VIRTUAL(m_nn->BufferGetInterleave(m_def.output[3]));
   for(int i=0;i < numDetects;i++) {
      box_p[4*i+1]=detects[i].xmin;
      box_p[4*i+0]=detects[i].ymin;
      box_p[4*i+3]=detects[i].xmax;
      box_p[4*i+2]=detects[i].ymax;
      classes_p[i]=detects[i].detectClass;
      probabilty_p[i]=m_lookup_score[detects[i].score];
   }
   numDetect_p[0]=numDetects;
   return ZtaStatusOk;
}
