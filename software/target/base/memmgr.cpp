#include "memmgr.h"
#include "ztahost.h"

mem_header_t *MemMgr::M_top=0;
mem_header_t *MemMgr::M_bot=0;

// Initialize memory manager
// Initialize the memory pool

void MemMgr::init(void *p, int len) {
   mem_header_t *h;
   len = (len / 8) * 8;
   M_top = (mem_header_t *)p;
   M_bot = (mem_header_t *)((uint32_t)p + len);
   h = (mem_header_t *)M_top;
   h->len = len;
   h->flags = 0;
   h = trailer(h);
   h->len = len;
   h->flags = 0;
}

// Allocate a memory block from global pool

void *MemMgr::allocate(int len) {
   mem_header_t *h, *h2;
   int remain;
   len = ((len + 7) / 8) * 8;
   len += 2 * sizeof(mem_header_t);
   h = (mem_header_t *)M_top;
   while (h) {
      if (h->flags == 0 && h->len >= (size_t)len) {
         // Split this block
         remain = (int)h->len - len;
         if (remain >= (int)(2 * sizeof(mem_header_t) + 8)) {
            h->len = len;
            h->flags = 1;
            h2 = trailer(h);
            h2->len = len;
            h2->flags = 1;

            h2 = (mem_header_t *)((uint32_t)h2 + sizeof(mem_header_t));
            h2->len = remain;
            h2->flags = 0;
            h2 = trailer(h2);
            h2->len = remain;
            h2->flags = 0;
         } else {
            h->flags = 1;
            h2 = trailer(h);
            h2->flags = 1;
         }
         return body(h);
      }
      else
         h = next(h);
   }
   return 0;
}

// Release a memory block back to global pool

void MemMgr::free(void *p)
{
   mem_header_t *h, *h2, *above, *below;
   h = (mem_header_t *)((uint32_t)p - sizeof(mem_header_t));
   above = previous(h);
   below = next(h);
   // Check if we can merge with block above
   if (above && above->flags == 0) {
      above->len += h->len;
      above->flags = 0;
      h2 = trailer(above);
      h2->len = above->len;
      h2->flags = 0;
      h = above;
   }
   // Check if we can merge with block below
   if (below && below->flags == 0) {
      h->len += below->len;
      h->flags = 0;
      h2 = trailer(h);
      h2->len = h->len;
      h2->flags = 0;
   }
   h->flags = 0;
}

// Trailer section of memory block

mem_header_t *MemMgr::trailer(mem_header_t *h) {
   return ((mem_header_t *)((uint32_t)(h)+(h)->len - sizeof(mem_header_t)));
}

// Body section of memory block

void *MemMgr::body(mem_header_t *h) {
   return (void *)((uint32_t)h + sizeof(mem_header_t));
}

// Get next memory block

mem_header_t *MemMgr::next(mem_header_t *h) {
   mem_header_t *h2;
   h2 = ((mem_header_t *)((uint32_t)(h)+(h)->len));
   if ((uint32_t)h2 >= (uint32_t)M_bot)
      return 0;
   else
      return h2;
}

// Get previous memory block

mem_header_t *MemMgr::previous(mem_header_t *h) {
   if ((uint32_t)(h) <= (uint32_t)M_top)
      return 0;
   else
      return (mem_header_t *)((uint32_t)(h)-((mem_header_t *)((uint32_t)(h)-sizeof(mem_header_t)))->len);
}
