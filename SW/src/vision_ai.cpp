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
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
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
#include "../apps/nn/tf.h"
#include "../apps/gdi/gdi.h"

//---------------------------------------------------------------------
// Example on how to use ztachip for vision AI applications
// Input from webcam are processed by ztachip
// Show the following vision applications
//    - Image classification using MobinetV2
//    - Object detection using SSD-MobinetV2
//    - Edge detection
//    - Harris-Corner feature extraction
//    - Optical flow
//    - Run objectDetection+edgeDetection+OpticalFlow+HarrisCorner
//      same time
//----------------------------------------------------------------------

#define MAX_SSD_RESULT      4
#define MAX_OUTPUT          4
#define ALPHABET_DIM        16

#define GRAPH_EXE_TIMEOUT 15 // 15msec

typedef struct {
   int x1,y1;
   int x2,y2;
   int probability;
   const char *label;
} SSD_RESULT;

typedef enum
{
  TestCaseImageClassifier=0,
  TestCaseObjectDetection,
  TestCaseEdgeDetection,
  TestCaseHarrisCorner,
  TestCaseOpticalFlow,
  TestCaseAll,
  TestCaseMax
} TestCase;

static const char *testcase_label[TestCaseMax]= {
   "ImgClassifier",
   "ObjectDetect",
   "EdgeDetect",
   "PointOfInterest",
   "MotionDectect",
   "MultiTasking"
};

#define NUM_PROGRESS  8
static const char *progress_str[NUM_PROGRESS]={"|","/","-","\\","|","/","-","\\"};

static TestCase testcase=TestCaseObjectDetection;

// Main loop

