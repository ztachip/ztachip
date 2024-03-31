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

// This file implements the API between micropython and ztachip

#include <stdlib.h>
#include <vector>
#include "../base/ztalib.h"
#include "soc.h"
#include "../base/zta.h"
#include "../base/util.h"
#include "../apps/color/color.h"
#include "../apps/color/kernels/color.h"
#include "../apps/of/of.h"
#include "../apps/of/kernels/of.h"
#include "../apps/canny/canny.h"
#include "../apps/canny/kernels/canny.h"
#include "../apps/harris/harris.h"
#include "../apps/harris/kernels/harris.h"
#include "../apps/resize/resize.h"
#include "../apps/resize/kernels/resize.h"
#include "../apps/gaussian/gaussian.h"
#include "../apps/equalize/equalize.h"
#include "../apps/gdi/gdi.h"
#include "../apps/nn/tf.h"
#include "mpy.h"

static std::vector<MPY_HANDLE> tensorLst;
static std::vector<MPY_HANDLE> graphNodeLst;
static std::vector<MPY_HANDLE> graphLst;


//
// Initialize ztachip from micropython
//
void MPY_Init() {
   ztaInit();
   GdiInit();
   DisplayInit(DISPLAY_WIDTH,DISPLAY_HEIGHT);
   CameraInit(WEBCAM_WIDTH,WEBCAM_HEIGHT);
}

// Remove all previously allocated objecys such as tensor,graphNode,graph
void MPY_DeleteAll() {
   int i;
   for(i=0;i < (int)graphLst.size();i++)
      MPY_Graph_Delete(graphLst[i]);
   for(i=0;i < (int)graphNodeLst.size();i++)
      MPY_GraphNode_Delete(graphNodeLst[i]);
   for(i=0;i < (int)tensorLst.size();i++)
      MPY_TENSOR_Delete(tensorLst[i]);
   graphLst.clear();
   graphNodeLst.clear();
   tensorLst.clear();
}

// API for set led state
void MPY_LedSet(uint32_t ledState) {
   LedSetState(ledState);
}

// API for pushbutton
uint32_t MPY_PushButtonState() {
   return PushButtonGetState();
}

// Get time
uint32_t MPY_GetTimeMsec() {
   return TimeGet();
}

// Get elapsed time
uint32_t MPY_GetElapsedTimeMsec() {
   static uint32_t lastTime=0;
   uint32_t now;
   uint32_t elapsed;
   now=TimeGet();
   elapsed=(int32_t)now-(int32_t)lastTime;
   lastTime=now;
   return elapsed;
}

// API for camera

bool MPY_Camera_Capture() {
   return CameraCaptureReady();   
}

// API for Display

void MPY_Display_FlushScreenCanvas() {
   DisplayUpdateBuffer();
}

// Return the width of camera capture

int MPY_CameraWidth() {
   return WEBCAM_WIDTH;
}

// Return the height of camera capture

int MPY_CameraHeight() {
   return WEBCAM_HEIGHT;
}

// Return with width of display

int MPY_DisplayWidth() {
   return DISPLAY_WIDTH;
}

// Return the height of display

int MPY_DisplayHeight() {
   return DISPLAY_HEIGHT;
}

// Draw point

void MPY_Canvas_DrawPoint(int r,int c) {
   GdiDrawPoint(r,c);
}

// Draw text

void MPY_Canvas_DrawText(const char *str,int r,int c) {
   GdiDrawText(str,r,c);
}  

// Draw a rectangle

void MPY_Canvas_DrawRectangle(int r1,int c1,int r2,int c2) {
   GdiDrawRectangle(r1,c1,r2,c2);
}

// API for create tensor objects

MPY_HANDLE MPY_TENSOR_Create(eMPY_TensorType _type) {
   TENSOR *tensor;
   switch(_type) {
      case eMPY_TensorTypeCamera:
         {
         std::vector<int> dim={3,WEBCAM_HEIGHT,WEBCAM_WIDTH};
         tensor=new TENSOR();
         tensor->Create(TensorDataTypeUint8,TensorFormatInterleaved,TensorObjTypeRGB,dim);
         }
         break;
      case eMPY_TensorTypeDisplay:
         tensor=new TENSOR();
         break;
      case eMPY_TensorTypeData:
         tensor=new TENSOR();
         break;
      default:
         return 0;
   }
   tensorLst.push_back((MPY_HANDLE)tensor);
   return (MPY_HANDLE)tensor;
}

// Return number of dimentions for this tensor

int MPY_TENSOR_NumDim(MPY_HANDLE hwd) {
   TENSOR *tensor=(TENSOR *)hwd;
   return tensor->GetDimension()->size();
}

// Return size of a tensor dimension

int MPY_TENSOR_GetDim(MPY_HANDLE hwd,int dimIdx) {
   TENSOR *tensor=(TENSOR *)hwd;
   return tensor->GetDimension(dimIdx);
}

// Return buffer associated with the tensor

void *MPY_TENSOR_GetBuf(MPY_HANDLE hwd) {
   TENSOR *tensor=(TENSOR *)hwd;
   return tensor->GetBuf();
}

