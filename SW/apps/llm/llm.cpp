#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <stdint.h>
#ifndef __WIN32__
#include <unistd.h>
#endif
#include <sys/stat.h>
#include "../../base/types.h"
#include "../../base/util.h"
#include "../../src/soc.h"
#include "../../base/zta.h"
#include "../../base/ztalib.h"
#include "../../base/ztalog.h"
#include "../../src/soc.h"
#include "../../apps/llm/llm.h"
#include "kernels/llm_m.h"
#include "reference/llm_ref.h"
#include "llm.h"
#include "gguf/zuf.h"
#include "tokenizer.h"

//-------------------------------------------------------------------------
//
// This file implements the execution of LLAMA model
//
//--------------------------------------------------------------------------

#ifdef __WIN32__
// When running on PC, replace kernel functions with reference implementation version
#define kernel_llm_matmul_q4_exe kernel_ref_llm_matmul_q4_exe
#define kernel_llm_matmul_q8_exe kernel_ref_llm_matmul_q8_exe
#define kernel_llm_quantize_exe kernel_ref_llm_quantize_exe
#define kernel_llm_rms_exe kernel_ref_llm_rms_exe
#define kernel_llm_dot_product_exe kernel_ref_llm_dot_product_exe
#define kernel_llm_dot_product2_exe kernel_ref_llm_dot_product2_exe
#define kernel_llm_rope_exe kernel_ref_llm_rope_exe
#define kernel_llm_cosine_exe kernel_ref_llm_cosine_exe
#define kernel_llm_sine_exe kernel_ref_llm_sine_exe
#define kernel_llm_residual_exe kernel_ref_llm_residual_exe
#define kernel_llm_SwiGLU_exe kernel_ref_llm_SwiGLU_exe
#define kernel_llm_softmax_exe kernel_ref_llm_softmax_exe
#define kernel_llm_find_max kernel_ref_llm_find_max
#define kernel_llm_scale_exe kernel_ref_llm_scale_exe
#define kernel_llm_find_k_max
#endif

#ifdef __WIN32__
extern "C" void kernel_llm_done()
{
}
int TIMEGET()
{
    return 0;
}
#else
#define TIMEGET TimeGet
#endif

#define K_MAX  100 // Maximum number of highest priority tokens to be chosen from during sampling

// Constructor of LLAMA object

llama::llama() {
    m_runtime.x=0;
    m_runtime.xq.q=0;
    m_runtime.xq.s=0;
    m_runtime.xb=0;
    m_runtime.xbq.q=0;
    m_runtime.xbq.s=0;
    m_runtime.xb2=0;
    m_runtime.hb=0;
    m_runtime.hbq.q=0;
    m_runtime.hbq.s=0;
    m_runtime.hb2=0;
    m_runtime.q=0;
    m_runtime.att=0;
    m_runtime.logits=0;
    m_runtime.key_cache=0;
    m_runtime.value_cache=0;
    m_runtime.freq=0;
    m_runtime.cosine=0;
    m_runtime.sine=0;
    m_tokenizer=0;
    m_pos=0;
    m_pos2=0;
    m_samplingGreedy=true;
    m_samplingThreshold=0.0f;
    m_minp = 0.0f;
    m_samplingScale=1.0f;
    m_maxTokenResponse = -1;
    m_numTokenResponse = 0;
    m_stat.numTokens = 0;
    m_stat.totalTime = 0;
}

// Destructor

llama::~llama() {
    Close();
}

// Open the ZUF file
// ZUF file is the model file for ztachip
// Convert GGUF to ZUF by SW/gguf/quant

