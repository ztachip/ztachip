#include <math.h>
#include "../../base/types.h"
#include "../../base/tensor.h"
#include "../../base/graph.h"
#include "kernels/resize.h"
#include "resize.h"

// Graph node to do image resize
// Resize using boxing method

GraphNodeResize::GraphNodeResize() : GraphNode() {
   m_temp=0;
   m_filter[0]=0;
   m_filter[1]=0;
   m_filteri[0]=0;
   m_filteri[1]=0;
   m_spu=0;
   m_input=0;
   m_output=0;
   m_dst_w=m_dst_h=0;
   m_src_w=m_src_h=0;
   m_nChannel=0;
}

GraphNodeResize::GraphNodeResize(TENSOR *input,TENSOR *output,
                                 int dst_w,int dst_h) :
                                 GraphNode() {
   m_temp=0;
   m_filter[0]=0;
   m_filter[1]=0;
   m_filteri[0]=0;
   m_filteri[1]=0;
   m_spu=0;
   m_input=0;
   m_output=0;
   m_dst_w=m_dst_h=0;
   m_src_w=m_src_h=0;
   m_nChannel=0;
   Create(input,output,dst_w,dst_h);
}

ZtaStatus GraphNodeResize::Create(TENSOR *input,TENSOR *output,
                                 int dst_w,int dst_h) {
   Cleanup();
   m_dst_w=dst_w;
   m_dst_h=dst_h;
   m_input=input;
   m_output=output;
   return ZtaStatusOk;
}

GraphNodeResize::~GraphNodeResize() {
   Cleanup();
}

// Doing verify stage.
// Build filter parameters for image resizing algorithm...

ZtaStatus GraphNodeResize::Verify() {
   int16_t *filter_p;
   uint8_t *filteri_p;
   float left,right;
   int ileft,iright;
   float left_fraction,right_fraction;
   float filter[8];
   float scale[2];
   int x;

   Cleanup();

   if((*(m_input->GetDimension())).size()!=3) {
      printf("Input has wrong dimension. Must be 3 \n");
      return ZtaStatusFail;   
   }
   if(m_input->GetFormat() != TensorFormatSplit) {
      printf("Input has wrong format. Must be TensorFormatSplit\n");
      return ZtaStatusFail;
   }
   if(m_input->GetDataType() != TensorDataTypeUint8) {
      printf("Input has wrong data type. Must be Uint8\n");
      return ZtaStatusFail;
   }
   m_src_w=(*(m_input->GetDimension()))[2];
   m_src_h=(*(m_input->GetDimension()))[1];
   m_nChannel=(*(m_input->GetDimension()))[0];

   std::vector<int> dim={m_nChannel,m_dst_h,m_dst_w};
   m_output->Create(TensorDataTypeUint8,TensorFormatSplit,m_input->GetSemantic(),dim);

   m_func=ztahostGetExportFunction("do_resize_box");
   if(m_func==0) {
      printf("Resize is not supported \n");
      return ZtaStatusFail;
   }
   m_temp=ztahostAllocSharedMem(2*(m_src_w*m_src_h*3+64));
   for(int i=0;i < 2;i++) {
      m_filter[i]=ztahostAllocSharedMem(sizeof(int16_t)*BOX_RESIZE_MAX_FILTER*NUM_THREAD_PER_CORE);
      m_filteri[i]=ztahostAllocSharedMem(NUM_THREAD_PER_CORE);
   }
   m_scale_denomitor[0]=(BOX_RESIZE_MAX_OUTBUF*m_src_w)/m_dst_w;
   m_scale_denomitor[1]=(BOX_RESIZE_MAX_OUTBUF*m_src_h)/m_dst_h;

   if(m_scale_denomitor[0] > BOX_RESIZE_MAX_INBUF ||
      m_scale_denomitor[1] > BOX_RESIZE_MAX_INBUF) {
      printf("Scaling exeeding allowed range \n");
      return ZtaStatusFail;
   }
   for(int i=0;i < 2;i++) {
      scale[i]=(float)BOX_RESIZE_MAX_OUTBUF/(float)m_scale_denomitor[i];
      m_filterLen[i]=ceil(1/scale[i])+1;
   }
   if(m_filterLen[0] > BOX_RESIZE_MAX_FILTER ||
      m_filterLen[1] > BOX_RESIZE_MAX_FILTER) {
      printf("Scaling exeeding allowed range \n");
      assert(0);
      return ZtaStatusFail;
   }

   // Build filter for image resizing
   // Filter determines how much pixel values to combined within a window 
   // in order to create a new scaled down pixel

   for(int i=0;i < 2;i++) {
      filter_p=(int16_t *)ZTA_SHARED_MEM_P(m_filter[i]);
      filteri_p=(uint8_t *)ZTA_SHARED_MEM_P(m_filteri[i]);
      for(x=0;x < 16;x++,filter_p+=BOX_RESIZE_MAX_FILTER) {
         int j;
         memset(filter_p,0,BOX_RESIZE_MAX_FILTER*sizeof(int16_t));
         memset(filter,0,sizeof(filter));
         left=x/scale[i];
         right=left+1/scale[i];
         ileft=floor(left);
         left_fraction=(1.0-(left-(int)left));
         iright=floor(right);
         right_fraction=(right-(int)right);
         for(j=ileft;j <= iright;j++) {
            if(j==ileft)
               filter[j-ileft]=left_fraction;
            else if(j==iright)
               filter[j-ileft]=right_fraction;
            else
               filter[j-ileft]=1.0;
         }
         assert((j-ileft) <= m_filterLen[i]);
         for(;j < m_filterLen[i];j++)
            filter[j-ileft]=0;
         for(j=0;j < m_filterLen[i];j++)
            filter_p[j]=(int16_t)(0.5+filter[j]*((float)(1<<BOX_RESIZE_SCALE)));
         filteri_p[x]=(uint8_t)ileft;
      }
   }

   // Build SPU lookup table.
   // This is used for arithmetic scaling of output pixel.

   ZTA_SHARED_MEM spu;
   int16_t *pp;

   m_spu=ztahostAllocSharedMem(2*SPU_SIZE*2*sizeof(int16_t));
   pp=(int16_t *)ZTA_SHARED_MEM_P(m_spu);

   spu=ztahostBuildSpu(spuCallback,(float *)&scale[0],0);
   memcpy(pp,ZTA_SHARED_MEM_P(spu),SPU_SIZE*2*sizeof(int16_t));
   ztahostFreeSharedMem(spu);

   spu=ztahostBuildSpu(spuCallback,(float *)&scale[1],0);
   memcpy(pp+SPU_SIZE*2,ZTA_SHARED_MEM_P(spu),SPU_SIZE*2*sizeof(int16_t));
   ztahostFreeSharedMem(spu);
  
   return ZtaStatusOk;
}

