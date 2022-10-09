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

#ifndef __TARGET_BASE_TENSOR_H__
#define __TARGET_BASE_TENSOR_H__

#include <stdint.h>
#include <vector>
#include "types.h"
#include "ztalib.h"

// Tensor data types

typedef enum {
   TensorDataTypeInt8,
   TensorDataTypeUint8,
   TensorDataTypeInt16,
   TensorDataTypeUint16,
   TensorDataTypeFloat32
} TensorDataType;

// Tensor format.
// Tensor outermost dimension may be stored in an interleave format
// Tensor outermost dimension may be stored in a regular array format (split)

typedef enum {
   TensorFormatInterleaved,
   TensorFormatSplit
} TensorFormat;

// Tensor data meaning...

typedef enum {
   TensorObjTypeRGB, // Image with pixel color in RGB order
   TensorObjTypeBGR, // Image with pixel color in BGR order
   TensorObjTypeYUYV, // Image with YUYV pixel (2bytes per pixel)
   TensorObjTypeMonochrome, // Image monochrome but with 3 color plane (R=G=B)
   TensorObjTypeMonochromeSingleChannel, // Image monochrome but 1 color plane
   TensorObjTypeUnknown // Unknown meaning
} TensorObjType;

class TENSOR {
public:
   TENSOR();
   TENSOR(TensorDataType _dataType,TensorFormat _fmt,TensorObjType _objType,int numDim,...);
   ZtaStatus Create(TensorDataType _dataType,TensorFormat _fmt,TensorObjType _objType,std::vector<int> &dim,ZTA_SHARED_MEM _shm=0);
   ZtaStatus Clone(TENSOR *other);
   ZtaStatus Alias(TENSOR *other);
   ZtaStatus Alias(ZTA_SHARED_MEM _shm);
   ZtaStatus CreateWithBitmap(const char *bmpFile,TensorFormat fmt=TensorFormatSplit);
   ~TENSOR();
   TensorDataType GetDataType() {return m_dataType;}
   TensorFormat GetFormat() {return m_fmt;}
   TensorObjType GetObjType() {return m_objType;}
   std::vector<int> *GetDimension() {return &m_dim;}
   int GetDimension(int _idx) {return m_dim[_idx];}
   ZTA_SHARED_MEM GetBufShm() {return m_shm;}
   void *GetBuf() {return m_buf;}
   ZTA_SHARED_MEM GetShm() {return m_shm;}
   int GetBufLen() {return m_size;}
   static size_t GetTensorSize(std::vector<int>& shape);
public:
   std::vector<int> m_dim;
private:
   ZtaStatus setDataType(TensorDataType _dataType);
   ZtaStatus setFormat(TensorFormat fmt);
   ZtaStatus setObjType(TensorObjType _objType);
   ZtaStatus setDimension(std::vector<int> &dim);
   ZtaStatus allocate(ZTA_SHARED_MEM shm=0);
private:
   ZTA_SHARED_MEM m_shm;
   bool m_isAlias;
   TensorDataType m_dataType;
   int m_dataElementLen;
   TensorFormat m_fmt;
   TensorObjType m_objType;
   void *m_buf;
   int m_size;
};

#endif
