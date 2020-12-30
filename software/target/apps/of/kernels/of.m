#include "../../../base/ztam.h"
#include "of.h"

// Doing dense optical flow using Lucas-Kanade method.
// https://en.wikipedia.org/wiki/Lucas%E2%80%93Kanade_method

extern void mycallback(int);

typedef struct {
   uint32_t input[2];
   uint32_t x_gradient;
   uint32_t y_gradient;
   uint32_t t_gradient;
   uint32_t x_vect;
   uint32_t y_vect;
   uint32_t display;
   uint32_t spu;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   int dst_w;
   int dst_h;
} Request;

// Find gradient in X and Y direction

static void of_phase_0(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h,pad;
   int inputLen;
   uint32_t input[2],x_gradient,y_gradient,t_gradient;
   int x,y,cnt;
   int x_off,y_off;
   int ksz=3;

   x_off=req->x_off;
   y_off=req->y_off;
   pad=(ksz/2);
   dx2=NUM_PCORE*TILE_DX_DIM;
   dx=NUM_PCORE*TILE_DX_DIM-pad;
   dy=TILE_DY_DIM*VECTOR_WIDTH;
   dxcnt=(req->w+dx-1)/dx;
   dycnt=(req->h+dy-1)/dy;
   h=(req->h+TILE_DY_DIM-1)/TILE_DY_DIM;
   if(pid==0) {
      from=0;
      to=(dycnt<=1)?dycnt:dycnt/2;
   } else {
      if(dycnt <= 1)
         return;
      from=dycnt/2;
      to=dycnt;
   }

   // Load the convolution kernel...
   > EXE_LOCKSTEP(of::init,NUM_PCORE);
   ztamTaskYield();

   inputLen=req->src_w*req->src_h;
   input[0]=req->input[0];
   input[1]=req->input[1];
   inputLen-=y_off*req->src_w;
   input[0]+=y_off*req->src_w;
   input[0]-=req->src_w*pad;
   input[1]+=y_off*req->src_w;
   input[1]-=req->src_w*pad;

   inputLen+=req->src_w*pad;
   x_gradient=req->x_gradient;
   y_gradient=req->y_gradient;
   t_gradient=req->t_gradient;

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;
         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >(ushort)PCORE(NUM_PCORE)[0].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(ushort)PCORE(NUM_PCORE)[cnt-1].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];

            >(ushort)PCORE(NUM_PCORE)[0].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(ushort)PCORE(NUM_PCORE)[cnt-1].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM-pad:TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >(ushort)PCORE(NUM_PCORE)[0].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= SHORT(0);
            >(ushort)PCORE(NUM_PCORE)[0].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= SHORT(0);
         }
         
         // Copy input to PCORE array...

         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(ushort)MEM(input[0],inputLen(h,TILE_DY_DIM+,req->src_w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx+x_off:x*dx+dx2+x_off-1];

         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(ushort)MEM(input[1],inputLen(h,TILE_DY_DIM+,req->src_w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:TILE_DY_DIM+2*pad-1][x*dx+x_off:x*dx+dx2+x_off-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
         >(ushort)PCORE(NUM_PCORE)[0:cnt-2].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >(ushort)PCORE(NUM_PCORE)[1:cnt-1].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];
         
         // Copy right margin from left tiles to the immediate right tiles...

         >(ushort)PCORE(NUM_PCORE)[1:cnt-1].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(ushort)SYNC PCORE(NUM_PCORE)[0:cnt-2].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         // Copy left margin from right tiles to the immediate left tiles...
         >(ushort)PCORE(NUM_PCORE)[0:cnt-2].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM+pad:TILE_DX_DIM+2*pad-1][:] <=
         >(ushort)PCORE(NUM_PCORE)[1:cnt-1].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
         >(ushort)PCORE(NUM_PCORE)[1:cnt-1].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(ushort)PCORE(NUM_PCORE)[0:cnt-2].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][TILE_DX_DIM:TILE_DX_DIM+pad-1][:];

         if(y==0)
         {
            >PCORE(NUM_PCORE)[*].of::inbuf1(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= SHORT(0);
            >PCORE(NUM_PCORE)[*].of::inbuf2(TILE_DY_DIM+2*pad,TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= SHORT(0);
         }

         > EXE_LOCKSTEP(of::calc_gradient,NUM_PCORE);

         ztamTaskYield();

         // Copy result tiles back to memory
         >(int)MEM(x_gradient,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (int)PCORE(NUM_PCORE)[II].of::x_gradient(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];

         >(int)MEM(y_gradient,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (int)PCORE(NUM_PCORE)[II].of::y_gradient(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];

         >(int)MEM(t_gradient,req->dst_h,req->dst_w)[y*dy:y*dy+TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <=
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=0:TILE_DX_DIM-1) (int)PCORE(NUM_PCORE)[II].of::t_gradient(TILE_DY_DIM,TILE_DX_DIM,VECTOR_WIDTH)[I][J][K];
      }
   }
}

// Calculate optical flow based on Lucas-Kanade method...

static void of_phase_1(void *_p,int pid) {
   Request *req=(Request *)_p;
   int from,to;
   int dx,dx2,dy;
   int dxcnt,dycnt;
   int h2,pad;
   int x_gradientLen;
   uint32_t x_gradient;
   int y_gradientLen;
   uint32_t y_gradient;
   int t_gradientLen;
   uint32_t t_gradient;
   int x,y,cnt;
   int w,h;
   int ksz=OF1_TILE_MAX_KZ;

   if(pid==0) {
      > SPU <= (int)MEM(req->spu,SPU_LOOKUP_SIZE*4)[:];
   }
   pad=(ksz/2);
   w=req->w;
   h=req->h;
   dx2=NUM_PCORE*OF1_TILE_DX_DIM;
   dx=NUM_PCORE*OF1_TILE_DX_DIM-pad;
   dy=OF1_TILE_DY_DIM*VECTOR_WIDTH;
   dxcnt=(w+dx-1)/dx;
   dycnt=(h+dy-1)/dy;
   h2=(h+OF1_TILE_DY_DIM-1)/OF1_TILE_DY_DIM;
   if(pid==0) {
      from=0;
      to=(dycnt<=1)?dycnt:dycnt/2;
   } else {
      if(dycnt <= 1)
         return;
      from=dycnt/2;
      to=dycnt;
   }
   // Load the convolution kernel...
   > EXE_LOCKSTEP(of1::init,NUM_PCORE);
   ztamTaskYield();

   x_gradientLen=w*h*sizeof(int16_t);
   x_gradient=req->x_gradient;
   x_gradient-=w*pad*sizeof(int16_t);
   x_gradientLen+=w*pad*sizeof(int16_t);

   y_gradientLen=w*h*sizeof(int16_t);
   y_gradient=req->y_gradient;
   y_gradient-=w*pad*sizeof(int16_t);
   y_gradientLen+=w*pad*sizeof(int16_t);

   t_gradientLen=w*h*sizeof(int16_t);
   t_gradient=req->t_gradient;
   t_gradient-=w*pad*sizeof(int16_t);
   t_gradientLen+=w*pad*sizeof(int16_t);

   for(y=from;y < to;y++) {
      for(x=0;x < dxcnt;x++) {
         cnt=NUM_PCORE;

         // Copy the left-pad from left most tiles edges from memory.
         if(x>0) {
            >(int)PCORE(NUM_PCORE)[0].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(int)PCORE(NUM_PCORE)[cnt-1].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM-pad:OF1_TILE_DX_DIM+pad-pad-1][:];
            >(int)PCORE(NUM_PCORE)[0].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(int)PCORE(NUM_PCORE)[cnt-1].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM-pad:OF1_TILE_DX_DIM+pad-pad-1][:];

            >(int)PCORE(NUM_PCORE)[0].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= 
            >(int)PCORE(NUM_PCORE)[cnt-1].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM-pad:OF1_TILE_DX_DIM+pad-pad-1][:];
         } else {
            // There is nothing at the left. So set it to zero...
            >(int)PCORE(NUM_PCORE)[0].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT(0);
            >(int)PCORE(NUM_PCORE)[0].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT(0);
            >(int)PCORE(NUM_PCORE)[0].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <= INT(0);
         }
         // Copy input to PCORE array...
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+OF1_TILE_DX_DIM-1) (int) PCORE(NUM_PCORE)[II].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(int)MEM(x_gradient,x_gradientLen(h2,OF1_TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:OF1_TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+OF1_TILE_DX_DIM-1) (int) PCORE(NUM_PCORE)[II].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(int)MEM(y_gradient,y_gradientLen(h2,OF1_TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:OF1_TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM+2*pad-1) FOR(II=0:NUM_PCORE-1) FOR(J=pad:pad+OF1_TILE_DX_DIM-1) (int) PCORE(NUM_PCORE)[II].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[I][J][K] <= 
         >(int)MEM(t_gradient,t_gradientLen(h2,OF1_TILE_DY_DIM+,w))[y*VECTOR_WIDTH:y*VECTOR_WIDTH+VECTOR_WIDTH-1][0:OF1_TILE_DY_DIM+2*pad-1][x*dx:x*dx+dx2-1];

         // Copy the gap from adjacent tile.

         // Copy left margin from right tiles to the immediate left tiles...
	     >(int)PCORE(NUM_PCORE)[0:cnt-2].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM+pad:OF1_TILE_DX_DIM+2*pad-1][:] <=
         >(int)PCORE(NUM_PCORE)[1:cnt-1].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
	     >(int)PCORE(NUM_PCORE)[1:cnt-1].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(int)SYNC PCORE(NUM_PCORE)[0:cnt-2].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+pad-1][:];

         // Copy left margin from right tiles to the immediate left tiles...
	     >(int)PCORE(NUM_PCORE)[0:cnt-2].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM+pad:OF1_TILE_DX_DIM+2*pad-1][:] <=
         >(int)PCORE(NUM_PCORE)[1:cnt-1].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
	     >(int)PCORE(NUM_PCORE)[1:cnt-1].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(int)PCORE(NUM_PCORE)[0:cnt-2].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+pad-1][:];

         // Copy left margin from right tiles to the immediate left tiles...
	     >(int)PCORE(NUM_PCORE)[0:cnt-2].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM+pad:OF1_TILE_DX_DIM+2*pad-1][:] <=
         >(int)PCORE(NUM_PCORE)[1:cnt-1].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][pad:2*pad-1][:];

         // Copy right margin from left tiles to the immediate right tiles...
	     >(int)PCORE(NUM_PCORE)[1:cnt-1].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][0:pad-1][:] <=
         >(int)PCORE(NUM_PCORE)[0:cnt-2].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+pad-1][:];
         if(y==0) {
            >(int)PCORE(NUM_PCORE)[*].of1::x_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT(0);
            >(int)PCORE(NUM_PCORE)[*].of1::y_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT(0);
            >(int)PCORE(NUM_PCORE)[*].of1::t_gradient(OF1_TILE_DY_DIM+2*pad,OF1_TILE_DX_DIM+2*pad,VECTOR_WIDTH)[0:pad-1][:][0] <= INT(0);
         }
         > EXE_LOCKSTEP(of1::calc_lucus_kanade,NUM_PCORE);

         ztamTaskYield();

         >(int)PCORE(NUM_PCORE)[:].of1::t_gradient(OF1_TILE_DY_DIM,OF1_TILE_DX_IN_DIM,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+OF1_TILE_DX_DIM-1][:] <= PROC(0) <= 
         >(int)PCORE(NUM_PCORE)[:].of1::t_gradient(OF1_TILE_DY_DIM,OF1_TILE_DX_IN_DIM,VECTOR_WIDTH)[:][OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+OF1_TILE_DX_DIM-1][:];

         > EXE_LOCKSTEP(of1::calc_lucus_kanade_final,NUM_PCORE);

         ztamTaskYield();

         // Copy result tiles back to memory
         >(int)MEM(req->x_vect,h,w)[y*dy:y*dy+OF1_TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <= 
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+OF1_TILE_DX_DIM-1) (int)PCORE(NUM_PCORE)[II].of1::x_gradient(OF1_TILE_DY_DIM,OF1_TILE_DX_IN_DIM,VECTOR_WIDTH)[I][J][K];

         >(int)MEM(req->y_vect,h,w)[y*dy:y*dy+OF1_TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <= 
         >SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+OF1_TILE_DX_DIM-1) (int)PCORE(NUM_PCORE)[II].of1::y_gradient(OF1_TILE_DY_DIM,OF1_TILE_DX_IN_DIM,VECTOR_WIDTH)[I][J][K];
    
         if(req->display) {
            // Show red color for horizontal movementto the right 
            >(ushort)MEM(req->display,3,h,w)[0][y*dy:y*dy+OF1_TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <= PROC(1) <=
            >(ushort)SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+OF1_TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].of1::x_gradient(OF1_TILE_DY_DIM,OF1_TILE_DX_IN_DIM,VECTOR_WIDTH)[I][J][K]; 

            // Show green color for horizontal movement to the left          
            >(ushort)MEM(req->display,3,h,w)[1][y*dy:y*dy+OF1_TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <= PROC(2) <=
            >(ushort)SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+OF1_TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].of1::x_gradient(OF1_TILE_DY_DIM,OF1_TILE_DX_IN_DIM,VECTOR_WIDTH)[I][J][K]; 

            // Show blue color for vertical movement 
            >(ushort)MEM(req->display,3,h,w)[2][y*dy:y*dy+OF1_TILE_DY_DIM*VECTOR_WIDTH-1][x*dx:x*dx+dx2-1] <= PROC(3) <=
            >(ushort)SCATTER(0) FOR(K=0:VECTOR_WIDTH-1) FOR(I=0:OF1_TILE_DY_DIM-1) FOR(II=0:NUM_PCORE-1) FOR(J=OF1_TILE_DX_DIM:OF1_TILE_DX_DIM+OF1_TILE_DX_DIM-1) PCORE(NUM_PCORE)[II].of1::y_gradient(OF1_TILE_DY_DIM,OF1_TILE_DX_IN_DIM,VECTOR_WIDTH)[I][J][K]; 
         }
      }
   }
}

