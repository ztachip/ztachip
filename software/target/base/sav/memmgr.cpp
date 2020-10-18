#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <malloc.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <assert.h>
#include <signal.h>
#include <vector>
#include <string>
#include "util.h"
#include "ztahost.h"

static void mem_init(void *p, int len);
static void *mem_alloc(int len);
static void mem_free(void *p);
static void mysleep(int);
static int configureDDR(bool);

// Variables...

static volatile void *M_bridgeMem=0;
static volatile uint32_t *M_ddrCtrlMem=0;
static volatile void *M_ztaMem=0;

static volatile uint32_t *M_dmaMem = 0;
static uint32_t M_dmaBaseAddr=0;
static uint32_t M_dmaBaseSize=0;

static int M_fd=-1;
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

static int TotalSharedMemAllocSize=0;

// Go to sleep for a while...
// Check serial port output

static void mysleep(int timeout) {
   ztaSerial();
}

// Load export symbols from ztachip binary file
// These symbols are kernel functions that can be called
// from host CPU

static int loadSymbols(char *fname) {
   char line[256];
   FILE *fp=fopen(fname,"r");
   if(!fp) {
      printf("Unable to open %s \n",fname);
      return -1;
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
   return 0;
}


// Load program to PCORE array

static int programPcore(char *fname) {
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
      return -1;
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
            return -1;
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
   return 0;
}

// Load program and data to MCORE
// Do the software reset

static int programMcore(const char *filename) {
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
      return -1;
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

   *ZTAH_GREG(M_ztaMem,0,REG_SOFT_RESET)=0;
   usleep(100);

   *ZTAH_PROG_MCODE(M_ztaMem,0)=0;
   *ZTAH_PROG_MCODE(M_ztaMem,1)=0;
   *ZTAH_PROG_MCODE(M_ztaMem,2)=0;
   *ZTAH_PROG_MCODE(M_ztaMem,3)=0;

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
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4)=instruction1;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+0) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return -1;
                  } 
                  overlay[offset]=instruction1;
               }
            } else if(count==2) {
               if(addr < MCORE_OVERLAY_ADDRESS) {
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4)=instruction1;
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4+1)=instruction2;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+1) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return -1;
                  } 
                  overlay[offset]=instruction1;
                  overlay[offset+1]=instruction2;
               }
            } else if(count==3) {
               if(addr < MCORE_OVERLAY_ADDRESS) {
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4)=instruction1;
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4+1)=instruction2;
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4+2)=instruction3;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+2) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return -1;
                  } 
                  overlay[offset]=instruction1;
                  overlay[offset+1]=instruction2;
                  overlay[offset+2]=instruction3;
               }
            } else if(count==4) {
               if(addr < MCORE_OVERLAY_ADDRESS) {
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4)=instruction1;
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4+1)=instruction2;
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4+2)=instruction3;
                  *ZTAH_PROG_MCODE(M_ztaMem,addr/4+3)=instruction4;
               } else {
                  offset=(addr-MCORE_OVERLAY_ADDRESS)/4;
                  if((offset+3) >= kMcoreOverlaySize) {
                     printf("MCORE overlay size too large \r\n");
                     return -1;
                  } 
                  overlay[offset]=instruction1;
                  overlay[offset+1]=instruction2;
                  overlay[offset+2]=instruction3;
                  overlay[offset+3]=instruction4;
               }
            }
         } else {
            if(count==1) {
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4)=instruction1;
            } else if(count==2) {
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4)=instruction1;
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4+1)=instruction2;
            } else if(count==3) {
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4)=instruction1;
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4+1)=instruction2;
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4+2)=instruction3;
            } else if(count==4) {
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4)=instruction1;
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4+1)=instruction2;
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4+2)=instruction3;
               *ZTAH_PROG_MDATA(M_ztaMem,addr/4+3)=instruction4;
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
   *ZTAH_GREG(M_ztaMem,0,REG_SOFT_RESET)=1;
   usleep(1000);
   return 0;
}