// Send the resize request to ztachip...

ZtaStatus GraphNodeResize::Schedule(int queue) {
   ztahostMsgqWriteInt(queue,m_func);
   ztahostMsgqWriteInt(queue,GetNextRequestId(queue));
   ztahostMsgqWritePointer(queue,m_input->GetBuf());
   ztahostMsgqWritePointer(queue,m_output->GetBuf());
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_temp));
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_filter[0]));
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_filter[1]));
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_filteri[0]));
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_filteri[1]));
   ztahostMsgqWriteInt(queue,m_filterLen[0]);
   ztahostMsgqWriteInt(queue,m_filterLen[1]);
   ztahostMsgqWritePointer(queue,ZTA_SHARED_MEM_P(m_spu));
   ztahostMsgqWriteInt(queue,m_nChannel);
   ztahostMsgqWriteInt(queue,m_src_w); // w
   ztahostMsgqWriteInt(queue,m_src_h); // h
   ztahostMsgqWriteInt(queue,m_dst_w); // src_w
   ztahostMsgqWriteInt(queue,m_dst_h); // src_h
   ztahostMsgqWriteInt(queue,m_scale_denomitor[0]); 
   ztahostMsgqWriteInt(queue,m_scale_denomitor[1]); 
   return ZtaStatusOk;
}

void GraphNodeResize::Cleanup() {
   if(m_temp) {
      ztahostFreeSharedMem(m_temp);
      m_temp=0;
   }
   for(int i=0;i < 2;i++) {
      if(m_filter[i]) {
         ztahostFreeSharedMem(m_filter[i]);
         m_filter[i]=0;
      }
      if(m_filteri[i]) {
         ztahostFreeSharedMem(m_filteri[i]);
         m_filteri[i]=0;
      }
   }
   if(m_spu) {
      ztahostFreeSharedMem(m_spu);
      m_spu=0;
   }

}

// Callback to build SPU lookup table
// The table lookup is for output pixel value scaling 

float GraphNodeResize::spuCallback(float input,void *pparm,uint32_t parm) {
   static float scale=0;
   int v;
   if(pparm)
      scale=*((float *)pparm);
   v=(int)(input*scale+0.5);
   if(v>255)
      v=255;
   return (float)v;
}
