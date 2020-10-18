#include "..\..\..\base\ztam.h"
#include "histogram.h"

// Perform histogram equalization

typedef struct {
   uint32_t input;
   uint32_t output;
   uint32_t output2;
   int nchannels;
   uint32_t equalize;
   int w;
   int h;
   int src_w;
   int src_h;
   int x_off;
   int y_off;
   struct {
      int channel;
      int extra_zero[2];
   } ws;
} Request;

extern void mycallback(int);

static void histogram(Request *req,int pid) {
   int x,y;
   int step,step_x,step_y;
   int dx,dy;
   uint32_t input,output,output2,p;
   int x_off,y_off;
   int src_w,src_h;
   int i,j,count,extra_zero;
   int np,nt;
   bool clip;
   int len;

   input=req->input+req->src_w*req->src_h*req->ws.channel;
   output=req->output+req->ws.channel*(kHistogramBinSize*VECTOR_WIDTH)*2*2;
   output2=req->output2+req->w*req->h*req->ws.channel;
   np=NUM_PCORE;
   nt=NUM_THREAD_PER_CORE;
   step_x = kHistogramInSize*nt;
   step_y = np;
   dx=req->w;
   dy=req->h;
   src_w=req->src_w;
   src_h=req->src_h;
   x_off=req->x_off;
   y_off=req->y_off;

   if(x_off==0 && y_off==0 && src_w==dx && src_h==dy) {
      // No clipping...
      dx=dx*dy;
      dy=1;
      src_w=src_w*src_h;
      src_h=1;
      step_x=step_x*step_y;
      step_y=1;
      clip=false;
   } else {
      clip=true;
   }
   if(!clip) {
      // Split the job in the X direction
      if(pid==0) {
         dx=dx/2;
         src_w=src_w/2;
      } else {
         input=input+dx/2;
         output2=output2+dx/2;
         dx=dx-dx/2;
         src_w=src_w-src_w/2;
      }
   } else {
      // Split the job in the Y direction
      if(pid==0) {
         dy=dy/2;
         src_h=y_off+dy;
      } else {
         input=input+(y_off+dy/2)*src_w;
         src_h=src_h-(y_off+dy/2);
         dy=dy-dy/2;
         y_off=0;
      }
   }

   if(clip) {
      // If read access is clipped, access pattern may have extra reads inorder
      // to fit the read tiles...
      // Try to maximize utilization by reducing number of threads
      for(nt=NUM_MIN_THREAD_FOR_MAX_EFFICIENCY;nt <= NUM_THREAD_PER_CORE;nt++) {
         step=kHistogramInSize*nt;
         if(((dx+step-1)/step) <= ((dx+step_x-1)/step_x))
            break;  
      }
      step_x=step;
   }

   count=1000/kHistogramInSize;

   i=0;
   j=0;
;ZTAM_GREG(0,5,_task_curr2)=DP_EXE_CMD(1,0,((np)-1),(_task_curr2),0,0,((nt)-1),0);
   ztamTaskYield();

   for(y=0;y < dy;y+=step_y) {
      for(x=0;x < dx;x += step_x) {
         if(clip) {
{{int t00=(0),t01=(1),t02=((np)-1);ZTAM_GREG(16,8,0)=(4096)*t01;ZTAM_GREG(17,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(18,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(24,8,0)=t00*(4096);ZTAM_GREG(5,8,0)=((((step_x-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=127;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(1032+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*(((step_x-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);}{int t00=(y+y_off),t01=(1),t02=(y+y_off+step_y-1),t10=(x+x_off),t11=(1),t12=(x+x_off+step_x-1);ZTAM_GREG(16,8,0)=(1*(src_w))*t01;ZTAM_GREG(17,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(18,8,0)=((src_h)-t00)*(1*(src_w))-1;ZTAM_GREG(24,8,0)=t00*(1*(src_w));ZTAM_GREG(8,8,0)=((1)*t11);ZTAM_GREG(5,8,0)=((t12-t10+t11)/t11)-1;ZTAM_GREG(12,8,0)=((src_w)-1-t10);ZTAM_GREG(25,8,0)=t10*(1);int tbar=t00*(1*(src_w))+t10*(1)+0;ZTAM_GREG(4,8,0)=tbar+((input)>>(((DP_DATA_TYPE_UINT8)&1)));;ZTAM_GREG(19,8,0)=(1036317|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
         } else {
{{int t00=(0),t01=(1),t02=((np)-1);ZTAM_GREG(16,8,0)=(4096)*t01;ZTAM_GREG(17,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(18,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(24,8,0)=t00*(4096);ZTAM_GREG(5,8,0)=((((kHistogramInSize*nt-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=127;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(1032+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*(((kHistogramInSize*nt-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);}{int t00=(x),t01=(1),t02=(x+step_x-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((src_w)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((input)>>(((DP_DATA_TYPE_UINT8)&1)));;ZTAM_GREG(19,8,0)=(1036317|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
         }
;ZTAM_GREG(0,5,_task_curr2)=DP_EXE_CMD(1,102,((np)-1),(_task_curr2),0,0,((nt)-1),0);

         ztamTaskYield();

         i++;
         j+=(step_x*step_y);
         if(i >= count) {
;ZTAM_GREG(0,5,_task_curr2)=DP_EXE_CMD(1,30,((np)-1),(_task_curr2),0,0,((nt)-1),0);
            ztamTaskYield();
            i=0;
         }
;ZTAM_GREG(0,5,_task_curr2)=(2+(11<<3));
         if(req->equalize) {
{{int t00=(x),t01=(1),t02=(x+step_x-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((src_w)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((output2)>>(((DP_DATA_TYPE_UINT8)&1)));;ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*((0)+1));ZTAM_GREG(19,8,0)=(1036319|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=((np)-1);ZTAM_GREG(16,8,0)=(4096)*t01;ZTAM_GREG(17,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(18,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(24,8,0)=t00*(4096);ZTAM_GREG(5,8,0)=((((kHistogramInSize*nt-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=127;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(1032+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(19,8,0)=(1032221|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((0)>=0)?1:0,(0)&(3),(0));}
         } else {
{{int t00=(x),t01=(1),t02=(x+step_x-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((src_w)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((output2)>>(((DP_DATA_TYPE_UINT8)&1)));;ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*((0)+1));ZTAM_GREG(19,8,0)=(1036319|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=((np)-1);ZTAM_GREG(16,8,0)=(4096)*t01;ZTAM_GREG(17,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(18,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(24,8,0)=t00*(4096);ZTAM_GREG(5,8,0)=((((kHistogramInSize*nt-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=127;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(1032+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(19,8,0)=(1032221|(DP_DATA_TYPE_UINT8<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
         }
;ZTAM_GREG(0,5,_task_curr2)=(3+(11<<3));
      }
   }

;ZTAM_GREG(0,5,_task_curr2)=DP_EXE_CMD(1,30,((np)-1),(_task_curr2),0,0,((nt)-1),0);

   ztamTaskYield();

ZTAM_GREG(0,23,0)=(nt);

   // Summarize results among the threads...
;ZTAM_GREG(0,5,_task_curr2)=DP_EXE_CMD(1,58,((np)-1),(_task_curr2),1,0,((kHistogramBinSize)-1),0);
   ztamTaskYield();

   // Save results to SCRATCH...
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=(pid==0)?0:len*2*2;
{{int t00=(0),t01=(1),t02=(len-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((len)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*((0)+1));ZTAM_GREG(19,8,0)=(1034271|(DP_DATA_TYPE_INT16<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(np-1);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize-1)-(0)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(8+(0)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(19,8,0)=(1032221|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
   p += len*2;
{{int t00=(0),t01=(1),t02=(len-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((len)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*((0)+1));ZTAM_GREG(19,8,0)=(1034271|(DP_DATA_TYPE_INT16<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(np-1);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize-1)-(0)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(520+(0)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(19,8,0)=(1032221|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}

   req->ws.extra_zero[pid]=j-dx*dy;
}

// Aggregate the results from all the cores from both process 1 & 2

static void histogram_final(Request *req) {
   uint32_t p;
   int np,len,extra_zero;

   np=NUM_PCORE;
   len=np*kHistogramBinSize*VECTOR_WIDTH;
   p=0;
{{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize*np-1)-(0)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(8+(0)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*(((kHistogramBinSize*np-1)-(0)+(1))/(1))*((((8)-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_FLOAT8<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(len-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((len)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(19,8,0)=(1034269|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
   p += len*2;
{{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize*np-1)-(0)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(520+(0)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*(((kHistogramBinSize*np-1)-(0)+(1))/(1))*((((8)-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_FLOAT8<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(len-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((len)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(19,8,0)=(1034269|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
   p += len*2;
{{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize*2*np-1)-(kHistogramBinSize*np)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(8+(kHistogramBinSize*np)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*(((kHistogramBinSize*2*np-1)-(kHistogramBinSize*np)+(1))/(1))*((((8)-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_FLOAT8<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(len-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((len)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(19,8,0)=(1034269|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
   p += len*2;
{{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize*2*np-1)-(kHistogramBinSize*np)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(520+(kHistogramBinSize*np)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*(((kHistogramBinSize*2*np-1)-(kHistogramBinSize*np)+(1))/(1))*((((8)-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_FLOAT8<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(len-1);ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((len)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(19,8,0)=(1034269|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}

   if((2*np) > NUM_THREAD_PER_CORE)
      ztamAssert("Histogram FAIL");

ZTAM_GREG(0,23,0)=(2*np);
;ZTAM_GREG(0,5,_task_curr2)=DP_EXE_CMD(1,58,((1)-1),(_task_curr2),1,0,((kHistogramBinSize)-1),0);

   extra_zero=req->ws.extra_zero[0]+req->ws.extra_zero[1];

{{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(16,8,0)=(4096)*t01;ZTAM_GREG(17,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(18,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(24,8,0)=t00*(4096);ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(520+(kHistogramBinSize)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*((((8)-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_INT16<<5))|((0)<<8);}{;ZTAM_GREG(28,8,0)=(extra_zero/1000);ZTAM_GREG(19,8,0)=(1034269|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
{{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(16,8,0)=(4096)*t01;ZTAM_GREG(17,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(18,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(24,8,0)=t00*(4096);ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(8+(kHistogramBinSize)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*(((1*((((8)-1)-(0)+(1))/(1)))-1)+1));ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_INT16<<5))|((0)<<8);}{;ZTAM_GREG(28,8,0)=(extra_zero%1000);ZTAM_GREG(19,8,0)=(1034269|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}

;ZTAM_GREG(0,5,_task_curr2)=DP_EXE_CMD(1,88,((1)-1),(_task_curr2),0,0,((1)-1),0);

   p=req->output+req->ws.channel*(kHistogramBinSize*VECTOR_WIDTH)*2*2;
{{int t00=(0),t01=(1),t02=(((kHistogramBinSize*VECTOR_WIDTH)-1));ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((kHistogramBinSize*VECTOR_WIDTH)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*((0)+1));ZTAM_GREG(19,8,0)=(1036319|(DP_DATA_TYPE_INT16<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize-1)-(0)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(520+(0)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(19,8,0)=(1032221|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
   p+=kHistogramBinSize*VECTOR_WIDTH*2;
{{int t00=(0),t01=(1),t02=(((kHistogramBinSize*VECTOR_WIDTH)-1));ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((kHistogramBinSize*VECTOR_WIDTH)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((p)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(26,8,0)=(((t02-t00+t01)/t01)*((0)+1));ZTAM_GREG(19,8,0)=(1036319|(DP_DATA_TYPE_INT16<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(0);ZTAM_GREG(13,8,0)=(4096)*t01;ZTAM_GREG(14,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(15,8,0)=((np)-t00)*(4096)-1;ZTAM_GREG(23,8,0)=t00*(4096);ZTAM_GREG(17,8,0)=((((kHistogramBinSize-1)-(0)+(1))/(1))-1);ZTAM_GREG(16,8,0)=(8)*(1);ZTAM_GREG(18,8,0)=511;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(5,8,0)=(((((8)-1)-(0)+(1))/(1))-1);ZTAM_GREG(8,8,0)=(1)*(1);ZTAM_GREG(12,8,0)=511;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(4,8,0)=t00*(4096)+(8+(0)*(8)+(0))+((_task_curr2))*2097152+(1<<(11+REGISTER_DEPTH));ZTAM_GREG(19,8,0)=(1032221|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
}


void do_histogram() {
   Request req;
   int resp,i;
   req.input=ztamMsgReadPointer();
   req.output=ztamMsgReadPointer();
   req.output2=ztamMsgReadPointer();
   req.nchannels=ztamMsgReadInt();
   req.equalize=ztamMsgReadPointer();
   req.w=ztamMsgReadInt();
   req.h=ztamMsgReadInt();
   req.src_w=ztamMsgReadInt();
   req.src_h=ztamMsgReadInt();
   req.x_off=ztamMsgReadInt();
   req.y_off=ztamMsgReadInt();
   resp=ztamMsgReadInt();
   if(req.equalize) {
{{;ZTAM_GREG(8,8,0)=1;ZTAM_GREG(5,8,0)=1;ZTAM_GREG(12,8,0)=1;ZTAM_GREG(25,8,0)=0;ZTAM_GREG(16,8,0)=2;ZTAM_GREG(17,8,0)=127;ZTAM_GREG(18,8,0)=127;ZTAM_GREG(24,8,0)=0;ZTAM_GREG(4,8,0)=(2<<(11+REGISTER_DEPTH));ZTAM_GREG(26,8,0)=256;ZTAM_GREG(19,8,0)=(1032223|(DP_DATA_TYPE_INT16<<5))|((0)<<8);}{int t00=(0),t01=(1),t02=(((SPU_LOOKUP_SIZE)-1));ZTAM_GREG(8,8,0)=((1)*t01);ZTAM_GREG(5,8,0)=((t02-t00+t01)/t01)-1;ZTAM_GREG(12,8,0)=((SPU_LOOKUP_SIZE)-1-t00);ZTAM_GREG(25,8,0)=t00*(1);int tbar=t00*(1)+0;ZTAM_GREG(4,8,0)=tbar+((req.equalize)>>(((DP_DATA_TYPE_INT16)&1)));;ZTAM_GREG(19,8,0)=(1036317|(DP_DATA_TYPE_INT16<<5))|((0)<<8);};ZTAM_GREG(0,5,_task_curr2)=DP_TRANSFER_CMD(1,_task_curr2,0,0,0,0,0,0,((-1)>=0)?1:0,(-1)&(3),(0));}
   }
   for(i=0;i < req.nchannels;i++) {
      req.ws.channel=i;
      ztamTaskSpawn(histogram,&req,1);
      histogram(&req,0);
      while(ztamTaskStatus(1))
         ztamTaskYield();
      histogram_final(&req);
   }
   if(resp >= 0)
ZTAM_GREG(0,23,0)=((uint32_t)((CallbackFunc)(mycallback)));ZTAM_GREG(0,24,0)=(int)(resp);;ZTAM_GREG(0,5,_task_curr2)=(6+(11<<3));
}


