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
#include "ma_add.h"
#include "ma_scale.h"

// Blur image using Gaussian filtering

int main(int argc,char *argv[]) {
   TENSOR tensorInput[2];
   TENSOR tensorTemp[2];
   ZtaStatus rc;
   Graph graph;
   GraphNodeMaAdd nodeMaAdd;
   GraphNodeMaScale nodeMaScale;
   GraphNodeSinker nodeSinker;
   int masz=1000; // Matrix size=1000

   // Load ztachip image to FPGA
   ztahostInit("../../software/target/builds/ztachip.hex",0x80000,512*0x100000,512*0x100000,true);

   // Create input tensors for matrix addition X and Y
   std::vector<int> dim={masz};
   tensorInput[0].Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim);
   tensorInput[1].Clone(&tensorInput[0]);

   // Initialize input tensors with some values
   uint8_t *x=(uint8_t *)tensorInput[0].GetBuf();
   uint8_t *y=(uint8_t *)tensorInput[1].GetBuf();
   for(int i=0;i < masz;i++) {
      x[i]=(i%16);
      y[i]=(i%16)+1;
   }
   // Create the graph node for matrix addition
   rc=nodeMaAdd.Create(&tensorInput[0],&tensorInput[1],&tensorTemp[0]);
   assert(rc==ZtaStatusOk);

   rc=nodeMaScale.Create(&tensorTemp[0],&tensorTemp[1],2);
   assert(rc==ZtaStatusOk);

   // Create the sinker graph node. This is always the last node in a graph 
   rc=nodeSinker.Create(1,&tensorTemp[1]);
   assert(rc==ZtaStatusOk);

   // Add graph nodes to a graph
   graph.Add(&nodeMaAdd);
   graph.Add(&nodeMaScale);
   graph.Add(&nodeSinker);
   // Execute the graph
   graph.Verify();
   graph.Schedule();

   // Wait for result
   while(graph.Wait(0) != ZtaStatusOk);
   // Check result
   uint8_t *z=(uint8_t *)graph.GetOutputTensor(0)->GetBuf();
   for(int i=0;i < masz;i++) {
      if(2*(x[i]+y[i]) != z[i]) {
         printf("MISMATCH \n");
         exit(0);
      }
   }
   // Done with processing the result
   graph.Consume();
   printf("Tutorial complete sucessfully \n");
   return 0;
}

