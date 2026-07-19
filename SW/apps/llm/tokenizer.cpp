#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <stdint.h>
#ifndef __WIN32__
#include <unistd.h>
#endif
#include <sys/stat.h>
#include <vector>
#include <string>
#include "../../base/types.h"
#include "../../src/soc.h"
#include "tokenizer.h"

static int compare_tokens(const void *a, const void *b) {
    return strcmp(((SPMTokenIndex*)a)->str, ((SPMTokenIndex*)b)->str);
}

Tokenizer::Tokenizer() {
    m_special.NL = -1;
    m_special.BOS = 1;
    m_special.EOS = 2;
}

Tokenizer::~Tokenizer() {
}

//************************************************************** 
// SPM tokenizer
//************************************************************** 

TokenizerSPM::TokenizerSPM() : Tokenizer() {
    vocab = 0;
    vocab_scores = 0;
    sorted_vocab = 0;
    str_buffer = 0;
}

TokenizerSPM::~TokenizerSPM() {
    if(vocab)
        free(vocab);
    if(vocab_scores)
        free(vocab_scores);
    if(sorted_vocab)
        free(sorted_vocab);
    if(str_buffer)
        free(str_buffer);
}

void TokenizerSPM::Build(float *scoreLst,char *_tokens,uint32_t _vocab_size,uint32_t _max_token_length) {
    vocab_size = _vocab_size;
    max_token_length = _max_token_length;
    vocab = (char**)malloc(vocab_size * sizeof(char*));
    vocab_scores = (float*)malloc(vocab_size * sizeof(float));
    sorted_vocab = 0;
    str_buffer = (char *)malloc((max_token_length*2 +1 +2) * sizeof(char));
    for (int i = 0; i < 256; i++) {
        byte_pieces[i * 2] = (unsigned char)i;
        byte_pieces[i * 2 + 1] = '\0';
    }
    for(uint32_t i=0;i < vocab_size;i++) {
        if(i <= 2)
            vocab_scores[i]=0;
        else
            vocab_scores[i] = scoreLst[i];
    }
    char *p1=_tokens;
    for (uint32_t i = 0; i < vocab_size; i++) {
        vocab[i] = p1;
        p1 += strlen(p1)+1;
        if (!strcmp(vocab[i], "\n") || !strcmp(vocab[i], "\xc4\x8a"))
            m_special.NL = i;
    }
    sorted_vocab = (SPMTokenIndex *)malloc(vocab_size * sizeof(SPMTokenIndex));
    for (uint32_t i = 0; i < vocab_size; i++) {
        sorted_vocab[i].str = vocab[i];
        sorted_vocab[i].id = i;
    }
    qsort(sorted_vocab,vocab_size,sizeof(SPMTokenIndex),compare_tokens);
}

char* TokenizerSPM::TokenToString(int prev_token, int token) {
    char *piece = vocab[token];
    // following BOS (1) token, sentencepiece decoder strips any leading whitespace (see PR #89)
    if (prev_token == 1 && piece[0] == ' ') { piece++; }
    // careful, some tokens designate raw bytes, and look like e.g. '<0x01>'
    // parse this and convert and return the actual byte
    unsigned char byte_val;
    if (sscanf(piece, "<0x%02hhX>", &byte_val) == 1) {
        piece = (char*)byte_pieces + byte_val * 2;
    }
    return piece;
}