ZtaStatus llama::Open(const char* checkpoint_path) {
    int kv_dim;
    int head_size;
    uint32_t sz;
    uint32_t max_token_length;
    float *scoreLst;
    char *mergeLst;
    char *tokenLst;
    uint32_t quant;
    static char key[100];
    static char keyf[100];
    static char keyq[100];
    static char keys[100];

    printf("Opening model\r\n");

    if(m_zuf.Open(checkpoint_path) != ZtaStatusOk)
        return ZtaStatusFail;

    if(!m_zuf.ReadItemU32("llama.embedding_length", m_config.dim))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemU32("llama.feed_forward_length", m_config.hidden_dim))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemU32("llama.block_count", m_config.n_layers))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemU32("llama.attention.head_count", m_config.n_heads))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemU32("llama.attention.head_count_kv", m_config.n_kv_heads))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemU32("llama.vocab_size", m_config.vocab_size))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemU32("llama.context_length", m_config.seq_len))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemFloat("llama.rope.freq_base", m_config.freq_base))
        return ZtaStatusFail;

    if(m_config.seq_len > MAX_LLM_SEQ_LEN)
        m_config.seq_len = MAX_LLM_SEQ_LEN;

    assert(m_config.n_layers <= MAX_NLAYERS);
    assert((m_config.hidden_dim % GS) == 0);
    assert((m_config.dim % GS) == 0);

    kv_dim = (m_config.dim * m_config.n_kv_heads) / m_config.n_heads;

    head_size = m_config.dim / m_config.n_heads;

    m_config.inv_sqrtf_head_size=1/sqrtf(head_size);

    if(!m_zuf.ReadArrayFP16("token_embd.weight", sz, &m_weights.token_embedding_table))
        return ZtaStatusFail;

    for(int i=0;i < (int)m_config.n_layers;i++) {
        sprintf(key, "blk.%d.attn_norm.weight", i);
        if(!m_zuf.ReadArrayFloat(key, sz, &m_weights.rms_att_weight[i]))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(keyf, "blk.%d.attn_q.weight.f", i);
        sprintf(keyq, "blk.%d.attn_q.weight.q", i);
        sprintf(keys, "blk.%d.attn_q.weight.s", i);
        if(!m_zuf.ReadItemU32(keyf,quant))
            return ZtaStatusFail;
        m_weights.wqq[i].quant = (ZUF_QUANT)quant;
        if(!m_zuf.ReadArrayU8(keyq, sz, &m_weights.wqq[i].q))
            return ZtaStatusFail;
        if(!m_zuf.ReadArrayFP16(keys, sz, (float16_t **)&m_weights.wqq[i].s))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(keyf, "blk.%d.attn_k.weight.f", i);
        sprintf(keyq, "blk.%d.attn_k.weight.q", i);
        sprintf(keys, "blk.%d.attn_k.weight.s", i);
        if(!m_zuf.ReadItemU32(keyf,quant))
            return ZtaStatusFail;
        m_weights.wkq[i].quant = (ZUF_QUANT)quant;
        if(!m_zuf.ReadArrayU8(keyq, sz, &m_weights.wkq[i].q))
            return ZtaStatusFail;
        if(!m_zuf.ReadArrayFP16(keys, sz, (float16_t **) & m_weights.wkq[i].s))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(keyf, "blk.%d.attn_v.weight.f", i);
        sprintf(keyq, "blk.%d.attn_v.weight.q", i);
        sprintf(keys, "blk.%d.attn_v.weight.s", i);
        if(!m_zuf.ReadItemU32(keyf,quant))
            return ZtaStatusFail;
        m_weights.wvq[i].quant = (ZUF_QUANT)quant;
        if(!m_zuf.ReadArrayU8(keyq, sz, &m_weights.wvq[i].q))
            return ZtaStatusFail;
        if(!m_zuf.ReadArrayFP16(keys, sz, (float16_t **) & m_weights.wvq[i].s))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(keyf, "blk.%d.attn_output.weight.f", i);
        sprintf(keyq, "blk.%d.attn_output.weight.q", i);
        sprintf(keys, "blk.%d.attn_output.weight.s", i);
        if(!m_zuf.ReadItemU32(keyf,quant))
            return ZtaStatusFail;
        m_weights.woq[i].quant = (ZUF_QUANT)quant;
        if(!m_zuf.ReadArrayU8(keyq, sz, &m_weights.woq[i].q))
            return ZtaStatusFail;
        if(!m_zuf.ReadArrayFP16(keys, sz, (float16_t **) & m_weights.woq[i].s))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(key, "blk.%d.ffn_norm.weight", i);
        if(!m_zuf.ReadArrayFloat(key,sz,&m_weights.rms_ffn_weight[i]))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(keyf, "blk.%d.ffn_gate.weight.f", i);
        sprintf(keyq, "blk.%d.ffn_gate.weight.q", i);
        sprintf(keys, "blk.%d.ffn_gate.weight.s", i);
        if(!m_zuf.ReadItemU32(keyf,quant))
            return ZtaStatusFail;
        m_weights.w1q[i].quant = (ZUF_QUANT)quant;
        if(!m_zuf.ReadArrayU8(keyq, sz, &m_weights.w1q[i].q))
            return ZtaStatusFail;
        if(!m_zuf.ReadArrayFP16(keys, sz, (float16_t **) & m_weights.w1q[i].s))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(keyf, "blk.%d.ffn_down.weight.f", i);
        sprintf(keyq, "blk.%d.ffn_down.weight.q", i);
        sprintf(keys, "blk.%d.ffn_down.weight.s", i);
        if(!m_zuf.ReadItemU32(keyf,quant))
            return ZtaStatusFail;
        m_weights.w2q[i].quant = (ZUF_QUANT)quant;
        if(!m_zuf.ReadArrayU8(keyq, sz, &m_weights.w2q[i].q))
            return ZtaStatusFail;
        if(!m_zuf.ReadArrayFP16(keys, sz, (float16_t **) & m_weights.w2q[i].s))
            return ZtaStatusFail;
    }

    for (int i = 0; i < (int)m_config.n_layers; i++) {
        sprintf(keyf, "blk.%d.ffn_up.weight.f", i);
        sprintf(keyq, "blk.%d.ffn_up.weight.q", i);
        sprintf(keys, "blk.%d.ffn_up.weight.s", i);
        if(!m_zuf.ReadItemU32(keyf,quant))
            return ZtaStatusFail;
        m_weights.w3q[i].quant = (ZUF_QUANT)quant;
        if(!m_zuf.ReadArrayU8(keyq, sz, &m_weights.w3q[i].q))
            return ZtaStatusFail;
        if(!m_zuf.ReadArrayFP16(keys, sz, (float16_t **) & m_weights.w3q[i].s))
            return ZtaStatusFail;
    }

    if(!m_zuf.ReadArrayFloat("output_norm.weight", sz, &m_weights.rms_final_weight))
        return ZtaStatusFail;
    if(!m_zuf.ReadItemU32("output.weight.f",quant))
        return ZtaStatusFail;
    m_weights.wclsq.quant = (ZUF_QUANT)quant;
    if(!m_zuf.ReadArrayU8("output.weight.q", sz, &m_weights.wclsq.q))
        return ZtaStatusFail;
    if(!m_zuf.ReadArrayFP16("output.weight.s", sz, (float16_t **)(&m_weights.wclsq.s)))
        return ZtaStatusFail;


    // Allocate runtime tensors

    m_runtime.x = (float16_t *)calloc(m_config.dim, sizeof(float16_t));
    m_runtime.xb = (float16_t *)calloc(m_config.dim, sizeof(float16_t));
    m_runtime.xb2 = (float16_t *)calloc(m_config.dim, sizeof(float16_t));
    m_runtime.hb = (float16_t *)calloc(m_config.hidden_dim, sizeof(float16_t)); 
    m_runtime.hb2 = (float16_t *)calloc(m_config.hidden_dim, sizeof(float16_t));
    m_runtime.q = (float16_t *)calloc(m_config.dim, sizeof(float16_t));

    m_runtime.key_cache = (float16_t *)calloc(m_config.n_layers * m_config.seq_len * kv_dim, sizeof(float16_t));
    m_runtime.value_cache = (float16_t *)calloc(m_config.n_layers * m_config.seq_len * kv_dim, sizeof(float16_t));
    m_runtime.att = (float16_t *)calloc(m_config.seq_len+16, sizeof(float16_t));
    m_runtime.logits = (float16_t *)calloc(m_config.vocab_size, sizeof(float16_t));

    m_runtime.xbq.q = (int16_t *)calloc(m_config.dim, sizeof(int16_t));
    m_runtime.xbq.s = (float16_t *)calloc(m_config.dim/GS, sizeof(float16_t));
    
    m_runtime.hbq.q = (int16_t *)calloc(m_config.hidden_dim, sizeof(int16_t));
    m_runtime.hbq.s = (float16_t *)calloc(m_config.hidden_dim / GS, sizeof(float16_t));

    m_runtime.xq.q = (int16_t *)calloc(m_config.dim, sizeof(int16_t));
    m_runtime.xq.s = (float16_t *)calloc(m_config.dim / GS, sizeof(float16_t));

    // Generate lookup 

    m_runtime.freq = (float *)malloc(sizeof(float)*m_config.dim);
    m_runtime.cosine = (float *)malloc(sizeof(float)*m_config.dim);
    m_runtime.sine = (float *)malloc(sizeof(float)*m_config.dim);
    for (uint32_t i = 0; i < m_config.dim; i+=2) {
        m_runtime.freq[i/2] = 1.0f / powf(m_config.freq_base,(i % head_size)/(float)head_size);
    }

    // Initialize tokenizer
    if(!m_zuf.ReadItemU32("tokenizer.maxlen",max_token_length))
        return ZtaStatusFail;
    if(!m_zuf.ReadArrayString("tokenizer.tokens", sz, &tokenLst))
        return ZtaStatusFail;
    if(m_zuf.ReadArrayFloat("tokenizer.scores", sz, &scoreLst)) {
        TokenizerSPM *tokenizer;
        tokenizer = new TokenizerSPM();
        tokenizer->Build(scoreLst,tokenLst,m_config.vocab_size,max_token_length);
        m_tokenizer = (Tokenizer *)tokenizer;
    }
    else if(m_zuf.ReadArrayString("tokenizer.merges", m_mergeSize, &mergeLst)) {
        TokenizerBFE *tokenizer;
        tokenizer = new TokenizerBFE();
        tokenizer->Build(m_config.vocab_size,tokenLst,m_mergeSize,mergeLst,max_token_length);
        m_tokenizer = (Tokenizer *)tokenizer;
    }
    else
        return ZtaStatusFail;
    return ZtaStatusOk;
}

