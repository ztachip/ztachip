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

// This file implements GGUF file format decoder.
// GGUF is expected to be float32
// Quantization to Q4 or Q8 is done here also

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <math.h>
#include <fcntl.h>
#include <string.h>
#include <fcntl.h>
#include <string>
#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <vector>
#include <string>
#include "../../../base/types.h"
#include "../../../base/util.h"
#include "../../../base/zta.h"
#include "../../../apps/llm/kernels/llm_p.h"
#include "gguf.h"
#include "zuf.h"

#define GGUF_DEFAULT_ALIGNMENT 32

enum ggml_type {
    GGML_TYPE_F32 = 0,
    GGML_TYPE_F16 = 1,
    GGML_TYPE_Q4_0 = 2,
    GGML_TYPE_Q4_1 = 3,
    GGML_TYPE_Q5_0 = 6,
    GGML_TYPE_Q5_1 = 7,
    GGML_TYPE_Q8_0 = 8,
    GGML_TYPE_Q8_1 = 9,
    GGML_TYPE_Q2_K = 10,
    GGML_TYPE_Q3_K = 11,
    GGML_TYPE_Q4_K = 12,
    GGML_TYPE_Q5_K = 13,
    GGML_TYPE_Q6_K = 14,
    GGML_TYPE_Q8_K = 15,
    GGML_TYPE_IQ2_XXS = 16,
    GGML_TYPE_IQ2_XS = 17,
    GGML_TYPE_IQ3_XXS = 18,
    GGML_TYPE_IQ1_S = 19,
    GGML_TYPE_IQ4_NL = 20,
    GGML_TYPE_IQ3_S = 21,
    GGML_TYPE_IQ2_S = 22,
    GGML_TYPE_IQ4_XS = 23,
    GGML_TYPE_I8 = 24,
    GGML_TYPE_I16 = 25,
    GGML_TYPE_I32 = 26,
    GGML_TYPE_I64 = 27,
    GGML_TYPE_F64 = 28,
    GGML_TYPE_IQ1_M = 29,
    GGML_TYPE_BF16 = 30,
    GGML_TYPE_Q4_0_4_4 = 31,
    GGML_TYPE_Q4_0_4_8 = 32,
    GGML_TYPE_Q4_0_8_8 = 33,
    GGML_TYPE_COUNT,
};

enum gguf_type {
    GGUF_TYPE_UINT8 = 0,
    GGUF_TYPE_INT8 = 1,
    GGUF_TYPE_UINT16 = 2,
    GGUF_TYPE_INT16 = 3,
    GGUF_TYPE_UINT32 = 4,
    GGUF_TYPE_INT32 = 5,
    GGUF_TYPE_FLOAT32 = 6,
    GGUF_TYPE_BOOL = 7,
    GGUF_TYPE_STRING = 8,
    GGUF_TYPE_ARRAY = 9,
    GGUF_TYPE_UINT64 = 10,
    GGUF_TYPE_INT64 = 11,
    GGUF_TYPE_FLOAT64 = 12,
    GGUF_TYPE_COUNT,
};

static const size_t GGUF_TYPE_SIZE[GGUF_TYPE_COUNT] = {
    sizeof(uint8_t),
    sizeof(int8_t),
    sizeof(uint16_t),
    sizeof(int16_t),
    sizeof(uint32_t),
    sizeof(int32_t),
    sizeof(float),
    sizeof(bool), 
    0,
    0,
    sizeof(uint64_t),
    sizeof(int64_t),
    sizeof(double)
};

// Convert from float32 to bfloat

static void float32tofp16(float *x,float16_t *y,int N) {
    for(int i=0;i < N;i++) {
        y[i] = F2FP16(x[i]);
        assert((y[i] & 0x7fff) < 0x7C00); // Dont expect scale of embedded vector to exceed FP16 scale
    }
}

// Constructor

GGUF::GGUF()
{
    m_top = 0;
    m_qq = 0;
    m_qs = 0;
}

// Destructor. Cleanup

