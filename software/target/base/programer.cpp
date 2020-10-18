#include <stdint.h>
#include <unistd.h>
#include <vector>
#include <string>
#include <string.h>
#include "zta.h"
#include "ztahost.h"
#include "programmer.h"

static ZTA_SHARED_MEM M_overlay=0;
static ZTA_SHARED_MEM M_pcore[kMcoreMaxOverlay];
static int M_pcoreLen[kMcoreMaxOverlay];
static ZTA_SHARED_MEM M_c[kMcoreMaxOverlay];
static int M_cLen[kMcoreMaxOverlay];
static std::vector<int> M_funcAddr;
static std::vector<std::string> M_funcName;

#define kMcoreOverlaySize     (MCORE_OVERLAY_ADDRESS)
#define kPcoreProgMaxSize     (INSTRUCTION_BYTE_WIDTH*(1<<INSTRUCTION_DEPTH))
#define kPcoreConstantMaxSize (1<<LOCAL_ADDR_DEPTH)

#define REGISTER (ztahostGetRegisterMemMap())

// Load codes to mcore/pcore

ZtaStatus Programmer::Program(const char *fname) {

   *ZTAH_GREG(REGISTER,0,REG_DDR_BAR)=0;

   if(loadSymbols(fname) != 0)
      return ZtaStatusFail;
   if(programPcore(fname) != 0)
      return ZtaStatusFail;
   if(programMcore(fname) != 0)
      return ZtaStatusFail;

   // Send command to mcore to start running   

   ztahostMsgqWriteInt(0,1+kMcoreMaxOverlay*4+1);
   ztahostMsgqWriteInt(0,0);
   for(int i=0;i < kMcoreMaxOverlay;i++) {
      ztahostMsgqWriteInt(0,M_cLen[i]);
      ztahostMsgqWritePointer(0,M_c[i]);
   }
   for(int i=0;i < kMcoreMaxOverlay;i++) {
      ztahostMsgqWriteInt(0,M_pcoreLen[i]);
      ztahostMsgqWritePointer(0,M_pcore[i]);
   }
   ztahostMsgqWritePointer(0,M_overlay);
   return ZtaStatusOk;
}

// Return function pointer to a exported kernel function
// from ztachip binary image

uint32_t Programmer::GetExportFunction(const char *funcName) {
   for(int i=0;i < (int)M_funcName.size();i++) {
      if(strcmp(funcName,M_funcName[i].c_str())==0) 
         return M_funcAddr[i];
   }
   return 0;
}

// Load export symbols from ztachip binary file
// These symbols are kernel functions that can be called
// from host CPU

ZtaStatus Programmer::loadSymbols(const char *fname) {
   char line[256];
   FILE *fp=fopen(fname,"r");
   if(!fp) {
      printf("Unable to open %s \n",fname);
      return ZtaStatusFail;
   }
   for(;;) {
      if(!fgets(line,sizeof(line)-1,fp))
         break;
      if(strstr(line,".MAP BEGIN"))
         break;
   }
   for(;;) {
      char *funcName;
      uint32_t addr;
      if(!fgets(line,sizeof(line)-1,fp))
         break;
      if(strstr(line,".MAP END"))
         break;
      funcName=strtok(line,"\r\n\t @");
      addr=strtol(strtok(0,"\r\n\t "),0,16);
      M_funcName.push_back(funcName);
      M_funcAddr.push_back(addr);
   }
   fclose(fp);
   return ZtaStatusOk;
}


// Load PCORE code to DDR memory.
// mcore will then load images to pcores using DDR's DMA when required.

