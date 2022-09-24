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

#include <stdint.h>
#include <assert.h>
#include <vector>
#include <stdarg.h>
#include <malloc.h>
#include "types.h"
#include "ztalib.h"
#include "util.h"
#include "tensor.h"

// Default constructor.
// Tensor definition/allocation to be provided later

TENSOR::TENSOR() {
   m_shm=0;
   m_isAlias=false;
   m_dataType=TensorDataTypeUint8;
   m_dataElementLen=1;
   m_fmt=TensorFormatSplit;
   m_semantic=TensorSemanticUnknown;
   m_buf=0;
   m_size=0;
}

// Create a fully defined tensor.
// Also allocate memory for it

TENSOR::TENSOR(TensorDataType _dataType,TensorFormat _fmt,TensorSemantic _semantic,int numDim,...):TENSOR() {
   va_list args;
   int v;

   setDataType(_dataType);
   setFormat(_fmt);
   setSemantic(_semantic);
   va_start(args,numDim);
   for(int i=0;i < numDim;i++) {
      v=va_arg(args,int);
      m_dim.push_back(v);
   }
   m_size=TENSOR::GetTensorSize(m_dim)*m_dataElementLen;
   allocate();
   va_end(args);
}

// Create tensor. Free previous allocation
// If _shm specified, tensor buffer has been created already so just reference it directly
// Otherwise allocate new buffer

ZtaStatus TENSOR::Create(TensorDataType _dataType,TensorFormat _fmt,TensorSemantic _semantic,std::vector<int> &dim,
                        ZTA_SHARED_MEM _shm) {
   if(m_shm && !m_isAlias) {
      ztaFreeSharedMem(m_shm);
   }
   m_shm=0;
   m_isAlias=false;
   setDataType(_dataType);
   setFormat(_fmt);
   setSemantic(_semantic);
   setDimension(dim);
   if(_shm)
      allocate(_shm);
   else
      allocate();
   return ZtaStatusOk;
}

ZtaStatus TENSOR::Clone(TENSOR *other) {
   return Create(other->GetDataType(),other->GetFormat(),other->GetSemantic(),other->m_dim);
}

ZtaStatus TENSOR::CreateWithBitmap(const char *bmpFile,TensorFormat fmt)
{
   uint8_t *pict;
   int bmp_w,bmp_h;
   int bmpActualWidth;
   int r,c;
   int w,h;
   int dx,dy;
   uint8_t *output;

   pict = bmpRead(bmpFile,&bmp_h,&bmp_w);
   if(!pict) {
      return ZtaStatusFail;
   }
   if(fmt==TensorFormatSplit) {
      std::vector<int> dim={3,bmp_h,bmp_w};
      Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim);
   } else {
      std::vector<int> dim={bmp_h,3*bmp_w};
      Create(TensorDataTypeUint8,TensorFormatSplit,TensorSemanticRGB,dim);
   }
   output=(uint8_t *)GetBuf();

   w=bmp_w;
   h=bmp_h;
   dx=0;
   dy=0;
   bmpActualWidth=((bmp_w*3+3)/4)*4;
   uint8_t red, blue, green;
   for (r = 0; r < h; r++) {
      for (c = 0; c < w; c++) {
         blue = (pict[((bmp_h-1)-(r+dy))*bmpActualWidth+3*(c+dx)+0]);
         green = (pict[((bmp_h-1)-(r+dy))*bmpActualWidth+3*(c+dx)+1]);
         red = (pict[((bmp_h-1)-(r+dy))*bmpActualWidth+3*(c+dx)+2]);
         if(fmt==TensorFormatSplit) {
            output[0*w*h+r*w+c] = red;
            output[1*w*h+r*w+c] = green;
            output[2*w*h+r*w+c] = blue;
         } else {
             output[3*(r*w+c)] = red;
             output[3*(r*w+c)+1] = green;
             output[3*(r*w+c)+2] = blue;
         }
      }
   }
   free(pict);
   return ZtaStatusOk;
}

TENSOR::~TENSOR() {
   if(m_shm && !m_isAlias)
      ztaFreeSharedMem(m_shm);
}

ZtaStatus TENSOR::setDataType(TensorDataType _dataType) {
   m_dataType=_dataType;
   switch(m_dataType) {
      case TensorDataTypeInt8:
      case TensorDataTypeUint8:
         m_dataElementLen=1;
         break;
      case TensorDataTypeInt16:
      case TensorDataTypeUint16:
         m_dataElementLen=2;
         break;
      case TensorDataTypeFloat32:
         m_dataElementLen=4;
         break;
      default:
         assert(0);
   }
   return ZtaStatusOk;
}

ZtaStatus TENSOR::setSemantic(TensorSemantic _semantic) {
   m_semantic=_semantic;
   return ZtaStatusOk;
}

ZtaStatus TENSOR::setFormat(TensorFormat fmt) {
   m_fmt=fmt;
   return ZtaStatusOk;
}

ZtaStatus TENSOR::setDimension(std::vector<int> &_dim) {
   m_dim.clear();
   m_dim=_dim;
   m_size = TENSOR::GetTensorSize(m_dim)*m_dataElementLen;
   return ZtaStatusOk;
}

ZtaStatus TENSOR::allocate(ZTA_SHARED_MEM shm) {
   assert(m_size < (1<<(DP_ADDR_WIDTH-1))); // Tensor must be less than half tensor address dynamic range
   if(m_shm && !m_isAlias)
      ztaFreeSharedMem(m_shm);
   m_isAlias=false;
   if(shm) {
      m_shm=shm;
   } else {
      m_shm=ztaAllocSharedMem(m_size);
   }
   m_buf=ZTA_SHARED_MEM_VIRTUAL(m_shm);
   return ZtaStatusOk;
}

// Set this tensor as an alias for another buffer

ZtaStatus TENSOR::Alias(TENSOR *other) {
   if(m_shm && !m_isAlias)
      ztaFreeSharedMem(m_shm);
   m_shm=other->GetShm();
   m_isAlias=true;
   m_buf=ZTA_SHARED_MEM_VIRTUAL(m_shm);
   assert(other->m_size==m_size);
   return ZtaStatusOk;
}

ZtaStatus TENSOR::Alias(ZTA_SHARED_MEM _shm) {
   if(m_shm && !m_isAlias)
      ztaFreeSharedMem(m_shm);
   m_shm=_shm;
   m_isAlias=true;
   m_buf=ZTA_SHARED_MEM_VIRTUAL(m_shm);
   return ZtaStatusOk;
}

// Return total tensor array size

size_t TENSOR::GetTensorSize(std::vector<int>& shape) {
   size_t sz=1;
   for(int i=0;i < (int)shape.size();i++) {
      sz*=shape[i];
   }
   return sz;
}