void llama::Close() {
    if(m_runtime.x != 0) {
        free(m_runtime.x);
        m_runtime.x=0;
    }
    if(m_runtime.xq.q != 0) {
        free(m_runtime.xq.q);
        m_runtime.xq.q=0;
    }
    if(m_runtime.xq.s != 0) {
        free(m_runtime.xq.s);
        m_runtime.xq.s=0;
    }
    if(m_runtime.xb != 0) {
        free(m_runtime.xb);
        m_runtime.xb=0;
    }
    if(m_runtime.xbq.q != 0) {
        free(m_runtime.xbq.q);
        m_runtime.xbq.q=0;
    }
    if(m_runtime.xbq.s != 0) {
        free(m_runtime.xbq.s);
        m_runtime.xbq.s=0;
    }
    if(m_runtime.xb2 != 0) {
        free(m_runtime.xb2);
        m_runtime.xb2=0;
    }
    if(m_runtime.hb != 0) {
        free(m_runtime.hb);
        m_runtime.hb=0;
    }
    if(m_runtime.hbq.q != 0) {
        free(m_runtime.hbq.q);
        m_runtime.hbq.q=0;
    }
    if(m_runtime.hbq.s != 0) {
        free(m_runtime.hbq.s);
        m_runtime.hbq.s=0;
    }
    if(m_runtime.hb2 != 0) {
        free(m_runtime.hb2);
        m_runtime.hb2=0;
    }
    if(m_runtime.q != 0) {
        free(m_runtime.q);
        m_runtime.q=0;
    }
    if(m_runtime.att != 0) {
        free(m_runtime.att);
        m_runtime.att=0;
    }
    if(m_runtime.logits != 0) {
        free(m_runtime.logits);
        m_runtime.logits=0;
    }
    if(m_runtime.key_cache != 0) {
        free(m_runtime.key_cache);
        m_runtime.key_cache=0;
    }
    if(m_runtime.value_cache != 0) {
        free(m_runtime.value_cache);
        m_runtime.value_cache=0;
    }
    if(m_runtime.freq != 0) {
        free(m_runtime.freq);
        m_runtime.freq=0;
    }
    if(m_runtime.cosine != 0) {
        free(m_runtime.cosine);
        m_runtime.cosine=0;
    }
    if(m_runtime.sine != 0) {
        free(m_runtime.sine);
        m_runtime.sine=0;
    }
    if(m_tokenizer) {
        delete m_tokenizer;
        m_tokenizer=0;
    }
    m_zuf.Close();
} 

