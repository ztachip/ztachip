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
#include "../../software/target/apps/harris/harris.h"

// Find harris-corner features of interest in an image

int main(int argc,char *argv[]) {
   TENSOR tensorInput;
   TENSOR tensor[5];
   ZtaStatus rc;
   Graph graph;
   GraphNodeColorAndReshape nodeConvert2Mono;
   GraphNodeHarris nodeHarris;
   GraphNodeSinker nodeSinker;

   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   if(argc < 2) {
      printf("Bad parameter: Usage> harris_corner image_file\n");
      exit(-1);
   }

   if(BitmapRead(argv[1],&tensorInput) != ZtaStatusOk) {
      printf("Unable to load image file. Image file format must be 24-bit BMP \n");
      exit(-1);
   }

   // Build graph
   // Color to mono conversion graph node
   rc=nodeConvert2Mono.Create(&tensorInput,&tensor[0],TensorSemanticMonochromeSingleChannel,TensorFormatSplit);
   assert(rc==ZtaStatusOk);
   // Harris corner features extraction node
   rc=nodeHarris.Create(&tensor[0],&tensor[1]);
   assert(rc==ZtaStatusOk);
   // Sinker node
   rc=nodeSinker.Create(2,&tensor[0],&tensor[1]);
   assert(rc==ZtaStatusOk);

   graph.Add(&nodeConvert2Mono);
   graph.Add(&nodeHarris);
   graph.Add(&nodeSinker);

   // Execute graph
   graph.Verify();
   graph.Schedule();

   // Wait for result
   while(graph.Wait(0) != ZtaStatusOk);


   // Draw a dot for each features found in the image 
   int x,y;
   int16_t *p1,*p2;
   uint8_t *p3;
   uint8_t *display=(uint8_t *)tensorInput.GetBuf();
   int w=graph.GetOutputDimension(1,1);
   int h=graph.GetOutputDimension(1,0);
   int w2=((w+3)/4)*4;
   int16_t *score=(int16_t *)graph.GetOutputBuf(1);
   for(y=0,p1=score;y < h;y++,p1+=w) {
      for(x=0,p2=p1;x < w;x++,p2++) {
         if(*p2 != 0) {
            p3=&display[x+y*w2];
            p3[0]=255;
            p3[w2*h]=0;
            p3[2*w2*h]=0;
         }
      }
   }
   BitmapWrite("harris_corner.bmp",&tensorInput);
   // Done with processing result
   graph.Consume();
   return 0;
}

