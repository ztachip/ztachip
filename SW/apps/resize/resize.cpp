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

#include <math.h>
#include <string.h>
#include <assert.h>
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
      return ZtaStatusFail;   
   }
   if(m_input->GetFormat() != TensorFormatSplit) {
      return ZtaStatusFail;
   }
   if(m_input->GetDataType() != TensorDataTypeUint8) {
      return ZtaStatusFail;
   }
   m_src_w=(*(m_input->GetDimension()))[2];
   m_src_h=(*(m_input->GetDimension()))[1];
   m_nChannel=(*(m_input->GetDimension()))[0];

   std::vector<int> dim={m_nChannel,m_dst_h,m_dst_w};
   m_output->Create(TensorDataTypeUint8,TensorFormatSplit,m_input->GetSemantic(),dim);

   m_temp=ztaAllocSharedMem(2*(m_src_w*m_src_h*3+64));
   for(int i=0;i < 2;i++) {
      m_filter[i]=ztaAllocSharedMem(sizeof(int16_t)*BOX_RESIZE_MAX_FILTER*NUM_THREAD_PER_CORE);
      m_filteri[i]=ztaAllocSharedMem(NUM_THREAD_PER_CORE);
   }
   m_scale_denomitor[0]=(BOX_RESIZE_MAX_OUTBUF*m_src_w)/m_dst_w;
   m_scale_denomitor[1]=(BOX_RESIZE_MAX_OUTBUF*m_src_h)/m_dst_h;

   if(m_scale_denomitor[0] > BOX_RESIZE_MAX_INBUF ||
      m_scale_denomitor[1] > BOX_RESIZE_MAX_INBUF) {
      return ZtaStatusFail;
   }
   for(int i=0;i < 2;i++) {
      scale[i]=(float)BOX_RESIZE_MAX_OUTBUF/(float)m_scale_denomitor[i];
      m_filterLen[i]=ceil(1/scale[i])+1;
   }
   if(m_filterLen[0] > BOX_RESIZE_MAX_FILTER ||
      m_filterLen[1] > BOX_RESIZE_MAX_FILTER) {
      assert(0);
      return ZtaStatusFail;
   }

   // Build filter for image resizing
   // Filter determines how much pixel values to combined within a window 
   // in order to create a new scaled down pixel

   for(int i=0;i < 2;i++) {
      filter_p=(int16_t *)ZTA_SHARED_MEM_VIRTUAL(m_filter[i]);
      filteri_p=(uint8_t *)ZTA_SHARED_MEM_VIRTUAL(m_filteri[i]);
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

   m_spu=ztaBuildSpuBundle(2,
                       spuCallback,(float *)&scale[0],0,0,
                       spuCallback,(float *)&scale[1],0,0);
   return ZtaStatusOk;
}

// Send the resize request to ztachip...

ZtaStatus GraphNodeResize::Prepare(int queue,bool stepMode) {

   kernel_resize_exe(
      (unsigned int)GetNextRequestId(queue),
	  (unsigned int)m_input->GetBuf(),
	  (unsigned int)m_output->GetBuf(),
	  (unsigned int)ZTA_SHARED_MEM_VIRTUAL(m_temp),
	  (unsigned int)ZTA_SHARED_MEM_VIRTUAL(m_filter[0]),
	  (unsigned int)ZTA_SHARED_MEM_VIRTUAL(m_filter[1]),
	  (unsigned int)ZTA_SHARED_MEM_VIRTUAL(m_filteri[0]),
	  (unsigned int)ZTA_SHARED_MEM_VIRTUAL(m_filteri[1]),
      m_filterLen[0],
      m_filterLen[1],
	  (unsigned int)ZTA_SHARED_MEM_VIRTUAL(m_spu),
      m_nChannel,
      m_src_w,
      m_src_h,
      m_dst_w,
      m_dst_h,
      m_scale_denomitor[0],
      m_scale_denomitor[1]
	);

   return ZtaStatusOk;
}

void GraphNodeResize::Cleanup() {
   if(m_temp) {
      ztaFreeSharedMem(m_temp);
      m_temp=0;
   }
   for(int i=0;i < 2;i++) {
      if(m_filter[i]) {
         ztaFreeSharedMem(m_filter[i]);
         m_filter[i]=0;
      }
      if(m_filteri[i]) {
         ztaFreeSharedMem(m_filteri[i]);
         m_filteri[i]=0;
      }
   }
   if(m_spu) {
      ztaFreeSharedMem(m_spu);
      m_spu=0;
   }

}

// Callback to build SPU lookup table
// The table lookup is for output pixel value scaling 

int16_t GraphNodeResize::spuCallback(int16_t input,void *pparm,uint32_t parm) {
   static float scale=0;
   int v;
   if(pparm)
      scale=*((float *)pparm);
   v=(int)((float)input*scale+0.5);
   if(v>255)
      v=255;
   return (int16_t)v;
}