GGUF::~GGUF()
{
    if (m_top)
        free(m_top);
    if (m_qq)
        free(m_qq);
    if (m_qs)
        free(m_qs);
}

// Find a key in the GGUF file
// Every GGUF attributes have a key which is a string 

bool GGUF::findKey(const char* key) {
    std::string s;
    int i, j, n;
    enum gguf_type type, arrayType;

    seek(m_kvBegin);
    for (i = 0; i < m_nKV; i++) {
        readString(&s);
        if (strcmp(s.c_str(),key)==0) {
            return true;
        }
        type = (enum gguf_type)readS32();
        switch (type) {
            case GGUF_TYPE_STRING:
                readString(0);
                break;
            case GGUF_TYPE_ARRAY:
                arrayType = (enum gguf_type)readU32();
                n = (int)readU64();
                if (arrayType == GGUF_TYPE_STRING) {
                    for(j=0;j < n;j++)
                        readString(0);
                }
                else
                    readBlob(n * GGUF_TYPE_SIZE[arrayType]);
                break;
            default:
                readBlob(GGUF_TYPE_SIZE[type]);
                break;
        }
    }
    return false;
}

// Find a tensor in GGUF
// Every tensors have a key which is a string

bool GGUF::findTensor(const char* key) {
    std::string s;
    int i, j;
    int ndims;

    seek(m_tensorBegin);
    for (i = 0; i < m_nTensors; i++) {
        readString(&s); 
        if (strcmp(s.c_str(),key)==0)
            return true;
        ndims = readU32();
        for (j = 0; j < ndims; j++)
            readU64();
        readU32();
        readU64();
    }
    return false;
}

// Retrieve a tensor of float32 numbers

bool GGUF::GetFloat32Tensor(const char* key,size_t &size,uint8_t **tensor) {
    size_t offset;
    int ndims;
    int j;
    enum ggml_type type;

    if (!findTensor(key))
        return false;
    size = 1;
    ndims = readU32();
    for (j = 0; j < ndims; j++)
        size *= readU64();
    type = (enum ggml_type)readU32();
    assert(type == GGML_TYPE_F32);
    offset = readU64();
    offset += m_tensorDataBegin;
    *tensor = m_top + offset;
    return true;
}

// Retrieve an attribute (by key matching) that is INT32 format

bool GGUF::ReadKeyS32(const char *key,int32_t *v) {
    enum gguf_type type;
    if (!findKey(key))
        return false;
    type = (enum gguf_type)readU32();
    assert(type == GGUF_TYPE_INT32);
    *v = readS32();
    return true;
}

// Retrieve an attribute (by key matching) that is UINT32 format

bool GGUF::ReadKeyU32(const char* key, uint32_t* v) {
    enum gguf_type type;
    if (!findKey(key))
        return false;
    type = (enum gguf_type)readU32();
    assert(type == GGUF_TYPE_UINT32);
    *v = readU32();
    return true;
}

// Retrieve an attribute (by key matching) that is float format

bool GGUF::ReadKeyFloat(const char* key, float* v) {
    enum gguf_type type;
    if (!findKey(key))
        return false;
    type = (enum gguf_type)readU32();
    assert(type == GGUF_TYPE_FLOAT32);
    *v = readFloat();
    return true;
}

// Retrieve an attribute (by key matching) that is an array of INT32

bool GGUF::ReadKeyS32Array(const char* key,int &n,int32_t **v) {
    enum gguf_type type, arrayType;
    if (!findKey(key))
        return false;
    type = (enum gguf_type)readU32();
    assert(type == GGUF_TYPE_ARRAY);
    arrayType = (enum gguf_type)readU32();
    assert(arrayType == GGUF_TYPE_INT32);
    n = (int)readU64();
    *v = (int32_t *)readBlob(0);
    return true;
}

// Retrieve an attribute (by key matching) that is an array of UINT32

