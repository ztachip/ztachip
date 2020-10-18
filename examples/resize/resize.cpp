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

// Image resize with boxing method

int main(int argc,char *argv[]) {
   int w,h;
   TENSOR tensorInput;
   TENSOR tensor[4];
   ZtaStatus rc;
   Graph graph;
   GraphNodeResize nodeResize;
   GraphNodeSinker nodeSinker;

   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   if(argc < 2) {
      printf("Bad parameter: Usage> resize image_file\n");
      exit(-1);
   }
   if(BitmapRead(argv[1],&tensorInput) != ZtaStatusOk) {
      printf("Unable to load image file. Image file format must be 24-bit BMP \n");
      exit(-1);
   }
   w=tensorInput.GetDimension(2);
   h=tensorInput.GetDimension(1);
   // Build graph
   // Image resize graph node
   rc=nodeResize.Create(&tensorInput,&tensor[0],h/2,w/2);
   assert(rc==ZtaStatusOk);
   // Sinker graph node
   rc=nodeSinker.Create(1,&tensor[0]);
   assert(rc==ZtaStatusOk);

   graph.Add(&nodeResize);
   graph.Add(&nodeSinker);

   // Execute graph
   graph.Verify();
   graph.Schedule();

   // Wait for result
   while(graph.Wait(0) != ZtaStatusOk);

   BitmapWrite("resize.bmp",graph.GetOutputTensor(0));

   // Done with process result
   graph.Consume();
   return 0;
}

