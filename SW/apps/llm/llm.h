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

#ifndef _TARGET_APPS_LLM_LLM_H_
#define _TARGET_APPS_LLM_LLM_H_

#include "stdint.h"
#include <string>
#include "../../base/types.h"
#include "kernels/llm_m.h"
#include "tokenizer.h"
#include "gguf/zuf.h"

#define MAX_NLAYERS 32 

#define GS 32

#define MIN_TOKEN_PROBABILITY 0.1

typedef struct {
    ZUF_QUANT quant;
    uint8_t* q;
    float16_t* s;
} WeightTensor;

typedef struct {
    int16_t* q;
    float16_t* s;
} ActivationTensor;

#define MAX_LLM_SEQ_LEN  1024

// This class implements the execution of LLAMA model

class llama {
public:
    llama();
    ~llama();
    ZtaStatus Open(const char* checkpoint_path);
    ZtaStatus SystemPrompt(char *prompt);
    ZtaStatus UserPrompt(char *userPrompt,std::string *output);
    void Clear();
    void Close();
    ZtaStatus SetSamplingPolicy(float temperature,float p,float min_p,int k,int maxTokenResponse);
    ZtaStatus SetSamplingPolicyGreedy();
    void ClearStat();
    float GetStatTokPerSec();
    uint32_t GetStatNumTokens();
    void PrintDebugStat();
private:
    void matmul(int req_id,int N,int D,int gs,int16_t *x_v,float16_t *x_s,WeightTensor *w,float16_t *result);
    float16_t* forward(int token, int pos);
    int sampling(float16_t* logits);
    void safe_printf(char *piece);
private:
    ZUF m_zuf;
    Tokenizer *m_tokenizer;
    std::string *m_output;
    uint32_t m_mergeSize;
    std::vector<int> m_promptTokens;
    int m_pos;
    int m_pos2=0;
    struct {
        uint32_t dim; // transformer dimension
        uint32_t hidden_dim; // for ffn layers
        uint32_t n_layers; // number of layers
        uint32_t n_heads; // number of query heads
        uint32_t n_kv_heads; // number of key/value heads (can be < query heads because of multiquery)
        uint32_t vocab_size; // vocabulary size, usually 256 (byte-level)
        uint32_t seq_len; // max sequence length
        float inv_sqrtf_head_size; // 1/sqrt(dim/n_heads)
        float freq_base;
    } m_config;
    struct {
        // current wave of activations
        float16_t *x; // activation at current time stamp (dim,)
        ActivationTensor xq;
        float16_t *xb; // same, but inside a residual branch (dim,)
        ActivationTensor xbq;
        float16_t *xb2; // an additional buffer just for convenience (dim,)
        float16_t *hb; // buffer for hidden dimension in the ffn (hidden_dim,)
        ActivationTensor hbq;
        float16_t *hb2; // buffer for hidden dimension in the ffn (hidden_dim,)
        float16_t *q; // query (dim,)
        float16_t *att; // buffer for scores/attention values (n_heads, seq_len)
        float16_t *att2; // buffer for scores/attention values (n_heads, seq_len)
        float16_t *logits; // output logits
        float16_t* key_cache;   // (layer, seq_len, dim)
        float16_t* value_cache; // (layer, seq_len, dim)
        float *freq;
        float *cosine;
        float *sine;
    } m_runtime;
    struct {
        float16_t* token_embedding_table;    // (vocab_size, dim)
        float* rms_att_weight[MAX_NLAYERS]; // (layer, dim) rmsnorm weights
        float* rms_ffn_weight[MAX_NLAYERS]; // (layer, dim)
        float* rms_final_weight; // (dim,)
        WeightTensor  wqq[MAX_NLAYERS]; // Quantized of wq
        WeightTensor  wkq[MAX_NLAYERS]; // Quantized of wq
        WeightTensor  wvq[MAX_NLAYERS]; // Quantized of wq
        WeightTensor  woq[MAX_NLAYERS]; // Quantized of wq
        WeightTensor  w1q[MAX_NLAYERS]; // Quantized of wq
        WeightTensor  w2q[MAX_NLAYERS]; // Quantized of wq
        WeightTensor  w3q[MAX_NLAYERS]; // Quantized of wq
        WeightTensor  wclsq; // Quantized of wq
    } m_weights;
    struct {
        int numTokens;
        uint64_t totalTime;
    } m_stat;
    bool m_samplingGreedy;
    float m_samplingThreshold;
    float m_minp;
    float m_samplingScale;
    int m_samplingK;
    int m_maxTokenResponse;
    int m_numTokenResponse;
};

#endif