int ztahostInit(const char *pcoreFile,const char *mcoreFile,const char *constFile,uint32_t regBaseAddr,uint32_t dmaBaseAddr,uint32_t dmaBaseSize,bool hasVideo) {
   int i;

  // enable bridges

  system ("echo 1 > /sys/class/fpga-bridge/fpga2hps/enable");
  system ("echo 1 > /sys/class/fpga-bridge/hps2fpga/enable");
  system ("echo 1 > /sys/class/fpga-bridge/lwhps2fpga/enable");

   // Map to FPGA HPS bridge region

   if( ( M_fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
      printf( "ERROR: could not open \"/dev/mem\"...\n" );
      return -1;
   }
   M_bridgeMem = mmap(NULL,
      0x100000,
      PROT_READ|PROT_WRITE,
      MAP_SHARED,
      M_fd,
      0xff200000);
   if( M_bridgeMem == MAP_FAILED ) {
      printf( "ERROR: mmap() failed...\n" );
      return -1;
   }
   M_ddrCtrlMem = (volatile uint32_t *)mmap(NULL,
      0x100000,
      PROT_READ|PROT_WRITE,
      MAP_SHARED,
      M_fd,
      0xffc25000);
   if( M_ddrCtrlMem == MAP_FAILED ) {
      printf( "ERROR: mmap() failed...\n" );
      return -1;
   }

   M_ztaMem=(void *)(regBaseAddr+(uint32_t)M_bridgeMem);

   // Map to global memory pool

   M_dmaBaseAddr = dmaBaseAddr;
   M_dmaBaseSize = dmaBaseSize;
   M_dmaMem = (volatile uint32_t *)mmap(NULL,
      M_dmaBaseSize,
      PROT_READ | PROT_WRITE,
      MAP_SHARED,
      M_fd,
      M_dmaBaseAddr);
   if (M_dmaMem == MAP_FAILED) {
      printf("ERROR: mmap() failed...\n");
      return -1;
   }
   
   // Initialize memory manager
   
   mem_init((void *)M_dmaMem, M_dmaBaseSize);

   configureDDR(hasVideo);

   *ZTAH_GREG(M_ztaMem,0,REG_DDR_BAR)=0;

   loadSymbols("ztachip.hex");
   programPcore("ztachip.hex");
   programMcore("ztachip.hex");

   // Send constant transfer command

   ztahostMsgWriteInt(1+kMcoreMaxOverlay*4+1);
   ztahostMsgWriteInt(0);
   for(i=0;i < kMcoreMaxOverlay;i++) {
      ztahostMsgWriteInt(M_cLen[i]);
      ztahostMsgWritePointer(M_c[i]);
   }
   for(i=0;i < kMcoreMaxOverlay;i++) {
      ztahostMsgWriteInt(M_pcoreLen[i]);
      ztahostMsgWritePointer(M_pcore[i]);
   }
   ztahostMsgWritePointer(M_overlay);
   return 0;
}

// Return function address of an exported symbol
// Return 0 if function cannot be found

uint32_t ztahostGetExportFunction(char *funcName) {
   for(int i=0;i < M_funcName.size();i++) {
      if(strcmp(funcName,M_funcName[i].c_str())==0) 
         return M_funcAddr[i];
   }
   return 0;
}

// Return number of slots available in outbox message queue

int ztahostMsgWriteAvail() {
   return *ZTAH_GREG(M_ztaMem,0,REG_MSGQ_WRITE_AVAIL);
}

// Put an integer to the outbox

void ztahostMsgWriteInt(int32_t v) {
   while(ztahostMsgWriteAvail()==0)
      mysleep(100); // Not ideal. Need to implement interrupt scheme
   *ZTAH_GREG(M_ztaMem,0,REG_MSGQ_WRITE)=v;
}

// Put a float to the outbox

void ztahostMsgWriteFloat(float v) {
   while(ztahostMsgWriteAvail()==0)
      mysleep(100); // Not ideal. Need to implement interrupt scheme
   *ZTAH_GREGF(M_ztaMem,0,REG_MSGQ_WRITE)=v;
}

// Put a pointer to the outbox
// Convert to offset within DDR window

void ztahostMsgWritePointer(ZTA_SHARED_MEM p,uint32_t offset) {
   uint32_t v;
   if(p==0) {
      v=0;
      offset=0;
   }
   else
      v=ZTA_SHARED_MEM_PHYSICAL(p);
   while(ztahostMsgWriteAvail()==0)
      mysleep(100); // Not ideal. Need to implement interrupt scheme
   *ZTAH_GREG(M_ztaMem,0,REG_MSGQ_WRITE)=v+offset;
}

// Return number of messages available in the inbox

int ztahostMsgReadAvail() {
   return *ZTAH_GREG(M_ztaMem,0,REG_MSGQ_READ_AVAIL);
}

// Get an integer from the inbox

int32_t ztahostMsgReadInt() {
   while(ztahostMsgReadAvail()==0)
      mysleep(100); // Not ideal. Need to implement interrupt scheme
   return *ZTAH_GREG(M_ztaMem,0,REG_MSGQ_READ);
}

// Get a float from the inbox

float ztahostMsgReadFloat() {
   while(ztahostMsgReadAvail()==0)
      mysleep(100); // Not ideal. Need to implement interrupt scheme
   return *ZTAH_GREGF(M_ztaMem,0,REG_MSGQ_READ);
}

// Return current size of allocated shared memory
int ztahostGetTotalAllocSharedMem() {
   return TotalSharedMemAllocSize;
}

// Allocate shared memory from non-cached data region

ZTA_SHARED_MEM ztahostAllocSharedMem(int _size) {
   void *p;
   ZTA_MEM_HEADER *h;
   uint32_t pVirtual;
   uint32_t pPhysical;
   int size;

   TotalSharedMemAllocSize+=_size;  

   size = _size+sizeof(ZTA_MEM_HEADER)+VECTOR_WIDTH;
   size = (size+VECTOR_WIDTH-1) & (~(VECTOR_WIDTH-1));

   // Allocated shared memory from non-cached region....
   pVirtual = (uint32_t)mem_alloc(size);
   if(!pVirtual) 
   {
      printf( "ERROR: mmap() failed...\n" );
      assert(0);
      return 0;
   }
   pPhysical = M_dmaBaseAddr + ((uint32_t)pVirtual-(uint32_t)M_dmaMem);
   h=(ZTA_MEM_HEADER *)(((uint32_t)pVirtual+VECTOR_WIDTH-1) & (~(VECTOR_WIDTH-1)));
   h->vmem=(uint32_t)pVirtual;
   h->pmem=(uint32_t)pPhysical;
   h->size=_size;
   p=(void *)((uint8_t *)h+sizeof(ZTA_MEM_HEADER));
   assert(((uint32_t)p&(VECTOR_WIDTH-1))==0);
   h->pmem += ((uint32_t)p-(uint32_t)pVirtual);
   memset((uint8_t *)ZTA_SHARED_MEM_P(((ZTA_SHARED_MEM)p)),0,_size);
   return (ZTA_SHARED_MEM)p;
}

// Free a previously allocated shared memory

void ztahostFreeSharedMem(ZTA_SHARED_MEM p) {
   ZTA_MEM_HEADER *h;
   TotalSharedMemAllocSize-=ZTA_SHARED_MEM_LEN(p);  
   h = (ZTA_MEM_HEADER *)((uint32_t)p-sizeof(ZTA_MEM_HEADER));
   assert((((uint32_t)h->vmem+VECTOR_WIDTH-1) & (~(VECTOR_WIDTH-1)))==(uint32_t)h); // Integrity check
   mem_free((void *)h->vmem);
}

// Return address to access SOC BRIDGE

void *ztahostGetBridgeMem() {
   return (void *)M_bridgeMem;
}

// Build stream processor lookup table
// Stream processor implements a lookup table which maps an input value to an output value.
// User provide func callback to specify the mapping between input and output

ZTA_SHARED_MEM ztahostBuildSpu(float (*func)(float,void *pparm,uint32_t parm),void *pparm,uint32_t parm) {
   uint16_t v;
   float v2;
   int16_t v3,v4,slope;
   int16_t *p;
   ZTA_SHARED_MEM shm;
   shm = ztahostAllocSharedMem(SPU_SIZE*2*sizeof(int16_t));
   p=(int16_t *)ZTA_SHARED_MEM_P(shm);
   for(int i=0;i < SPU_SIZE;i++) {
      v=((i*SPU_REMAINDER)&0xFFF);
      if(v & 0x800)
         v |= 0xF800;
      Util::Int2Float((int16_t *)&v,&v2,DATA_BIT_WIDTH-1,1);
      v2=(*func)(v2,(i==0)?pparm:0,parm);
      Util::Float2Int(&v2,&v3,DATA_BIT_WIDTH-1,1);
      v=((i*SPU_REMAINDER+(SPU_REMAINDER-1))&0xFFF);
      if(v & 0x800)
         v |= 0xF800;
      Util::Int2Float((int16_t *)&v,&v2,DATA_BIT_WIDTH-1,1);
      v2=(*func)(v2,0,parm);
      Util::Float2Int(&v2,&v4,DATA_BIT_WIDTH-1,1);
      slope=(int16_t)(((((int)v4-(int)v3)))*SPU_REMAINDER)/(SPU_REMAINDER-1);
      p[2*i]=slope;
      p[2*i+1]=v3;
   }
   return shm;
}

// Check if any data available at serial port from ztachip
// Then display serial output on host console

void ztaSerial() {
   int i;
   int ivar;
   double fvar;
   unsigned char *p2;
   unsigned char ch;
   unsigned char p[8];
   while(*ZTAH_GREG(M_ztaMem,0,REG_SERIAL_READ_AVAIL) > 0) {
      ch=(char)(*ZTAH_GREG(M_ztaMem,0,REG_SERIAL_READ));
      if(ch==1) {
         while(*ZTAH_GREG(M_ztaMem,0,REG_SERIAL_READ_AVAIL) < 4);
            for(i=0,p2=(unsigned char *)&ivar+3;i < 4;i++,p2--)
               *p2=(char)(*ZTAH_GREG(M_ztaMem,0,REG_SERIAL_READ));
            printf("%d",ivar);
      } else if(ch==2) {
         while(*ZTAH_GREG(M_ztaMem,0,REG_SERIAL_READ_AVAIL) < 8);
         p2=(unsigned char *)&fvar;
         for(i=0;i < 8;i++)
            p[i]=(unsigned char)(*ZTAH_GREG(M_ztaMem,0,REG_SERIAL_READ));
         p2[7]=p[4];
         p2[6]=p[5];
         p2[5]=p[6];
         p2[4]=p[7];
         p2[3]=p[0];
         p2[2]=p[1];
         p2[1]=p[2];
         p2[0]=p[3];
         printf("%lf",fvar);
      } else {
         printf("%c",ch);
      }
   }
}

// Configure F2H DDR memory port. Set priority and weights for each port
static int configureDDR(bool _hasVideo) {
   static char *port_name[10] = {
      "FPGA AXI S0 R, Avalon-MM S0 R/W",
      "FPGA AXI S0 W, Avalon-MM S1 R/W",
      "FPGA AXI S1 R, Avalon-MM S2 R/W",
      "FPGA AXI S1 W, Avalon-MM S3 R/W",
      "FPGA AXI S2 R, Avalon-MM S4 R/W",
      "FPGA AXI S2 W, Avalon-MM S5 R/W",
      "L3  AXI 32-bit S0 R",
      "MPU AXI 64-bit S0 R",
      "L3  AXI 32-bit S1 W",
      "MPU AXI 64-bit S1 W"
   };
   /* Port Priorities.  Valid Values are 0 - 7 */
   static int port_prio[10] = { 6,6, 7, 6, 0, 0, 0, 0, 0, 0 };
   /* Port Weights.  Valid values are 0 - 31 */
   static int port_weight[10] = { 31, 31, 31, 31, 0, 0, 0, 0, 0, 0 };
   /* Sum-of-Weights for each Priority Level 0-7.  Valid values are 0-31 */
   static int sow[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
   /* Port Data Widths */
   static int port_width[10] = { 64, 64, 128, 64, 64, 64, 64, 64, 64, 64 };

   int i;
   int weight_reg_val0 = 0;
   int weight_reg_val1 = 0;
   int weight_reg_val2 = 0;
   int weight_reg_val3 = 0;
   int prio_reg_val = 0;

   printf("\r\n Configure DDR memory controller!!!! \r\n");

   if(_hasVideo) {
      printf("Configure DDR for video\n");
      port_prio[0]=6;
      port_prio[1]=6;
      port_prio[2]=7;
      port_weight[0]=31;
      port_weight[1]=31;
      port_weight[2]=31;
   } else {
      printf("Configure DDR for no-video\n");
      port_prio[0]=7;
      port_prio[1]=7;
      port_prio[2]=1;
      port_weight[0]=31;
      port_weight[1]=31;
      port_weight[2]=1;
   }

   *(M_ddrCtrlMem+(0x23))=0;

   for (i = 0; i < 10; i++) {
      /* Set Priorities */
      prio_reg_val |= (port_prio[i] & 7) << (i * 3);
   }

   *(M_ddrCtrlMem + (0xAC >> 2)) = prio_reg_val;

   // Set weights

   for (i = 0; i < 10; i++) {
      /* Set Weights */
      if (i <= 5) {
         weight_reg_val0 |= (port_weight[i] & 0x1f) << (i * 5);
      } else if (i == 6) {
         weight_reg_val0 |= (port_weight[i] & 0x03) << (i * 5);
         weight_reg_val1 |= (port_weight[i] >> 2) & 0x7;
      } else {
         weight_reg_val1 |= (port_weight[i] & 0x1f) << (3 + (i - 7) * 5);
      }
      // Sum Weights
      sow[port_prio[i]] += port_weight[i];
   }

   /* Set Sums of Weights */
   for (i = 0; i < 8; i++) {
      if (i == 0) {
         weight_reg_val1 |= (sow[i] & 0xff) << 18;
      } else if (i == 1) {
         weight_reg_val1 |= (sow[i] & 0x3f) << 26;
         weight_reg_val2 |= (sow[i] >> 6) & 0x3;
      } else if (i <= 4) {
         weight_reg_val2 |= (sow[i] & 0xff) << (2 + (i - 2) * 8);
      } else if (i == 5) {
         weight_reg_val2 |= (sow[i] & 0x3f) << 26;
         weight_reg_val3 |= (sow[i] >> 6) & 0x3;
      } else {
         weight_reg_val3 |= (sow[i] & 0xff) << (2 + (i - 6) * 8);
      }
      if (sow[i] > 128)
         printf("WARNING: Sum of weights for Priority %d is %d, which is more than 128!\n\n", i, sow[i]);
   }
   *(M_ddrCtrlMem + (0xB0 >> 2)) = weight_reg_val0;
   *(M_ddrCtrlMem + (0xB4 >> 2)) = weight_reg_val1;
   *(M_ddrCtrlMem + (0xB8 >> 2)) = weight_reg_val2;
   *(M_ddrCtrlMem + (0xBC >> 2)) = weight_reg_val3;
   return 0;
}

// --------------------------------------------
// Memory manager....
// --------------------------------------------

typedef struct {
   uint32_t len;
   uint32_t flags;
} mem_header_t;

static mem_header_t *M_top = 0;
static mem_header_t *M_bot = 0;

inline mem_header_t *mem_trailer(mem_header_t *h) {
   return ((mem_header_t *)((uint32_t)(h)+(h)->len - sizeof(mem_header_t)));
}

inline void *mem_body(mem_header_t *h) {
   return (void *)((uint32_t)h + sizeof(mem_header_t));
}

inline mem_header_t *mem_next(mem_header_t *h) {
   mem_header_t *h2;
   h2 = ((mem_header_t *)((uint32_t)(h)+(h)->len));
   if ((uint32_t)h2 >= (uint32_t)M_bot)
      return 0;
   else
      return h2;
}

inline mem_header_t *mem_prev(mem_header_t *h) {
   if ((uint32_t)(h) <= (uint32_t)M_top)
      return 0;
   else
      return (mem_header_t *)((uint32_t)(h)-((mem_header_t *)((uint32_t)(h)-sizeof(mem_header_t)))->len);
}

static void mem_init(void *p, int len) {
   mem_header_t *h;
   len = (len / 8) * 8;
   M_top = (mem_header_t *)p;
   M_bot = (mem_header_t *)((uint32_t)p + len);
   h = (mem_header_t *)M_top;
   h->len = len;
   h->flags = 0;
   h = mem_trailer(h);
   h->len = len;
   h->flags = 0;
}

// Allocate a memory block from global pool

static void *mem_alloc(int len) {
   mem_header_t *h, *h2;
   int remain;
   len = ((len + 7) / 8) * 8;
   len += 2 * sizeof(mem_header_t);
   h = (mem_header_t *)M_top;
   while (h) {
      if (h->flags == 0 && h->len >= len) {
         // Split this block
         remain = h->len - len;
         if (remain >= (2 * sizeof(mem_header_t) + 8)) {
            h->len = len;
            h->flags = 1;
            h2 = mem_trailer(h);
            h2->len = len;
            h2->flags = 1;

            h2 = (mem_header_t *)((uint32_t)h2 + sizeof(mem_header_t));
            h2->len = remain;
            h2->flags = 0;
            h2 = mem_trailer(h2);
            h2->len = remain;
            h2->flags = 0;
         } else {
            h->flags = 1;
            h2 = mem_trailer(h);
            h2->flags = 1;
         }
         return mem_body(h);
      }
      else
         h = mem_next(h);
   }
   return 0;
}

// Release a memory block back to global pool

static void mem_free(void *p)
{
   mem_header_t *h, *h2, *above, *below;
   h = (mem_header_t *)((uint32_t)p - sizeof(mem_header_t));
   above = mem_prev(h);
   below = mem_next(h);
   // Check if we can merge with block above
   if (above && above->flags == 0) {
      above->len += h->len;
      above->flags = 0;
      h2 = mem_trailer(above);
      h2->len = above->len;
      h2->flags = 0;
      h = above;
   }
   // Check if we can merge with block below
   if (below && below->flags == 0) {
      h->len += below->len;
      h->flags = 0;
      h2 = mem_trailer(h);
      h2->len = h->len;
      h2->flags = 0;
   }
   h->flags = 0;
}