// Return buffer length associated with the tensor

int MPY_TENSOR_GetBufLen(MPY_HANDLE hwd) {
   TENSOR *tensor=(TENSOR *)hwd;
   return tensor->GetBufLen();
}

// Return data type of the tensor

eMPY_TensorDataType MPY_TENSOR_GetDataType(MPY_HANDLE hwd) {
   TENSOR *tensor=(TENSOR *)hwd;
   switch(tensor->GetDataType()) {
      case TensorDataTypeInt8:
         return eMPY_TensorDataTypeInt8;
      case TensorDataTypeUint8:
         return eMPY_TensorDataTypeUint8;
      case TensorDataTypeInt16:
         return eMPY_TensorDataTypeInt16;
      case TensorDataTypeUint16:
         return eMPY_TensorDataTypeUint16;
      case TensorDataTypeFloat32:
         return eMPY_TensorDataTypeFloat32;
      default:
         assert(0);      
   }
}

// Delete a tensor object

void MPY_TENSOR_Delete(MPY_HANDLE hwd) {
   if(hwd != 0)
      delete (TENSOR *)hwd;
}

// Bind last camera capture to the tensor

bool MPY_TENSOR_GetCameraCapture(MPY_HANDLE _tensor) {
   TENSOR *tensor;
   tensor=(TENSOR *)_tensor;
   if(tensor) 
      tensor->Alias((ZTA_SHARED_MEM)CameraGetCapture());
   return true;
}

// Any drawing to a display are first put on a canvas work space 
// before the whole canvas is being displayed.
// Bind display canvas workspace buffer to a tensor

bool MPY_TENSOR_GetScreenCanvas(MPY_HANDLE _tensor) {
   TENSOR *tensor;
   tensor=(TENSOR *)_tensor;
   if(tensor)
      tensor->Alias((ZTA_SHARED_MEM)DisplayGetBuffer()); 
   return true;  
}

// API for GraphNode for transformation  

MPY_HANDLE MPY_GraphNodeTransform_Create(
                  MPY_HANDLE _tensorInput,
                  MPY_HANDLE _tensorOutput,
                  eMPY_TensorColorSpace _dstColorSpace,
                  eMPY_TensorFormat _dstFormat,
                  int _dst_x,int _dst_y,int _dst_w,int _dst_h
) {
   GraphNodeColorAndReshape *node;
   TensorObjType dstColorSpace;
   TensorFormat dstFormat;
   switch(_dstColorSpace) {
      case eMPY_TensorColorSpaceColor:
         dstColorSpace=TensorObjTypeRGB;
         break;
      case eMPY_TensorColorSpaceMonochromeMultiChannel:
         dstColorSpace=TensorObjTypeMonochrome;
         break;
      case eMPY_TensorColorSpaceMonoChromeSingleChannel:
         dstColorSpace=TensorObjTypeMonochromeSingleChannel;
         break;
      default:
         return 0;
   }
   switch(_dstFormat) {
      case eMPY_TensorFormatInterleaved:
         dstFormat=TensorFormatInterleaved;
         break;
      case eMPY_TensorFormatPlanar:
         dstFormat=TensorFormatSplit;
         break;
      default:
         return 0;
   }
   node = new GraphNodeColorAndReshape();
   node->Create((TENSOR *)_tensorInput,
                (TENSOR *)_tensorOutput,
                dstColorSpace,
               dstFormat,
               0,0,0,0,
               _dst_x,_dst_y,_dst_w,_dst_h);
   graphNodeLst.push_back((MPY_HANDLE)node);
   return (MPY_HANDLE)node;
}

// Create graph node for canny edge detection

MPY_HANDLE MPY_GraphNodeCanny_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor) {
   GraphNodeCanny *node;
   TENSOR *inputTensor,*outputTensor;

   inputTensor=(TENSOR *)_inputTensor;
   outputTensor=(TENSOR *)_outputTensor;
   node = new GraphNodeCanny();
   node->Create(inputTensor,outputTensor);
   graphNodeLst.push_back((MPY_HANDLE)node);
   return (MPY_HANDLE)node;
}

// Set edge detection threshold for Canny algorithm

void MPY_GraphNodeCanny_SetThreshold(MPY_HANDLE _node,int _loThreshold,int _hiThreshold) {
   GraphNodeCanny *node=(GraphNodeCanny *)_node;
   node->SetThreshold(_loThreshold,_hiThreshold);
}

// Create graph node for gaussian blurring

MPY_HANDLE MPY_GraphNodeGaussian_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor) {
   GraphNodeGaussian *node;
   TENSOR *inputTensor,*outputTensor;

   inputTensor=(TENSOR *)_inputTensor;
   outputTensor=(TENSOR *)_outputTensor;
   node = new GraphNodeGaussian();
   node->Create(inputTensor,outputTensor);
   graphNodeLst.push_back((MPY_HANDLE)node);
   return (MPY_HANDLE)node;
}

// Set sigma of Gaussian algorithm

void MPY_GraphNodeGaussian_SetSigma(MPY_HANDLE _node,float sigma) {
   GraphNodeGaussian *node=(GraphNodeGaussian *)_node;
   node->SetSigma(sigma);
}