bool GGUF::ReadKeyU32Array(const char* key, int& n,uint32_t **v) {
    enum gguf_type type, arrayType;
    if (!findKey(key))
        return false;
    type = (enum gguf_type)readU32();
    assert(type == GGUF_TYPE_ARRAY);
    arrayType = (enum gguf_type)readU32();
    assert(arrayType == GGUF_TYPE_UINT32);
    n = (int)readU64();
    *v = (uint32_t *)readBlob(0);
    return true;
}

// Retrieve an attribute (by key matching) that is an array of float

bool GGUF::ReadKeyFloatArray(const char* key, int& n,float **v) {
    enum gguf_type type, arrayType;
    if (!findKey(key))
        return false;
    type = (enum gguf_type)readU32();
    assert(type == GGUF_TYPE_ARRAY);
    arrayType = (enum gguf_type)readU32();
    assert(arrayType == GGUF_TYPE_FLOAT32);
    n = (int)readU64();
    *v = (float *)readBlob(0);
    return true;
}

// Retrieve an attribute (by key matching) that is an array of strings

bool GGUF::ReadKeyStringArray(const char* key,std::vector<std::string> *strLst) {
    enum gguf_type type, arrayType;
    std::string s;
    int n;
    int i;
    if (!findKey(key))
        return false;
    type = (enum gguf_type)readU32();
    assert(type == GGUF_TYPE_ARRAY);
    arrayType = (enum gguf_type)readU32();
    assert(arrayType == GGUF_TYPE_STRING);
    n = (int)readU64();
    for (i = 0; i < n; i++) {
        if (strLst) {
            readString(&s);
            strLst->push_back(s);
        }
        else
            readString(0);
    }
    return true;
}

// Quantize a tensor to Q4 or Q8