ZtaStatus TokenizerSPM::StringToToken(char *text, int8_t bos, int8_t eos, std::vector<int> &tokens,int timeout) {
    // encode the string text (input) into an upper-bound preallocated tokens[] array
    // bos != 0 means prepend the BOS token (=1), eos != 0 means append the EOS token (=2)
    assert(text);

    // create a temporary buffer that will store merge candidates of always two consecutive tokens
    // *2 for concat, +1 for null terminator +2 for UTF8 (in case max_token_length is 1)

    size_t str_len = 0;

    // add optional BOS (=1) token, if desired
    if (bos) tokens.push_back(1);

    // add_dummy_prefix is true by default
    // so prepend a dummy prefix token to the input string, but only if text != ""
    // TODO: pretty sure this isn't correct in the general case but I don't have the
    // energy to read more of the sentencepiece code to figure out what it's doing
    if (text[0] != '\0') {
        int dummy_prefix = lookup((char *)" ");
        tokens.push_back(dummy_prefix);
    }

    // Okay UTF-8 time. This will get messy. Here is the reference from Wikipedia:
    // Code point ↔ UTF-8 conversion
    // First code point	Last code point	Byte 1	Byte 2	Byte 3	Byte 4
    // U+0000	U+007F	    0xxxxxxx
    // U+0080	U+07FF	    110xxxxx	10xxxxxx
    // U+0800	U+FFFF	    1110xxxx	10xxxxxx	10xxxxxx
    // U+10000	U+10FFFF    11110xxx	10xxxxxx	10xxxxxx	10xxxxxx

    // process the raw (UTF-8) byte sequence of the input string
    for (char *c = text; *c != '\0'; c++) {

        // reset buffer if the current byte is ASCII or a leading byte
        // 0xC0 is 11000000, so (*c & 0xC0) keeps the first 2 bits and zeros the rest
        // 0x80 is 10000000
        // in UTF-8, all continuation bytes start with "10" in first two bits
        // so in English this is: "if this byte is not a continuation byte"
        if ((*c & 0xC0) != 0x80) {
            // this byte must be either a leading byte (11...) or an ASCII char (0x...)
            // => reset our location, as we're starting a new UTF-8 codepoint
            str_len = 0;
        }

        // append the current byte to the buffer
        str_buffer[str_len++] = *c; // ++ is post-increment, incremented after this line
        str_buffer[str_len] = '\0';

        // while the next character is a continuation byte, continue appending
        // but if there are too many of them, just stop to avoid overruning str_buffer size.
        if ((*(c+1) & 0xC0) == 0x80 && str_len < 4) {
            continue;
        }

        // ok c+1 is not a continuation byte, so we've read in a full codepoint
        int id = lookup(str_buffer);

        if (id != -1) {
            // we found this codepoint in vocab, add it as a token
            tokens.push_back(id);
        } else {
            // byte_fallback encoding: just encode each byte as a token
            // +3 is here because the first 3 vocab elements are <unk>, <s>, </s>
            // so the individual bytes only start at index 3
            for (int i=0; i < (int)str_len; i++) {
                tokens.push_back((int)((unsigned char)str_buffer[i] + 3));
            }
        }
        str_len = 0; // protect against a sequence of stray UTF8 continuation bytes
    }

    // merge the best consecutive pair each iteration, according the scores in vocab_scores
    while (1) {
        float best_score = -1e10;
        int best_id = -1;
        int best_idx = -1;

        for (int i=0; i < (int)(tokens.size()-1); i++) {
            // check if we can merge the pair (tokens[i], tokens[i+1])
            sprintf(str_buffer, "%s%s",vocab[tokens[i]],vocab[tokens[i+1]]);
            int id = lookup(str_buffer);
            if (id != -1 && vocab_scores[id] > best_score) {
                // this merge pair exists in vocab! record its score and position
                best_score = vocab_scores[id];
                best_id = id;
                best_idx = i;
            }
        }

        if (best_idx == -1) {
            break; // we couldn't find any more pairs to merge, so we're done
        }

        // merge the consecutive pair (best_idx, best_idx+1) into new token best_id
        tokens[best_idx] = best_id;
        // delete token at position best_idx+1, shift the entire sequence back 1
        for (int i = best_idx+1; i < (int)(tokens.size()-1); i++) {
            tokens[i] = tokens[i+1];
        }
        tokens.pop_back();
    }

    // add optional EOS (=2) token, if desired
    if (eos) tokens.push_back(2);
    return ZtaStatusOk;
}

int TokenizerSPM::lookup(char *str) {
    // efficiently find the perfect match for str in vocab, return its index or -1 if not found
    SPMTokenIndex tok; // acts as the key to search for
    tok.str = str;
    SPMTokenIndex *res = (SPMTokenIndex *)bsearch(&tok, sorted_vocab, vocab_size, sizeof(SPMTokenIndex), compare_tokens);
    return res != NULL ? res->id : -1;
}


//************************************************************** 
// BFE tokenizer
//************************************************************** 

static int BFE_compare_tokens(const void *a, const void *b) {
    return strcmp(((BFE_TokenIndex*)a)->str, ((BFE_TokenIndex*)b)->str);
}

TokenizerBFE::TokenizerBFE() : Tokenizer() {
    m_vocabSize=0;
    m_vocab=0;
    m_mergeSize=0;
    m_merge=0;
    m_mergeHash = 0;
    m_token=0;
    sorted_vocab=0;
    m_shash = 0;
    m_inProgress=false;
}

TokenizerBFE::~TokenizerBFE() {
    if (m_vocab)
        free(m_vocab);
    if (m_merge)
        free(m_merge);
    if (m_mergeHash)
        free(m_mergeHash);
    if (m_token)
        free(m_token);
    if(sorted_vocab)
        free(sorted_vocab);
    if(m_shash)
        free(m_shash);
}

