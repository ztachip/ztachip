#ifndef _APPS_OF_KERNELS_OF_H_
#define _APPS_OF_KERNELS_OF_H_

// Parameter for doing convolution

#define TILE_DX_DIM        4  // Tile dimension 
#define TILE_DY_DIM        4  // Tile dimension 
#define TILE_MAX_PAD       1  // Overlap region between tiles
#define TILE_MAX_KZ        3  // (TILE_MAX_PAD*2+1)

#define OF_MAX_INBUF       36 // (TILE_DX_DIM+2*TILE_MAX_PAD)*(TILE_DY_DIM+2*TILE_MAX_PAD)
#define OF_MAX_OUTBUF      16  // TILE_DX_DIM*TILE_DY_DIM

// Parameter for doing Lucas-Kanade windowing

#define OF1_TILE_DX_DIM    4  // Tile dimension 
#define OF1_TILE_DY_DIM    4  // Tile dimension
#define OF1_TILE_DX_IN_DIM 8  // OF1_TILE_DX_DIM+2*OF1_TILE_MAX_PAD 
#define OF1_TILE_DY_IN_DIM 8  // OF1_TILE_DY_DIM+2*OF1_TILE_MAX_PAD 
#define OF1_TILE_MAX_PAD   2  // Overlap region between tiles
#define OF1_TILE_MAX_KZ    5  // (OF1_TILE_MAX_PAD*2+1)

#define OF1_MAX_INBUF     64 // (OF1_TILE_DX_DIM+2*OF1_TILE_MAX_PAD)*(OF1_TILE_DY_DIM+2*OF1_TILE_MAX_PAD)
#define OF1_MAX_OUTBUF    16  // OF1_TILE_DX_DIM*OF1_TILE_DY_DIM

#endif