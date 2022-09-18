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

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../base/ztahost.h"
#include "../../base/tensor.h"
#include "nn.h"

ZTA_SHARED_MEM NeuralNet::BuildSpu(SPU_FUNC func,void *pparm,uint32_t parm,uint32_t parm2) {
   ZTA_SHARED_MEM shm;
   shm=ztahostBuildSpuBundle(1,func,pparm,parm,parm2);
   m_bufUnboundLst.push_back(shm);
   return shm;
}

bool NeuralNet::BufferIsInit(int bufid) {
   if(bufid >= (int)m_bufLst.size())
      return false;
   return m_bufLst[bufid].shmFlat || m_bufLst[bufid].shmInterleave;
}

ZTA_SHARED_MEM NeuralNet::BufferGetFlat(int bufid) {
   if(bufid < (int)m_bufLst.size())
      return m_bufLst[bufid].shmFlat;
   else
      return 0;
}

ZTA_SHARED_MEM NeuralNet::BufferGetInterleave(int bufid) {
   if(bufid < (int)m_bufLst.size())
      return m_bufLst[bufid].shmInterleave;
   else
      return 0;
}

// Mark the buffer as an external buffer so do not free it

void NeuralNet::BufferSetAsExternal(int bufid,bool flatFmt,bool interleaveFmt) {
   if(flatFmt)
      m_bufLst[bufid].shmFlatIsRef=true;
   if(interleaveFmt)
      m_bufLst[bufid].shmInterleaveIsRef=true;
}

ZTA_SHARED_MEM NeuralNet::BufferAllocate(size_t sz) {
   ZTA_SHARED_MEM shm;
   shm=ztahostAllocSharedMem(sz);
  // This buffer is not associated with an id
   m_bufUnboundLst.push_back(shm);
   return shm;
}

// Register a already allocated buffer that to be freed later
void NeuralNet::BufferAllocateExternal(ZTA_SHARED_MEM shm) {
   m_bufUnboundLst.push_back(shm);
}

ZtaStatus NeuralNet::BufferAllocate(int bufid,NeuralNetTensorType type,size_t sz,bool flatFmt,bool interleaveFmt) {
   assert(bufid >= 0);
   switch(type) {
      case NeuralNetTensorType_FLOAT32: sz *= 4;break;
      case NeuralNetTensorType_FLOAT16: sz *= 2;break;
      case NeuralNetTensorType_INT32: sz *= 4;break;
      case NeuralNetTensorType_UINT8: break;
      case NeuralNetTensorType_INT64: sz *= 4;break;
      case NeuralNetTensorType_STRING: break;
      case NeuralNetTensorType_BOOL: break;
      case NeuralNetTensorType_INT16: sz *= 2;break;
      case NeuralNetTensorType_COMPLEX64: sz *= 4;break;
      case NeuralNetTensorType_INT8: break;
      default:
         assert(0);
   }
   if(bufid < (int)m_bufLst.size()) {
      if(flatFmt) {
         if(!m_bufLst[bufid].shmFlat) {
            m_bufLst[bufid].shmFlat=ztahostAllocSharedMem(sz);
         } else {
//            assert(ZTA_SHARED_MEM_LEN(m_bufLst[bufid].shmFlat)==sz);
         }
      }
      if(interleaveFmt) {
         if(!m_bufLst[bufid].shmInterleave) {
            m_bufLst[bufid].shmInterleave=ztahostAllocSharedMem(sz);
         } else {
//            assert(ZTA_SHARED_MEM_LEN(m_bufLst[bufid].shmInterleave)==sz);
         }
      }
   } else {
      for(int i=m_bufLst.size();i <= bufid;i++) {
         NeuralNetBuffer blank;
         blank.shmFlat=0;
         blank.shmFlatIsRef=false;
         blank.shmInterleave=0;
         blank.shmInterleaveIsRef=false;
         blank.sz=0;
         m_bufLst.push_back(blank);
      }
      NeuralNetBuffer def;
      def.sz=sz;
      def.shmFlat=flatFmt?ztahostAllocSharedMem(sz):0;
      def.shmFlatIsRef=false;
      def.shmInterleave=interleaveFmt?ztahostAllocSharedMem(sz):0;
      def.shmInterleaveIsRef=false;
      m_bufLst[bufid]=def;
   }
   return ZtaStatusOk;
}

// Allocate a buffer by referencing an external tensor object