// Set sampling policy
// Temperature is used to scaled down logit probability to flatten out probability
// p is the accumulate probability threshold that we can choose the tokens. A large
// p allows less likely tokens to be chosen.

ZtaStatus llama::SetSamplingPolicy(float temperature,float p,float min_p,int k,int maxTokenResponse) {
    if(temperature==0)
        return ZtaStatusFail;
    if(p < 0.0 || p > 1.0)
        return ZtaStatusFail;
    if(k > K_MAX)
        return ZtaStatusFail;
    m_samplingGreedy = false;
    m_samplingThreshold = p;
    m_minp = min_p;
    m_samplingScale = 1/temperature;
    m_samplingK = k;
    m_maxTokenResponse = maxTokenResponse;
    return ZtaStatusOk;
}

// Set sampling policy to be greedy
// Meaning tokens with highest probability is always chosen
//
ZtaStatus llama::SetSamplingPolicyGreedy() {
    m_samplingGreedy = true;
    m_samplingThreshold = 0;
    m_minp = 0.0f;
    m_samplingScale = 0;
    m_samplingK = 1;
    return ZtaStatusOk;
}

// matmul operation
// Matrix multiplication between weights and activations
// Support weight with Q8 or Q4 quantization

void llama::matmul(int req_id,int N,int D,int gs,int16_t *x_v,float16_t *x_s,WeightTensor *w,float16_t *result) {
    if(w->quant==ZUF_QUANT_INT4)
        kernel_llm_matmul_q4_exe(req_id,N,D,gs,x_v,x_s,w->q,w->s,result);
    else
        kernel_llm_matmul_q8_exe(req_id,N,D,gs,x_v,x_s,w->q,w->s,result);
}

