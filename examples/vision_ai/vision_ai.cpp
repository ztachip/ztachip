#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <vector>
#include <string>
#include "webcam.h"
#include "gui.h"
#include "../../software/target/base/ztahost.h"
#include "../../software/target/base/graph.h"
#include "../../software/target/apps/color/color.h"
#include "../../software/target/apps/resize/resize.h"
#include "../../software/target/apps/gaussian/gaussian.h"
#include "../../software/target/apps/nn/tf.h"
#include "../../software/target/apps/canny/canny.h"
#include "../../software/target/apps/equalize/equalize.h"
#include "../../software/target/apps/harris/harris.h"
#include "../../software/target/apps/of/of.h"

// Example on how to use ztachip for vision AI applications
// Input from webcam are processed by ztachip
// Results are shown on GUI using GTK library.
// Show the following vision applications
//    - Image classification using MobinetV2
//    - Object detection using SSD-MobinetV2
//    - Edge detection
//    - Contrast enhancement
//    - Gaussian blurring
//    - Harris-Corner feature extraction
//    - Optical flow
//    - Run objectDetection+edgeDetection+OpticalFlow+HarrisCorner 
//      same time in different windows
//
using namespace std;

#define WEBCAM_WIDTH 640
#define WEBCAM_HEIGHT 480

typedef enum
{
  TestCaseImageClassifier=0,
  TestCaseObjectDetection,
  TestCaseEdgeDetection,
  TestCaseEqualize,
  TestCaseGaussian,
  TestCaseHarrisCorner,
  TestCaseOpticalFlow,
  TestCaseAll,
  TestCaseMax
} TestCase;

static Graph graph(0);
static Graph graphNN(1);
static GraphNodeColorAndReshape nodeInput;
static GraphNodeColorAndReshape nodeOutput;
static GraphNodeColorAndReshape nodeOutputs[4];
static GraphNodeColorAndReshape nodeConvert2Mono;
static GraphNodeResize nodeResize;
static GraphNodeResize nodeResizeNN;
static GraphNodeGaussian nodeGaussian;
static GraphNodeCanny nodeCanny;
static GraphNodeEqualize nodeEqualize;
static GraphNodeHarris nodeHarris;
static GraphNodeOpticalFlow nodeOpticalFlow;
static GraphNodeSinker nodeSinker;
static GraphNodeSinker nodeSinkerNN;
static TfliteNn nodeNN;
static TENSOR tensorInput;
static TENSOR tensorInputNN;
static TENSOR tensorOutput;
static TENSOR tensorResize;
static TENSOR tensorSSDInput;
static TENSOR tensorNN[4];
static TENSOR tensorHarris;
static TENSOR tensorOpticalFlowInput;
static TENSOR tensorOpticalFlowGradientX;
static TENSOR tensorOpticalFlowGradientY;
static TENSOR tensorOpticalFlowGradientT;
static TENSOR tensorOpticalFlowVectX;
static TENSOR tensorOpticalFlowVectY;
static TENSOR tensorOpticalFlowDisplay;
static TENSOR tensor[16];

static TestCase testcase=TestCaseObjectDetection;


// Build processing graph...