// Create graph node for Harris-Corner detection

MPY_HANDLE MPY_GraphNodeHarris_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor) {
   GraphNodeHarris *node;
   TENSOR *inputTensor,*outputTensor;

   inputTensor=(TENSOR *)_inputTensor;
   outputTensor=(TENSOR *)_outputTensor;
   node = new GraphNodeHarris();
   node->Create(inputTensor,outputTensor);
   graphNodeLst.push_back((MPY_HANDLE)node);
   return (MPY_HANDLE)node;
}

// Create graph node for optical flow

MPY_HANDLE MPY_GraphNodeOpticalFlow_Create(MPY_HANDLE _input,MPY_HANDLE _output) {
   GraphNodeOpticalFlow *node;
   TENSOR *x_gradient = new TENSOR();
   TENSOR *y_gradient = new TENSOR();
   TENSOR *t_gradient = new TENSOR();
   TENSOR *x_vect = new TENSOR();
   TENSOR *y_vect = new TENSOR();

   node = new GraphNodeOpticalFlow();

   node->Create((TENSOR *)_input,
               x_gradient,
               y_gradient,
               t_gradient,
               x_vect,
               y_vect,
               (TENSOR *)_output);
   tensorLst.push_back((MPY_HANDLE)x_gradient);
   tensorLst.push_back((MPY_HANDLE)y_gradient);
   tensorLst.push_back((MPY_HANDLE)t_gradient);
   tensorLst.push_back((MPY_HANDLE)x_vect);
   tensorLst.push_back((MPY_HANDLE)y_vect);
   graphNodeLst.push_back((MPY_HANDLE)node);
   return (MPY_HANDLE)node;
}

// Create graph node for image resize

MPY_HANDLE MPY_GraphNodeResize_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor,int w,int h) {
   GraphNodeResize *node;
   TENSOR *inputTensor,*outputTensor;

   inputTensor=(TENSOR *)_inputTensor;
   outputTensor=(TENSOR *)_outputTensor;
   node = new GraphNodeResize();
   node->Create(inputTensor,outputTensor,w,h);
   graphNodeLst.push_back((MPY_HANDLE)node);
   return (MPY_HANDLE)node;
}

// Create graph node for TensorFlowLite 

MPY_HANDLE MPY_GraphNodeNeuralNet_Create(const char *modelFile,
                                       const char *labelFile,
                                       MPY_HANDLE _inputTensor,
                                       int numOutputTensor,
                                       MPY_HANDLE _outputTensor1,
                                       MPY_HANDLE _outputTensor2,
                                       MPY_HANDLE _outputTensor3,
                                       MPY_HANDLE _outputTensor4) {
   TfliteNn *node;

   node = new TfliteNn();
   node->Create(modelFile,
               (TENSOR *)_inputTensor,
               numOutputTensor,
               (TENSOR *)_outputTensor1,
               (TENSOR *)_outputTensor2,
               (TENSOR *)_outputTensor3,
               (TENSOR *)_outputTensor4);
   node->LabelLoad(labelFile);
   graphNodeLst.push_back((MPY_HANDLE)node);
   return (MPY_HANDLE)node;
}

// Get Label string associated with TensorFlowLite model

const char *MPY_GraphNodeNeuralNet_GetLabel(MPY_HANDLE hwd,int idx) {
   TfliteNn *node=(TfliteNn *)hwd;
   return node->LabelGet(idx);
}

// Delete a graph node

void MPY_GraphNode_Delete(MPY_HANDLE hwd) {
   if(hwd != 0)
      delete (GraphNode *)hwd;
}

// Delete a graph object

void MPY_Graph_Delete(MPY_HANDLE hwd) {
   if(hwd != 0)
      delete (Graph *)hwd;
}

// Create a graph

MPY_HANDLE MPY_Graph_Create(int numNodes,MPY_HANDLE *nodeLst) {
   Graph *graph;
   GraphNode *node;
   int i;

   graph = new Graph;
   for(i=0;i < numNodes;i++) {
      node=(GraphNode *)nodeLst[i];
      if(node)
         graph->Add(node);
   }
   graph->Verify();
   graphLst.push_back((MPY_HANDLE)graph);
   return (MPY_HANDLE)graph;
}

// Check if graph is currently busy processing

bool MPY_Graph_IsBusy(MPY_HANDLE _graph) {
   Graph *graph=(Graph *)_graph;
   if(graph)
      return graph->IsRunning();
   else
      return false;
}

// Run the graph but on a timeout
// After timeout, this function needs to be called again to continue
// with the processing

bool MPY_Graph_RunWithTimeout(MPY_HANDLE _graph,uint32_t _timeout) {
   Graph *graph=(Graph *)_graph;
   if(!graph)
      return false;
   if(!graph->IsRunning())
      graph->Prepare();
   graph->Run(_timeout);
   return true;
}

// Run the graph until completion

bool MPY_Graph_Run(MPY_HANDLE _graph) {
   Graph *graph=(Graph *)_graph;
   if(!graph)
      return false;
   graph->Prepare();
   graph->RunUntilCompletion();
   return true;
}