ZtaStatus NeuralNet::BufferAllocate(int bufid,TENSOR *_tensor) {
   assert(bufid >= 0);
   if(bufid < (int)m_bufLst.size()) {
      if(_tensor->GetFormat()==TensorFormatSplit) {
         if(!m_bufLst[bufid].shmFlat) {
            m_bufLst[bufid].shmFlat=_tensor->GetBufShm();
            m_bufLst[bufid].shmFlatIsRef=true;
         } else {
            if(!m_bufLst[bufid].shmFlatIsRef)
               ztahostFreeSharedMem(m_bufLst[bufid].shmFlat);
            m_bufLst[bufid].shmFlat=_tensor->GetBufShm();
            m_bufLst[bufid].shmFlatIsRef=true;                   
         }
      }
      if(_tensor->GetFormat()==TensorFormatInterleaved) {
         if(!m_bufLst[bufid].shmInterleave) {
            m_bufLst[bufid].shmInterleave=_tensor->GetBufShm();
            m_bufLst[bufid].shmInterleaveIsRef=true;
         } else {
            if(!m_bufLst[bufid].shmInterleaveIsRef)
               ztahostFreeSharedMem(m_bufLst[bufid].shmInterleave);
            m_bufLst[bufid].shmInterleave=_tensor->GetBufShm();
            m_bufLst[bufid].shmInterleaveIsRef=true;          
         }
      }
   } else {
      for(int i=m_bufLst.size();i <= bufid;i++) {
         NeuralNetBuffer blank;
         blank.shmFlat=0;
         blank.shmFlatIsRef=false;
         blank.shmInterleave=0;
         blank.shmInterleaveIsRef=false;
         blank.sz=0;
         m_bufLst.push_back(blank);
      }
      NeuralNetBuffer def;
      def.sz=_tensor->GetBufLen();
      def.shmFlat=(_tensor->GetFormat()==TensorFormatSplit)?_tensor->GetBufShm():0;
      def.shmFlatIsRef=def.shmFlat?true:false;
      def.shmInterleave=(_tensor->GetFormat()==TensorFormatInterleaved)?_tensor->GetBufShm():0;
      def.shmInterleaveIsRef=def.shmInterleave?true:false;
      m_bufLst[bufid]=def;
   }
   return ZtaStatusOk;
}

void NeuralNet::BufferFreeAll() {
   for(int i=0;i < (int)m_bufLst.size();i++) {
      if(m_bufLst[i].shmFlat) {
         if(!m_bufLst[i].shmFlatIsRef)
            ztahostFreeSharedMem(m_bufLst[i].shmFlat);
      }
      if(m_bufLst[i].shmInterleave) {
         if(!m_bufLst[i].shmInterleaveIsRef)
            ztahostFreeSharedMem(m_bufLst[i].shmInterleave);
      }
   }
   for(int i=0;i < (int)m_bufUnboundLst.size();i++) {
      if(m_bufUnboundLst[i])
         ztahostFreeSharedMem(m_bufUnboundLst[i]);
   }
   m_bufLst.clear();
   m_bufUnboundLst.clear();
}

// Some supporting functions to intepret inference results...

// Load label file 
ZtaStatus NeuralNet::LabelLoad(const char *fname) {
   FILE *fp;
   char str[200];
   fp=fopen(fname,"r");
   if(!fp) {
      return ZtaStatusFail;
   }
   m_labels.clear();
   while(fgets(str,sizeof(str)-1,fp)) {
      strtok(str,"\r\n");
      m_labels.push_back(str);
   }
   fclose(fp);
   return ZtaStatusOk;
}

// Get string associated with a label ID

const char *NeuralNet::LabelGet(int _idx) {
   return (_idx < (int)m_labels.size())?m_labels[_idx].c_str():0;
}

// Find the top5 result from the list

ZtaStatus NeuralNet::GetTop5(uint8_t *prediction,int predictionSize,int *top5)
{
   unsigned int v;
   unsigned int t;
   unsigned int i0;
   unsigned int i1;
   unsigned int i2;
   unsigned int i3;
   unsigned int i4;

   i0=0x00000000;
   i1=0x00000000;
   i2=0x00000000;
   i3=0x00000000;
   i4=0x00000000;

   for(int i=0;i < predictionSize;i++) {
      v=(prediction[i] << 16)+i;
      if(v > i4) {
         i4=v; 
         if(i4 > i3) {
            t=i3;i3=i4;i4=t;
            if(i3 > i2) { 
               t=i2;i2=i3;i3=t;
               if(i2 > i1) {
                  t=i1;i1=i2;i2=t;
                  if(i1 > i0) {
                     t=i0;i0=i1;i1=t;
                  }
               }
            }
         }
      }
   }
   top5[0] = (int)(i0&0xFFFF);
   top5[1] = (int)(i1&0xFFFF);
   top5[2] = (int)(i2&0xFFFF);
   top5[3] = (int)(i3&0xFFFF);
   top5[4] = (int)(i4&0xFFFF);
   return ZtaStatusOk;
}