void TokenizerBFE::Build(uint32_t vocabSize, char* vocab,uint32_t mergeSize, char *merge,uint32_t max_token_length) {
    uint32_t i;
    char* p;

    if (m_vocab) {
        free(m_vocab);
        m_vocab = 0;
    }
    if (m_merge) {
        free(m_merge);
        m_merge = 0;
    }
    if (m_token) {
        free(m_token);
        m_token = 0;
    }
    m_vocabSize = vocabSize;
    m_vocab = (char **)malloc(m_vocabSize * sizeof(char*));
    m_mergeSize = mergeSize/2;
    m_merge = (BFEMerge *)malloc(m_mergeSize * sizeof(BFEMerge));
    m_mergeHash = (uint8_t *)malloc(m_mergeSize * sizeof(uint16_t));
    m_token = (char *)malloc(max_token_length + 16);
    for (i = 0, p = vocab; i < vocabSize; i++) {
        m_vocab[i] = p;
        p += strlen(p) + 1;
        if (!strcmp(m_vocab[i], "\n") || !strcmp(m_vocab[i], "\xc4\x8a"))
            m_special.NL = i;
    }
    sorted_vocab = (BFE_TokenIndex *)malloc(vocabSize * sizeof(BFE_TokenIndex));
    for (uint32_t i = 0; i < vocabSize; i++) {
        sorted_vocab[i].str = m_vocab[i];
        sorted_vocab[i].id = i;
    }
    qsort(sorted_vocab,vocabSize,sizeof(BFE_TokenIndex),BFE_compare_tokens);
    
    for (i = 0, p = merge; i < m_mergeSize; i++) {
        m_merge[i].first = p;
        p += strlen(p) + 1;
        m_merge[i].second = p;
        p += strlen(p) + 1;
        m_mergeHash[2*i] = hashFunc(m_merge[i].first);
        m_mergeHash[2*i+1] = hashFunc(m_merge[i].second);
    }
}

char *TokenizerBFE::TokenToString(int prev_token,int token) {
    char* src, * dst;
    if(token==m_special.NL) {
        m_token[0]='\r';
        m_token[1]='\n';
        m_token[2]=0;
        return m_token;
    }
    src = m_vocab[token];
    dst = m_token;
    assert(token < (int)m_vocabSize && token >= 0);
    while (*src) {
        if ((uint8_t)(*src) == 0xc4 && (uint8_t)(src[1]) == 0xa0) {
            *dst = ' ';
            src += 2;
            dst++;
        }
        else {
            *dst = *src;
            dst++;
            src++;
        }
    }
    *dst = 0;
    return m_token;
}

ZtaStatus TokenizerBFE::StringToToken(char* text,int8_t bos,int8_t eos,std::vector<int> &tokens,int timeout) {
    int count = 0;
    int i,r;
    bool merged;
    int maxCount=0;
    uint32_t tick,tock;
    int match1=0;
    int match2=0;
    uint8_t *p,*p2;

    tick = TimeGet();

    // Convert text into tokens, keeping space as its own symbol
    if(text) {
        m_s.clear();
        if(m_shash)
            free(m_shash);
        m_shash = (uint8_t *)malloc(strlen(text) + 1);

        m_shashLen = 0;
        m_nTokens = 0;

        for (i = 0; i < (int)strlen(text); i++) {
            char buf[8];
            if (text[i] == ' ') {
                m_s.push_back(std::string("\xc4\xa0"));
                m_shash[m_shashLen++]=hashFunc((char*)"\xc4\xa0");
                m_nTokens++;
            }
            else {
                sprintf(buf, "%c", text[i]);
                m_s.push_back(std::string(buf));
                m_shash[m_shashLen++]=hashFunc(buf);
                m_nTokens++;
            }
        }
        m_inProgress=true;
    }
    if(!m_inProgress) {
        return ZtaStatusOk;
    }
    merged = true;
    while (merged) {
        if(timeout > 0) {
            tock = TimeGet();
            if(((int32_t)tock-(int32_t)tick) >= timeout)
                break;
        }
        merged = false;
        for (r = 0,p2=m_mergeHash; r < (int)m_mergeSize; r++,p2 += 2) {
            uint8_t key1 = p2[0];
            uint8_t key2 = p2[1];
            for (i = 0,p=m_shash; i < (m_nTokens - 1);i++,p++) {
                if(key1 != p[0] || key2 != p[1])
                    continue;
                if (strcmp(m_s[i].c_str(), m_merge[r].first) == 0 &&
                    strcmp(m_s[i + 1].c_str(), m_merge[r].second) == 0) {
                    m_s[i] = m_s[i] + m_s[i + 1];
                    m_s.erase(m_s.begin() + i + 1);
                    m_nTokens--;
                    p[0] = p[0] + p[1];
                    if((m_shashLen-i-2) > 0)
                        memcpy(&p[1], &p[2],(m_shashLen-i-2));
                    m_shashLen--;
                    merged = true;
                    break;
                }
            }
            if (merged)
                break;
        }
    }
    if(merged) {
        return ZtaStatusPending;
    }
    for (i = 0; i < (int)m_s.size(); i++) {
        int id=lookupToken((char *)m_s[i].c_str());
        if(id >= 0)
            tokens.push_back(id);        
    }
    m_inProgress=false;
    return ZtaStatusOk;
}

int TokenizerBFE::lookupToken(char *str) {
    BFE_TokenIndex tok; 
    tok.str = str;
    BFE_TokenIndex *res = (BFE_TokenIndex *)bsearch(&tok, sorted_vocab, m_vocabSize, sizeof(BFE_TokenIndex), BFE_compare_tokens);
    return res != NULL ? res->id : -1;
}

uint8_t TokenizerBFE::hashFunc(char* s) {
    uint8_t sum = 0;
    while (*s) {
        sum += (uint8_t)(*s);
        s++;
    }
    return sum;
}



