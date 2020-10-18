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
#include "memmgr.h"
#include "programmer.h"
#include "ztahost.h"

static volatile void *M_bridgeMem=0;
static volatile uint32_t *M_ddrCtrlMem=0;
static volatile void *M_ztaMem=0;
static volatile uint32_t *M_dmaMem = 0;
static uint32_t M_dmaBaseAddr=0;
static uint32_t M_dmaBaseSize=0;
static int M_fd=-1;
static int TotalSharedMemAllocSize=0;

static void mysleep(int);
static ZtaStatus configureDDR(bool);

// Initialization at host node before using ztachip framework

ZtaStatus ztahostInit(const char *ztachipFile,uint32_t regBaseAddr,uint32_t dmaBaseAddr,uint32_t dmaBaseSize,bool hasVideo) {

  // enable bridges

  system ("echo 1 > /sys/class/fpga-bridge/fpga2hps/enable");
  system ("echo 1 > /sys/class/fpga-bridge/hps2fpga/enable");
  system ("echo 1 > /sys/class/fpga-bridge/lwhps2fpga/enable");

   // Map to FPGA HPS bridge region

   if( ( M_fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
      printf( "ERROR: could not open \"/dev/mem\"...\n" );
      return ZtaStatusFail;
   }
   M_bridgeMem = mmap(NULL,
      0x100000,
      PROT_READ|PROT_WRITE,
      MAP_SHARED,
      M_fd,
      0xff200000);
   if( M_bridgeMem == MAP_FAILED ) {
      printf( "ERROR: mmap() failed...\n" );
      return ZtaStatusFail;
   }
   M_ddrCtrlMem = (volatile uint32_t *)mmap(NULL,
      0x100000,
      PROT_READ|PROT_WRITE,
      MAP_SHARED,
      M_fd,
      0xffc25000);
   if( M_ddrCtrlMem == MAP_FAILED ) {
      printf( "ERROR: mmap() failed...\n" );
      return ZtaStatusFail;
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
      return ZtaStatusFail;
   }

   // Configure DDR memory controller

   configureDDR(hasVideo);
   
   // Initialize memory manager
   
   MemMgr::init((void *)M_dmaMem, M_dmaBaseSize);

   // Load programs to mcore/pcore and boot ztachip up...

   if(Programmer::Program(ztachipFile) != ZtaStatusOk) {
      printf("Error loading ztachip image \n");
      return ZtaStatusFail;
   }
   return ZtaStatusOk;
}

// Return function address of an exported symbol
// Return 0 if function cannot be found

uint32_t ztahostGetExportFunction(const char *funcName) {
   return Programmer::GetExportFunction(funcName);
}

// Return number of slots available in outbox message queue

int ztahostMsgqWriteAvail(int queue) {
   return *ZTAH_GREG(M_ztaMem,queue,REG_MSGQ_WRITE_AVAIL);
}

// Put an integer to the outbox

void ztahostMsgqWriteInt(int queue,int32_t v) {
   while(ztahostMsgqWriteAvail(queue)==0) {
      mysleep(100); // Not ideal. Need to implement interrupt scheme
printf("SLEEP \n");
   }
   *ZTAH_GREG(M_ztaMem,queue,REG_MSGQ_WRITE)=v;
}

// Put a float to the outbox

void ztahostMsgqWriteFloat(int queue,float v) {
   while(ztahostMsgqWriteAvail(queue)==0) {
      mysleep(100); // Not ideal. Need to implement interrupt scheme
printf("SLEEP \n");
   }
   *ZTAH_GREGF(M_ztaMem,queue,REG_MSGQ_WRITE)=v;
}

// Put a pointer to the outbox
// Convert to offset within DDR window

void ztahostMsgqWritePointer(int queue,ZTA_SHARED_MEM p,uint32_t offset) {
   uint32_t v;
   if(p==0) {
      v=0;
      offset=0;
   }
   else
      v=ZTA_SHARED_MEM_PHYSICAL(p);
   while(ztahostMsgqWriteAvail(queue)==0) {
      mysleep(100); // Not ideal. Need to implement interrupt scheme
printf("SLEEP \n");
   }
   *ZTAH_GREG(M_ztaMem,queue,REG_MSGQ_WRITE)=v+offset;
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
   pVirtual = (uint32_t)MemMgr::allocate(size);
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
   MemMgr::free((void *)h->vmem);
}

// Return address to access SOC BRIDGE

volatile void *ztahostGetBridgeMem() {
   return (volatile void *)M_bridgeMem;
}

// Return address to ztachip register memory map address

volatile void *ztahostGetRegisterMemMap() {
   return (volatile void *)M_ztaMem;
}

// Build stream processor lookup table
// Stream processor implements a lookup table which maps an input value to an output value.
// User provide func callback to specify the mapping between input and output

ZTA_SHARED_MEM ztahostBuildSpu(float (*func)(float,void *pparm,uint32_t parm),void *pparm,uint32_t parm,ZTA_SHARED_MEM _shm) {
   uint16_t v;
   float v2;
   int16_t v3,v4,slope;
   int16_t *p;
   ZTA_SHARED_MEM shm;

   if(_shm==0) {
      shm = ztahostAllocSharedMem(SPU_SIZE*2*sizeof(int16_t));
   } else {
      assert(ZTA_SHARED_MEM_LEN(_shm) >= (SPU_SIZE*2*sizeof(int16_t)));
      shm = _shm;
   }
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
static ZtaStatus configureDDR(bool _hasVideo) {
   /* Port Priorities.  Valid Values are 0 - 7 */
   static int port_prio[10] = { 6,6, 7, 6, 0, 0, 0, 0, 0, 0 };
   /* Port Weights.  Valid values are 0 - 31 */
   static int port_weight[10] = { 31, 31, 31, 31, 0, 0, 0, 0, 0, 0 };
   /* Sum-of-Weights for each Priority Level 0-7.  Valid values are 0-31 */
   static int sow[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };

   int i;
   int weight_reg_val0 = 0;
   int weight_reg_val1 = 0;
   int weight_reg_val2 = 0;
   int weight_reg_val3 = 0;
   int prio_reg_val = 0;

   if(_hasVideo) {
      port_prio[0]=6;
      port_prio[1]=6;
      port_prio[2]=7;
      port_weight[0]=31;
      port_weight[1]=31;
      port_weight[2]=31;
   } else {
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
   return ZtaStatusOk;
}

// Go to sleep for a while...
// Check serial port output

static void mysleep(int timeout) {
   ztaSerial();
}