int vision_ai() {
   ZtaStatus rc;
   int i,j;
   unsigned int vv;
   int r;
   Graph graph;
   Graph graphNN;
   GraphNodeColorAndReshape nodeInput;
   GraphNodeColorAndReshape nodeOutput;
   GraphNodeColorAndReshape nodeOutputs[MAX_OUTPUT];
   GraphNodeColorAndReshape nodeConvert2Mono;
   GraphNodeResize nodeResize;
   GraphNodeResize nodeResizeNN;
   GraphNodeGaussian nodeGaussian;
   GraphNodeCanny nodeCanny;
   GraphNodeEqualize nodeEqualize;
   GraphNodeHarris nodeHarris;
   GraphNodeOpticalFlow nodeOpticalFlow;
   TfliteNn nodeNN;
   TENSOR tensorInput;
   TENSOR tensorInputNN;
   TENSOR tensorOutput;
   TENSOR tensorOutputs[MAX_OUTPUT];
   TENSOR tensorResize;
   TENSOR tensorSSDInput;
   TENSOR tensorNN[4];
   TENSOR tensorHarris;
   TENSOR tensorOpticalFlowInput;
   TENSOR tensorOpticalFlowGradientX;
   TENSOR tensorOpticalFlowGradientY;
   TENSOR tensorOpticalFlowGradientT;
   TENSOR tensorOpticalFlowVectX;
   TENSOR tensorOpticalFlowVectY;
   TENSOR tensorOpticalFlowDisplay;
   TENSOR tensor[16];
   int top5[5];
   uint8_t top5_probability[5];
   bool top5_valid=false;
   bool ssd_valid=false;
   char buf[128];
   SSD_RESULT ssd_result[MAX_SSD_RESULT];
   int ssd_result_cnt=0;
   bool readyToSwitch=false;
   uint32_t buttonStatus;
   int progress_cnt=0;
   uint8_t *displayBuffer;

   std::vector<int> dim={3,WEBCAM_HEIGHT,WEBCAM_WIDTH};
   rc=tensorInput.Create(TensorDataTypeUint8,TensorFormatInterleaved,TensorObjTypeRGB,dim);

    // Create the appropriate graph according to test case.

   if(testcase==TestCaseEdgeDetection) {
      // Graph for edge detection
      rc=nodeInput.Create(&tensorInput,&tensor[1],TensorObjTypeRGB,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeConvert2Mono.Create(&tensor[1],&tensor[2],TensorObjTypeMonochromeSingleChannel,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeCanny.Create(&tensor[2],&tensor[3]);
      assert(rc==ZtaStatusOk);
      nodeCanny.SetThreshold(81,100);
      rc=nodeOutput.Create(&tensor[3],&tensorOutput,TensorObjTypeMonochrome,TensorFormatInterleaved);
      assert(rc==ZtaStatusOk);

      graph.Add(&nodeInput);
      graph.Add(&nodeConvert2Mono);
      graph.Add(&nodeCanny);
      graph.Add(&nodeOutput);
      graph.Verify();
   } else if(testcase==TestCaseOpticalFlow) {
      // Graph for optical flow
      rc=nodeInput.Create(&tensorInput,&tensor[1],TensorObjTypeRGB,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeConvert2Mono.Create(&tensor[1],
                                 &tensorOpticalFlowInput,
                                 TensorObjTypeMonochromeSingleChannel,
                                 TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeOpticalFlow.Create(&tensorOpticalFlowInput,
                              &tensorOpticalFlowGradientX,
                              &tensorOpticalFlowGradientY,
                              &tensorOpticalFlowGradientT,
                              &tensorOpticalFlowVectX,
                              &tensorOpticalFlowVectY,
                              &tensorOpticalFlowDisplay);
      assert(rc==ZtaStatusOk);
      rc=nodeOutput.Create(&tensorOpticalFlowDisplay,&tensorOutput,TensorObjTypeRGB,TensorFormatInterleaved);
      assert(rc==ZtaStatusOk);

      graph.Add(&nodeInput);
      graph.Add(&nodeConvert2Mono);
      graph.Add(&nodeOpticalFlow);
      graph.Add(&nodeOutput);
      graph.Verify();
   } else if(testcase==TestCaseHarrisCorner) {
      // Graph for harris-corner feature detection
      rc=nodeInput.Create(&tensorInput,&tensor[1],TensorObjTypeRGB,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeConvert2Mono.Create(&tensor[1],&tensor[2],TensorObjTypeMonochromeSingleChannel,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeHarris.Create(&tensor[2],&tensorHarris);
      assert(rc==ZtaStatusOk);
      rc=nodeOutput.Create(&tensor[1],&tensorOutput,TensorObjTypeRGB,TensorFormatInterleaved);
      assert(rc==ZtaStatusOk);

      graph.Add(&nodeInput);
      graph.Add(&nodeConvert2Mono);
      graph.Add(&nodeHarris);
      graph.Add(&nodeOutput);
      graph.Verify();
   } else if(testcase==TestCaseImageClassifier) {
      // Graph for image classifier using Mobinet model
      rc=nodeInput.Create(&tensorInput,&tensor[1],TensorObjTypeRGB,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeResize.Create(&tensor[1],&tensor[2],224,224);
      assert(rc==ZtaStatusOk);
      rc=nodeNN.Create("mobilenet_v2_1_0_224_quant.tflite",&tensor[2],1,&tensorNN[0]);
      assert(rc==ZtaStatusOk);
      rc=nodeNN.LabelLoad("labels_mobilenet_quant_v1_224.txt");
      assert(rc==ZtaStatusOk);

      graphNN.Add(&nodeInput);
      graphNN.Add(&nodeResize);
      graphNN.Add(&nodeNN);
      graphNN.Verify();
      // Graph to show the background camera capture for image classifier
      rc=nodeOutput.Create(&tensorInput,&tensorOutput,TensorObjTypeRGB,TensorFormatInterleaved);
      assert(rc==ZtaStatusOk);
      graph.Add(&nodeOutput);
      graph.Verify();
   } else if(testcase==TestCaseObjectDetection) {
      // Graph for object detection using SSD-Mobinet model.
      rc=nodeInput.Create(&tensorInput,&tensor[1],TensorObjTypeRGB,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeResize.Create(&tensor[1],&tensor[2],300,300);
      assert(rc==ZtaStatusOk);
      rc=nodeNN.Create("detect.tflite",&tensor[2],4,&tensorNN[0],&tensorNN[1],&tensorNN[2],&tensorNN[3]);
      assert(rc==ZtaStatusOk);
      rc=nodeNN.LabelLoad("labelmap.txt");
      assert(rc==ZtaStatusOk);

      graphNN.Add(&nodeInput);
      graphNN.Add(&nodeResize);
      graphNN.Add(&nodeNN);
      graphNN.Verify();
      // Graph to show background camera capture when doing object detection
      rc=nodeOutput.Create(&tensorInput,&tensorOutput,TensorObjTypeRGB,TensorFormatInterleaved);
      assert(rc==ZtaStatusOk);
      graph.Add(&nodeOutput);
      graph.Verify();
   } else if(testcase==TestCaseAll) {
      // Graph to show multitasking capability of ztachip
      // Here we do object detection + edge detection + harris-corner+optical
      // flow at the same time
      // This example also shows how to run 2 graphs simultaneously.
      // The display is partitioned into 4 tiles.
      // Each of the 4 vision tasks output to seperate tile on the display
      int w=WEBCAM_WIDTH/2;
      int h=WEBCAM_HEIGHT/2;
      rc=nodeInput.Create(&tensorInput,&tensor[1],TensorObjTypeRGB,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeResize.Create(&tensor[1],&tensorResize,w,h);
      assert(rc==ZtaStatusOk);
      // Object detection background. The output is the top left tile of full display
      rc=nodeOutputs[0].Create(&tensorResize,&tensorOutputs[0],TensorObjTypeRGB,TensorFormatInterleaved,
                           0,0,0,0,
                           0,0,w*2,h*2);

      assert(rc==ZtaStatusOk);

      // Edge detection

      rc=nodeConvert2Mono.Create(&tensorResize,&tensor[2],TensorObjTypeMonochromeSingleChannel,TensorFormatSplit);
      assert(rc==ZtaStatusOk);
      rc=nodeCanny.Create(&tensor[2],&tensor[3]);
      assert(rc==ZtaStatusOk);
      nodeCanny.SetThreshold(81,100);
      // Output for edge detection is the top right tile of full display
      rc=nodeOutputs[1].Create(&tensor[3],&tensorOutputs[1],TensorObjTypeMonochrome,TensorFormatInterleaved,
                           0,0,0,0,
                           w,0,w*2,h*2);
      assert(rc==ZtaStatusOk);

      // Harris corner
      rc=nodeHarris.Create(&tensor[2],&tensorHarris);
      assert(rc==ZtaStatusOk);
      // Output of harris-corner is the bottom left tile of full display
      rc=nodeOutputs[2].Create(&tensorResize,&tensorOutputs[2],TensorObjTypeRGB,TensorFormatInterleaved,
                           0,0,0,0,
                           0,h,w*2,h*2);
      assert(rc==ZtaStatusOk);

      // OpticalFlow
      rc=nodeOpticalFlow.Create(&tensor[2],
                              &tensorOpticalFlowGradientX,
                              &tensorOpticalFlowGradientY,
                              &tensorOpticalFlowGradientT,
                              &tensorOpticalFlowVectX,
                              &tensorOpticalFlowVectY,
                              &tensorOpticalFlowDisplay);
      assert(rc==ZtaStatusOk);
      // Output of optical flow is the bottom right tile of full display
      rc=nodeOutputs[3].Create(&tensorOpticalFlowDisplay,&tensorOutputs[3],TensorObjTypeRGB,TensorFormatInterleaved,
                           0,0,0,0,
                           w,h,w*2,h*2);
      assert(rc==ZtaStatusOk);

      // ------------------
      // This is the first graph. Doing the vision processing
      // ------------------

      graph.Add(&nodeInput);
      graph.Add(&nodeResize);
      // Object detection background
      graph.Add(&nodeOutputs[0]);
      // Edge detection
      graph.Add(&nodeConvert2Mono);
      graph.Add(&nodeCanny);
      graph.Add(&nodeOutputs[1]);
      // HarrisCorner
      graph.Add(&nodeHarris);
      graph.Add(&nodeOutputs[2]);
      // OpticalFlow
      graph.Add(&nodeOpticalFlow);
      graph.Add(&nodeOutputs[3]);
      graph.Verify();

      //---------------------
      // There is the second graph that doing ObjectDetection AI processing
      // ---------------------

      rc=nodeResizeNN.Create(&tensor[1],&tensorSSDInput,300,300);
      assert(rc==ZtaStatusOk);
      rc=nodeNN.Create("detect.tflite",&tensorSSDInput,4,&tensorNN[0],&tensorNN[1],&tensorNN[2],&tensorNN[3]);
      assert(rc==ZtaStatusOk);
      rc=nodeNN.LabelLoad("labelmap.txt");
      assert(rc==ZtaStatusOk);
      graphNN.Add(&nodeResizeNN);
      graphNN.Add(&nodeNN);
      graphNN.Verify();
   }
   while(1) {
      // Check push button to see if it is time to switch demos
      buttonStatus=PushButtonGetState();
      if(!readyToSwitch) {
         if(buttonStatus == 0)
            readyToSwitch=true;
      }
      if(!graphNN.IsRunning() && readyToSwitch) {
         if(buttonStatus != 0) {
            if(buttonStatus&1) {
               testcase=(TestCase)((int)testcase+1);
               if(testcase >= TestCaseMax)
                  testcase=(TestCase)0;
            } else {
               testcase=((int)testcase==0)?(TestCase)((int)TestCaseMax-1):(TestCase)((int)testcase-1);
            }
            return 0;
         }
      }

      // Check if there is new image ready from camera

      if(CameraCaptureReady()) {
         displayBuffer=DisplayGetBuffer();
         // New capture available...
         tensorInput.Alias((ZTA_SHARED_MEM)CameraGetCapture());
         if(testcase==TestCaseAll) {
            for(int i=0;i < MAX_OUTPUT;i++) {
               tensorOutputs[i].Alias((ZTA_SHARED_MEM)displayBuffer);
            }
         } else {
            tensorOutput.Alias((ZTA_SHARED_MEM)displayBuffer);
         }

         // Execute first graph to completion since these are fast tasks
         graph.Prepare();
         graph.RunUntilCompletion();

         FLUSH_DATA_CACHE();
         if(testcase==TestCaseHarrisCorner || testcase==TestCaseAll) {
            // Update display with point-of-interests from Harris-Corner algorithm
            uint16_t *harris_p=(uint16_t *)tensorHarris.GetBuf();
            int i;
            int w,h;
            if(testcase==TestCaseAll) {
               w=WEBCAM_WIDTH/2;
               h=WEBCAM_HEIGHT/2;
            } else {
               w=WEBCAM_WIDTH;
               h=WEBCAM_HEIGHT;
            }
            for(i=0;i < h;i++) {
               for(j=0;j < w;j++,harris_p++) {
                  if(*harris_p != 0) {
                     GdiDrawPoint((testcase==TestCaseAll)?(i+h):i,j);
                  }
               }
            }
         }
         if(testcase==TestCaseImageClassifier) {
            // Update display with image classifier results if available
            if(top5_valid) {
               for(i=0;i < 5;i++) {
                  sprintf(buf,"%s 0.%02d",nodeNN.LabelGet(top5[i]),(top5_probability[i]*100)>>8);
                  GdiDrawText(buf,(i<<4),0);
               }
            }
         }
         if(testcase==TestCaseObjectDetection || testcase==TestCaseAll) {
              // Update display with object detection boxes if available
            if(ssd_valid) {
               for(int i=0;i < ssd_result_cnt;i++) {
                  sprintf(buf,"%s 0.%02d",(char *)ssd_result[i].label,ssd_result[i].probability);
                  GdiDrawText(buf,
                              ssd_result[i].y1+2,
                              ssd_result[i].x1+2);

                  GdiDrawRectangle(ssd_result[i].y1,
                                 ssd_result[i].x1,
                                 ssd_result[i].y2,
                                 ssd_result[i].x2);
               }
            }
         }
         // Update screen label
         sprintf(buf,"%s %s", (char *)testcase_label[testcase],progress_str[progress_cnt]);
         GdiDrawText(buf,0,WEBCAM_WIDTH-strlen(buf)*ALPHABET_DIM-8);
         if(++progress_cnt>=NUM_PROGRESS)
            progress_cnt=0;
         // Update video memory
         DisplayUpdateBuffer();
      } 
      // There is no new images. Continue to process the second graph
      // for AI processing.
      if(testcase==TestCaseImageClassifier) {
         if(graphNN.IsRunning()) {
            graphNN.Run(GRAPH_EXE_TIMEOUT);
            if(!graphNN.IsRunning()) {
                  // Got new result from image classifier. Save it to display later
                  FLUSH_DATA_CACHE();
                  uint8_t *probability=(uint8_t *)tensorNN[0].GetBuf();
                  NeuralNet::GetTop5(probability,tensorNN[0].GetBufLen(),top5);
                  for(i=0;i < 5;i++) {
                     top5_probability[i]=probability[top5[i]];
                  }
                  top5_valid=true;
            }
         } 
         else {
            graphNN.Prepare();     
         }
      } else if(testcase==TestCaseObjectDetection || testcase==TestCaseAll) {
         if(graphNN.IsRunning()) {
            graphNN.Run(GRAPH_EXE_TIMEOUT);
            if(!graphNN.IsRunning())
            {
               // Got new result from object detection. Save it to display later
               FLUSH_DATA_CACHE();
               float *box_p=(float *)tensorNN[0].GetBuf();
               float *classes_p=(float *)tensorNN[1].GetBuf();
               float *probability_p=(float *)tensorNN[2].GetBuf();
               float *numDetect_p=(float *)tensorNN[3].GetBuf();
               ssd_result_cnt=(int)numDetect_p[0];
               if(ssd_result_cnt > MAX_SSD_RESULT)
                  ssd_result_cnt=MAX_SSD_RESULT;
               if(ssd_result_cnt < 0)
                  ssd_result_cnt=0;
               for(int i=0;i < ssd_result_cnt;i++) {
                  ssd_result[i].x1=box_p[4*i+1]*WEBCAM_WIDTH;
                  ssd_result[i].y1=box_p[4*i+0]*WEBCAM_HEIGHT;
                  ssd_result[i].x2=box_p[4*i+3]*WEBCAM_WIDTH;
                  ssd_result[i].y2=box_p[4*i+2]*WEBCAM_HEIGHT;
                  ssd_result[i].probability=probability_p[i]*100;
                  ssd_result[i].label=nodeNN.LabelGet((int)classes_p[i]);
                  if(testcase==TestCaseAll) {
                     ssd_result[i].x1=ssd_result[i].x1>>1;
                     ssd_result[i].y1=ssd_result[i].y1>>1;
                     ssd_result[i].x2=ssd_result[i].x2>>1;
                     ssd_result[i].y2=ssd_result[i].y2>>1;
                  }
               }
               ssd_valid=true;
            }
         }
         else {
            graphNN.Prepare();     
         }
      }
   }
   return 0;
}

