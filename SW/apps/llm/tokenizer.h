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

#ifndef _TARGET_APPS_LLM_TOKENIZER_H_
#define _TARGET_APPS_LLM_TOKENIZER_H_

#include "stdint.h"
#include <vector>
#include "../../base/types.h"

class Tokenizer {
public:
    Tokenizer();
    virtual ~Tokenizer();
    virtual ZtaStatus StringToToken(char* text, int8_t bos, int8_t eos, std::vector<int> &tokens,int timeout=0)=0;
    virtual char* TokenToString(int prev_token, int token)=0;
public:
    struct {
        int NL;
        int BOS;
        int EOS;
    } m_special;
};

typedef struct {
    char *str;
    int id;
} SPMTokenIndex;

typedef struct {
    char *str;
    int id;
} BFE_TokenIndex;

typedef struct {
    char* first;
    char* second;
} BFEMerge;

class TokenizerSPM : public Tokenizer {
public:
    TokenizerSPM();
    virtual ~TokenizerSPM();
public:
    virtual void Build(float *scoreLst,char *tokens,uint32_t vocab_size,uint32_t max_token_length);
    virtual char* TokenToString(int prev_token, int token);
    virtual ZtaStatus StringToToken(char *text, int8_t bos, int8_t eos, std::vector<int> &tokens,int timeout=0);
private:
    int lookup(char *str);
private:
    char** vocab;
    float* vocab_scores;
    SPMTokenIndex *sorted_vocab;
    uint32_t vocab_size;
    uint32_t max_token_length;
    char *str_buffer;
    unsigned char byte_pieces[512];
};

class TokenizerBFE : public Tokenizer {
public:
    TokenizerBFE();
    virtual ~TokenizerBFE();
    void Build(uint32_t vocabSize, char* vocab, uint32_t mergeSize, char* merge,uint32_t max_token_length);
    virtual ZtaStatus StringToToken(char* text, int8_t bos, int8_t eos, std::vector<int> &tokens,int timeout=0);
    virtual char* TokenToString(int prev_token, int token);
private:
    int lookupToken(char *str);
    uint8_t hashFunc(char* s);
private:
    char* m_token;
    uint32_t m_vocabSize;
    char** m_vocab;
    uint32_t m_mergeSize;
    BFEMerge* m_merge;
    uint8_t *m_mergeHash;
    BFE_TokenIndex *sorted_vocab;
    std::vector<std::string> m_s;
    uint8_t *m_shash;
    int m_shashLen;
    int m_nTokens;
    bool m_inProgress;
};

#endif