// Main token processing chain

float16_t* llama::forward(int token, int pos) {
    float16_t *x = m_runtime.x;
    float16_t *k_start;
    float16_t *k;
    float16_t *v;
    int dim = m_config.dim;
    int kv_dim = (m_config.dim * m_config.n_kv_heads) / m_config.n_heads;
    int kv_mul = m_config.n_heads / m_config.n_kv_heads;
    int hidden_dim =  m_config.hidden_dim;
    int head_size = dim / m_config.n_heads;
    uint32_t resp;

    // copy the token embedding into x

    float16_t* content_row = m_weights.token_embedding_table + (token * dim);

    // forward all the layers
    for(unsigned long long l = 0; l < m_config.n_layers; l++) {

        x = (l==0)?content_row:m_runtime.x;

        kernel_llm_rms_exe(-1,dim,x,(l==0),m_runtime.xb,m_weights.rms_att_weight[l]);

        // key and value point to the kv cache
        int loff = l * m_config.seq_len * kv_dim; // kv cache layer offset for convenience
        k = m_runtime.key_cache + (loff + pos * kv_dim);
        v = m_runtime.value_cache + (loff + pos * kv_dim);

        kernel_llm_quantize_exe(-1,dim,m_runtime.xb,m_runtime.xbq.s,m_runtime.xbq.q);

        matmul(-1,dim, dim, GS, m_runtime.xbq.q,m_runtime.xbq.s, &m_weights.wqq[l], m_runtime.q);

        matmul(-1,dim, kv_dim, GS, m_runtime.xbq.q,m_runtime.xbq.s, &m_weights.wkq[l], k);

        matmul(-1,dim, kv_dim, GS, m_runtime.xbq.q,m_runtime.xbq.s, &m_weights.wvq[l], v);

        // RoPE relative positional encoding: complex-valued rotate q and k in each head
        kernel_llm_cosine_exe(-1,dim/2,m_runtime.freq,(float)pos,m_runtime.cosine);

        kernel_llm_sine_exe(-1,dim/2,m_runtime.freq,(float)pos,m_runtime.sine); 

        assert((kv_dim%2)==0);

        kernel_llm_rope_exe(-1,kv_dim/2,m_runtime.cosine,m_runtime.sine,m_runtime.q,m_runtime.q);

        kernel_llm_rope_exe(-1,kv_dim/2,m_runtime.cosine,m_runtime.sine,k,k);

        kernel_llm_rope_exe(-1,(dim-kv_dim)/2,
                            &m_runtime.cosine[kv_dim/2],
                            &m_runtime.sine[kv_dim/2],
                            &m_runtime.q[kv_dim],
                            &m_runtime.q[kv_dim]);
        // multihead attention. iterate over all heads
        int h;
        for (h = 0; h < (int)m_config.n_heads; h++) {
            // get the query vector for this head
            float16_t* q = m_runtime.q + (h * head_size);
            // attention scores for this head
            // iterate over all timesteps, including the current one
            k_start = m_runtime.key_cache + (loff + (h / kv_mul) * head_size);

            kernel_llm_dot_product_exe(-1,head_size,(pos+1),q,k_start,kv_dim,m_runtime.att,m_config.inv_sqrtf_head_size);

            kernel_llm_softmax_exe(-1,m_runtime.att,pos + 1);

            // weighted sum of the values, store back into xb
            float16_t* xb = m_runtime.xb + (h * head_size);
            k_start = m_runtime.value_cache + (loff + (h / kv_mul) * head_size);
            kernel_llm_dot_product2_exe(-1,head_size,(pos+1),m_runtime.att,k_start,kv_dim,xb);
        }

        kernel_llm_quantize_exe(-1,dim,m_runtime.xb,m_runtime.xbq.s,m_runtime.xbq.q);

        matmul(-1,dim, dim, GS, m_runtime.xbq.q,m_runtime.xbq.s, &m_weights.woq[l], m_runtime.xb2);

        kernel_llm_residual_exe(-1,dim,x,(l==0),m_runtime.x,m_runtime.xb2);

        kernel_llm_rms_exe(-1,dim,m_runtime.x,false,m_runtime.xb,m_weights.rms_ffn_weight[l]);

        kernel_llm_quantize_exe(-1,dim,m_runtime.xb,m_runtime.xbq.s,m_runtime.xbq.q);

        matmul(-1,dim, hidden_dim, GS,m_runtime.xbq.q,m_runtime.xbq.s, &m_weights.w1q[l], m_runtime.hb);

        matmul(-1,dim, hidden_dim, GS,m_runtime.xbq.q,m_runtime.xbq.s, &m_weights.w3q[l], m_runtime.hb2);

        // SwiGLU non-linearity

        kernel_llm_SwiGLU_exe(-1,m_runtime.hb,m_runtime.hb2,hidden_dim);

        // final matmul to get the output of the ffn

        kernel_llm_quantize_exe(-1,hidden_dim,m_runtime.hb,m_runtime.hbq.s,m_runtime.hbq.q);

        matmul(-1,hidden_dim, dim, GS,m_runtime.hbq.q,m_runtime.hbq.s, &m_weights.w2q[l],m_runtime.xb);

        kernel_llm_residual_exe(-1,dim,m_runtime.x,false,m_runtime.x,m_runtime.xb); 
#ifndef __WIN32__
        while(ztaReadResponse(&resp)) {}
#endif
    }

    kernel_llm_rms_exe(-1,dim,m_runtime.x,false,m_runtime.x,m_weights.rms_final_weight);
    // classifier into logits

    kernel_llm_quantize_exe(-1,dim,m_runtime.x,m_runtime.xq.s,m_runtime.xq.q);

    matmul(-1,m_config.dim, m_config.vocab_size, GS,m_runtime.xq.q,m_runtime.xq.s, &m_weights.wclsq,m_runtime.logits);

    kernel_llm_done();
    return m_runtime.logits;
}

