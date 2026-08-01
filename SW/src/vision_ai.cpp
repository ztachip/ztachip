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
#include "../apps/llm/llm.h"

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

#define GRAPH_AI_EXE_TIMEOUT 15 // 15msec

#define AI_OUTPUT_NUM_LINE 3 // Number of lines to show AI output

#define AI_OUTPUT_LINE_WIDTH (WEBCAM_WIDTH/ALPHABET_DIM)

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
  TestCaseChatbot,
  TestCaseAll,
  TestCaseMax
} TestCase;

static const char *testcase_label[TestCaseMax]= {
   "ImgClassifier",
   "ObjectDetect",
   "EdgeDetect",
   "PointOfInterest",
   "MotionDectect",
   "Chatbot",
   "MultiTasking"
};

#define NUM_PROGRESS  8

static const char *progress_str[NUM_PROGRESS]={"|","/","-","\\","|","/","-","\\"};

static TestCase testcase=TestCaseObjectDetection;

static Graph graphLLM;

static GraphNodeLLM nodeLLM;

// Class to implement chatbot UI
class Chatbot_UI {
public:
   Chatbot_UI();
   ~Chatbot_UI();
   ZtaStatus Create(bool _active);
   char *GetInput();
   void BlinkCursor();
   void SwitchToUser();
   void ShowResponse(std::string &output);
public:
   char m_aiOutputLine[AI_OUTPUT_NUM_LINE][AI_OUTPUT_LINE_WIDTH+1];
   int m_aiOutputLineLen[AI_OUTPUT_NUM_LINE];
   bool m_inputPending;
   bool m_active;
   int m_inputLen;   
   char m_input[256];
};

static Chatbot_UI chatbotUI;

// Chatbot UI constructor
Chatbot_UI::Chatbot_UI() {
   m_inputLen = 0;
   m_inputPending = true;
   m_active = false;
   for(int i=0;i < AI_OUTPUT_NUM_LINE;i++)
      m_aiOutputLineLen[i] = 0; 
}

Chatbot_UI::~Chatbot_UI() {
}

ZtaStatus Chatbot_UI::Create(bool _active) {
   m_inputLen = 0;
   m_inputPending = true;
   m_active = _active;
   for(int i=0;i < AI_OUTPUT_NUM_LINE;i++) {
      memset(m_aiOutputLine[i],' ',AI_OUTPUT_LINE_WIDTH);
      m_aiOutputLine[i][AI_OUTPUT_LINE_WIDTH] = 0;
      m_aiOutputLineLen[i] = 0; 
   }
   if(_active) {
      m_aiOutputLine[0][0]='_';
      m_aiOutputLineLen[0]=1;
      strcpy(m_aiOutputLine[1],"Ask LLM a question");
      m_aiOutputLineLen[1]=strlen(m_aiOutputLine[1]);
      m_aiOutputLine[1][m_aiOutputLineLen[1]]=' ';
   }
   else {
      strcpy(m_aiOutputLine[1],"LLM is not available.");
      m_aiOutputLineLen[1]=strlen(m_aiOutputLine[1]);
      m_aiOutputLine[1][m_aiOutputLineLen[1]]=' ';

      strcpy(m_aiOutputLine[0],"Error download model.");
      m_aiOutputLineLen[0]=strlen(m_aiOutputLine[0]);
      m_aiOutputLine[0][m_aiOutputLineLen[0]]=' ';
   }
   return ZtaStatusOk;
}

// If Im in user input mode then blink the cursor
void Chatbot_UI::BlinkCursor() {
   if(!m_active)
      return;
   if(m_inputPending) {
      if(m_aiOutputLine[0][m_aiOutputLineLen[0]-1]=='_')
         m_aiOutputLine[0][m_aiOutputLineLen[0]-1]=' ';
      else
         m_aiOutputLine[0][m_aiOutputLineLen[0]-1]='_';
   }
}