ZtaStatus Programmer::programPcore(const char *fname) {
   FILE *fp;
   int index;
   char line[256];
   uint32_t *pcore;
   unsigned int v;
   unsigned int tag,addr,instruction,dummy1,dummy2;
   volatile unsigned short *cmem;

   fp=fopen(fname,"r");
   if(!fp) {
      printf("Unable to open ztachip.hex \n");
      return ZtaStatusFail;
   }
   for(index=0;index < kMcoreMaxOverlay;index++) {
      M_pcore[index]=ztahostAllocSharedMem(kPcoreProgMaxSize*sizeof(uint32_t));
      M_pcoreLen[index]=0;
      pcore=(uint32_t *)ZTA_SHARED_MEM_P(M_pcore[index]);
      M_c[index]=ztahostAllocSharedMem(kPcoreConstantMaxSize*sizeof(uint16_t));
      M_cLen[index]=0;
      cmem=(uint16_t *)ZTA_SHARED_MEM_P(M_c[index]);
      for(;;) {
         if(!fgets(line,sizeof(line)-1,fp))
            break;
         if(strstr(line,".CODE BEGIN"))
            break;
      }
      for(;;) {
         if(!fgets(line,sizeof(line)-1,fp))
            break;
         if(strstr(line,".CODE END")) {
            break;
         }
         if(sscanf(line,":%02x%04x%02x%08x%02x",&tag,&addr,&dummy1,&instruction,&dummy2) < 0)
            break;
         if(tag==0)
            continue;
         if(M_pcoreLen[index] >= kPcoreProgMaxSize) {
            printf("\r\nPCORE program is too big. Max size is %d words\r\n",kPcoreProgMaxSize);
            return ZtaStatusFail;
         }
         pcore[M_pcoreLen[index]++]=instruction;
      }
      for(;;) {
         if(!fgets(line,sizeof(line)-1,fp))
            break;
         if(strstr(line,".CONSTANT BEGIN"))
            break;
      }
      for(;;) {
         if(!fgets(line,sizeof(line)-1,fp))
            break;
         if(strstr(line,".CONSTANT END"))
            break;
         if(sscanf(line,"%08x",&v) < 0)
            break;
         cmem[M_cLen[index]++]=v;
      }
   }
   fclose(fp);
   return ZtaStatusOk;
}

// Load program and data to MCORE
// Do the software reset

