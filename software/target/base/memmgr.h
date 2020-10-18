#ifndef __TARGET_BASE_MEMMGR_H__
#define __TARGET_BASE_MEMMGR_H__

#include <stdint.h>

typedef struct {
   uint32_t len;
   uint32_t flags;
} mem_header_t;

class MemMgr {
public:
   static void init(void *p, int len);
   static void *allocate(int len);
   static void free(void *p);
private:
   static mem_header_t *trailer(mem_header_t *h);
   static void *body(mem_header_t *h);
   static mem_header_t *next(mem_header_t *h);
   static mem_header_t *previous(mem_header_t *h);
private:
   static mem_header_t *M_top;
   static mem_header_t *M_bot;
};

#endif
