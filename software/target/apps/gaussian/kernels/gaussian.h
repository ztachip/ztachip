#ifndef _GAUSSIAN_H_
#define _GAUSSIAN_H_

#define TILE_DX_DIM   8  // Tile dimension 
#define TILE_DY_DIM   4  // Tile dimension 
#define TILE_MAX_PAD  3  // Overlap region between tiles
#define TILE_MAX_KZ   7  // (TILE_MAX_PAD*2+1)

#define ICONV_MAX_INBUF     140 // (TILE_DX_DIM+2*TILE_MAX_PAD)*(TILE_DY_DIM+2*TILE_MAX_PAD)
#define ICONV_MAX_OUTBUF    32  // TILE_DX_DIM*TILE_DY_DIM
#define ICONV_MAX_KERNEL    49  // (TILE_MAX_PAD*2+1)**2

#define SCALE_FACTOR    10

#endif