// If Im not in user input mode then show the LLM response
void Chatbot_UI::ShowResponse(std::string &output) {
   if(!m_active)
      return;
   if(!m_inputPending) {
      const char *str = output.c_str();
      for(int i=0;i < (int)output.size();i++) {
         m_aiOutputLine[0][m_aiOutputLineLen[0]] = str[i];
         m_aiOutputLineLen[0]++;
         if(m_aiOutputLineLen[0] >= AI_OUTPUT_LINE_WIDTH) {
            for(int i=AI_OUTPUT_NUM_LINE-1;i >= 1;i--) {
               memcpy(m_aiOutputLine[i],m_aiOutputLine[i-1],sizeof(m_aiOutputLine[1]));
               m_aiOutputLineLen[i] = m_aiOutputLineLen[i-1];
            }
            m_aiOutputLineLen[0] = 0;
            memset(m_aiOutputLine[0],' ',AI_OUTPUT_LINE_WIDTH);
         }
      }
   }
}

// Get and process keyboard input
char *Chatbot_UI::GetInput()
{
   char ch;

   if(!m_active) {
      // LLM not available.
      // Flush serial input queue
      while(UartReadAvailable()) {
         UartRead();
      }
      return 0;
   }
   for(;;) {    
      if(UartReadAvailable()) {
         if(!m_inputPending) {
            for(int i=AI_OUTPUT_NUM_LINE-1;i >= 1;i--) {
               memcpy(m_aiOutputLine[i],m_aiOutputLine[i-1],AI_OUTPUT_LINE_WIDTH);
               m_aiOutputLineLen[i] = m_aiOutputLineLen[i-1];
            }
            memset(m_aiOutputLine[0],' ',AI_OUTPUT_LINE_WIDTH);
            m_aiOutputLineLen[0] = 1;
            m_aiOutputLine[0][0] = '_';
            m_inputPending = true;
         }
         ch = UartRead();
         printf("%c",ch);
         fflush(stdout);
         if(ch==0x3) {
            memset(m_aiOutputLine[0],' ',AI_OUTPUT_LINE_WIDTH);
            m_aiOutputLineLen[0]=1;
            m_aiOutputLine[0][0]='_';
            m_inputLen = 0;
         }
         else if(ch=='\n' || ch=='\r') {
            printf("\r\n");
            fflush(stdout);
            m_input[m_inputLen]=0;
            m_inputLen = 0;
            m_inputPending = false;
            for(int i=AI_OUTPUT_NUM_LINE-1;i >= 1;i--) {
               memcpy(m_aiOutputLine[i],m_aiOutputLine[i-1],AI_OUTPUT_LINE_WIDTH);
               m_aiOutputLineLen[i] = m_aiOutputLineLen[i-1];
            }
            if(m_aiOutputLineLen[1]>0) {
               m_aiOutputLine[1][m_aiOutputLineLen[1]-1]=' ';
               m_aiOutputLineLen[1]--;
            }
            memset(m_aiOutputLine[0],' ',AI_OUTPUT_LINE_WIDTH);
            m_aiOutputLineLen[0] = 0;
            return m_input;
         } else if(ch=='\b') {
            if(m_inputLen > 0) {
               m_inputLen--;
               if(m_aiOutputLineLen[0] > 1) {
                  m_aiOutputLine[0][m_aiOutputLineLen[0]-1] = ' ';
                  m_aiOutputLine[0][m_aiOutputLineLen[0]-2] = '_';
                  m_aiOutputLineLen[0]--;
               }
            }
         } else {
            if(m_inputLen < (int)(sizeof(m_input)-1)) {
               m_input[m_inputLen++]=ch;
               m_aiOutputLine[0][m_aiOutputLineLen[0]-1]=ch;
               if(m_aiOutputLineLen[0] < AI_OUTPUT_LINE_WIDTH) {
                  m_aiOutputLine[0][m_aiOutputLineLen[0]]='_';
                  m_aiOutputLineLen[0]++;
               } 
               else {
                  for(int i=AI_OUTPUT_NUM_LINE-1;i >= 1;i--) {
                     memcpy(m_aiOutputLine[i],m_aiOutputLine[i-1],AI_OUTPUT_LINE_WIDTH);
                     m_aiOutputLineLen[i] = m_aiOutputLineLen[i-1];
                  }
                  memset(m_aiOutputLine[0],' ',AI_OUTPUT_LINE_WIDTH); 
                  m_aiOutputLine[0][0] = '_';
                  m_aiOutputLineLen[0] = 1;
               }
            }
         } 
      }
      else
         break;
   }
   return 0;
}

