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

// This header file defined the interface between micropython and ztachip

#ifndef _MPY_H_
#define _MPY_H_

#include <stdint.h>
#include <stdbool.h>

typedef uint32_t MPY_HANDLE;

typedef enum {
   eMPY_TensorDataTypeInt8,
   eMPY_TensorDataTypeUint8,
   eMPY_TensorDataTypeInt16,
   eMPY_TensorDataTypeUint16,
   eMPY_TensorDataTypeFloat32
} eMPY_TensorDataType;

typedef enum {
    eMPY_TensorTypeCamera,
    eMPY_TensorTypeDisplay,
    eMPY_TensorTypeData
} eMPY_TensorType;

typedef enum {
   eMPY_TensorFormatInterleaved,
   eMPY_TensorFormatPlanar
} eMPY_TensorFormat;

typedef enum {
    eMPY_TensorColorSpaceColor,
    eMPY_TensorColorSpaceMonochromeMultiChannel,
    eMPY_TensorColorSpaceMonoChromeSingleChannel
} eMPY_TensorColorSpace;

#ifdef __cplusplus
extern "C" {
#endif
extern void MPY_Init();
extern void MPY_DeleteAll();
extern void MPY_LedSet(uint32_t ledState);
extern uint32_t MPY_PushButtonState();
extern uint32_t MPY_GetTimeMsec();
extern uint32_t MPY_GetElapsedTimeMsec();
extern bool MPY_Camera_Capture();
extern void MPY_Display_FlushScreenCanvas();
extern void MPY_Canvas_DrawText(const char *str,int r,int c);
extern void MPY_Canvas_DrawPoint(int r,int c);
extern void MPY_Canvas_DrawRectangle(int r1,int c1,int r2,int c2);
extern MPY_HANDLE MPY_GraphNodeCopyAndTransform_Create(
                    MPY_HANDLE _tensorInput,
                    MPY_HANDLE _tensorOutput,
                    eMPY_TensorColorSpace _dstColorSpace,
                    eMPY_TensorFormat _dstFormat,
                    int _dst_x,int _dst_y,int _dst_dx,int _dst_dy);
extern MPY_HANDLE MPY_GraphNodeGaussian_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor);
extern void MPY_GraphNodeGaussian_SetSigma(MPY_HANDLE _node,float sigma);
extern MPY_HANDLE MPY_GraphNodeHarris_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor);
extern MPY_HANDLE MPY_GraphNodeCanny_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor);
extern void MPY_GraphNodeCanny_SetThreshold(MPY_HANDLE _node,int _loThreshold,int _hiThreshold);
extern MPY_HANDLE MPY_GraphNodeOpticalFlow_Create(MPY_HANDLE _input,MPY_HANDLE _output);
extern MPY_HANDLE MPY_GraphNodeResize_Create(MPY_HANDLE _inputTensor,MPY_HANDLE _outputTensor,int w,int h);
extern MPY_HANDLE MPY_GraphNodeNeuralNet_Create(const char *modelFile,
                                                const char *labelFile,
                                                MPY_HANDLE _inputTensor,
                                                int numOutputTensor,
                                                MPY_HANDLE _outputTensor1,
                                                MPY_HANDLE _outputTensor2,
                                                MPY_HANDLE _outputTensor3,
                                                MPY_HANDLE _outputTensor4);
extern const char *MPY_GraphNodeNeuralNet_GetLabel(MPY_HANDLE hwd,int idx);
extern void MPY_GraphNode_Delete(MPY_HANDLE hwd);
extern void MPY_Graph_Delete(MPY_HANDLE hwd);
extern MPY_HANDLE MPY_Graph_Create(int numNodes,MPY_HANDLE *nodeLst);
extern bool MPY_Graph_IsBusy(MPY_HANDLE _graph);
extern bool MPY_Graph_RunWithTimeout(MPY_HANDLE _graph,uint32_t _timeout);
extern bool MPY_Graph_Run(MPY_HANDLE _graph);
extern MPY_HANDLE MPY_TENSOR_Create(eMPY_TensorType _type);
extern int MPY_TENSOR_NumDim(MPY_HANDLE hwd);
extern int MPY_TENSOR_GetDim(MPY_HANDLE hwd,int dimIdx);
extern void *MPY_TENSOR_GetBuf(MPY_HANDLE hwd);
extern int MPY_TENSOR_GetBufLen(MPY_HANDLE hwd);
extern eMPY_TensorDataType MPY_TENSOR_GetDataType(MPY_HANDLE hwd);
extern void MPY_TENSOR_Delete(MPY_HANDLE hwd);
extern bool MPY_TENSOR_GetCameraCapture(MPY_HANDLE _tensor);
extern bool MPY_TENSOR_GetScreenCanvas(MPY_HANDLE _tensor);
extern int MPY_CameraWidth();
extern int MPY_CameraHeight();
extern int MPY_DisplayWidth();
extern int MPY_DisplayHeight();
#ifdef __cplusplus
}
#endif

#endif