ZtaStatus GGUF::quantize(float* x, size_t sz, int N, int D,bool reorder,ZUF_QUANT quant) {
    int num_groups = sz / GS_DEFAULT;
    float Q_MAX;
    float scale;
    int d[16], e[16], e2[16], d2[16];
    int N2 = N / GS_DEFAULT;
    int quantRange;

    if(quant==ZUF_QUANT_INT4) {
        Q_MAX = 7.0f;
        quantRange = 7;
    } else {
        Q_MAX = 127.0f;
        quantRange = 127;
    }
    assert(sz == (size_t)(N * D));
    if (m_qq)
        free(m_qq);
    if (m_qs)
        free(m_qs);
    m_qq = (uint8_t*)malloc(N * D * sizeof(uint8_t));

    m_qs = (float16_t*)malloc(N * D * sizeof(float16_t));

    memset(m_qq, 0, N * D);


    // Initial weight tensor dimension is D * N
    // To map to pcore memory space, it is further broken down to ((D/vector_width)*vector_width)*((N/GS_DEFAULT)*(GS_DEFAULT/LLM_GS)*LLM_GS)
    // VECTOR_WIDTH=vector_width
    // DxN weight tensor original dimension
    // GS_DEFAULT= quantization group size
    // LLM_GS = quantization group is broken down to sub-group so that it fits in PCORE memory space

    d[0] = D / VECTOR_WIDTH;
    d[1] = VECTOR_WIDTH;
    d[2] = N / GS_DEFAULT;
    d[3] = (quant==ZUF_QUANT_INT4)?(GS_DEFAULT/LLM_GS/2):(GS_DEFAULT/LLM_GS/2);
    d[4] = (quant==ZUF_QUANT_INT4)?(LLM_GS/2):(LLM_GS);
    d[5] = (quant==ZUF_QUANT_INT4)?2:2;

    e[0] = d[1] * d[2] * d[3] * d[4] * d[5];
    e[1] = d[2] * d[3] * d[4] * d[5];
    e[2] = d[3] * d[4] * d[5];
    e[3] = d[4] * d[5];
    e[4] = d[5];
    e[5] = 1;

    // Then reorder the dimension of weight tensor to...
    // (GS_DEFAULT/LLM_GS)*(N/GS_DEFAULT)*(D/VECTOR_WIDTH)*LLM_GS*VECTOR_WIDTH

    d2[0] = (quant==ZUF_QUANT_INT4)?(GS_DEFAULT/LLM_GS/2):(GS_DEFAULT/LLM_GS/2); //3
    d2[1] = N / GS_DEFAULT; //2
    d2[2] = D / VECTOR_WIDTH; //0 
    d2[3] = (quant==ZUF_QUANT_INT4)?(LLM_GS/2):(LLM_GS); //4
    d2[4] = VECTOR_WIDTH; //1 
    d2[5] = (quant==ZUF_QUANT_INT4)?2:2; //5

    e2[0] = d2[1] * d2[2] * d2[3] * d2[4] * d2[5];
    e2[1] = d2[2] * d2[3] * d2[4] * d2[5];
    e2[2] = d2[3] * d2[4] * d2[5];
    e2[3] = d2[4] * d2[5];
    e2[4] = d2[5];
    e2[5] = 1;


    for (int group = 0; group < (int)num_groups; group++) {

        // find the max absolute value in the current group
        float wmax = 0.0;
        for (int i = 0; i < GS_DEFAULT; i++) {
            float val = (float)fabs(x[group * GS_DEFAULT + i]);
            if (val > wmax) {
                wmax = val;
            }
        }
        // calculate and write the scaling factor
        scale = wmax / Q_MAX;
        // Convert to bfloat
#if 1
        float found_scale=0;
        float min_error=0;
        // Try to saturate the max value a little bit so it clips
        // See how much we can saturate the max value such that the RMS error of all weights
        // in the block be minimum
        for(int clip=0;clip < 2;clip++) {
            float error=0;
            for (int i = 0; i < GS_DEFAULT; i++) {
                float quant_value=x[group * GS_DEFAULT + i] / scale;
                int8_t quantized;
                float diff;
                int quant32;
                if(quant_value >= 0)
                    quant32=(int)(quant_value+0.5f);
                else
                    quant32=(int)(quant_value-0.5f);
                if(quant32 > quantRange)
                    quantized = quantRange;
                else if(quant32 < (-quantRange))
                    quantized = -quantRange;
                else
                    quantized = (int8_t)quant32;
                diff = (x[group * GS_DEFAULT + i]-((float)quantized * scale));
                error += diff*diff;
            }
            if(clip==0 || error < min_error) {
                found_scale = scale;
                min_error = error;
            }
            scale = scale * 0.9; // reduce by 10%
        }
        scale = found_scale;
        // Convert to bfloat
#endif
        float16_t scale_fp16 = F2FP16(scale);
        assert((scale_fp16 & 0x7fff) < 0x7C00); // Not expecting weight scale to exceed max allowed by FP16
        if(!reorder) {
            m_qs[group] = scale_fp16;
        }
        else {
            // Reorder the tensor dimensions for optimum data transfer from DDR to PCORE memory space
            int x, y;
            x = group % N2;
            y = group / N2;
            m_qs[y + x * D] = scale_fp16;
            assert((y+x*D) < num_groups);
        }

        // calculate and write the quantized values
        for (int i = 0; i < GS_DEFAULT; i++) {
            float quant_value=x[group * GS_DEFAULT + i] / scale;
            int8_t quantized;
            int x[64];
            int xx;
            int idx;
            int pair_idx;
            int quant32;

            if(quant_value >= 0)
                quant32=(int)(quant_value+0.5f);
            else
                quant32=(int)(quant_value-0.5f);
            if(quant32 > quantRange)
                quantized = quantRange;
            else if(quant32 < (-quantRange))
                quantized = -quantRange;
            else
                quantized = (int8_t)quant32;
                
            if (quant==ZUF_QUANT_INT4) {
                xx = group * (GS_DEFAULT / 2) + i / 2;
                pair_idx = ((group * GS_DEFAULT + i) % 2);
            }
            else {
                xx = group * (GS_DEFAULT) + i;
                pair_idx = 0;
            }

            if(!reorder) {
                if(quant==ZUF_QUANT_INT4) {
                    if (pair_idx == 0)
                        m_qq[xx] = (m_qq[xx] & 0xF0) | ((uint8_t)quantized & 0x0F);
                    else
                        m_qq[xx] = (m_qq[xx] & 0x0F) | ((((uint8_t)quantized) << 4) & 0xF0);
                } 
                else {
                    m_qq[xx] = (uint8_t)quantized;
                }
            } else {
                // Reorder the tensor dimensions for optimum data transfer from DDR to PCORE memory space
                x[0] = xx / e[0];
                xx -= x[0] * e[0];

                x[1] = xx / e[1];
                xx -= x[1] * e[1];

                x[2] = xx / e[2];
                xx -= x[2] * e[2];

                x[3] = xx / e[3];
                xx -= x[3] * e[3];

                x[4] = xx / e[4];
                xx -= x[4] * e[4];

                x[5] = xx / e[5];

                // Mapping from old index to new index
                idx = x[0] * e2[2] + // 0->2
                    x[1] * e2[4] + // 1->4 ..
                    x[2] * e2[1] + // 2->1
                    x[3] * e2[0] + // 3->0
                    x[4] * e2[3] + // 4->3
                    x[5] * e2[5];  // 5->5

                if(quant==ZUF_QUANT_INT4) {
                    if (pair_idx == 0)
                        m_qq[idx] = (m_qq[idx] & 0xF0) | ((uint8_t)quantized & 0x0F);
                    else
                        m_qq[idx] = (m_qq[idx] & 0x0F) | ((((uint8_t)quantized) << 4) & 0xF0);
                }
                else {
                    m_qq[idx] = quantized;
                }
            }
        }
    }
    return ZtaStatusOk;
}