// Sampling step
// Choose the next token from the probability list
// If greedy sampling is chosen then always choose the token with highest probabily
// Otherwise ztachip uses a combination of top-k top-p and temperature for sampling
// First the token probability is normalize with softmax
// Then we choose the top K_SIZE number of tokens
// Then we prune the list further until the total probability of remaining tokens <= p
// Then we choose a random number
// Pick a tokens where the total probability upto the chosen tokens is <= random number 

int llama::sampling(float16_t* _logits) {
    static int top[K_MAX];
    static float topp[K_MAX];
    static float16_t toppbf[K_MAX];
    static uint32_t seed = 123456789;
    float accum = 0;
    float prob;
    int cutoff, select;
    float randf;
    float sum;
    int ksz;

    FLUSH_DATA_CACHE();

    if(m_samplingGreedy)
        return kernel_llm_find_max(_logits, m_config.vocab_size);

    kernel_llm_find_k_max(_logits,m_config.vocab_size,m_samplingK,m_samplingScale,top,toppbf);

    kernel_llm_done();  
    
    kernel_llm_softmax_exe(-1, toppbf, m_samplingK);
        
    kernel_llm_done(); 

    FLUSH_DATA_CACHE();

    for(int i=0;i < m_samplingK;i++)
        topp[i] = BF2F(toppbf[i]);

    sum = 0;
    for (ksz = 0;ksz < m_samplingK; ksz++) {
        sum += topp[ksz];
        if(topp[ksz] < topp[0]*m_minp)
            break;
        if (sum > m_samplingThreshold)
            break;
    }
    if (ksz > m_samplingK)
        ksz = m_samplingK;
    if (ksz == 0)
        ksz = 1;

    sum=0;
    for(int i=0;i < ksz;i++) {
        sum += topp[i];
    }
    for(int i=0;i < ksz;i++) {
        topp[i] = topp[i]/sum;
    }

    seed = (seed * 1664525 + 1013904223);
    randf = (float)(seed & 0xFFFFFF) / (float)0x1000000;
    for (select=0,accum=0.0;select < ksz;select++)
    {
        accum += topp[select];
        if (accum >= randf)
            break;
    }
    if(select >= ksz)
        select = ksz-1;
    return top[select];
}