ZtaStatus Programmer::programMcore(const char *filename) {
   int count;
   FILE *fp;
   int is_prog;
   uint32_t *overlay;
   int offset;
   char line[256];
   unsigned int tag,addr,dummy1,dummy2;
   unsigned instruction1;
   unsigned instruction2;
   unsigned instruction3;
   unsigned instruction4;
   unsigned base=0;
   fp=fopen(filename,"r");
   if(!fp) {
      printf("\r\n Cannot open file \r\n");
      return ZtaStatusFail;
   }
   while(fgets(line,sizeof(line)-1,fp)) {
      if(strstr(line,".MAIN BEGIN"))
         break;
   }

   is_prog=0;

   // Allocate memory for overlay memory
   if(!M_overlay)
      M_overlay=ztahostAllocSharedMem(kMcoreOverlaySize*sizeof(uint32_t));
   overlay=(uint32_t *)ZTA_SHARED_MEM_P(M_overlay);

   *ZTAH_GREG(REGISTER,0,REG_SOFT_RESET)=0;
   usleep(100);

   *ZTAH_PROG_MCODE(REGISTER,0)=0;
   *ZTAH_PROG_MCODE(REGISTER,1)=0;
   *ZTAH_PROG_MCODE(REGISTER,2)=0;
   *ZTAH_PROG_MCODE(REGISTER,3)=0;

   fgets(line,sizeof(line)-1,fp);
   while(line[0] != 0) {
      if (strncmp(line,":00",3)==0) {
         count=0;
         break;
      } else if(strncmp(line,":02",3)==0) {
         sscanf(line,":%02x%04x%02x%04x%02x",&tag,&addr,&dummy1,&base,&dummy2);
         count=0;
      } else if(strncmp(line,":04",3)==0) {
         sscanf(line,":%02x%04x%02x%08x%02x",&tag,&addr,&dummy1,&instruction1,&dummy2);
         count=1;
      } else if(strncmp(line,":08",3)==0) {
         sscanf(line,":%02x%04x%02x%08x%08x%02x",&tag,&addr,&dummy1,&instruction1,&instruction2,&dummy2);
         count=2;
      } else if(strncmp(line,":0C",3)==0) {
         sscanf(line,":%02x%04x%02x%08x%08x%08x%02x",&tag,&addr,&dummy1,&instruction1,&instruction2,&instruction3,&dummy2);
         count=3;
      } else {
         sscanf(line,":%02x%04x%02x%08x%08x%08x%08x%02x",&tag,&addr,&dummy1,&instruction1,&instruction2,&instruction3,&instruction4,&dummy2);
         count=4;
      }
      if(dummy1==0) {
         addr=addr + ((base&0xF)<<16);
         if(is_prog==1) {
            if(count==1) {
               if(addr < MCORE_OVERLAY_ADDRESS) {
                  *ZTAH_PROG_MCODE(REGISTER,addr/4)=instruction1;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+0) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return ZtaStatusFail;
                  } 
                  overlay[offset]=instruction1;
               }
            } else if(count==2) {
               if(addr < MCORE_OVERLAY_ADDRESS) {
                  *ZTAH_PROG_MCODE(REGISTER,addr/4)=instruction1;
                  *ZTAH_PROG_MCODE(REGISTER,addr/4+1)=instruction2;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+1) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return ZtaStatusFail;
                  } 
                  overlay[offset]=instruction1;
                  overlay[offset+1]=instruction2;
               }
            } else if(count==3) {
               if(addr < MCORE_OVERLAY_ADDRESS) {
                  *ZTAH_PROG_MCODE(REGISTER,addr/4)=instruction1;
                  *ZTAH_PROG_MCODE(REGISTER,addr/4+1)=instruction2;
                  *ZTAH_PROG_MCODE(REGISTER,addr/4+2)=instruction3;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+2) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return ZtaStatusFail;
                  } 
                  overlay[offset]=instruction1;
                  overlay[offset+1]=instruction2;
                  overlay[offset+2]=instruction3;
               }
            } else if(count==4) {
               if(addr < MCORE_OVERLAY_ADDRESS) {
                  *ZTAH_PROG_MCODE(REGISTER,addr/4)=instruction1;
                  *ZTAH_PROG_MCODE(REGISTER,addr/4+1)=instruction2;
                  *ZTAH_PROG_MCODE(REGISTER,addr/4+2)=instruction3;
                  *ZTAH_PROG_MCODE(REGISTER,addr/4+3)=instruction4;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+3) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return ZtaStatusFail;
                  } 
                  overlay[offset]=instruction1;
                  overlay[offset+1]=instruction2;
                  overlay[offset+2]=instruction3;
                  overlay[offset+3]=instruction4;
               }
            }
         } else {
            if(count==1) {
               *ZTAH_PROG_MDATA(REGISTER,addr/4)=instruction1;
            } else if(count==2) {
               *ZTAH_PROG_MDATA(REGISTER,addr/4)=instruction1;
               *ZTAH_PROG_MDATA(REGISTER,addr/4+1)=instruction2;
            } else if(count==3) {
               *ZTAH_PROG_MDATA(REGISTER,addr/4)=instruction1;
               *ZTAH_PROG_MDATA(REGISTER,addr/4+1)=instruction2;
               *ZTAH_PROG_MDATA(REGISTER,addr/4+2)=instruction3;
            } else if(count==4) {
               *ZTAH_PROG_MDATA(REGISTER,addr/4)=instruction1;
               *ZTAH_PROG_MDATA(REGISTER,addr/4+1)=instruction2;
               *ZTAH_PROG_MDATA(REGISTER,addr/4+2)=instruction3;
               *ZTAH_PROG_MDATA(REGISTER,addr/4+3)=instruction4;
            }
         }
      } else if(dummy1==4) {
         is_prog=1;
      }
      if(!fgets(line,sizeof(line)-1,fp) || strstr(line,".MAIN END"))
         break;
   }
   fclose(fp);
   usleep(100);
   *ZTAH_GREG(REGISTER,0,REG_SOFT_RESET)=1;
   usleep(1000);
   return ZtaStatusOk;
}
