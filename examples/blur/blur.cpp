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
#include "../../software/target/apps/gaussian/gaussian.h"

// Blur image using Gaussian filtering

int main(int argc,char *argv[]) {
   TENSOR tensorInput;
   TENSOR tensor[4];
   ZtaStatus rc;
   Graph graph;
   GraphNodeGaussian nodeGaussian;
   GraphNodeSinker nodeSinker;

   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   if(argc < 2) {
      printf("Bad parameter: Usage> blur image_file\n");
      exit(-1);
   }
   if(BitmapRead(argv[1],&tensorInput) != ZtaStatusOk) {
      printf("Unable to load image file. Image file format must be 24-bit BMP \n");
      exit(-1);
   }

   // Create the graph
   // Gaussian filter graph node
   rc=nodeGaussian.Create(&tensorInput,&tensor[0]);
   assert(rc==ZtaStatusOk);
   nodeGaussian.SetSigma(1.5);
   // Sinker graph node
   rc=nodeSinker.Create(1,&tensor[0]);
   assert(rc==ZtaStatusOk);

   graph.Add(&nodeGaussian);
   graph.Add(&nodeSinker);

   // Execute the graph
   graph.Verify();
   graph.Schedule();

   // Wait for result
   while(graph.Wait(0) != ZtaStatusOk);

   BitmapWrite("blur.bmp",graph.GetOutputTensor(0));

   // Done with processing the result
   graph.Consume();
   return 0;
}