void llama::safe_printf(char *piece) {
    // piece might be a raw byte token, and we only want to print printable chars or whitespace
    // because some of the other bytes can be various control codes, backspace, etc.
    if (piece == NULL) { return; }
    if (piece[0] == '\0') { return; }
    if (piece[1] == '\0') {
        unsigned char byte_val = piece[0];
        if (!(isprint(byte_val) || isspace(byte_val))) {
            return; // bad byte, don't print it
        }
    }
    printf("%s", piece);
    if(m_output)
        m_output->append(piece);
}

// Inject system prompt

ZtaStatus llama::SystemPrompt(char *prompt) {
    char* piece;
    m_output = 0;
    m_promptTokens.clear();
    m_promptTokens.push_back(m_tokenizer->m_special.BOS);
    m_tokenizer->StringToToken((char *)"system", 1, 0, m_promptTokens);
    m_promptTokens.push_back(m_tokenizer->m_special.NL);
    m_tokenizer->StringToToken(prompt, 1, 0, m_promptTokens);
    m_promptTokens.push_back(m_tokenizer->m_special.EOS);
    m_promptTokens.push_back(m_tokenizer->m_special.NL);
    if(m_promptTokens.size() >= m_config.seq_len)
        return ZtaStatusFail;
    m_pos = 0; // Start from begin of context window
    for(int i=0;i < (int)m_promptTokens.size();i++) {
        forward(m_promptTokens[i], m_pos);
        m_pos++;
    }
    m_pos2=0;
    return ZtaStatusOk;
}

