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

#ifndef __GGUF_H_
#define __GGUF_H_

#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <fcntl.h>
#include <string>
#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>
#include <vector>
#include <string>
#include "zuf.h"
#include "../../../base/types.h"

// Class to parse GGUF file format
// Quantize tensors and then save it in ZUF format

class GGUF
{
public:
    GGUF();
    ~GGUF();
    ZtaStatus Open(const char* fname);
    ZtaStatus SaveAsZUF(const char* modelName,bool forSim,ZUF_QUANT quant);
    ZtaStatus Verify(const char* fname);
    bool ReadKeyS32(const char* key, int32_t* v);
    bool ReadKeyU32(const char* key, uint32_t* v);
    bool ReadKeyFloat(const char* key, float* v);
    bool ReadKeyS32Array(const char* key, int& n, int32_t** v);
    bool ReadKeyU32Array(const char* key, int& n, uint32_t** v);
    bool ReadKeyFloatArray(const char* key, int& n, float** v);
    bool ReadKeyStringArray(const char* key, std::vector<std::string>* strLst);
    bool GetFloat32Tensor(const char* key, size_t& size,uint8_t** tensor);
private:
    inline size_t read(void* p, size_t len) {
        memcpy(p, m_top + m_curr, len);
        m_curr += len;
        return len;
    }
    inline size_t tell() {
        return m_curr;
    }
    inline void seek(size_t pos) {
        m_curr = pos;
    }
    inline int8_t readS8() {
        int8_t v;
        read(&v, sizeof(int8_t));
        return v;
    }
    inline uint8_t readU8() {
        uint8_t v;
        read(&v, sizeof(uint8_t));
        return v;
    }
    inline int32_t readS32() {
        int32_t v;
        read(&v, sizeof(int32_t));
        return v;
    }
    inline uint32_t readU32() {
        uint32_t v;
        read(&v, sizeof(uint32_t));
        return v;
    }
    inline uint64_t readU64() {
        uint64_t v;
        read(&v, sizeof(uint64_t));
        return v;
    }
    inline int64_t readS64() {
        int64_t v;
        read(&v, sizeof(uint64_t));
        return v;
    }
    inline float readFloat() {
        float v;
        read(&v, sizeof(float));
        return v;
    }
    inline uint8_t* readBlob(size_t len) {
        uint8_t* p;
        p = m_top + m_curr;
        m_curr += len;
        return p;
    }
    inline void readString(std::string *s)
    {
        uint64_t strLen;
        char* p;
        uint8_t* content;

        strLen = readU64();
        content = readBlob(strLen);
        if (s) {
            s->resize(strLen + 1);
            p = (char*)s->c_str();
            memcpy(p, content, strLen);
            p[strLen] = 0;
        }
    }
private:
    bool findKey(const char* key);
    bool findTensor(const char* key);
public:
    ZtaStatus quantize(float* x, size_t sz, int N, int D,bool reorder,ZUF_QUANT quant);
    uint8_t* m_qq;
    float16_t* m_qs;
private:
    uint8_t* m_top;
    size_t m_curr;
    size_t m_size;
private:
    uint32_t m_version;
    int64_t m_nTensors;
    int64_t m_nKV;
    size_t m_kvBegin;
    size_t m_tensorBegin;
    size_t m_tensorDataBegin;
};

#endif