// Switch chatbot to user entering query mode
void Chatbot_UI::SwitchToUser() {
   if(!m_active)
      return;
   if(!m_inputPending) {
      for(int i=AI_OUTPUT_NUM_LINE-1;i >= 1;i--) {
         memcpy(m_aiOutputLine[i],m_aiOutputLine[i-1],AI_OUTPUT_LINE_WIDTH);
         m_aiOutputLineLen[i] = m_aiOutputLineLen[i-1];
      }
      memset(m_aiOutputLine[0],' ',AI_OUTPUT_LINE_WIDTH);
      m_aiOutputLineLen[0] = 1;
      m_aiOutputLine[0][0] = '_';
      m_inputPending = true;
      printf("\r\n>");
      fflush(stdout);
   }
}

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
   static bool initLLM=false;
   static bool runLLM=false;
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
   int buttonIsPressed=0;
   int progress_cnt=0;
   uint8_t *displayBuffer;

   if(!initLLM) {
      // LLM is a large Graph node with long weight download so so create
      // LLM graph just once...
      nodeLLM.Create();

      rc=nodeLLM.Open("SMOLLM2.ZUF");
      if(rc==ZtaStatusOk)
         runLLM = true;
      else
         runLLM = false;
      if(runLLM) {
         chatbotUI.Create(true);
         printf("\r\n>");
         fflush(stdout);
         graphLLM.Add(&nodeLLM);
         graphLLM.Verify();
         nodeLLM.SetSamplingPolicy(0.6,0.9,0.05,40,40); // temperature=0.7,p-threshold=0.9;min_p=0.05,
         nodeLLM.SystemPrompt((char*)"You answer questions briefly");
      } else {
         chatbotUI.Create(false);
      }
      initLLM = true;
   }

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
   } else if(testcase==TestCaseChatbot) {
      // IN chat mode, we like to show what the camera input so that we can ask LLM about
      // what is sees
      // LLM graph is only created once since it is large with long weight download
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
      if(buttonStatus)
         buttonIsPressed=10;
      else if(buttonIsPressed>0)
         buttonIsPressed--;
      if(!readyToSwitch) {
         if(buttonStatus)
            readyToSwitch=true;
      }
      if(!graphNN.IsRunning() && readyToSwitch) {
         if(buttonIsPressed==0) {
            testcase=(TestCase)((int)testcase+1);
            if(testcase >= TestCaseMax)
               testcase=(TestCase)0;
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
         if(testcase==TestCaseAll || testcase==TestCaseChatbot) {
            // Display chatbot window
            chatbotUI.BlinkCursor();
            for(int i=0;i < AI_OUTPUT_NUM_LINE;i++) {
               GdiDrawText((const char *)chatbotUI.m_aiOutputLine[i],
                           WEBCAM_HEIGHT-ALPHABET_DIM*(i+1)-1,
                           0);
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
      if(testcase==TestCaseAll || testcase==TestCaseChatbot) {
         // In these test cases, process LLM graph
         char *prompt = chatbotUI.GetInput();
         if(prompt) {
            // Got a new query from user
            nodeLLM.Clear(); 
            nodeLLM.ClearStat();
            nodeLLM.UserPrompt(prompt);
            graphLLM.Prepare(); // Restart LLM graph execution for new query
            printf("\r\n");
            fflush(stdout);
         }
         if(graphLLM.IsRunning()) {
            // Continu with LLM execution
            graphLLM.Run(GRAPH_AI_EXE_TIMEOUT);
         }
         else {
            // If LLM is not running then swith to user input mode to get
            // next query from users
            chatbotUI.SwitchToUser();
         }
         if(nodeLLM.m_output.size() > 0) {
            // Update chatbot UI for any LLM responses.
            chatbotUI.ShowResponse(nodeLLM.m_output);
            nodeLLM.m_output.clear();
         }
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

