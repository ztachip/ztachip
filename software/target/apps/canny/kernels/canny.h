#ifndef _CANNY_H_
#define _CANNY_H_

#define TILE_DX_DIM     4  // Tile dimension 
#define TILE_DY_DIM     4  // Tile dimension 
#define TILE_MAX_PAD    1  // Overlap region between tiles
#define TILE_MAX_KZ     3  // (TILE_MAX_PAD*2+1)

#define CANNY_MAX_INBUF    36 // (TILE_DX_DIM+2*TILE_MAX_PAD)*(TILE_DY_DIM+2*TILE_MAX_PAD)
#define CANNY_MAX_OUTBUF   16  // TILE_DX_DIM*TILE_DY_DIM
#define CANNY_MAX_KERNEL   9  // (TILE_MAX_PAD*2+1)**2

// Gradient direction

#define DIRECTION_EW    0
#define DIRECTION_NS    1
#define DIRECTION_NE_SW 2
#define DIRECTION_NW_SE 3

#endif