// Open GGUF file 

ZtaStatus GGUF::Open(const char* fname)
{
    FILE* fp = 0;
    uint8_t *magic;
    std::string key;
    std::string s;

    if (m_top)
        free(m_top);
    m_top = 0;
    fp = fopen(fname, "rb");
    if (!fp)
        return ZtaStatusFail;
    fseek(fp, 0, SEEK_END);
    m_size = ftell(fp);
    m_top = (uint8_t *)malloc(m_size);
    m_curr = 0;
    fseek(fp, 0, SEEK_SET);
    if (fread(m_top, 1, m_size, fp) != m_size)
        goto FAIL;
    fclose(fp);
    fp = 0;
 
    magic = readBlob(4);
    if (memcmp(magic, "GGUF",4) != 0)
        goto FAIL;

    m_version = readU32();
    m_nTensors = readU64();
    m_nKV = readU64();

    m_kvBegin = tell();

    findKey((char *)"");

    m_tensorBegin = tell();

    findTensor((char*)"");

    m_tensorDataBegin = tell();

    m_tensorDataBegin = ((m_tensorDataBegin+GGUF_DEFAULT_ALIGNMENT-1)/GGUF_DEFAULT_ALIGNMENT)*GGUF_DEFAULT_ALIGNMENT;

    return ZtaStatusOk;
FAIL:
    if (fp)
        fclose(fp);
    return ZtaStatusFail;
}

// Save GGUF as ZUF format
// ztachip works with ZUF format

