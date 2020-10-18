#include "../../../base/ztam.h"
#include "color.h"

extern void mycallback(int parm2);

#define PCORE_DX  4
#define PCORE_DY  (NUM_PCORE/PCORE_DX)

typedef struct {
   uint32_t input;
   uint32_t output;
   uint32_t spu;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   int dst_x;
   int dst_y;
   int dst_w;
   int dst_h;
   int dst_channel_fmt;
   int dst_channel_color;
} RequestColor;

typedef struct {
   uint32_t input;
   uint32_t output;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   int dst_x;
   int dst_y;
   int dst_w;
   int dst_h;
   int src_channel_fmt;
   int src_channel_color;
   int dst_channel_fmt;
   int dst_channel_color;
   uint32_t equalize;
} RequestCopy;

// Kernel to convert from YUYV color space to RGB color space

static void yuyv2rgb(void *_p,int pid) {
   RequestColor *req=(RequestColor *)_p;
   int x,y;
   int x2,y2;
   int step_x,step_y,step2_x,step2_y;
   int dx,dy,dx2,dy2;
   int from,to,w,h,pixelBytePerChannel;
   uint32_t input,output;
   int x_off,y_off;
   int src_w,src_h;
   uint32_t output1;
   uint32_t output2;
   int outputLen;
   bool clip;

   if(pid==0) {
      > SPU <= (int)MEM(req->spu,SPU_LOOKUP_SIZE)[:];
   }
   pixelBytePerChannel=(req->dst_channel_fmt==kChannelFmtInterleave)?RGB_PIXEL_SIZE:1;
   x_off=req->x_off;
   if(x_off&1)
      ztamAssert("Invalid resize offset");
   x_off=x_off*YUYV_PIXEL_SIZE;
   y_off=req->y_off;

   if( req->src_w==req->w &&
       req->src_h==req->h ) {
      // No clipping...
      clip=false;
      w=req->w*req->h;
      h=1;
      src_w=req->src_h*req->src_w*YUYV_PIXEL_SIZE; // Must be even
      src_h=1;  // Must be even
      step_x = PIXEL_PER_THREAD*YUYV_PIXEL_SIZE*NUM_THREAD_PER_CORE*VECTOR_WIDTH*NUM_PCORE;
      step_y = 1;
      step2_x = PIXEL_PER_THREAD*NUM_THREAD_PER_CORE*pixelBytePerChannel*VECTOR_WIDTH*NUM_PCORE;
      step2_y = 1;
      input=req->input;
      output=req->output;
      dx=(w/2)*h*YUYV_PIXEL_SIZE;
      dy=1;
      dx2=(w/2)*pixelBytePerChannel;
      dy2=1;
      if(pid==1) {
         dx=(w-w/2)*h*YUYV_PIXEL_SIZE;;
         dx2=(w-w/2)*pixelBytePerChannel;
         input+=(w/2)*h*YUYV_PIXEL_SIZE;
         output+=(w/2)*pixelBytePerChannel;
      }
   } else {
      clip=true;
      w=req->w;
      h=req->h;
      src_w=req->src_w*YUYV_PIXEL_SIZE; // Must be even
      src_h=req->src_h;  // Must be even
      step_x = PIXEL_PER_THREAD*YUYV_PIXEL_SIZE*NUM_THREAD_PER_CORE*PCORE_DX;
      step_y = VECTOR_WIDTH*PCORE_DY;
      step2_x = PIXEL_PER_THREAD*NUM_THREAD_PER_CORE*PCORE_DX*pixelBytePerChannel;
      step2_y = VECTOR_WIDTH*PCORE_DY;
      input=req->input;
      output=req->output;
      dx=w*YUYV_PIXEL_SIZE;
      dy=h/2;
      dx2=w*pixelBytePerChannel;
      dy2=h/2;
      outputLen=w*(h/2);
      if(pid==1) {
         dy=h-h/2;
         dy2=h-h/2;
         input+=src_w*(h/2);
         output+=w*(h/2)*pixelBytePerChannel;
	      outputLen=(w*h)-(w*(h/2));
      }
   }

   if(req->dst_channel_fmt==kChannelFmtInterleave) {
      > EXE_LOCKSTEP(yuyv2rgb::init_interleave,NUM_PCORE);
   } else {
      > EXE_LOCKSTEP(yuyv2rgb::init_split,NUM_PCORE);
   }
   output1=output+w*h;
   output2=output+2*w*h;
   for(y=0,y2=0;
       y < dy;
       y+=step_y,y2+=step2_y) {
      for(x=0,x2=0;
       x < dx;
       x += step_x,x2+=step2_x) {
         if(clip) {
            > (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::yuyv(YUYV_BUF_SIZE/8,8,8)[:][:][K] <= (ushort)MEM(input,src_h,src_w)[y+y_off:y+y_off+step_y-1][x+x_off:x+x_off+step_x-1];
         } else {
            > (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::yuyv(YUYV_BUF_SIZE/8,8,8)[:][:][K] <= (ushort)MEM(input,src_h,src_w)[y+y_off][x+x_off:x+x_off+step_x-1];
         }
         > EXE_LOCKSTEP(yuyv2rgb::convert,NUM_PCORE);
         if(req->dst_channel_fmt==kChannelFmtInterleave) {
            if(req->dst_channel_color==kChannelColorBGR) {
               > EXE_LOCKSTEP(yuyv2rgb::final_bgr_interleave,NUM_PCORE);
            } else {
               > EXE_LOCKSTEP(yuyv2rgb::final_rgb_interleave,NUM_PCORE);
            }
         } else {
            if(req->dst_channel_color==kChannelColorBGR) {
               > EXE_LOCKSTEP(yuyv2rgb::final_bgr_split,NUM_PCORE);
            } else {
               > EXE_LOCKSTEP(yuyv2rgb::final_rgb_split,NUM_PCORE);
            }
         }
         ztamTaskYield();
         if(req->dst_channel_fmt==kChannelFmtInterleave) {
            if(clip) {
               > (ushort)MEM(output,dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(RGB_BUF_SIZE/8,8,8)[:][:][L];
            } else {
               > (ushort)MEM(output,dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(RGB_BUF_SIZE/8,8,8)[:][:][L];
            }
         } else {
            if(clip) {
               > (ushort)MEM(output|(dx2*dy2),dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(3,RGB_BUF_SIZE/24,8,8)[0][:][:][L];
               > (ushort)MEM(output1|(dx2*dy2),dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(3,RGB_BUF_SIZE/24,8,8)[1][:][:][L];
               > (ushort)MEM(output2|(dx2*dy2),dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(3,RGB_BUF_SIZE/24,8,8)[2][:][:][L];
            } else {
               > (ushort)MEM(output|(dx2*dy2),dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(3,RGB_BUF_SIZE/24,8,8)[0][:][:][L];
               > (ushort)MEM(output1|(dx2*dy2),dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(3,RGB_BUF_SIZE/24,8,8)[1][:][:][L];
               > (ushort)MEM(output2|(dx2*dy2),dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(0) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].yuyv2rgb::rgb(3,RGB_BUF_SIZE/24,8,8)[2][:][:][L];
            }
         }
      }
   }
}

// Process request from host to do YUYV to RGB color conversion

void do_yuyv2rgb(int queue) {
   RequestColor req;
   int resp;
   req.input=ztamMsgqReadPointer(queue);
   req.output=ztamMsgqReadPointer(queue);
   req.spu=ztamMsgqReadPointer(queue);
   req.w=ztamMsgqReadInt(queue);
   req.h=ztamMsgqReadInt(queue);
   req.dst_channel_fmt=ztamMsgqReadInt(queue);
   req.dst_channel_color=ztamMsgqReadInt(queue);
   req.src_w=ztamMsgqReadInt(queue);
   req.src_h=ztamMsgqReadInt(queue);
   req.x_off=ztamMsgqReadInt(queue);
   req.y_off=ztamMsgqReadInt(queue);
   req.dst_x=ztamMsgqReadInt(queue);
   req.dst_y=ztamMsgqReadInt(queue);
   req.dst_w=ztamMsgqReadInt(queue);
   req.dst_h=ztamMsgqReadInt(queue);
   resp=ztamMsgqReadInt(queue);
   ztamTaskSpawn(yuyv2rgb,&req,1);
   yuyv2rgb(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

// Kernel to do tensor reshape/resize

static void copy(void *_p,int pid) {
   RequestCopy *req=(RequestCopy *)_p;
   int f;
   int x,y;
   int x2,y2,x2_off,y2_off;
   int step_x,step_y,step2_x,step2_y;
   int dx,dy,dx2,dy2;
   int from,to,w,h;
   int src_pixel_size,dst_pixel_size;
   uint32_t input,output;
   int x_off,y_off;
   int src_w,src_h;
   int pcore_dx,pcore_dy;
   int equalize=(req->equalize==0)?-1:0;
   bool clip;
   int output2;
   int output3;

   src_pixel_size=(req->src_channel_fmt==kChannelFmtInterleave)?RGB_PIXEL_SIZE:1;
   dst_pixel_size=(req->dst_channel_fmt==kChannelFmtInterleave)?RGB_PIXEL_SIZE:1;
   input=req->input;
   output=req->output;

   if(pid==0 && req->equalize) {
      > SPU <= (int)MEM(req->equalize,SPU_LOOKUP_SIZE)[:];
   }

   if(req->src_w==req->w && req->src_h==req->h &&
      req->dst_w==req->w && req->dst_h==req->h) {
      // No clipping....
      clip=false;
      pcore_dx=NUM_PCORE;
      pcore_dy=1;
      w=req->w*req->h;
      h=1;
      src_w=w*src_pixel_size; // Must be even
      src_h=1;  // Must be even
      x_off=0;
      y_off=0;   
      step_x = src_pixel_size*NUM_THREAD_PER_CORE*pcore_dx*VECTOR_WIDTH*pcore_dy;
      step_y = 1;
      step2_x = NUM_THREAD_PER_CORE*pcore_dx*dst_pixel_size*VECTOR_WIDTH*pcore_dy;
      step2_y = 1;

      dx=(w/2)*src_pixel_size;
      dy=1;
      dx2=(w/2)*dst_pixel_size;
      dy2=1;
      y2_off=0;
      x2_off=0;
      if(pid==1) {
         dx=(w-w/2)*src_pixel_size;
         dx2=(w-w/2)*dst_pixel_size;
         input+=(w/2)*src_pixel_size;
         output+=(w/2)*dst_pixel_size;
      }
   } else {
      // With clipping...
      clip=true;
      pcore_dx=4;
      pcore_dy=NUM_PCORE/pcore_dx;
      w=req->w;
      h=req->h;
      src_w=req->src_w*src_pixel_size; // Must be even
      src_h=req->src_h;  // Must be even
      x_off=req->x_off;
      x_off=x_off*src_pixel_size;
      y_off=req->y_off;   
      step_x = src_pixel_size*NUM_THREAD_PER_CORE*pcore_dx;
      step_y = VECTOR_WIDTH*pcore_dy;
      step2_x = NUM_THREAD_PER_CORE*pcore_dx*dst_pixel_size;
      step2_y = VECTOR_WIDTH*pcore_dy;
	   dx=w*src_pixel_size;
      dy=h/2;
      dx2=req->dst_w*dst_pixel_size;
      dy2=req->dst_h;
      x2_off=req->dst_x*dst_pixel_size;
      y2_off=req->dst_y;
      if(pid==1) {
         dy=h-h/2;
         input+=src_w*(h/2);
         y2_off+=h/2;
      }
   }

   // Choose kernel functions
   int src_channel_fmt,dst_channel_fmt;
   int src_channel_color,dst_channel_color;
 
   src_channel_fmt=req->src_channel_fmt;
   dst_channel_fmt=req->dst_channel_fmt;
   src_channel_color=req->src_channel_color;
   dst_channel_color=req->dst_channel_color;

   if(src_channel_fmt==kChannelFmtSingle && dst_channel_fmt==kChannelFmtInterleave) {
      f=$copy::split_mono2interleave_mono;
   } else if(src_channel_fmt==kChannelFmtInterleave && dst_channel_fmt==kChannelFmtSplit) {
      if(src_channel_color!=kChannelColorMono && dst_channel_color==kChannelColorMono) {
         if(src_channel_color==kChannelColorRGB)
            f=$copy::interleaveRGB2split_mono;
         else
            f=$copy::interleaveBGR2split_mono;
      } else if(src_channel_color==dst_channel_color) {
         f=$copy::interleave2split;
      } else {
         f=$copy::interleave2split_reverse;
      }
   } else if(src_channel_fmt==kChannelFmtSplit && dst_channel_fmt==kChannelFmtInterleave) {
      if(src_channel_color!=kChannelColorMono && dst_channel_color==kChannelColorMono) {
         if(src_channel_color==kChannelColorRGB)
            f=$copy::splitRGB2interleave_mono;
         else
            f=$copy::splitBGR2interleave_mono;
      } else if(src_channel_color==dst_channel_color) {
         f=$copy::split2interleave;
      } else {
         f=$copy::split2interleave_reverse;
      }
   } else if(src_channel_fmt==kChannelFmtSplit && dst_channel_fmt==kChannelFmtSplit) {
      if(src_channel_color!=kChannelColorMono && dst_channel_color==kChannelColorMono) {
         if(src_channel_color==kChannelColorRGB)
            f=$copy::splitRGB2split_mono;
         else
            f=$copy::splitBGR2split_mono;
      } else if(src_channel_color==dst_channel_color) {
         f=$copy::split2split;
      } else {
         f=$copy::split2split_reverse;
      }
   } else if(src_channel_fmt==kChannelFmtSingle && dst_channel_fmt==kChannelFmtSingle) {
      f=$copy::mono2mono;
   } else if(src_channel_fmt==kChannelFmtInterleave && dst_channel_fmt==kChannelFmtSingle) {
      if(src_channel_color==kChannelColorRGB)
         f=$copy::interleaveRGB2mono;
      else
         f=$copy::interleaveBGR2mono;
   } else if(src_channel_fmt==kChannelFmtSplit && dst_channel_fmt==kChannelFmtSingle) {
      if(src_channel_color==kChannelColorRGB)
         f=$copy::splitRGB2mono;
      else
         f=$copy::splitBGR2mono;
   } else {
      if(src_channel_color!=kChannelColorMono && dst_channel_color==kChannelColorMono) {
         if(src_channel_color==kChannelColorRGB)
            f=$copy::interleaveRGB2interleave_mono;
         else
            f=$copy::interleaveBGR2interleave_mono;
      } else if(src_channel_color==dst_channel_color) {
         f=$copy::interleave2interleave;
      } else {
         f=$copy::interleave2interleave_reverse;
      }
   }

   if(src_channel_fmt==kChannelFmtInterleave) {
      > EXE_LOCKSTEP(copy::in_interleave_init,NUM_PCORE);
   } else {
      > EXE_LOCKSTEP(copy::in_split_init,NUM_PCORE);
   }
   if(dst_channel_fmt==kChannelFmtInterleave) {
      > EXE_LOCKSTEP(copy::out_interleave_init,NUM_PCORE);
   } else {
      > EXE_LOCKSTEP(copy::out_split_init,NUM_PCORE);
   }
   ztamYield();
   
   output2=output+w*h;
   output3=output+2*w*h;

   for(y=0,y2=y2_off;
       y < dy;
       y+=step_y,y2+=step2_y) {
      for(x=0,x2=x2_off;
         x < dx;
         x += step_x,x2+=step2_x) {
         if(src_channel_fmt==kChannelFmtInterleave) {
            if(clip) {
               > (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::in(RGB2RGB_BUF_SIZE/8,8,8)[:][:][K] <= (ushort)MEM(input,src_h,src_w)[y+y_off:y+y_off+step_y-1][x+x_off:x+x_off+step_x-1];
            } else {
               > (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::in(RGB2RGB_BUF_SIZE/8,8,8)[:][:][K] <= (ushort)MEM(input,src_h,src_w)[y+y_off][x+x_off:x+x_off+step_x-1];
            }
         } else {
            if(src_channel_fmt==kChannelFmtSingle) {
               if(clip) {
                  > (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::in(3,RGB2RGB_BUF_SIZE/24,8,8)[0][:][:][K] <= (ushort) MEM(input,src_h,src_w)[y+y_off:y+y_off+step_y-1][x+x_off:x+x_off+step_x-1];
               } else {
                  > (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::in(3,RGB2RGB_BUF_SIZE/24,8,8)[0][:][:][K] <= (ushort) MEM(input,src_h,src_w)[y+y_off][x+x_off:x+x_off+step_x-1];
               }
            } else {
               if(clip) {
                  > (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(LL=0:2) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::in(3,RGB2RGB_BUF_SIZE/24,8,8)[LL][:][:][K] <= (ushort) FOR(MM=y+y_off:y+y_off+step_y-1) FOR(KK=0:2) MEM(input,3,src_h,src_w)[KK][MM][x+x_off:x+x_off+step_x-1];
               } else {
                  > (ushort) SCATTER(0) FOR(LL=0:2) FOR(X=0:PCORE_DY-1) FOR(K=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::in(3,RGB2RGB_BUF_SIZE/24,8,8)[LL][:][:][K] <= (ushort) FOR(KK=0:2) MEM(input,3,src_h,src_w)[KK][y+y_off][x+x_off:x+x_off+step_x-1];
               }
            }
         }

         > EXE_LOCKSTEP(f,NUM_PCORE);

         ztamTaskYield();

         if(dst_channel_fmt==kChannelFmtInterleave) {
            if(clip) {
               > (ushort)MEM(output,dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(equalize) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(RGB2RGB_BUF_SIZE/8,8,8)[:][:][L];
            } else {
               > (ushort)MEM(output,dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(equalize) <= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(RGB2RGB_BUF_SIZE/8,8,8)[:][:][L];
            }
         } else {
            if(clip) {
               > (ushort)MEM(output,dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(equalize)<= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(3,RGB2RGB_BUF_SIZE/24,8,8)[0][:][:][L];
            } else {
               > (ushort)MEM(output,dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(equalize)<= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(3,RGB2RGB_BUF_SIZE/24,8,8)[0][:][:][L];
            }
            if(dst_channel_fmt!=kChannelFmtSingle) {
               if(clip) {
                  > (ushort)MEM(output2,dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(equalize)<= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(3,RGB2RGB_BUF_SIZE/24,8,8)[1][:][:][L];
                  > (ushort)MEM(output3,dy2,dx2)[y2:y2+step2_y-1][x2:x2+step2_x-1] <= PROC(equalize)<= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(3,RGB2RGB_BUF_SIZE/24,8,8)[2][:][:][L];
               } else {
                  > (ushort)MEM(output2,dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(equalize)<= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(3,RGB2RGB_BUF_SIZE/24,8,8)[1][:][:][L];
                  > (ushort)MEM(output3,dy2,dx2)[y2][x2:x2+step2_x-1] <= PROC(equalize)<= (ushort) SCATTER(0) FOR(X=0:PCORE_DY-1) FOR(L=0:VECTOR_WIDTH-1) FOR(JJ=0:PCORE_DX-1) PCORE(PCORE_DY,PCORE_DX)[X][JJ].copy::out(3,RGB2RGB_BUF_SIZE/24,8,8)[2][:][:][L];
               }
            }
         }
      }
   }
} 


// Process request from host to do tensor reshape/resize

void do_copy(int queue)
{
   RequestCopy req;
   int resp;
   req.input=ztamMsgqReadPointer(queue);
   req.output=ztamMsgqReadPointer(queue);
   req.w=ztamMsgqReadInt(queue);
   req.h=ztamMsgqReadInt(queue);
   req.src_channel_fmt=ztamMsgqReadInt(queue);
   req.src_channel_color=ztamMsgqReadInt(queue);
   req.dst_channel_fmt=ztamMsgqReadInt(queue);
   req.dst_channel_color=ztamMsgqReadInt(queue);
   req.src_w=ztamMsgqReadInt(queue);
   req.src_h=ztamMsgqReadInt(queue);
   req.x_off=ztamMsgqReadInt(queue);
   req.y_off=ztamMsgqReadInt(queue);
   req.dst_x=ztamMsgqReadInt(queue);
   req.dst_y=ztamMsgqReadInt(queue);
   req.dst_w=ztamMsgqReadInt(queue);
   req.dst_h=ztamMsgqReadInt(queue);
   req.equalize=ztamMsgqReadPointer(queue);
   resp=ztamMsgqReadInt(queue);
   ztamTaskSpawn(copy,&req,1);
   copy(&req,0);
   while(ztamTaskStatus(1))
      ztamTaskYield();
   if(resp >= 0)
      >CALLBACK(mycallback,resp);
}

> EXPORT(do_yuyv2rgb);
> EXPORT(do_copy);
