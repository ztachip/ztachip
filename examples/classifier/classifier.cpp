#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <vector>
#include <string>
#include "../../software/target/base/bitmap.h"
#include "../../software/target/base/ztahost.h"
#include "../../software/target/base/graph.h"
#include "../../software/target/apps/resize/resize.h"
#include "../../software/target/apps/nn/tf.h"

// Image classification with MobinetV2
// Execute tflite model as is from Google (no retraining required) 
//
int main(int argc,char *argv[]) {
   int w=224,h=224;
   TENSOR tensorInput;
   TENSOR tensorOutput;
   TENSOR tensor[1];
   ZtaStatus rc;
   Graph graph;
   GraphNodeResize nodeResize;
   GraphNodeSinker nodeSinker;
   TfliteNn nodeNN;
   int top5[5];
   bool resize;

   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   if(argc < 2) {
      printf("Bad parameter: Usage> classifier image_file\n");
      exit(-1);
   }

   if(BitmapRead(argv[1],&tensorInput) != ZtaStatusOk) {
      printf("Unable to load image file. Image file format must be 24-bit BMP \n");
      exit(-1);
   }

   if(tensorInput.GetDimension(1)==h && tensorInput.GetDimension(2)==w) {
      // Create graph without image resize step because input image has already
      // the right dimension (224x224)
      resize=false;
      // TFLITE graph node
      rc=nodeNN.Create("../models/mobilenet_v2_1.0_224_quant.tflite",&tensorInput,1,&tensorOutput);
      if(rc!=ZtaStatusOk) {
         printf("Unable to load mobinet model \n");
         exit(-1);
      }
      nodeNN.LabelLoad("../models/labels_mobilenet_quant_v1_224.txt");
      // Sinker graph node
      rc=nodeSinker.Create(1,&tensorOutput);
      assert(rc==ZtaStatusOk);
      graph.Add(&nodeNN);
      graph.Add(&nodeSinker);
   } else {
      // Create graph with image resize step
      // Image resize is required when input image is not 224x224
      resize=true;
      if(tensorInput.GetDimension(1) < h || tensorInput.GetDimension(2) < w) {
         printf("Picture dimension has to be >= 224\n");
         exit(-1);
      }
      // Have to resize image first
      // Image resize graph node
      rc=nodeResize.Create(&tensorInput,&tensor[0],h,w);
      assert(rc==ZtaStatusOk);
      // TFLITE graph node
      rc=nodeNN.Create("mobilenet_v2_1.0_224_quant.tflite",&tensor[0],1,&tensorOutput);
      if(rc!=ZtaStatusOk) {
         printf("Unable to load mobinet model \n");
         exit(-1);
      }
      nodeNN.LabelLoad("labels_mobilenet_quant_v1_224.txt");
      // Sinker graph node
      rc=nodeSinker.Create(1,&tensorOutput);
      assert(rc==ZtaStatusOk);

      graph.Add(&nodeResize);
      graph.Add(&nodeNN);
      graph.Add(&nodeSinker);

      printf("Resize input image\n");
   }

   // Run the graph
   graph.Verify();
   graph.Schedule();

   // Wait for result
   while(graph.Wait(0) != ZtaStatusOk);

   // Calculate top5 result 
   uint8_t *probability=(uint8_t *)graph.GetOutputBuf(0);
   NeuralNet::GetTop5(probability,graph.GetOutputBufLen(0),top5);
   printf("Elapsed time%s=%d.%03d msec \n",resize?"(Including image resize)":"",graph.GetElapsedTime()/1000,graph.GetElapsedTime()%1000);
   for(int i=0;i < 5;i++) {
      printf("   %d %s %f\n",top5[i],nodeNN.LabelGet(top5[i]),(float)probability[top5[i]]/255.0);
   }

   // Done with processing result.
   graph.Consume();
   return 0;
}