ZtaStatus GGUF::SaveAsZUF(const char* modelName,bool forSim,ZUF_QUANT quant) {
    size_t sz;
    uint8_t* tensor;
    uint32_t dim;
    uint32_t hidden_dim;
    uint32_t n_layers;
    uint32_t n_heads;
    uint32_t n_kv_heads;
    uint32_t vocab_size;
    uint32_t seq_len;
    uint32_t i;
    static std::vector<std::string> strLst;
    static std::vector<std::string> mergeLst;
    uint32_t maxLen;
    uint32_t strLen;
    int scoreLstSize;
    float* scoreLst;
    std::string s;
    char key[100];
    char keyq[100];
    char keys[100];
    char keyf[100];
    float freq_base;
    static ZUF zuf;

    if (zuf.Create(modelName) != ZtaStatusOk)
        return ZtaStatusFail;

    if (!ReadKeyU32("llama.embedding_length", &dim))
        return ZtaStatusFail;
    zuf.WriteItemU32("llama.embedding_length", dim);

    if (!ReadKeyU32("llama.feed_forward_length", &hidden_dim))
        return ZtaStatusFail;
    zuf.WriteItemU32("llama.feed_forward_length", hidden_dim);

    if (!ReadKeyU32("llama.block_count", &n_layers))
        return ZtaStatusFail;
    zuf.WriteItemU32("llama.block_count", n_layers);

    if (!ReadKeyU32("llama.attention.head_count", &n_heads))
        return ZtaStatusFail;
    zuf.WriteItemU32("llama.attention.head_count", n_heads);

    if (!ReadKeyU32("llama.attention.head_count_kv", &n_kv_heads))
        return ZtaStatusFail;
    zuf.WriteItemU32("llama.attention.head_count_kv", n_kv_heads);

    if (!ReadKeyU32("llama.vocab_size", &vocab_size))
        return ZtaStatusFail;
    zuf.WriteItemU32("llama.vocab_size", vocab_size);

    if (!ReadKeyU32("llama.context_length", &seq_len))
        return ZtaStatusFail;
    zuf.WriteItemU32("llama.context_length", seq_len);

    if (!ReadKeyFloat("llama.rope.freq_base", &freq_base))
        return ZtaStatusFail;
    zuf.WriteItemFloat("llama.rope.freq_base", freq_base);

    // w->rms_att_weight. Should be F32
    for (i = 0; i < n_layers; i++) {
        sprintf(key, "blk.%d.attn_norm.weight", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        zuf.WriteItemArrayFloat(key, (uint32_t)sz, (float*)tensor);
    }

    // w->wq . Should be Q4
    for (i = 0; i < n_layers; i++) {
        sprintf(key, "blk.%d.attn_q.weight", (int)i);
        sprintf(keyf, "blk.%d.attn_q.weight.f", (int)i);
        sprintf(keyq, "blk.%d.attn_q.weight.q", (int)i);
        sprintf(keys, "blk.%d.attn_q.weight.s", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        quantize((float*)tensor, sz, dim, dim,!forSim,quant);
        zuf.WriteItemU32(keyf, quant);
        zuf.WriteItemArrayU8(keyq,(quant==ZUF_QUANT_INT4)?(sz/2):sz, (uint8_t *)m_qq);
        zuf.WriteItemArrayFP16(keys, (uint32_t)(sz/GS_DEFAULT), (float16_t*)m_qs);
    }

    // wk . Should be Q4
    for (i = 0; i < n_layers; i++) {
        sprintf(key, "blk.%d.attn_k.weight", (int)i);
        sprintf(keyf, "blk.%d.attn_k.weight.f", (int)i);
        sprintf(keyq, "blk.%d.attn_k.weight.q", (int)i);
        sprintf(keys, "blk.%d.attn_k.weight.s", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        quantize((float*)tensor, sz, dim, ((dim * n_kv_heads) / n_heads),!forSim,quant);
        zuf.WriteItemU32(keyf, quant);
        zuf.WriteItemArrayU8(keyq,(quant==ZUF_QUANT_INT4)?(sz/2):sz, (uint8_t*)m_qq);
        zuf.WriteItemArrayFP16(keys, (uint32_t)(sz / GS_DEFAULT), (float16_t*)m_qs);
    }

    // wv. Should be Q4
    for (i = 0; i < n_layers; i++) {
        sprintf(key, "blk.%d.attn_v.weight", (int)i);
        sprintf(keyf, "blk.%d.attn_v.weight.f", (int)i);
        sprintf(keyq, "blk.%d.attn_v.weight.q", (int)i);
        sprintf(keys, "blk.%d.attn_v.weight.s", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        quantize((float*)tensor, sz, dim, ((dim * n_kv_heads) / n_heads),!forSim,quant);
        zuf.WriteItemU32(keyf, quant);
        zuf.WriteItemArrayU8(keyq,(quant==ZUF_QUANT_INT4)?(sz/2):sz, (uint8_t*)m_qq);
        zuf.WriteItemArrayFP16(keys, (uint32_t)(sz / GS_DEFAULT), (float16_t*)m_qs);
    }

    // wo. Should be Q4
    for (i = 0; i < n_layers; i++) {
        sprintf(key, "blk.%d.attn_output.weight", (int)i);
        sprintf(keyf, "blk.%d.attn_output.weight.f", (int)i);
        sprintf(keyq, "blk.%d.attn_output.weight.q", (int)i);
        sprintf(keys, "blk.%d.attn_output.weight.s", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        quantize((float*)tensor, sz, dim, dim,!forSim,quant);
        zuf.WriteItemU32(keyf, quant);
        zuf.WriteItemArrayU8(keyq,(quant==ZUF_QUANT_INT4)?(sz/2):sz, (uint8_t*)m_qq);
        zuf.WriteItemArrayFP16(keys, (uint32_t)(sz/GS_DEFAULT), (float16_t*)m_qs);
    }

    // Should be F32
    for (i = 0; i < n_layers; i++) {
        sprintf(key, "blk.%d.ffn_norm.weight", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        zuf.WriteItemArrayFloat(key, (uint32_t)sz, (float*)tensor);
    }

    // w1q Should be Q4
    for (i = 0; i < n_layers; i++) {
        // Input to SwiGLU stage needs good accuracy. Quantize ffn_gate in INT8
        sprintf(key, "blk.%d.ffn_gate.weight", (int)i);
        sprintf(keyf, "blk.%d.ffn_gate.weight.f", (int)i);
        sprintf(keyq, "blk.%d.ffn_gate.weight.q", (int)i);
        sprintf(keys, "blk.%d.ffn_gate.weight.s", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        quantize((float*)tensor, sz, dim, hidden_dim,!forSim,quant);
        zuf.WriteItemU32(keyf, quant);
        zuf.WriteItemArrayU8(keyq,(quant==ZUF_QUANT_INT4)?(sz/2):sz, (uint8_t*)m_qq);
        zuf.WriteItemArrayFP16(keys, (uint32_t)(sz / GS_DEFAULT), m_qs);
    }

    // w3. Should be Q4
    for (i = 0; i < n_layers; i++) {
        // Input to SwigGLU needs good accuracy
        sprintf(key, "blk.%d.ffn_up.weight", (int)i);
        sprintf(keyf, "blk.%d.ffn_up.weight.f", (int)i);
        sprintf(keyq, "blk.%d.ffn_up.weight.q", (int)i);
        sprintf(keys, "blk.%d.ffn_up.weight.s", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        quantize((float*)tensor, sz, dim, hidden_dim,!forSim,quant);
        zuf.WriteItemU32(keyf,quant);
        zuf.WriteItemArrayU8(keyq,(quant==ZUF_QUANT_INT4)?(sz/2):sz, (uint8_t*)m_qq);
        zuf.WriteItemArrayFP16(keys, (uint32_t)(sz / GS_DEFAULT), m_qs);   
    }

    // w2. Should be Q4
    for (i = 0; i < n_layers; i++) {
        // This layer needs to be always in INT8 quantization
        sprintf(key, "blk.%d.ffn_down.weight", (int)i);
        sprintf(keyf, "blk.%d.ffn_down.weight.f", (int)i);
        sprintf(keyq, "blk.%d.ffn_down.weight.q", (int)i);
        sprintf(keys, "blk.%d.ffn_down.weight.s", (int)i);
        if (!GetFloat32Tensor(key, sz, &tensor))
            return ZtaStatusFail;
        quantize((float*)tensor, sz, hidden_dim, dim,!forSim,quant);
        zuf.WriteItemU32(keyf,quant);
        zuf.WriteItemArrayU8(keyq,(quant==ZUF_QUANT_INT4)?(sz/2):sz,(uint8_t*)m_qq);
        zuf.WriteItemArrayFP16(keys, (uint32_t)(sz / GS_DEFAULT), m_qs);   
    }

    // rms_final_weight. Should be F32
    if (!GetFloat32Tensor("output_norm.weight", sz, &tensor))
        return ZtaStatusFail;
    zuf.WriteItemArrayFloat("output_norm.weight", (uint32_t)sz, (float*)tensor);

    // wclsq. Always Q8_0 regardless if model is quantized for Q4 or Q8
    if (GetFloat32Tensor("output.weight", sz, &tensor)) {
        quantize((float*)tensor, sz, dim, vocab_size,!forSim,ZUF_QUANT_INT8);
        zuf.WriteItemU32("output.weight.f", ZUF_QUANT_INT8);
        zuf.WriteItemArrayU8("output.weight.q", (uint32_t)(sz), (uint8_t*)m_qq);
        zuf.WriteItemArrayFP16("output.weight.s", (uint32_t)(sz / GS_DEFAULT), m_qs);
    }
    else if(GetFloat32Tensor("token_embd.weight", sz, &tensor)) {
        quantize((float*)tensor, sz, dim, vocab_size,!forSim,ZUF_QUANT_INT8);
        zuf.WriteItemU32("output.weight.f", ZUF_QUANT_INT8);
        zuf.WriteItemArrayU8("output.weight.q", (uint32_t)(sz), (uint8_t*)m_qq);
        zuf.WriteItemArrayFP16("output.weight.s", (uint32_t)(sz / GS_DEFAULT), m_qs);
    }
    else
        return ZtaStatusFail;

    // w->token_embedding_table
    if (!GetFloat32Tensor("token_embd.weight", sz, &tensor))
        return ZtaStatusFail;
    float32tofp16((float *)tensor,(float16_t *)tensor,sz);
    zuf.WriteItemArrayFP16("token_embd.weight", (uint32_t)sz, (float16_t*)tensor);

    // Save tokenizer
    strLst.clear();
    if (!ReadKeyStringArray("tokenizer.ggml.tokens", &strLst))
        return ZtaStatusFail;
    maxLen = 0;
    for (int i = 0; i < (int)strLst.size(); i++) {
        static uint8_t ws[4] = {0xe2,0x96,0x81,0};
        size_t pos = 0;

        while ((pos = strLst[i].find((char*)ws, pos)) != std::string::npos) {
            strLst[i].replace(pos, 3, " ");
            pos += 1;
        }
        strLen = (uint32_t)strLst[i].size() - 1;
        maxLen = (maxLen < strLen) ? strLen : maxLen;
    }
    assert(strLst.size() == vocab_size);
    s.clear();
    for (uint32_t i = 0; i < vocab_size; i++) {
        if (i == 1 || i == 2) {
            char token[100];
            sprintf(token, "\n%s\n", strLst[i].c_str());
            s = s + token;
            s.push_back('\0');
        }
        else {
            strLen = (uint32_t)strLst[i].size() - 1;
            s = s + strLst[i];
        }
    }
    zuf.WriteItemU32("tokenizer.maxlen", maxLen);
    zuf.WriteItemArrayString("tokenizer.tokens", (uint32_t)vocab_size, (char *)s.c_str());

    // Save token score or merge depending on tokenizer type

    mergeLst.clear();
    if (ReadKeyFloatArray("tokenizer.ggml.scores", scoreLstSize, &scoreLst)) {
        assert(scoreLstSize == (int)vocab_size);
        zuf.WriteItemArrayFloat("tokenizer.scores", (uint32_t)scoreLstSize, scoreLst);
    }
    else if (ReadKeyStringArray("tokenizer.ggml.merges", &mergeLst)) {
        s.clear();
        for (uint32_t i = 0; i < mergeLst.size(); i++) {
            char *left;
            char* right;
            char *p;
            p = (char*)mergeLst[i].c_str();
            left = p;
            right = p;
            while (*p) {
                if (*p == ' ') {
                    right = p + 1;
                    *p = 0;
                }
                p++;
            }
            s = s + left;
            s.push_back(0);
            s = s + right;
            s.push_back(0);
        }
        zuf.WriteItemArrayString("tokenizer.merges", (uint32_t)mergeLst.size()*2, (char*)s.c_str());
    }
    else
        return ZtaStatusFail;
    zuf.CreateComplete();
    return ZtaStatusOk;
}