// Process optical flow request from host

void do_of(int queue) {
   int resp;
   Request req;
   req.input[0]=ztamMsgqReadPointer(queue);
   req.input[1]=ztamMsgqReadPointer(queue);
   req.x_gradient=ztamMsgqReadPointer(queue);
   req.y_gradient=ztamMsgqReadPointer(queue);
   req.t_gradient=ztamMsgqReadPointer(queue);
   req.x_vect=ztamMsgqReadPointer(queue);
   req.y_vect=ztamMsgqReadPointer(queue);
   req.display=ztamMsgqReadPointer(queue);
   req.spu=ztamMsgqReadPointer(queue);
   req.w=ztamMsgqReadInt(queue);
   req.h=ztamMsgqReadInt(queue);
   req.src_w=ztamMsgqReadInt(queue);
   req.src_h=ztamMsgqReadInt(queue);
   req.x_off=ztamMsgqReadInt(queue);
   req.y_off=ztamMsgqReadInt(queue);
   req.dst_w=ztamMsgqReadInt(queue);
   req.dst_h=ztamMsgqReadInt(queue);
   resp=ztamMsgqReadInt(queue);
   ztamTaskSpawn(of_phase_0,&req,1);
   of_phase_0(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   ztamTaskSpawn(of_phase_1,&req,1);
   of_phase_1(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

> EXPORT(do_of);
