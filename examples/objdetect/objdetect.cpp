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

// Object detection using Mobinet-SSDv1.
// Use TFLITE model from Google as is. (no retraining required)

int main(int argc,char *argv[]) {
   int w=300,h=300;
   TENSOR tensorInput;
   TENSOR tensor[5];
   ZtaStatus rc;
   Graph graph;
   GraphNodeResize nodeResize;
   GraphNodeSinker nodeSinker;
   TfliteNn nodeNN;
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
      // No image resize necessary
      resize=false;
      // Build graph
      // TFLITE graph node
      rc=nodeNN.Create("../models/detect.tflite",&tensorInput,4,&tensor[0],&tensor[1],&tensor[2],&tensor[3]);
      if(rc!=ZtaStatusOk) {
         printf("Unable to load mobinet model \n");
         exit(-1);
      }
      nodeNN.LabelLoad("../models/labelmap.txt");
      // Sinker node
      rc=nodeSinker.Create(4,&tensor[0],&tensor[1],&tensor[2],&tensor[3]);
      assert(rc==ZtaStatusOk);

      graph.Add(&nodeNN);
      graph.Add(&nodeSinker);
   } else {
      resize=true;
      if(tensorInput.GetDimension(1) < h || tensorInput.GetDimension(2) < w) {
         printf("Picture dimension has to be >= 300\n");
         exit(-1);
      }
      // Have to resize image first
      // Build graph
      // Image resize graph node
      rc=nodeResize.Create(&tensorInput,&tensor[0],h,w);
      assert(rc==ZtaStatusOk);
      // TFLITE graph node
      rc=nodeNN.Create("../models/detect.tflite",&tensor[0],4,&tensor[1],&tensor[2],&tensor[3],&tensor[4]);
      if(rc!=ZtaStatusOk) {
         printf("Unable to load mobinet model \n");
         exit(-1);
      }
      nodeNN.LabelLoad("../models/labelmap.txt");
      // Sinker graph node
      rc=nodeSinker.Create(4,&tensor[1],&tensor[2],&tensor[3],&tensor[4]);
      assert(rc==ZtaStatusOk);

      graph.Add(&nodeResize);
      graph.Add(&nodeNN);
      graph.Add(&nodeSinker);

      printf("Resize input image\n");
   }
   // Execute the graph
   graph.Verify();
   graph.Schedule();

   // Wait for result...
   while(graph.Wait(0) != ZtaStatusOk);

   // Print out detection boxes
   float *box_p=(float *)graph.GetOutputBuf(0);
   float *classes_p=(float *)graph.GetOutputBuf(1);
   float *probability_p=(float *)graph.GetOutputBuf(2);
   float *numDetect_p=(float *)graph.GetOutputBuf(3);

   printf("Elapsed time%s=%d.%03d msec \n",resize?"(Including image resize)":"",graph.GetElapsedTime()/1000,graph.GetElapsedTime()%1000);

   for(int i=0;i < (int)numDetect_p[0];i++) {
      printf("   %s: xmin=%f ymin=%f xmax=%f ymax=%f score=%f class=%d \n",
      nodeNN.LabelGet((int)classes_p[i]), 
      box_p[4*i+1],box_p[4*i+0],box_p[4*i+3],box_p[4*i+2],
      probability_p[i],(int)classes_p[i]);
   }

   // Done with processing result
   graph.Consume();
   return 0;
}

