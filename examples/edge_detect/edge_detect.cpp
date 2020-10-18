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
#include "../../software/target/apps/color/color.h"
#include "../../software/target/apps/resize/resize.h"
#include "../../software/target/apps/canny/canny.h"

// Perform image edge detection using canny algorithm

int main(int argc,char *argv[]) {
   TENSOR tensorInput;
   TENSOR tensor[5];
   ZtaStatus rc;
   Graph graph;
   GraphNodeColorAndReshape nodeConvert2Mono;
   GraphNodeCanny nodeCanny;
   GraphNodeColorAndReshape nodeOutput;
   GraphNodeSinker nodeSinker;

   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   if(argc < 2) {
      printf("Bad parameter: Usage> edge_detect image_file\n");
      exit(-1);
   }

   if(BitmapRead(argv[1],&tensorInput) != ZtaStatusOk) {
      printf("Unable to load image file. Image file format must be 24-bit BMP \n");
      exit(-1);
   }

   // Build processing graph
   // Convert from color to monochrome graph node
   rc=nodeConvert2Mono.Create(&tensorInput,&tensor[0],TensorSemanticMonochromeSingleChannel,TensorFormatSplit);
   assert(rc==ZtaStatusOk);
   // Canny edge detection graph node
   rc=nodeCanny.Create(&tensor[0],&tensor[1]);
   assert(rc==ZtaStatusOk);
   nodeCanny.SetThreshold(80,90);
   // Sinker node
   rc=nodeSinker.Create(1,&tensor[1]);
   assert(rc==ZtaStatusOk);

   graph.Add(&nodeConvert2Mono);
   graph.Add(&nodeCanny);
   graph.Add(&nodeSinker);

   // Execute graph
   graph.Verify();
   graph.Schedule();

   // Wait for result
   while(graph.Wait(0) != ZtaStatusOk);
   BitmapWrite("edge_detect.bmp",graph.GetOutputTensor(0));

   // Done with processing result.
   graph.Consume();
   return 0;
}

