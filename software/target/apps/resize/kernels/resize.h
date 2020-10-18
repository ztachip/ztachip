#ifndef _MYAPP_H_
#define _MYAPP_H_

// Image resize

#define TILE_DIM      8  // Tile dimension 
#define TILE_PAD      3  // Overlap region between tiles

#define RESIZE_MAX_INBUF     121 // (TILE_IN_DIM+TILE_PAD)**2
#define RESIZE_MAX_OUTBUF    64  // TILE_OUT_DIM**2

#define RESIZE_BOX_MAX_DOWNSCALE  4

#define BOX_RESIZE_MAX_INBUF     64 
#define BOX_RESIZE_MAX_OUTBUF    16

#define BOX_RESIZE_MAX_FILTER    8

#define BOX_RESIZE_SCALE 8

#endif