// Injust user prompt
// And then wait for the response

ZtaStatus llama::UserPrompt(char *userPrompt,std::string *output) {
    int token=0;
    int lastToken=-1;
    float16_t* logits;
    char* piece;
    int pos;
    bool cont=true;
    bool overflow=false;
    uint32_t startTime,endTime;

    m_output = output;
    if(m_output)
        m_output->clear();
    m_promptTokens.clear();
    m_promptTokens.push_back(m_tokenizer->m_special.BOS);
    m_tokenizer->StringToToken((char *)"user", 1, 0, m_promptTokens);
    m_promptTokens.push_back(m_tokenizer->m_special.NL);
    m_tokenizer->StringToToken(userPrompt, 1, 0, m_promptTokens);
    m_promptTokens.push_back(m_tokenizer->m_special.EOS);
    m_promptTokens.push_back(m_tokenizer->m_special.NL);
    m_promptTokens.push_back(m_tokenizer->m_special.BOS);
    m_tokenizer->StringToToken((char*)"assistant", 1, 0, m_promptTokens);
    m_promptTokens.push_back(m_tokenizer->m_special.NL);
    m_numTokenResponse=0;
    pos = 0;
    startTime = TIMEGET();
    while(cont) {
        if((pos+m_pos+m_pos2) >= (int)(m_config.seq_len-1)) {
            overflow = true;
            break;
        }
        if(pos < ((int)m_promptTokens.size()-1)) {
            forward(m_promptTokens[pos],pos+m_pos+m_pos2);
            m_stat.numTokens++;
            pos++;
        } else if(pos == ((int)m_promptTokens.size()-1)) {
            logits = forward(m_promptTokens[pos], pos+m_pos+m_pos2);
            m_stat.numTokens++;
            token = sampling(logits);
            lastToken = token;
            piece = m_tokenizer->TokenToString(token, token);
            safe_printf(piece);
            fflush(stdout);
            pos++;
        } else {
            logits = forward(token, pos+m_pos+m_pos2);
            m_stat.numTokens++;
            m_numTokenResponse++;
            token = sampling(logits);
            if(m_maxTokenResponse >= 0 && (m_numTokenResponse > m_maxTokenResponse)) {
                if(token==m_tokenizer->m_special.NL && lastToken==m_tokenizer->m_special.NL) {
                    // Good place to break even if it is not EOS token
                    break;
                }
            }
            lastToken = token;
            pos++;
            piece = m_tokenizer->TokenToString(token,token);
            if(token==m_tokenizer->m_special.EOS)
                break;
            safe_printf(piece);
            fflush(stdout);
        }
#ifndef __WIN32__
        while (UartReadAvailable()) {
            if (UartRead() == 0x3) // Ctrl+C
                cont=false;
        }
#endif
    }
    if(cont) {
        if(overflow) {
            m_pos2 = 0;
            printf("\r\n*** Conversation window grows too large. Clear chat history.\r\n");
        }
        else
            m_pos2 += pos; // Advance context window pos if there is no abort
    }
    endTime = TIMEGET();
    m_stat.totalTime += (uint64_t)((uint32_t)((int32_t)endTime-(int32_t)startTime));
    return ZtaStatusOk;
}

// Clear the context window.

void llama::Clear() {
    m_pos2 = 0;
}

// Clear statistics

void llama::ClearStat() {
    m_stat.numTokens=0;
    m_stat.totalTime=0;
}

// Get statistics about performance tokens/sec

float llama::GetStatTokPerSec() {
    return (float)((m_stat.numTokens)/(float)(m_stat.totalTime)*1000);
}

// Get statistics about number of tokens

uint32_t llama::GetStatNumTokens() {
    return (uint32_t)(m_stat.numTokens);
}