int GraphBuild() {
   int i;
   ZtaStatus rc;

   // First create graphNode to accept input from webcam
   std::vector<int> dim={1,WEBCAM_HEIGHT,WEBCAM_WIDTH};
   rc=tensorInput.Create(TensorDataTypeUint16,TensorFormatSplit,TensorSemanticYUYV,dim);
   std::vector<int> dim2={3,WEBCAM_HEIGHT,WEBCAM_WIDTH};
   rc=tensorInputNN.Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim2);

   // Create the rest of the graph based on test case

   switch(testcase) {
      case TestCaseImageClassifier: {
         // Graph for image classifier
         // Classifier is Mobinetv2 image input 224x224
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeResize.Create(&tensor[1],&tensor[2],224,224);
         assert(rc==ZtaStatusOk);
         rc=nodeNN.Create("../models/mobilenet_v2_1.0_224_quant.tflite",&tensor[2],1,&tensorNN[0]);
         assert(rc==ZtaStatusOk);
         rc=nodeNN.LabelLoad("../models/labels_mobilenet_quant_v1_224.txt");
         assert(rc==ZtaStatusOk);
         rc=nodeOutput.Create(&tensor[1],&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved);
         assert(rc==ZtaStatusOk);
         rc=nodeSinker.Create(2,&tensorOutput,&tensorNN[0]);
         assert(rc==ZtaStatusOk);
        
         graph.Add(&nodeInput);
         graph.Add(&nodeResize);
         graph.Add(&nodeNN);
         graph.Add(&nodeOutput);
         graph.Add(&nodeSinker);
         break;
         }
      case TestCaseObjectDetection: {
         // Graph for object detection
         // Object detection is SSD-Mobinetv1.0; image input 300x300
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeResize.Create(&tensor[1],&tensor[2],300,300);
         assert(rc==ZtaStatusOk);
         rc=nodeNN.Create("../models/detect.tflite",&tensor[2],4,&tensorNN[0],&tensorNN[1],&tensorNN[2],&tensorNN[3]);
         assert(rc==ZtaStatusOk);
         rc=nodeNN.LabelLoad("../models/labelmap.txt");
         assert(rc==ZtaStatusOk);
         rc=nodeOutput.Create(&tensor[1],&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved);
         assert(rc==ZtaStatusOk);
         rc=nodeSinker.Create(5,&tensorOutput,&tensorNN[0],&tensorNN[1],&tensorNN[2],&tensorNN[3]);
         assert(rc==ZtaStatusOk);
         
         graph.Add(&nodeInput);
         graph.Add(&nodeResize);
         graph.Add(&nodeNN);
         graph.Add(&nodeOutput);
         graph.Add(&nodeSinker);
         break;
         }
      case TestCaseEdgeDetection: {
         // Graph for edge detection based on Canny algorithm
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeConvert2Mono.Create(&tensor[1],&tensor[2],TensorSemanticMonochromeSingleChannel,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeCanny.Create(&tensor[2],&tensor[3]);
         assert(rc==ZtaStatusOk);
         rc=nodeOutput.Create(&tensor[3],&tensorOutput,TensorSemanticMonochrome,TensorFormatInterleaved);
         assert(rc==ZtaStatusOk);
         rc=nodeSinker.Create(1,&tensorOutput);
         assert(rc==ZtaStatusOk);

         graph.Add(&nodeInput);
         graph.Add(&nodeConvert2Mono);
         graph.Add(&nodeCanny);
         graph.Add(&nodeOutput);
         graph.Add(&nodeSinker);
         break;
         }
      case TestCaseEqualize: {
         // Graph for image equalizer. 
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeConvert2Mono.Create(&tensor[1],&tensor[2],TensorSemanticMonochromeSingleChannel,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeEqualize.Create(&tensor[2],&tensor[3]);
         assert(rc==ZtaStatusOk);
         rc=nodeOutput.Create(&tensor[3],&tensorOutput,TensorSemanticMonochrome,TensorFormatInterleaved);
         assert(rc==ZtaStatusOk);
         rc=nodeSinker.Create(1,&tensorOutput);
         assert(rc==ZtaStatusOk);

         graph.Add(&nodeInput);
         graph.Add(&nodeConvert2Mono);
         graph.Add(&nodeEqualize);
         graph.Add(&nodeOutput);
         graph.Add(&nodeSinker);
         break;
         }
      case TestCaseGaussian: {
         // Graph for gaussian blurring
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeGaussian.Create(&tensor[1],&tensor[2]);
         assert(rc==ZtaStatusOk);
         rc=nodeOutput.Create(&tensor[2],&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved);
         assert(rc==ZtaStatusOk);
         rc=nodeSinker.Create(1,&tensorOutput);
         assert(rc==ZtaStatusOk);

         graph.Add(&nodeInput);
         graph.Add(&nodeGaussian);
         graph.Add(&nodeOutput);
         graph.Add(&nodeSinker);
         break;
         }
      case TestCaseHarrisCorner: {
         // Graph for harris-corner feature detection
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeConvert2Mono.Create(&tensor[1],&tensor[2],TensorSemanticMonochromeSingleChannel,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeHarris.Create(&tensor[2],&tensorHarris);
         assert(rc==ZtaStatusOk);
         rc=nodeOutput.Create(&tensor[1],&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved);
         assert(rc==ZtaStatusOk);
         rc=nodeSinker.Create(2,&tensorOutput,&tensorHarris);
         assert(rc==ZtaStatusOk);

         graph.Add(&nodeInput);
         graph.Add(&nodeConvert2Mono);
         graph.Add(&nodeHarris);
         graph.Add(&nodeOutput);
         graph.Add(&nodeSinker);
         break;
         }
      case TestCaseOpticalFlow: {
         // Graph for optical flow
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeConvert2Mono.Create(&tensor[1],
                                    &tensorOpticalFlowInput,
                                    TensorSemanticMonochromeSingleChannel,
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
         rc=nodeOutput.Create(&tensorOpticalFlowDisplay,&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved);
         assert(rc==ZtaStatusOk);
         rc=nodeSinker.Create(4,&tensorOutput,&tensorOpticalFlowVectX,&tensorOpticalFlowVectY,&tensorOpticalFlowDisplay);
         assert(rc==ZtaStatusOk);

         graph.Add(&nodeInput);
         graph.Add(&nodeConvert2Mono);
         graph.Add(&nodeOpticalFlow);
         graph.Add(&nodeOutput);
         graph.Add(&nodeSinker);
         break;
         }
      case TestCaseAll: {
         int w=WEBCAM_WIDTH/2;
         int h=WEBCAM_HEIGHT/2;
         rc=nodeInput.Create(&tensorInput,&tensor[1],TensorSemanticRGB,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeResize.Create(&tensor[1],&tensorResize,w,h);
         assert(rc==ZtaStatusOk);

         // Object detection background

         rc=nodeOutputs[0].Create(&tensorResize,&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved,
                              0,0,0,0,
                              0,0,w*2,h*2);
         assert(rc==ZtaStatusOk);

         // Edge detection 

         rc=nodeConvert2Mono.Create(&tensorResize,&tensor[2],TensorSemanticMonochromeSingleChannel,TensorFormatSplit);
         assert(rc==ZtaStatusOk);
         rc=nodeCanny.Create(&tensor[2],&tensor[3]);
         assert(rc==ZtaStatusOk);
         rc=nodeOutputs[1].Create(&tensor[3],&tensorOutput,TensorSemanticMonochrome,TensorFormatInterleaved,
                              0,0,0,0,
                              w,0,w*2,h*2);
         assert(rc==ZtaStatusOk);

         // Harris corner
         rc=nodeHarris.Create(&tensor[2],&tensorHarris);
         assert(rc==ZtaStatusOk);
         rc=nodeOutputs[2].Create(&tensorResize,&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved,
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
         rc=nodeOutputs[3].Create(&tensorOpticalFlowDisplay,&tensorOutput,TensorSemanticRGB,TensorFormatInterleaved,
                              0,0,0,0,
                              w,h,w*2,h*2);
         assert(rc==ZtaStatusOk);

         rc=nodeSinker.Create(3,&tensorOutput,&tensorHarris,&tensor[1]);
         assert(rc==ZtaStatusOk);

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
         // Sinker
         graph.Add(&nodeSinker);


         rc=nodeResizeNN.Create(&tensorInputNN,&tensorSSDInput,300,300);
         assert(rc==ZtaStatusOk);
         rc=nodeNN.Create("../models/detect.tflite",&tensorSSDInput,4,&tensorNN[0],&tensorNN[1],&tensorNN[2],&tensorNN[3]);
         assert(rc==ZtaStatusOk);
         rc=nodeNN.LabelLoad("../models/labelmap.txt");
         assert(rc==ZtaStatusOk);
         rc=nodeSinkerNN.Create(4,&tensorNN[0],&tensorNN[1],&tensorNN[2],&tensorNN[3]);
         assert(rc==ZtaStatusOk);
         graphNN.Add(&nodeResizeNN);
         graphNN.Add(&nodeNN);
         graphNN.Add(&nodeSinkerNN);
         break;
         }
      default:
         break;
   }
   rc=graph.Verify();
   assert(rc==ZtaStatusOk);
   if(testcase==TestCaseAll) {
      rc=graphNN.Verify();
      assert(rc==ZtaStatusOk);
   }
   return 0;
}

// Annotate display with more result information

int Display(uint8_t *display,bool nnResultReady) {
   int w=tensorOutput.GetDimension(2);
   int h=tensorOutput.GetDimension(1);

   memcpy(display,graph.GetOutputBuf(0),graph.GetOutputBufLen(0));
   switch(testcase) {
      case TestCaseImageClassifier: {
         // Annotate image classification result on screen
         static char str[1024];
         int top5[5];
         uint8_t *result=(uint8_t *)graph.GetOutputBuf(1);
         int resultLen=graph.GetOutputBufLen(1);
         nodeNN.GetTop5(result,resultLen,top5);
         strcpy(str,"<span foreground='red'>");
         for(int i=0;i < 5;i++) {
            sprintf(&str[strlen(str)],"%0.3f %s\n", (float)(result[top5[i]]/255.0),nodeNN.LabelGet(top5[i]));
         }
         strcat(str,"</span>");
         GuiSetText(str);
         break;
         }
      case TestCaseObjectDetection: {
         // Draw rectangles around detection boxes
         int topResult;
         float topProbability;
         char str[200];
         float *box_p=(float *)graph.GetOutputBuf(1);
         float *classes_p=(float *)graph.GetOutputBuf(2);
         float *probability_p=(float *)graph.GetOutputBuf(3);
         float *numDetect_p=(float *)graph.GetOutputBuf(4);
         GuiDrawClear(w,h);
         for(int i=0;i < (int)numDetect_p[0];i++) {
            int xmin=(int)(box_p[4*i+1]*w);
            int ymin=(int)(box_p[4*i+0]*h);
            int xmax=(int)(box_p[4*i+3]*w);
            int ymax=(int)(box_p[4*i+2]*h);
            topResult=(int)classes_p[i];
            topProbability=probability_p[i];
            sprintf(str,"%0.3f %s", topProbability,nodeNN.LabelGet(topResult));
            GuiDrawRectangle(xmin,ymin,xmax-xmin+1,ymax-ymin+1,str);
         }
         break;
         }
      case TestCaseEdgeDetection: {
         char str[200];
         int lo,hi;
         static int last_hi=-1;
         // Update edge detection threshold based on slider setting
         nodeCanny.GetThreshold(&lo,&hi);
         hi=255-(int)(GuiGetScale()*(float)(255-lo));
         if(hi>255)
            hi=255;
         if(hi < lo)
            hi=lo;
         if(last_hi != hi)
            nodeCanny.SetThreshold(lo,hi);
         last_hi=hi;
         break;
         }
      case TestCaseEqualize: {
         static float lastContrast=-1.0;
         float contrast;
         // Update equalizer setting based on slider value
         contrast=1.0+GuiGetScale()*20.0;
         if(contrast != lastContrast) {
            nodeEqualize.SetContrast(contrast);
         }
         lastContrast=contrast;
         break;
         }
      case TestCaseGaussian: {
         char str[200];
         static float last_sigma=-1;
         float sigma;

         // Update gaussian sigma based on slider setting
         sigma=0.5+2.0*GuiGetScale();
         if(sigma != last_sigma)
            nodeGaussian.SetSigma(sigma);
         last_sigma=sigma;
         break;
         }
      case TestCaseHarrisCorner: {
         // Display detected corners
         int x,y;
         int16_t *p1,*p2;
         uint8_t *p3;
         int w=graph.GetOutputDimension(1,1);
         int h=graph.GetOutputDimension(1,0);
         int16_t *zero=(int16_t *)malloc(w*sizeof(int16_t));
         int16_t *score=(int16_t *)malloc(w*h*sizeof(int16_t));
         memcpy(score,graph.GetOutputBuf(1),w*h*sizeof(int16_t));
         memset(zero,0,w*sizeof(int16_t));
         for(y=0,p1=score;y < h;y++,p1+=w) {
            p2=p1;
            if(memcmp(p2,zero,w*sizeof(int16_t))==0)
               continue;
            for(x=0;x < w;x++,p2++) {
               if(*p2 != 0) {
                  p3=&display[3*(x+y*w)];
                  p3[0]=0;
                  p3[1]=255;
                  p3[2]=0;
                  if(x!=(w-1) && y!=(h-1)) {
                     p3+=3;
                     p3[0]=0;
                     p3[1]=255;
                     p3[2]=0;
                     p3+=(w*3);
                     p3[0]=0;
                     p3[1]=255;
                     p3[2]=0;
                     p3-=3;
                     p3[0]=0;
                     p3[1]=255;
                     p3[2]=0;
                  }
               } 
            }
         }
         free(score);
         free(zero);
         break;
         }
      case TestCaseOpticalFlow: {
         break;
         }
      case TestCaseAll: {
         // Display detected corners
         int x,y;
         int16_t *p1,*p2;
         uint8_t *p3;
         int w=graph.GetOutputDimension(1,1);
         int h=graph.GetOutputDimension(1,0);
         int16_t *score=(int16_t *)malloc(w*h*sizeof(int16_t));
         int16_t *zero=(int16_t *)malloc(w*sizeof(int16_t));
         memset(zero,0,w*sizeof(int16_t));
         memcpy(score,graph.GetOutputBuf(1),w*h*sizeof(int16_t));
         for(y=0,p1=score;y < h;y++,p1+=w) {
            p2=p1;
            if(memcmp(p2,zero,w*sizeof(int16_t))==0)
               continue;
            for(x=0;x < w;x++,p2++) {
               if(*p2 != 0) {
                  p3=&display[3*(x+(y+h)*2*w)];
                  p3[0]=0;
                  p3[1]=255;
                  p3[2]=0;
                  if(x!=(w-1) && y!=(h-1)) {
                     p3+=3;
                     p3[0]=0;
                     p3[1]=255;
                     p3[2]=0;
                     p3+=(2*w*3);
                     p3[0]=0;
                     p3[1]=255;
                     p3[2]=0;
                     p3-=3;
                     p3[0]=0;
                     p3[1]=255;
                     p3[2]=0;
                  }
               }
            }
         }
         free(score);
         free(zero);
         if(nnResultReady) {
            int topResult;
            float topProbability;
            char str[200];
            float *box_p=(float *)graphNN.GetOutputBuf(0);
            float *classes_p=(float *)graphNN.GetOutputBuf(1);
            float *probability_p=(float *)graphNN.GetOutputBuf(2);
            float *numDetect_p=(float *)graphNN.GetOutputBuf(3);
            GuiDrawClear(0,0);
            for(int i=0;i < (int)numDetect_p[0];i++) {
               int xmin=(int)(box_p[4*i+1]*w);
               int ymin=(int)(box_p[4*i+0]*h);
               int xmax=(int)(box_p[4*i+3]*w);
               int ymax=(int)(box_p[4*i+2]*h);
               topResult=(int)classes_p[i];
               topProbability=probability_p[i];
               sprintf(str,"%0.3f %s", topProbability,nodeNN.LabelGet(topResult));
               GuiDrawRectangle(xmin,ymin,xmax-xmin+1,ymax-ymin+1,str);
            }
         }
         break;
         }
      default:
         break;
   }
   return 0;
}

void help() {
   printf("Invalid parameter: Use...\n");
   printf("camera_in <testID>\n");
   printf("  0:Image classifier\n");
   printf("  1:Object detection\n");
   printf("  2:Edge detection. Hit '1' '2' '3' '4' to change threshold\n");
   printf("  3:Equalizer/Contrast enhancer. Hit '1' '2' to change contrast\n");
   printf("  4:Image blurring: Hit '1' '2' to change blurring effect\n");
   printf("  5:Harris corner detection\n");
   printf("  6:Optical flow \n");
   printf("  7:ObjectDetection+EdgeDetection+HarrisCornerDetection+OpticalFlow\n");
}

// This is called periodically
// Get webcam image and forward to ztachip to process
// When processing done then update display

static int poll(unsigned char *display) {
   uint8_t *imageCapture;

   if(graph.IsBusy())
      graph.Wait(0);
   if(testcase==TestCaseAll && graphNN.IsBusy())
      graphNN.Wait(0);
   if(!graph.IsBusy() && graph.GetOutputAvail()<=1) {
      if(WebcamCapture((uint16_t *)tensorInput.GetBuf())) {
         graph.Schedule();
      } else {
      }
   }
   if(graph.GetOutputAvail()>0) {
      if(testcase==TestCaseAll && !graphNN.IsBusy() && graphNN.GetOutputAvail()<=1) {
         memcpy(tensorInputNN.GetBuf(),graph.GetOutputBuf(2),tensorInputNN.GetBufLen());
         graphNN.Schedule();
      }
      if(testcase==TestCaseAll && graphNN.GetOutputAvail()>0) {
         Display(display,true);
         graphNN.Consume();
      } else {
         Display(display,false);
      }
      graph.Consume();
      return true;
   } else {
      return false;
   }
}

int main(int argc,char *argv[]) {
   int ch;
   uint8_t *imageCapture;

   if(argc != 2) {
      help();
      return -1;
   }
   testcase=(TestCase)(*argv[1]-'0');
   if(testcase < 0 || testcase >= TestCaseMax) {
      help();
      return -1;
   }
   
   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   if(GraphBuild())
      return -1;

   int w=graph.GetOutputDimension(0,2);
   int h=graph.GetOutputDimension(0,1);
   bool showSlider,showLabel,showDraw;

   switch(testcase) {
      case TestCaseImageClassifier: 
         showSlider=false;showLabel=true;showDraw=false;
         break;
      case TestCaseObjectDetection: 
         showSlider=false;showLabel=false;showDraw=true;
         break;
      case TestCaseEdgeDetection:
         showSlider=true;showLabel=false;showDraw=false;
         break;
      case TestCaseEqualize: 
         showSlider=true;showLabel=false;showDraw=false;
         break;
      case TestCaseGaussian:
         showSlider=true;showLabel=false;showDraw=false;
         break;
      case TestCaseHarrisCorner: 
         showSlider=false;showLabel=false;showDraw=false;
         break;
      case TestCaseOpticalFlow:
         showSlider=false;showLabel=false;showDraw=false;
         break;
      case TestCaseAll:
         showSlider=false;showLabel=false;showDraw=true;
         break;
      default:
         assert(0);
   }

   GuiInit(argc,argv,w,h,showSlider,showLabel,showDraw);

   if(WebcamInit(WEBCAM_WIDTH,WEBCAM_HEIGHT))
      return 1; 
   GuiRun(poll); 
   WebcamClose();
   return 0;
}
