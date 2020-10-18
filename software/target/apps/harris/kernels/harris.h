#ifndef _HARRIS_H_
#define _HARRIS_H_

#define TILE_DX_DIM   4  // Tile dimension 
#define TILE_DY_DIM   4  // Tile dimension 
#define TILE_MAX_PAD  1  // Overlap region between tiles
#define TILE_MAX_KZ   3  // (TILE_MAX_PAD*2+1)

#define HARRIS_MAX_INBUF     36 // (TILE_DX_DIM+2*TILE_MAX_PAD)*(TILE_DY_DIM+2*TILE_MAX_PAD)
#define HARRIS_MAX_OUTBUF    16  // TILE_DX_DIM*TILE_DY_DIM
#define HARRIS_MAX_KERNEL    9  // (TILE_MAX_PAD*2+1)**2


#endif