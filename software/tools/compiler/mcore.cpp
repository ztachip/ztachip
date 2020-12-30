//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]c
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except IN compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to IN writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string>
#include <vector>
#include <assert.h>
#include "zta.h"
#include "ast.h"
#include "ident.h"
#include "instruction.h"
#include "mcore.h"


// Tokens used by mcore intepreter...
#define TOKEN_NOP             "NOP"
#define TOKEN_PCORE           "PCORE"
#define TOKEN_PCORES          "PCORES"
#define TOKEN_SRAM            "SCRATCH"
#define TOKEN_SRAMH           "HSCRATCH"
#define TOKEN_SRAMS           "SCRATCHS"
#define TOKEN_DDR             "MEM"
#define TOKEN_DDRS            "MEMS"
#define TOKEN_EXE             "EXE"
#define TOKEN_LOCKSTEP_EXE    "EXE_LOCKSTEP"
#define TOKEN_PRINT           "PRINT"
#define TOKEN_NOTIFY          "CALLBACK"
#define TOKEN_NOTIFY_PRIO     "CALLBACK_PRIO"
#define TOKEN_LOG_ON          "LOG_ON"
#define TOKEN_LOG_OFF         "LOG_OFF"
#define TOKEN_FLUSH           "FLUSH"
#define TOKEN_ALL_INT         "INT"
#define TOKEN_ALL_HALF        "HALF"
#define TOKEN_ALL_SHORT       "SHORT"
#define TOKEN_FOR             "FOR"
#define TOKEN_REPEAT          "REPEAT"
#define TOKEN_PAD             "PAD"
#define TOKEN_SYNC            "SYNC"
#define TOKEN_THREAD          "THREAD"
#define TOKEN_SCATTER         "SCATTER"
#define TOKEN_STREAM          "PROC"
#define TOKEN_SPU             "SPU"
#define TOKEN_PCORE_PROG      "PROG"
#define TOKEN_EXPORT          "EXPORT"

// Datatypes
#define TOKEN_DATATYPE_INT    "INT"
#define TOKEN_DATATYPE_FLOAT  "FLOAT"

// PCORE layout
#define TOKEN_PCORE_LAYOUT_N    "N"
#define TOKEN_PCORE_LAYOUT_Nx2  "Nx2"
#define TOKEN_PCORE_LAYOUT_Nx4  "Nx4"
#define TOKEN_PCORE_LAYOUT_Nx8  "Nx8"
#define TOKEN_PCORE_LAYOUT_Nx16 "Nx16"

// Position for the specifier
#define SPECIFIER_PCORE_DIM      0
#define SPECIFIER_SRAM_ADDRESS   0
#define SPECIFIER_SRAM_DIM       1
#define SPECIFIER_DDR_ADDRESS    0
#define SPECIFIER_DDR_DIM        1
#define SPECIFIER_ALL_VAL        0

// Maximum of a line process by intepreter
#define MAX_LINE  8000

#define VM_STR "(_task_curr2)"

// Types of commands
#define CMD_EXE         0
#define CMD_NOTIFY      1
#define CMD_SYNC_NOTIFY 2
#define CMD_ASSIGN      3  
#define CMD_TRANSFER    4
#define CMD_NOP         5
#define CMD_LOG_ON      6
#define CMD_LOG_OFF     7
#define CMD_PRINT       8
#define CMD_EXPORT      9
#define CMD_INCLUDE     10

#define MAX_DP_STRIDE   6

// MCORE variables

#define VAR_SOURCE  0
#define VAR_DEST    1

// Bit position for DP_MODE register
#define DP_MODE_LOAD 0
#define DP_MODE_TEMPLATEID (DP_MODE_LOAD+1)
// **** NOTE ****** DP_MODE_DATATYPE+DP_MODE_DOUBLEPRECISION <= m_dataType (least significant bit of m_dataType is double precision
// So DP_MODE_DATATYPE and DP_MODE_DOUBLEPRECISION must be in this order....
#define DP_MODE_DOUBLEPRECISION  (DP_MODE_TEMPLATEID+DP_TEMPLATE_ID_WIDTH)
#define DP_MODE_DATATYPE (DP_MODE_DOUBLEPRECISION+1)
#define DP_MODE_DATA_MODEL (DP_MODE_DATATYPE+DATATYPE_WIDTH)
#define DP_MODE_SCATTER (DP_MODE_DATA_MODEL+DATAMODEL_WIDTH)
#define DP_MODE_BUSID  (DP_MODE_SCATTER+1)
#define DP_MODE_REPEAT (DP_MODE_BUSID+BUSID_WIDTH)
#define DP_MODE_MCAST (DP_MODE_REPEAT+1)


static int STR_DPREG_STRIDE[MAX_DP_STRIDE]={DPREG_STRIDE0,DPREG_STRIDE1,DPREG_STRIDE2,DPREG_STRIDE3,DPREG_STRIDE4,DPREG_BURST_STRIDE};
static int STR_DPREG_STRIDE_COUNT[MAX_DP_STRIDE]={DPREG_STRIDE0_COUNT,DPREG_STRIDE1_COUNT,DPREG_STRIDE2_COUNT,DPREG_STRIDE3_COUNT,DPREG_STRIDE4_COUNT,DPREG_COUNT};
static int STR_DPREG_STRIDE_MAX[MAX_DP_STRIDE]={DPREG_STRIDE0_MAX,DPREG_STRIDE1_MAX,DPREG_STRIDE2_MAX,DPREG_STRIDE3_MAX,DPREG_STRIDE4_MAX,DPREG_BURST_MAX};
static int STR_DPREG_STRIDE_MIN[MAX_DP_STRIDE]={DPREG_STRIDE0_MIN,DPREG_STRIDE1_MIN,DPREG_STRIDE2_MIN,DPREG_STRIDE3_MIN,DPREG_STRIDE4_MIN,DPREG_BURST_MIN};

int cMcore::M_currLine=0;
int cMcore::M_beginBlock=true;
static cMcoreDefine M_define[MAX_MCORE_DEFINE];
static int M_numDefine=0;
cMcoreVariable cMcore::M_vars[DP_TEMPLATE_MAX];
std::vector<std::string> cMcore::M_export;

char s_ztamFifoReady[] = "";

// This class hold MCORE term dimention information

cMcoreSpecifier::~cMcoreSpecifier()
{
}

cMcoreSpecifier::cMcoreSpecifier(const char *_v,const char *_v2,bool _plus)
{
   if(_v)
      m_v = _v;
   else
      m_v = "";
   if(_v2)
      m_v2 = _v2;
   else
      m_v2 = "";
   m_plus = _plus;
}

cMcoreSpecifier::cMcoreSpecifier(const cMcoreSpecifier &other)
{
   m_v = other.m_v;
   m_v2 = other.m_v2;
   m_plus = other.m_plus;
}


// Constructor for class described a memory reference template
cMcoreDefine::cMcoreDefine()
{
}

// Destructor for cMcoreDefine
cMcoreDefine::~cMcoreDefine()
{
}

// Constructor for class described a memory reference template
cMcoreVariable::cMcoreVariable()
{
   m_parmIndex = -1;
}

// Destructor for cMcoreDefine
cMcoreVariable::~cMcoreVariable()
{
}

std::string cMcoreVariable::getLine(cMcoreRange &range)
{
   std::string line;
   char temp[MAX_LINE];
   line = m_line;
   sprintf(temp, "%s:%s:%s",range.m_item[0].c_str(),range.m_item[1].c_str(),range.m_item[2].c_str());
   if(m_parmIndex >= 0)
      line.replace(line.find('$', 0), 1,std::string(temp));
   return line;
}

int cMcoreVariable::set(char *line, int parmIndex)
{
   m_line = line;
   m_parmIndex = parmIndex;
   return 0;
}

// Find a match for a define name
cMcoreDefine *cMcoreDefine::find(char *name)
{
   int i;
   for(i=M_numDefine-1;i >= 0;i--)
   {
      if(M_define[i].m_name==name)
         return &M_define[i];
   }
   return 0;
}

// Constructor for cMcoreTerm
// Format
// [Name](Specifier)[][][].funcName.parmName[..][..][..]
// Example
// PCORE:
//     PCORE(DATATYPE:vm:dy:dx)[pcore][tid].TEST.parm[:][:][range]  
//     SRAM(DATATYPE:ADDRESS:dz:dy:dx)[range][...][range]
//     DDR(DATATYPE:ADDRESS:dz:dy:dx)[range][...][range]
//     ALL(DATATYPE:val)

cMcoreTerm::cMcoreTerm()
{
   m_id=cMcoreTerm::eMcoreTermTypePCORE;
   m_identifier=0;
   m_maxNumThreads=NUM_THREAD_PER_CORE;
   m_dataModel=0;
   m_repeat = false;
   m_sync = false;
   m_stream = false;
   m_datatype = "";
   m_pcoreDim=0;
   m_pcoreSize=0;
   m_var=-1;
   m_isSource = true;
   m_varIndex = -1;
}

// Destructor of cMcoreTerm
cMcoreTerm::~cMcoreTerm()
{
}

void cMcoreTerm::GEN(FILE *fp,int p1,int p2,int p3,char *s)
{
   fprintf(fp, "ZTAM_GREG(%d,%d,%d)=%s;", p1, p2, p3, s);
}


int cMcoreTerm::GetParmRange()
{
   int numParmRange,i;
   for(i=0,numParmRange=0;i < (int)m_parm.size();i++)
   {
      if(m_parm[i].m_type==cMcoreRange::eMcoreRangeTypeRange)
         numParmRange++;
   }
   return numParmRange;
}

int cMcoreTerm::GetNumDim(cIdentifier *id)
{
   int numDim;
   if(m_parmSpecifier.size() == 0)
   {
      numDim=id->getNumDim();
      if(id->getVectorWidth() > 0)
         numDim++;
   }
   else
   {
      return m_parmSpecifier.size();
   }
   return numDim;
}

// Get total dimension for this tensor
int cMcoreTerm::GetDim()
{
   int numParmRange,dimSize;
   numParmRange=GetParmRange();
   dimSize=m_dim.size()+numParmRange;
   if(numParmRange==0)
      dimSize++;
   return dimSize;
}

std::string cMcoreTerm::GetDim(cIdentifier *id,int index)
{
   int size;
   char buf[128];
   if(m_parmSpecifier.size()==0)
   {
      if(index >= id->getNumDim())
         size=(1<<id->getVectorWidth());
      else
         size=id->getDim(index);
      sprintf(buf,"%d",size);
      return std::string(buf);
   }
   else
   {
      return m_parmSpecifier[index].m_v;
   }
}

std::string cMcoreTerm::GetDimSize(cIdentifier *id,int index)
{
   int size;
   char buf[128];
   if(m_parmSpecifier.size()==0)
   {
      if(index >= id->getNumDim())
         size=1;
      else
      {
         size=(id->getDimSize(index) << id->getVectorWidth());
      }
      sprintf(buf,"%d",size);
      return std::string(buf);
   }
   else
   {
      int i;
      sprintf(buf,"(1");
      for(i=index+1;i < (int)m_parmSpecifier.size();i++)
         sprintf(&buf[strlen(buf)],"*(%s)",m_parmSpecifier[i].m_v.c_str());
      sprintf(&buf[strlen(buf)],")");
      return std::string(buf);
   }
}

// Return if this tensor can perform scattering operation
bool cMcoreTerm::CanScatter()
{
   int dimSize,index;
   int from,to,i;

   // Always false for now...
   return false;

   if(m_id!=cMcoreTerm::eMcoreTermTypePCORE)
      return false;
   dimSize=GetDim();
   from=dimSize-m_pcoreSize-1;
   to=from+m_pcoreSize-1;
   // Check if all pcore-index are just above the last index
   for(i=m_pcoreDim;i <= (m_pcoreDim+m_pcoreSize-1);i++)
   {
      index=getStrideRegisterIndex(i,dimSize,false)-(MAX_DP_STRIDE-dimSize);
      if(index < from || index > to)
         return false;
   }
   return true;
}

// Generate temporary variable definitions required for the code generator
int cMcoreTerm::GenDef(FILE *out)
{
   int i,j;

   if (m_id == cMcoreTerm::eMcoreTermTypeVar)
      return 0;
   for(i=0;i < (int)m_index.size();i++)
   {
      for(j=0;j < (int)m_index[i].m_item.size();j++)
      {
         if(i==0 && j==0)
         {
            fprintf(out,"int ");
         }
         else
            fprintf(out,",");
         fprintf(out,"t%d%d=(%s)",i,j,m_index[i].m_item[j].c_str());
      }
   }
   fprintf(out,";");
   return 0;
}

// Perform validation on the term
// Calculate dimension of memory reference
int cMcoreTerm::Validate()
{
   cIdentifier *id = 0;
   std::vector<std::string> range_min;
   std::vector<std::string> range_max;
   char temp[MAX_LINE];
   int i, j;
   int var;
   std::string item1, item2, item3;

   if(m_name.length()==0)
   {
      // This is a global variable reference...
      m_id=cMcoreTerm::eMcoreTermTypeGlobalRef;
   }
   else if (decodeVarName((char *)m_name.c_str(),&var))
   {
      m_id=cMcoreTerm::eMcoreTermTypeVar;
      m_var = var;
   }
   else if(strcasecmp(m_name.c_str(),TOKEN_PCORE)==0 || strcasecmp(m_name.c_str(),TOKEN_PCORES)==0)
   {
      int numPCORES=cConfig::m_numPCORES;
      if(m_funcName=="")
         error(cMcore::M_currLine,"PCORE function parameter not specified");
      if(strcasecmp(m_name.c_str(),TOKEN_PCORES)==0)
      {
         // This is a fork. First dimension is fork count
         numPCORES=PID_MAX;
         if(m_specifier.size() < (SPECIFIER_PCORE_DIM+1))
            error(cMcore::M_currLine,"Invalid dimension");
         m_forkCount=m_specifier[SPECIFIER_PCORE_DIM].m_v;
         for(int ii=SPECIFIER_PCORE_DIM;ii < (int)m_specifier.size()-1;ii++)
         {
            m_specifier[ii]=m_specifier[ii+1];
         }
         m_specifier.resize(m_specifier.size()-1);
      }
      char temp[MAX_LINE],temp2[MAX_LINE];
      char *funcName,*parmName;
      cInstruction *func;
      strcpy(temp,m_funcName.c_str());
      if(strstr(temp,"."))
      {
         funcName=strtok(temp,".");
         parmName=strtok(0,".");
         if(!funcName || !parmName || strtok(0,"."))
            error(cMcore::M_currLine,"Invalid function parameter");
      }
      else
      {
         parmName=strstr(temp,"::");
         if(!parmName)
            error(cMcore::M_currLine,"Invalid function parameter");
         parmName[0]=0;
         parmName+=2;
         funcName=temp;
         strcpy(temp2,funcName);
         strcat(temp2,"::");
         funcName=temp2;
      }
      id=cIdentifier::lookupParm(root,funcName,parmName);
      if(!id)
         error(cMcore::M_currLine,"Undefined function parameter");
      m_identifier=id;
      if(!m_identifier->isKindOf(cIdentifierShared::getCLID()))
      {
         char temp2[MAX_STRING_LEN];      
         if(m_thread.size()==0)
         {
            sprintf(temp2,"%d",NUM_THREAD_PER_CORE);
            m_thread.push_back(cMcoreSpecifier(temp2,0));
         }
         if(m_thread.size() > 2)
            error(cMcore::M_currLine,"Invalid thread block dimension. Must be 1 or 2");
      }
      func=cInstruction::GetFunctionBegin(funcName);
      if(func)
      {
         m_maxNumThreads=func->m_maxNumThreads;
         m_dataModel=func->m_dataModel;
      }
      else if(strcmp(funcName,"root")==0)
      {
         m_maxNumThreads=NUM_THREAD_PER_CORE;
         m_dataModel=0;
      }
      else
         error(cMcore::M_currLine,"Undefined function name");

      // This is referencing PCORE memory space...
      m_id=cMcoreTerm::eMcoreTermTypePCORE;
      if (strcasecmp(m_cast.c_str(), "int") == 0 )
      {
         m_datatype="DP_DATA_TYPE_INT16";
      }
      else if(strcasecmp(m_cast.c_str(), "short") == 0)
      {
         m_datatype = "DP_DATA_TYPE_INT8";
      }
      else if(strcasecmp(m_cast.c_str(), "ushort") == 0)
      {
         m_datatype = "DP_DATA_TYPE_UINT8";
      }
      else if(strcasecmp(m_cast.c_str(), "uhalf") == 0)
      {
         m_datatype = "DP_DATA_TYPE_UFLOAT8";
      }     
      else if(strcasecmp(m_cast.c_str(), "half") == 0)
      {
         // Float8
         m_datatype = "DP_DATA_TYPE_FLOAT8";
      }
      else if(m_cast.length() > 0)
      {
         // This is a dynamic type
         char temp[MAX_LINE];
         sprintf(temp,"((%s)&0xFE)",m_cast.c_str());
         m_datatype = temp;
      }
      else
      {
         m_datatype = "DP_DATA_TYPE_FLOAT8";
      }
      if(m_specifier.size() <= SPECIFIER_PCORE_DIM)
      {
         // If dimension not specifier then set to 1 dimensional array=NUM_PCORE
         char temp[MAX_LINE];
         sprintf(temp,"%d",numPCORES);
         m_specifier.push_back(cMcoreSpecifier(temp,""));
      }
      if((m_specifier.size() > (SPECIFIER_PCORE_DIM+1)) && m_specifier[SPECIFIER_PCORE_DIM].m_v=="")
      {
         // If 2D array, if a dimension is not specifier then set it to NUM_PCORE/[the other dimension size]
         char temp[MAX_LINE];
         if(m_specifier.size() <= (SPECIFIER_PCORE_DIM+1))
            error(cMcore::M_currLine,"Invalid PCORE specification");
         sprintf(temp,"(%d/(%s))",numPCORES,m_specifier[SPECIFIER_PCORE_DIM+1].m_v.c_str());
         m_specifier[SPECIFIER_PCORE_DIM].m_v=temp;
      }
      if((m_specifier.size() > (SPECIFIER_PCORE_DIM+1)) &&  m_specifier[SPECIFIER_PCORE_DIM+1].m_v=="")
      {
         // If 2D array, if a dimension is not specifier then set it to NUM_PCORE/[the other dimension size]
         char temp[MAX_LINE];
         sprintf(temp,"(%d/(%s))",numPCORES,m_specifier[SPECIFIER_PCORE_DIM].m_v.c_str());
         m_specifier[SPECIFIER_PCORE_DIM+1].m_v=temp;
      }
      if(m_specifier.size()==(SPECIFIER_PCORE_DIM+1))
      {
         // One dimensional PCORE
         if(m_index.size() != (1+m_thread.size()))
            error(cMcore::M_currLine,"Invalid range for PCORE memory space");
         
         m_pcoreDim=m_dim.size();
         m_pcoreSize=1;
         sprintf(temp,"%d",REGISTER_SIZE*NUM_THREAD_PER_CORE);
         m_dim.push_back(temp);
         sprintf(temp,"%d",0);
         range_min.push_back(temp);         
         sprintf(temp,"(%s)-1",m_specifier[SPECIFIER_PCORE_DIM].m_v.c_str());
         range_max.push_back(temp);
      }
      else if(m_specifier.size()==(SPECIFIER_PCORE_DIM+2))
      {
         // Two dimensional PCORE
         if(m_index.size() != (2+m_thread.size()))
            error(cMcore::M_currLine,"Invalid range for PCORE memory space");
         m_pcoreDim=m_dim.size();
         m_pcoreSize=2;
         sprintf(temp,"%d*(%s)",REGISTER_SIZE*NUM_THREAD_PER_CORE,m_specifier[SPECIFIER_PCORE_DIM+1].m_v.c_str());
         m_dim.push_back(temp);
         sprintf(temp,"%d",REGISTER_SIZE*NUM_THREAD_PER_CORE);
         m_dim.push_back(temp);
         sprintf(temp,"%d",0);
         range_min.push_back(temp);
         sprintf(temp,"%d",0);
         range_min.push_back(temp);
         sprintf(temp,"(%s)-1",m_specifier[SPECIFIER_PCORE_DIM].m_v.c_str());
         range_max.push_back(temp);
         sprintf(temp,"(%s)-1",m_specifier[SPECIFIER_PCORE_DIM+1].m_v.c_str());
         range_max.push_back(temp);
      }
      else
         error(cMcore::M_currLine,"Invalid PCORE memory reference");

      // Build dimension for thread block....
      if(!m_identifier->isKindOf(cIdentifierShared::getCLID()))
      {
      if(m_thread.size()<=1)
      {
         // Thread block is 1 dimensional
         sprintf(temp,"%d",REGISTER_SIZE);
         m_dim.push_back(temp);
         sprintf(temp,"%d",0);
         range_min.push_back(temp);
         sprintf(temp,"%d",NUM_THREAD_PER_CORE-1);
         range_max.push_back(temp);
      }
      else
      {
         // Thread block is 2 dimensional...
         sprintf(temp,"%d*%s",REGISTER_SIZE,m_thread[1].m_v.c_str());
         m_dim.push_back(temp);
         sprintf(temp,"%d",REGISTER_SIZE);
         m_dim.push_back(temp);
         sprintf(temp,"%d",0);
         range_min.push_back(temp);
         sprintf(temp,"%d",0);
         range_min.push_back(temp);
         sprintf(temp,"%s-1",m_thread[0].m_v.c_str());
         range_max.push_back(temp);
         sprintf(temp,"%s-1",m_thread[1].m_v.c_str());
         range_max.push_back(temp);
      }
      }
   }
   else if (strcasecmp(m_name.c_str(), TOKEN_ALL_HALF) == 0)
   {
       // Constants
      m_id = cMcoreTerm::eMcoreTermTypeALLFloat;
      m_datatype = "DP_DATA_TYPE_FLOAT8";
      if (m_specifier.size() != 1)
         error(cMcore::M_currLine, "Invalid ALL syntax");
      if(m_scatter.size() > 0)
         error(cMcore::M_currLine, "SCATTER is only for PCORE");
   }
   else if(strcasecmp(m_name.c_str(),TOKEN_ALL_INT)==0)
   {
      // Constants
      m_id=cMcoreTerm::eMcoreTermTypeALLInt;
      m_datatype="DP_DATA_TYPE_INT16";
      if(m_specifier.size() != 1)
         error(cMcore::M_currLine,"Invalid ALL syntax");
      if(m_scatter.size() > 0)
           error(cMcore::M_currLine, "SCATTER is only for PCORE");
   }
   else if (strcasecmp(m_name.c_str(), TOKEN_ALL_SHORT) == 0)
   {
       // Constants
      m_id = cMcoreTerm::eMcoreTermTypeALLInt;
      m_datatype = "DP_DATA_TYPE_INT8";
      if (m_specifier.size() != 1)
         error(cMcore::M_currLine, "Invalid ALL syntax");
      if(m_scatter.size() > 0)
         error(cMcore::M_currLine, "SCATTER is only for PCORE");
   }
   else if (strcasecmp(m_name.c_str(), TOKEN_SPU) == 0)
   {
       // Program SPU unit
      m_id = cMcoreTerm::eMcoreTermTypeSPU;
      m_datatype="DP_DATA_TYPE_INT16";
      if(m_specifier.size()==0)
         m_spuCount=SPU_NUM_STREAM;
      else
         m_spuCount=atoi(m_specifier[0].m_v.c_str());
   }
   else if (strcasecmp(m_name.c_str(), TOKEN_PCORE_PROG) == 0)
   {
       // Program SPU unit
      m_id = cMcoreTerm::eMcoreTermTypePcoreProg;
      m_datatype="DP_DATA_TYPE_INT16";
      if(m_specifier.size() != 1)
         error(cMcore::M_currLine,"Invalid PROG specification");
   }
   else if(strcasecmp(m_name.c_str(),TOKEN_SRAM)==0 || strcasecmp(m_name.c_str(),TOKEN_SRAMS)==0)
   {
      // Referenced SRAM
      m_id=cMcoreTerm::eMcoreTermTypeSRAM;
      if(m_scatter.size() > 0)
           error(cMcore::M_currLine, "SCATTER is only for PCORE");

      if(strcasecmp(m_name.c_str(),TOKEN_SRAMS)==0)
      {
         // This is a fork. First dimension is fork count
         if(m_specifier.size() < (SPECIFIER_SRAM_DIM+1))
            error(cMcore::M_currLine,"Invalid dimension");
         m_forkCount=m_specifier[SPECIFIER_SRAM_DIM].m_v;
         for(int ii=SPECIFIER_SRAM_DIM;ii < (int)m_specifier.size()-1;ii++)
         {
            m_specifier[ii]=m_specifier[ii+1];
         }
         m_specifier.resize(m_specifier.size()-1);
      }
      if (strcasecmp(m_cast.c_str(), "int") == 0)
      {
         m_datatype = "DP_DATA_TYPE_INT16";
      }
      else if(strcasecmp(m_cast.c_str(), "short") == 0)
      {
         m_datatype = "DP_DATA_TYPE_INT8";
      }
      else if(strcasecmp(m_cast.c_str(), "uhalf") == 0)
      {
         m_datatype = "DP_DATA_TYPE_UFLOAT8";
      } 
      else if(strcasecmp(m_cast.c_str(), "ushort") == 0)
      {
         m_datatype = "DP_DATA_TYPE_UINT8";
      }
      else if(strcasecmp(m_cast.c_str(), "half") == 0)
      {
         m_datatype = "DP_DATA_TYPE_FLOAT8";
      }
      else if(m_cast.length() > 0)
      {
         char temp[MAX_LINE];
         sprintf(temp,"(%s)",m_cast.c_str());
         m_datatype = temp;
      }
      else
      {
         m_datatype= "DP_DATA_TYPE_INT16";
      }
      if(m_specifier.size() < 1)
         error(cMcore::M_currLine,"Invalid SRAM memory reference");
      if(m_specifier.size() <= SPECIFIER_SRAM_DIM)
      {
         // If dimension not specifier then set to 1 dimension array=[SRAM SIZE]
         char temp[MAX_LINE];
         sprintf(temp,"%d",SRAM_SIZE);
         m_specifier.push_back(cMcoreSpecifier(temp));
      }
      for(i=SPECIFIER_SRAM_DIM;i < (int)m_specifier.size();i++)
      {
         char temp[MAX_LINE];
         strcpy(temp,"1");
         for(j=i+1;j < (int)m_specifier.size();j++)
            sprintf(&temp[strlen(temp)],"*(%s)",m_specifier[j].m_v.c_str());
         m_dim.push_back(temp);
      }

      if(m_dim.size() != m_index.size())
         error(cMcore::M_currLine,"Invalid SRAM reference");
      for(i=0;i < (int)m_index.size();i++)
      {
         char temp[MAX_LINE];
         sprintf(temp,"%d",0);
         range_min.push_back(temp);
         sprintf(temp,"((%s)-1)",m_specifier[i+SPECIFIER_SRAM_DIM].m_v.c_str());
         range_max.push_back(temp);
      }
   }
   else if(strcasecmp(m_name.c_str(),TOKEN_DDR)==0 || strcasecmp(m_name.c_str(),TOKEN_DDRS)==0)
   {
      // Referenced DDR
      m_id=cMcoreTerm::eMcoreTermTypeDDR;
      if(strcasecmp(m_name.c_str(),TOKEN_DDRS)==0)
      {
         // This is a fork. First dimension is fork count
         if(m_specifier.size() < (SPECIFIER_DDR_DIM+1))
            error(cMcore::M_currLine,"Invalid dimension");
         m_forkCount=m_specifier[SPECIFIER_DDR_DIM].m_v;
         for(int ii=SPECIFIER_DDR_DIM;ii < (int)m_specifier.size()-1;ii++)
         {
            m_specifier[ii]=m_specifier[ii+1];
         }
         m_specifier.resize(m_specifier.size()-1);
      }
      if(m_scatter.size() > 0)
           error(cMcore::M_currLine, "SCATTER is only for PCORE");
      if (strcasecmp(m_cast.c_str(), "int") == 0)
      {
         m_datatype = "DP_DATA_TYPE_INT16";
      }
      else if(strcasecmp(m_cast.c_str(), "short") == 0)
      {
         m_datatype = "DP_DATA_TYPE_INT8";
      }
      else if(strcasecmp(m_cast.c_str(), "uhalf") == 0)
      {
         m_datatype = "DP_DATA_TYPE_UFLOAT8";
      } 
      else if (strcasecmp(m_cast.c_str(), "ushort") == 0)
      {
         m_datatype = "DP_DATA_TYPE_UINT8";
      }
      else if (strcasecmp(m_cast.c_str(), "half") == 0)
      {
         m_datatype = "DP_DATA_TYPE_FLOAT8";
      }    
      else if(m_cast.length() > 0)
      {
         char temp[MAX_LINE];
         sprintf(temp,"(%s)",m_cast.c_str());
         m_datatype=temp;
      }
      else
      {
         m_datatype="DP_DATA_TYPE_INT16";
      }
      if(m_specifier.size() < 1)
         error(cMcore::M_currLine,"Invalid DDR memory reference");
      if(m_specifier.size() <= SPECIFIER_DDR_DIM)
      {
         // If dimension not specifier then set to 1D array size=[MAX DDR SIZE]
         char temp[MAX_LINE];
         sprintf(temp,"%d",MAX_DP_ADDR_SIZE);
         m_specifier.push_back(cMcoreSpecifier(temp));
      }
      for(i=SPECIFIER_DDR_DIM;i < (int)m_specifier.size();i++)
      {
         char temp[MAX_LINE];
         strcpy(temp,"1");
         if(m_specifier[m_specifier.size()-1].m_v2.length()>0 && m_specifier.size() >= (2+SPECIFIER_DDR_DIM))
         {
            if((i+1) <= ((int)m_specifier.size()-2))
            {
            for(j=i+1;j < (int)m_specifier.size()-2;j++)
               sprintf(&temp[strlen(temp)],"*(%s)",m_specifier[j].m_v.c_str());
            sprintf(&temp[strlen(temp)],"*(((%s)-1)*(%s)+(%s))",
                  m_specifier[(int)m_specifier.size()-2].m_v.c_str(),
                  m_specifier[(int)m_specifier.size()-1].m_v.c_str(),
                  m_specifier[(int)m_specifier.size()-1].m_v2.c_str());
            }
            else if((i+1) == ((int)m_specifier.size()-1))
            {
            sprintf(&temp[strlen(temp)],"*((%s))",
                  m_specifier[(int)m_specifier.size()-1].m_v.c_str());
            }
         }
         else
         {
            for(j=i+1;j < (int)m_specifier.size();j++)
               sprintf(&temp[strlen(temp)],"*(%s)",m_specifier[j].m_v.c_str());
         }
         m_dim.push_back(temp);
      }
      if(m_dim.size() != m_index.size())
         error(cMcore::M_currLine,"Invalid DDR memory reference");
      for(i=0;i < (int)m_index.size();i++)
      {
         sprintf(temp,"%d",0);
         range_min.push_back(temp);
         sprintf(temp,"((%s)-1)",m_specifier[i+SPECIFIER_DDR_DIM].m_v.c_str());
         range_max.push_back(temp);
      }
   }
   else
      error(cMcore::M_currLine,"Unrecognized memory space");
   for(i=0;i < (int)m_index.size();i++)
   {
      m_index[i].validate((char *)range_min[i].c_str(),(char *)range_max[i].c_str());
   }
   // Check parameter list. This is only applied to PCORE memory reference
   if(m_parm.size() > 0)
   {
      // Validate parameter field
      int count=0;
      if(m_id != cMcoreTerm::eMcoreTermTypePCORE)
         error(cMcore::M_currLine,"Parameter is allowed for PCORE");
      for(i=0;i < (int)m_parm.size();i++)
      {
         if(m_parm[i].m_item.size() > 1)
            count++;
      }
      if((int)m_parm.size() != GetNumDim(id))
         error(cMcore::M_currLine,"Invalid parameter reference");
      for(i=0;i < (int)m_parm.size();i++)
      {
         char temp[MAX_LINE];
         sprintf(temp,"(%s)-1",GetDim(id,i).c_str());
         m_parm[i].validate("0",temp);
      }
   }

   // Locate mcore variable parameter....
   for (i = 0; i < (int)m_index.size(); i++)
   {
      if (m_index[i].m_isParm)
      {
         if (m_varIndex >= 0)
            error(cMcore::M_currLine, "Invalid MCORE variable."); // Only 1 mcore variable is allowed
         m_varIndex = i;
      }
   }
   for (i = 0; i < (int)m_parm.size(); i++)
   {
      if (m_parm[i].m_isParm) 
         error(cMcore::M_currLine, "Invalid MCORE variable."); // Parameter not allowed in variable section
   }
   return 0;
}

int cMcoreTerm::getStrideRegisterIndex(int index,int dimSize,bool scatter)
{
   int _index;
   int i;
   int count;
   int numParmRange;
   int parmRangeFor[MAX_DP_STRIDE];

   _index=index;
   for(i=0,numParmRange=0;i < (int)m_parm.size();i++)
   {
      if(m_parm[i].m_type==cMcoreRange::eMcoreRangeTypeRange)
      {
         parmRangeFor[numParmRange++]=m_parm[i].m_forIndex;
         assert(numParmRange <= MAX_DP_STRIDE);
      }
   }

   if(index < (int)m_index.size() && m_index[index].m_forIndex >= 0)
      index=m_index[index].m_forIndex;
   else if(index >= (int)m_index.size() && numParmRange > 0 && parmRangeFor[index-m_index.size()] >= 0)
      index=parmRangeFor[index-m_index.size()];
   else
   {
      count=0;
      for(i=0;i < index;i++)
      {
         if(i < (int)m_index.size() && m_index[i].m_forIndex < 0)
            count++;
         else if(i >= (int)m_index.size() && numParmRange==0)
            count++;
         else if(i >= (int)m_index.size() && parmRangeFor[i-m_index.size()] < 0)
            count++;
      }
      index=m_forRange.size() + count;
   }
   assert(dimSize <= MAX_DP_STRIDE);
   if(scatter)
   {
      if(m_pcoreSize > 0 && _index >= m_pcoreDim && _index <= (m_pcoreDim+m_pcoreSize-1))
      {
         // This index is for PCORE
         index=(_index-m_pcoreDim)+dimSize-m_pcoreSize-1;
      }
      else if(index < (dimSize-1))
      {
         // This index is not PCORE
         int index2;
         index2=getStrideRegisterIndex(_index,dimSize,false);
         for(i=m_pcoreDim;i <= (m_pcoreDim+m_pcoreSize-1);i++)
         {
            if(getStrideRegisterIndex(i,dimSize,false) < index2)
               index--;
         }
      }
   }
   index += (MAX_DP_STRIDE-dimSize);
   assert(index < MAX_DP_STRIDE);
   return index;
}

// Generate code for a memory reference term...
int cMcoreTerm::Gen(FILE *out,int _parm,cMcoreRange *_parmRange)
{
   char varOffset[MAX_LINE];
   char varStride[MAX_LINE];
   char varLen[MAX_LINE];
   char varLen2[MAX_LINE];
   int dp_template;
   char temp[MAX_LINE];
   int mode = 0;
   char maskStr[MAX_LINE];
   int maskMode;

   maskStr[0] = 0;
   maskMode = MCAST_FILTER_MASK;
   if (m_id == cMcoreTerm::eMcoreTermTypeVar)
   {
      // This is a dynamic variable. Restore register values that are saved earlier.
      assert(m_var >= 0);
      assert(_parm < 0);
      sprintf(temp, "((%d << 1)+_task_curr2)", m_var);
      GEN(out, 0, REG_DP_RESTORE, 0, temp);

      // Override with variable parameter...

      if (m_varParameter.size() > 0)
      {
         cMcoreTerm term;
         std::string line;
         line = cMcore::M_vars[m_var].getLine(m_varParameter[0]);
         cMcore::scan_term((char *)line.c_str(), &term);
         term.Validate();
         term.m_isSource = m_isSource;
         fprintf(out, "{");
         term.GenDef(out);
         term.Gen(out,cMcore::M_vars[m_var].getParmIndex(),&m_varParameter[0]);
         fprintf(out, "}");
      }
      if(m_isSource)
         sprintf(temp,"(DP_TEMPLATE_ID_SRC<<%d)",DP_MODE_TEMPLATEID);
      else
         sprintf(temp,"(DP_TEMPLATE_ID_DEST<<%d)",DP_MODE_TEMPLATEID);
      GEN(out,DPREG_MODE,REG_DP_TEMPLATE,0,temp);
      return 0;
   }

   dp_template=REG_DP_TEMPLATE;

   if(m_id==cMcoreTerm::eMcoreTermTypeALLFloat || m_id==cMcoreTerm::eMcoreTermTypeALLInt)
   {
       mode |= (cMcoreTerm::eMcoreTermTypeSRAM << DP_MODE_BUSID);
   }
   else if(m_id==cMcoreTerm::eMcoreTermTypeSPU)
   {
      // Program SPU unit...
      sprintf(temp, "%d", 1);
      GEN(out, DPREG_BURST_STRIDE, dp_template, 0, temp);
      sprintf(temp, "%d",1);
      GEN(out, DPREG_COUNT, dp_template, 0, temp);
      sprintf(temp,"%d",1);
      GEN(out, DPREG_BURST_MAX, dp_template, 0, temp);
      sprintf(temp, "%d", 0);
      GEN(out, DPREG_BURST_MIN, dp_template, 0, temp);

      sprintf(temp, "%d", 2);
      GEN(out, DPREG_STRIDE4, dp_template, 0, temp);
      sprintf(temp, "%d",(SPU_SIZE*m_spuCount)-1);
      GEN(out, DPREG_STRIDE4_COUNT, dp_template, 0, temp);
      sprintf(temp,"%d",(SPU_SIZE*m_spuCount)-1);
      GEN(out, DPREG_STRIDE4_MAX, dp_template, 0, temp);
      sprintf(temp, "%d", 0);
      GEN(out, DPREG_STRIDE4_MIN, dp_template, 0, temp);

      sprintf(temp, "(%d<<(11+REGISTER_DEPTH))",PCORE_PAGE_SPU);
      GEN(out, DPREG_BAR, dp_template, 0, temp);
      mode |= (cMcoreTerm::eMcoreTermTypePCORE << DP_MODE_BUSID);
   }
   else if(m_id==cMcoreTerm::eMcoreTermTypePcoreProg)
   {
      // Program SPU unit...
      sprintf(temp, "%d", 1);
      GEN(out, DPREG_BURST_STRIDE, dp_template, 0, temp);
      sprintf(temp, "%d",3);
      GEN(out, DPREG_COUNT, dp_template, 0, temp);
      sprintf(temp,"%d",3);
      GEN(out, DPREG_BURST_MAX, dp_template, 0, temp);
      sprintf(temp, "%d", 0);
      GEN(out, DPREG_BURST_MIN, dp_template, 0, temp);

      sprintf(temp, "%d", 4);
      GEN(out, DPREG_STRIDE4, dp_template, 0, temp);
      sprintf(temp, "((%s)-1)",(char *)m_specifier[0].m_v.c_str());
      GEN(out, DPREG_STRIDE4_COUNT, dp_template, 0, temp);
      sprintf(temp,"((%s)-1)",(char *)m_specifier[0].m_v.c_str());
      GEN(out, DPREG_STRIDE4_MAX, dp_template, 0, temp);
      sprintf(temp, "%d", 0);
      GEN(out, DPREG_STRIDE4_MIN, dp_template, 0, temp);

      sprintf(temp, "(%d<<(11+REGISTER_DEPTH))",PCORE_PAGE_PCORE_PROG);
      GEN(out, DPREG_BAR, dp_template, 0, temp);
      mode |= (cMcoreTerm::eMcoreTermTypePCORE << DP_MODE_BUSID);
   }
   else if(m_id==cMcoreTerm::eMcoreTermTypePCORE)
   {
      // PCORE array
      int i;
      int parmSize;
      int numParmRange;
      int offset;

      numParmRange=GetParmRange();
      parmSize=numParmRange;
      if(parmSize==0)
         parmSize++;

      if (_parm < 0 || _parm == 0)
      {
         if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
         {
         sprintf(temp, "(%s)*t01", m_dim[0].c_str());
         GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(0, m_dim.size() + parmSize, m_scatter.size()>0)], dp_template, 0, temp);
         sprintf(temp, "((t02-t00+t01)/t01)-1");
         GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(0, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);

         sprintf(temp, "((%s)-t00)*(%s)-1", m_specifier[SPECIFIER_PCORE_DIM].m_v.c_str(), m_dim[0].c_str());
         GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(0, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
         sprintf(temp, "t00*(%s)", m_dim[0].c_str());
         GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(0, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
         }
      }
      if(m_dim.size() >= 2)
      {
         if (_parm < 0 || _parm == 1)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t11", m_dim[1].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(1, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "((t12-t10+t11)/t11)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(1, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);

            sprintf(temp, "((%s)-t10)*(%s)-1", m_dim[1].c_str(), m_dim[1].c_str());
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(1, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "t10*(%s)", m_dim[1].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(1, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            }
         }
      }
      if(m_dim.size() >= 3)
      {
         if (_parm < 0 || _parm == 2)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t21", m_dim[2].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(2, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "((t22-t20+t21)/t21)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(2, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);

            sprintf(temp, "((%s)-t20)*(%s)-1", m_dim[2].c_str(), m_dim[2].c_str());
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(2, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "t20*(%s)", m_dim[2].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(2, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            }
         }
      }
      if(m_dim.size() >= 4)
      {
         if (_parm < 0 || _parm == 3)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t31", m_dim[3].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(3, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "((t32-t30+t31)/t31)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(3, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);

            sprintf(temp, "((%s)-t30)*(%s)-1", m_dim[3].c_str(), m_dim[3].c_str());
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(3, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "t30*(%s)", m_dim[3].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(3, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            }
         }
      }
      offset=m_identifier->getByteOffset();
      sprintf(varOffset,"%d",offset);
      if(m_parm.size() > 0)
      {
         if((int)m_parm.size() != GetNumDim(m_identifier))
            error(cMcore::M_currLine,"Invalid PCORE array reference");
         for(i=0;i < (int)m_parm.size();i++)
         {
            if (i < ((int)m_parm.size() - 1))
            {
               sprintf(&varOffset[strlen(varOffset)], "+(%s)*(%s)", (char *)m_parm[i].m_item[0].c_str(), GetDimSize(m_identifier, i).c_str());
            }
            else
            {
               sprintf(&varOffset[strlen(varOffset)], "+(%s)", m_parm[i].m_item[0].c_str());
            }
         }
      }
      if (_parm < 0)
      {
         if (m_parm.size() > 0)
         {
            if (numParmRange > 0)
            {
               int index = 0;
               strcpy(varLen, "(1");
               for (i = 0; i < (int)m_parm.size(); i++)
               {
                  if (m_parm[i].m_type == cMcoreRange::eMcoreRangeTypeRange)
                  {
                     // Reference a variable block

                     sprintf(varLen2, "(((%s)-(%s)+(%s))/(%s))", m_parm[i].m_item[2].c_str(), m_parm[i].m_item[0].c_str(), m_parm[i].m_item[1].c_str(), m_parm[i].m_item[1].c_str());
                     strcat(varLen, "*");
                     strcat(varLen, varLen2);
                     sprintf(varStride, "(%s)*(%s)", GetDimSize(m_identifier, i).c_str(), m_parm[i].m_item[1].c_str());
                     sprintf(temp, "(%s-1)", varLen2);
                     GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size() + index, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
                     sprintf(temp, "%s", varStride);
                     GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size() + index, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
                     sprintf(temp, "%d", (m_identifier->getLen() - 1));
                     GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size() + index, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
                     sprintf(temp, "%d", 0);
                     GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size() + index, m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
                     assert(!m_parm[i].m_isParm);
                     index++;
                  }
                  else if (m_parm[i].m_type != cMcoreRange::eMcoreRangeTypeSingle)
                     error(cMcore::M_currLine, "Invalid parameter reference.");
               }
               strcat(varLen, ")-1");
            }
            else
            {
               sprintf(varLen, "0");
               sprintf(varStride, "1");
               sprintf(temp, "%s", varLen);
               GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
               sprintf(temp, "%s", varStride);
               GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
               sprintf(temp, "%d", (m_identifier->getLen() - 1));
               GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
               sprintf(temp, "%d", 0);
               GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            }
         }
         else
         {
            // No parameter. Reference the whole variable
            sprintf(varLen, "%d", m_identifier->getLen() - 1);
            sprintf(varStride, "1");
            sprintf(temp, "%s", varLen);
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "%s", varStride);
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "%d", (m_identifier->getLen() - 1));
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
            sprintf(temp, "%d", 0);
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size(), m_dim.size() + parmSize, m_scatter.size() > 0)], dp_template, 0, temp);
         }
      }
      temp[0] = 0;
      if (m_dim.size() >= 4 && (_parm < 0 || _parm==3))
      {
         sprintf(&temp[strlen(temp)],"t30*(%s)+",m_dim[3].c_str());
      }
      if(m_dim.size() >= 3 && (_parm < 0 || _parm==2))
      {
         sprintf(&temp[strlen(temp)],"t20*(%s)+",m_dim[2].c_str());
      }
      if(m_dim.size() >= 2 && (_parm < 0 || _parm==1))
      {
         sprintf(&temp[strlen(temp)],"t10*(%s)+",m_dim[1].c_str());
      }
      if (m_dim.size() >= 1 && (_parm < 0 || _parm==0))
      {
         sprintf(&temp[strlen(temp)], "t00*(%s)+", m_dim[0].c_str());
      }
      if (_parm < 0)
      {
         if (!m_identifier->isKindOf(cIdentifierShared::getCLID()))
            sprintf(&temp[strlen(temp)], "(%s)+(%s)*%d", varOffset, VM_STR, ((1 << (13 + REGISTER_DEPTH))));
         else
            sprintf(&temp[strlen(temp)], "(%s)+(%s)*%d+(%d<<(11+REGISTER_DEPTH))", varOffset, VM_STR,
               ((1 << (13 + REGISTER_DEPTH))),PCORE_PAGE_SHARE);
      }
      else
         strcat(temp, "0;");
      GEN(out, DPREG_BAR, dp_template, 0, temp);

      if(m_forkCount.length()>0)
      {
         // Update all the Fork BAR address...
         if (_parm < 0)
         {
            sprintf(temp,"(0)");
            GEN(out, DPREG_FORK_STRIDE, dp_template, 0, temp);
            sprintf(temp,"(((%s)>1)?(%s):0)",m_forkCount.c_str(),m_forkCount.c_str());
            GEN(out,DPREG_FORK_COUNT,dp_template,0,temp);
            sprintf(temp,"((%s))",m_specifier[(int)m_specifier.size()-1].m_v.c_str());
            GEN(out,DPREG_BURST_MAX_LEN,dp_template,0,temp);
         }
      }

      if (m_scatter.size() > 0)
         mode |= (1 << DP_MODE_SCATTER);
      mode |= (m_id << DP_MODE_BUSID);
   } 
   else if(m_id==cMcoreTerm::eMcoreTermTypeSRAM || m_id==cMcoreTerm::eMcoreTermTypeDDR)
   {
      if(m_dim.size() > 1)
      {
         if (_parm < 0 || _parm == 0)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t01", m_dim[0].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(0, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t02-t00+t01)/t01)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(0, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM : SPECIFIER_DDR_DIM].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-t00)*(%s)-1",
                  m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM : SPECIFIER_DDR_DIM].m_v.c_str(),
                  m_dim[0].c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(0, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t00*(%s)", m_dim[0].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(0, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      if(m_dim.size() > 2)
      {
         if (_parm < 0 || _parm == 1)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t11", m_dim[1].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t12-t10+t11)/t11)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(1, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+1 : SPECIFIER_DDR_DIM+1].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-t10)*(%s)-1", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 1 : SPECIFIER_DDR_DIM + 1].m_v.c_str(),
                  m_dim[1].c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t10*(%s)", m_dim[1].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(1, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      if(m_dim.size() > 3)
      {
         if (_parm < 0 || _parm == 2)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t21", m_dim[2].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(2, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t22-t20+t21)/t21)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(2, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+2 : SPECIFIER_DDR_DIM+2].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-t20)*(%s)-1", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 2 : SPECIFIER_DDR_DIM + 2].m_v.c_str(),
                  m_dim[2].c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(2, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t20*(%s)", m_dim[2].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(2, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      if (m_dim.size() > 4)
      {
         if (_parm < 0 || _parm == 3)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t31", m_dim[3].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(3, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t32-t30+t31)/t31)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(3, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+3 : SPECIFIER_DDR_DIM+3].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-t30)*(%s)-1", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 3 : SPECIFIER_DDR_DIM + 3].m_v.c_str(),
                  m_dim[3].c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(3, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t30*(%s)", m_dim[3].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(3, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      if (m_dim.size() > 5)
      {
         if (_parm < 0 || _parm == 4)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "(%s)*t41", m_dim[4].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(4, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t42-t40+t41)/t41)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(4, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+4 : SPECIFIER_DDR_DIM+4].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-t40)*(%s)-1", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 4 : SPECIFIER_DDR_DIM + 4].m_v.c_str(),
                  m_dim[4].c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(4, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t40*(%s)", m_dim[4].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(4, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      if (m_dim.size() > 6)
          error(cMcore::M_currLine,"Array to deep");

      if(m_dim.size()==1)
      {         
         if (_parm < 0 || _parm == 0)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "((%s)*t01)", m_dim[0].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t02-t00+t01)/t01)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM : SPECIFIER_DDR_DIM].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-1-t00)", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM : SPECIFIER_DDR_DIM].m_v.c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t00*(%s)", m_dim[0].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      else if(m_dim.size()==2)
      {            
         if (_parm < 0 || _parm == 1)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "((%s)*t11)", m_dim[1].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t12-t10+t11)/t11)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+1 : SPECIFIER_DDR_DIM+1].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-1-t10)", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 1 : SPECIFIER_DDR_DIM + 1].m_v.c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t10*(%s)", m_dim[1].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      else if(m_dim.size()==3)
      {
         if (_parm < 0 || _parm == 2)
         {
            if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
            {
            sprintf(temp, "((%s)*t21)", m_dim[2].c_str());
            GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "((t22-t20+t21)/t21)-1");
            GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);

            if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+2 : SPECIFIER_DDR_DIM+2].m_plus)
            {
               sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
            }
            else
            {
               sprintf(temp, "((%s)-1-t20)", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 2 : SPECIFIER_DDR_DIM + 2].m_v.c_str());
            }
            GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            sprintf(temp, "t20*(%s)", m_dim[2].c_str());
            GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
            }
         }
      }
      else if (m_dim.size() == 4)
      {
          if (_parm < 0 || _parm == 3)
          {
             if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
             {
             sprintf(temp, "((%s)*t31)", m_dim[3].c_str());
             GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             sprintf(temp, "((t32-t30+t31)/t31)-1");
             GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);

             if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+3 : SPECIFIER_DDR_DIM+3].m_plus)
             {
                sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
             }
             else
             {
                sprintf(temp, "((%s)-1-t30)", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 3 : SPECIFIER_DDR_DIM + 3].m_v.c_str());
             }
             GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             sprintf(temp, "t30*(%s)", m_dim[3].c_str());
             GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             }
          }
       }
      else if (m_dim.size() == 5)
      {
          if (_parm < 0 || _parm == 4)
          {
             if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
             {
             sprintf(temp, "((%s)*t41)", m_dim[4].c_str());
             GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             sprintf(temp, "((t42-t40+t41)/t41)-1");
             GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);

             if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+4 : SPECIFIER_DDR_DIM+4].m_plus)
             {
                sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
             }
             else
             {
                sprintf(temp, "((%s)-1-t40)", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 4 : SPECIFIER_DDR_DIM + 4].m_v.c_str());
             }
             GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             sprintf(temp, "t40*(%s)", m_dim[4].c_str());
             GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             }
          }
      }
      else if (m_dim.size() == 6)
      {
          if (_parm < 0 || _parm == 5)
          {
             if(_parm<0 || _parmRange->m_type!=cMcoreRange::eMcoreRangeTypeSingle)
             {
             sprintf(temp, "((%s)*t51)", m_dim[5].c_str());
             GEN(out, STR_DPREG_STRIDE[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             sprintf(temp, "((t52-t50+t51)/t51)-1");
             GEN(out, STR_DPREG_STRIDE_COUNT[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);

             if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM+5 : SPECIFIER_DDR_DIM+5].m_plus)
             {
                sprintf(temp,"(%d)",MAX_DP_ADDR_SIZE-1);
             }
             else
             {
                sprintf(temp, "((%s)-1-t50)", m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_DIM + 5 : SPECIFIER_DDR_DIM + 5].m_v.c_str());
             }
             GEN(out, STR_DPREG_STRIDE_MAX[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             sprintf(temp, "t50*(%s)", m_dim[5].c_str());
             GEN(out, STR_DPREG_STRIDE_MIN[getStrideRegisterIndex(m_dim.size() - 1, m_dim.size(), false)], dp_template, 0, temp);
             }
          }
      }
      else
         error(cMcore::M_currLine,"Array too deep");
      temp[0] = 0;
      sprintf(temp,"int tbar=");
      if (m_dim.size() >= 1 && (_parm < 0 || _parm==0))
      {
         sprintf(&temp[strlen(temp)], "t00*(%s)+", m_dim[0].c_str());
      }
      if (m_dim.size() >= 2 && (_parm < 0 || _parm==1))
      {
         sprintf(&temp[strlen(temp)], "t10*(%s)+", m_dim[1].c_str());
      }
      if (m_dim.size() >= 3 && (_parm < 0 || _parm==2))
      {
         sprintf(&temp[strlen(temp)], "t20*(%s)+", m_dim[2].c_str());
      }
      if (m_dim.size() >= 4 && (_parm < 0 || _parm==3))
      {
         sprintf(&temp[strlen(temp)], "t30*(%s)+", m_dim[3].c_str());
      }
      if (m_dim.size() >= 5 && (_parm < 0 || _parm==4))
      {
         sprintf(&temp[strlen(temp)], "t40*(%s)+", m_dim[4].c_str());
      }
      if (m_dim.size() >= 6 && (_parm < 0 || _parm==5))
      {
         sprintf(&temp[strlen(temp)], "t50*(%s)+", m_dim[5].c_str());
      }
      if(m_dim.size() > 6)
         error(cMcore::M_currLine,"Array too deep");
      sprintf(&temp[strlen(temp)], "0;");
      fprintf(out,"%s",temp);
      temp[0]=0;
      strcpy(temp,"tbar+");
      if (_parm < 0)
      {
         char temp2[MAX_LINE];
         if(m_forkCount.length()==0) // This is a fork transfer so memory pointers is a list...
            sprintf(temp2,"%s",m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_ADDRESS : SPECIFIER_DDR_ADDRESS].m_v.c_str());
         else // Single transfer
         {
            if(m_id==cMcoreTerm::eMcoreTermTypeDDR)
               sprintf(temp2,"((%s)[0])",m_specifier[SPECIFIER_DDR_ADDRESS].m_v.c_str());
            else
               sprintf(temp2,"((%s))",m_specifier[SPECIFIER_SRAM_ADDRESS].m_v.c_str());
         }
         sprintf(&temp[strlen(temp)], "((%s)", temp2);
         sprintf(&temp[strlen(temp)], ">>(((%s)&1)));",m_datatype.c_str());
         // There is a buffer length limiter
         if(m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_ADDRESS : SPECIFIER_DDR_ADDRESS].m_v2.length() > 0)
         {
            sprintf(temp2,"(((%s)",m_specifier[(m_id == cMcoreTerm::eMcoreTermTypeSRAM) ? SPECIFIER_SRAM_ADDRESS : SPECIFIER_DDR_ADDRESS].m_v2.c_str());
            sprintf(&temp2[strlen(temp2)], ">>(((%s)&1)))-tbar);",m_datatype.c_str());
            GEN(out, DPREG_BUFSIZE, dp_template, 0, temp2);
         }
      }
      else
         strcat(temp, "0;");
      GEN(out, DPREG_BAR, dp_template, 0, temp);

      if(m_forkCount.length()>0)
      {
         // Update all the Fork BAR address...
         if (_parm < 0)
         {
            if(m_id==cMcoreTerm::eMcoreTermTypeDDR)
               sprintf(temp,"((%s)[1])",m_specifier[SPECIFIER_DDR_ADDRESS].m_v.c_str());
            else
               sprintf(temp,"(0)");
            GEN(out, DPREG_FORK_STRIDE, dp_template, 0, temp);
            sprintf(temp,"(((%s)>1)?(%s):0)",m_forkCount.c_str(),m_forkCount.c_str());
            GEN(out,DPREG_FORK_COUNT,dp_template,0,temp);
            sprintf(temp,"((%s))",m_specifier[(int)m_specifier.size()-1].m_v.c_str());
            GEN(out,DPREG_BURST_MAX_LEN,dp_template,0,temp);
         }
      }


      if(_parm < 0 && m_specifier[m_specifier.size()-1].m_v2.length()>0)
      {
         int index,index2;
         if(m_dim.size() < 2)
            error(cMcore::M_currLine,"Partial tensor must have at least 2 dimension");
         if(m_id != cMcoreTerm::eMcoreTermTypeDDR)
            error(cMcore::M_currLine,"Partial tensor must have DDR type");

         // There is a fractional dimention specifier...
         sprintf(temp,"((%s)-1)",m_specifier[m_specifier.size()-1].m_v2.c_str());
         GEN(out, DPREG_BURST_MAX2, dp_template, 0, temp);

         // This is the stride index just above the burst
         index=getStrideRegisterIndex(m_dim.size()-2, m_dim.size(), false);

         // Initialize burst_max_init for partial tensor and when stride is single entry
         // When stride is single entry, then burst_max starts with truncated max value
         // When stride is multi-entry, then burst_max starts with full max value 

         index2=m_dim.size()-2;
         fprintf(out,"if(((%s)*t%d1) > (((%s)-t%d0)*(%s)-1)){",
                  m_dim[index2].c_str(),index2,
                  m_specifier[SPECIFIER_DDR_DIM+index2].m_v.c_str(),index2,m_dim[index2].c_str());
         GEN(out, DPREG_BURST_MAX_INIT, dp_template, 0, temp);
         fprintf(out,"}");
         sprintf(temp,"(%d)",index);
         GEN(out, DPREG_BURST_MAX_INDEX, dp_template, 0, temp);
      }

      strcpy(varLen,"0");

      mode |= (m_id << DP_MODE_BUSID);
   }
   else
      error(cMcore::M_currLine,"Syntax error");

   if(!m_isSource || (m_var >= 0))
   {
      // Generate total word count for this transfer

      if (m_id==eMcoreTermTypePcoreProg)
      {
          sprintf(temp,"(4*(%s))",(char *)m_specifier[0].m_v.c_str());
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else if (m_id==eMcoreTermTypeSPU)
      {
          sprintf(temp,"%d",(SPU_SIZE*m_spuCount*2));
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else if (m_dim.size()==1)
      {
          sprintf(temp,"(((t02-t00+t01)/t01)*((%s)+1))",varLen);
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else if (m_dim.size()==2)
      {
          sprintf(temp,"(((t02-t00+t01)/t01)*((t12-t10+t11)/t11)*((%s)+1))",varLen);
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else if (m_dim.size()==3)
      {
          sprintf(temp,"(((t02-t00+t01)/t01)*((t12-t10+t11)/t11)*((t22-t20+t21)/t21)*((%s)+1))",varLen);
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else if (m_dim.size()==4)
      {
          sprintf(temp,"(((t02-t00+t01)/t01)*((t12-t10+t11)/t11)*((t22-t20+t21)/t21)*((t32-t30+t31)/t31)*((%s)+1))",varLen);
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else if (m_dim.size() == 5)
      {
          sprintf(temp,"(((t02-t00+t01)/t01)*((t12-t10+t11)/t11)*((t22-t20+t21)/t21)*((t32-t30+t31)/t31)*((t42-t40+t41)/t41)*((%s)+1))",varLen);
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else if (m_dim.size() == 6)
      {
          sprintf(temp,"(((t02-t00+t01)/t01)*((t12-t10+t11)/t11)*((t22-t20+t21)/t21)*((t32-t30+t31)/t31)*((t42-t40+t41)/t41)*((t52-t50+t51)/t51)*((%s)+1))",varLen);
          GEN(out,DPREG_TOTALCOUNT,dp_template,0,temp);
      }
      else
          error(cMcore::M_currLine, "Array too deep");
   }

   if ((!m_isSource || m_var >= 0))
   {
      // Generate brodcast information if this transfer has broadcast component
      if (m_id == cMcoreTerm::eMcoreTermTypePCORE)
      {
         if (m_pcoreSize == 1)
         {
            if (m_index[0].m_type == cMcoreRange::eMcoreRangeTypeWild)
            {
               strcpy(maskStr, "0");
               maskMode = MCAST_FILTER_MASK;
            }
         }
         else
         {
            char mask[MAX_LINE];
            if (m_specifier.size() == (SPECIFIER_PCORE_DIM + 1))
               sprintf(mask, "0");
            else
               sprintf(mask, "((%s)-1)", m_specifier[SPECIFIER_PCORE_DIM + 1].m_v.c_str());
            if (m_index[0].m_type == cMcoreRange::eMcoreRangeTypeWild && m_index[1].m_type == cMcoreRange::eMcoreRangeTypeWild)
            {
               strcpy(maskStr, "0");
               maskMode = MCAST_FILTER_MASK;
            }
            else if (m_index[0].m_type == cMcoreRange::eMcoreRangeTypeWild)
            {
               strcpy(maskStr, mask);
               maskMode = MCAST_FILTER_MASK;
            }
            else if (m_index[1].m_type == cMcoreRange::eMcoreRangeTypeWild)
            {
               strcpy(maskStr,mask);
               maskMode = MCAST_FILTER_RANGE;
            }
         }
      }
   }
   if(m_isSource || m_var >= 0)
   {
      if(m_pad.size()>0)
      {
         sprintf(temp,"(%s)",m_pad[0].m_v.c_str());
         GEN(out,DPREG_DATA,dp_template,0,temp);
      }
   }
   if(m_isSource || m_var >= 0)
   {
      // Specified constant if this is a constant assignment transfer
      if (m_id == cMcoreTerm::eMcoreTermTypeALLFloat)
      {
         sprintf(temp,"((int)(%s))",m_specifier[SPECIFIER_ALL_VAL].m_v.c_str());
         GEN(out,DPREG_DATA,dp_template,0,temp);
      }
      else if (m_id == cMcoreTerm::eMcoreTermTypeALLInt)
      {
         sprintf(temp,"(%s)",m_specifier[SPECIFIER_ALL_VAL].m_v.c_str());
         GEN(out,DPREG_DATA,dp_template,0,temp);
      }
      if (m_repeat)
         mode |= (1 << DP_MODE_REPEAT);
   }
   mode |= (1<<DP_MODE_LOAD);

   if(m_var < 0)
   {
      if (m_isSource)
         mode |= (DP_TEMPLATE_ID_SRC<<DP_MODE_TEMPLATEID);
      else
         mode |= (DP_TEMPLATE_ID_DEST<<DP_MODE_TEMPLATEID);
   }
   if (!maskStr[0])
   {
      mode |= (((1 << MCAST_WIDTH) - 1) << DP_MODE_MCAST);
      sprintf(temp, "(%d|(%s<<%d))", mode,m_datatype.c_str(),DP_MODE_DOUBLEPRECISION);
   }
   else
   {
      sprintf(temp, "((%d|(%s<<%d))|((((%s)&((1<<(MCAST_WIDTH-1))-1))+(%d<<(MCAST_WIDTH-1)))<<%d))",
              mode,m_datatype.c_str(),DP_MODE_DOUBLEPRECISION,maskStr,maskMode,DP_MODE_MCAST);
   }
   sprintf(&temp[strlen(temp)],"|((%d)<<%d)",m_dataModel,DP_MODE_DATA_MODEL);
   if(m_var >= 0)
      sprintf(&temp[strlen(temp)],"|(((%d<<1)+_task_curr2)<<%d)",m_var,DP_MODE_TEMPLATEID);
   if(_parm < 0)
      GEN(out,DPREG_MODE,dp_template,0,temp);
   return 0;
}

char *cMcoreTerm::decodeVarName(char *name,int *var)
{
   if ((name[0] == '$') && (name[1] >= '0' && name[1] <= '9'))
   {
      *var=(int)(name[1] - '0');
      return name + 2;
   }
   else
   {
      *var = -1;
      return 0;
   }
}

// Create the SCRATCH memory to hold intermediate data during a scatter transfer

void cMcoreTerm::ScratchCreate(cMcoreTerm *term,char *cast,char *_scratchAddr,std::string &forkCount)
{
   int i,count,dimSize;
   cMcoreRange range;
   int numParmRange;
   int index;
   bool fork;
   char buf[128];
   char scratchAddr[MAX_LINE];

   assert(term->m_id==cMcoreTerm::eMcoreTermTypePCORE);
   assert(term->m_scatter.size() > 0);
   m_id=cMcoreTerm::eMcoreTermTypeSRAM;
   m_datatype="DP_DATA_TYPE_INT16";
   sprintf(scratchAddr,"(%s+((%d)*_task_curr2))",_scratchAddr,1<<(SRAM_DEPTH-1));
   if(cast)
      m_cast.assign(cast);
   else
      m_cast="";
   m_specifier.push_back(cMcoreSpecifier(scratchAddr,0));
   if(forkCount.length()>0)
   {
      m_specifier.push_back(cMcoreSpecifier((char *)forkCount.c_str(),0));
      m_name=TOKEN_SRAMS;
      fork=true;
   }
   else
   {
      m_name=TOKEN_SRAM;
      fork=false;
   }
   numParmRange=term->GetParmRange();
   dimSize=term->GetDim();
   m_index.clear();
   
   // Create empty range first
   for(i=0;i < dimSize;i++)
   {
      m_index.push_back(range);
      m_specifier.push_back(cMcoreSpecifier(0,0));
   }

   // Build the range from non-parm range first...
   count=0;   
   for(i=0;i < (int)term->m_dim.size();i++)
   {   
      index=term->getStrideRegisterIndex(count,dimSize,false);
      index -= (MAX_DP_STRIDE-dimSize);
      m_index[index].m_item.push_back("0");
      m_index[index].m_item.push_back("1");
      sprintf(buf,"((((%s)-(%s))/(%s)))",term->m_index[i].m_item[2].c_str(),term->m_index[i].m_item[0].c_str(),term->m_index[i].m_item[1].c_str());
      m_index[index].m_item.push_back(buf);
      strcat(buf,"+1");
      m_specifier[index+SPECIFIER_SRAM_DIM+(fork?1:0)].m_v=buf;
      count++;
   }

   // Build the range from parameter block
   for(i=0;i < (int)term->m_parm.size();i++)
   {
      if(term->m_parm[i].m_type==cMcoreRange::eMcoreRangeTypeRange)
      {
         index=term->getStrideRegisterIndex(count,dimSize,false);
         index -= (MAX_DP_STRIDE-dimSize);
         m_index[index].m_item.push_back("0");
         m_index[index].m_item.push_back("1");
         sprintf(buf,"((((%s)-(%s))/(%s)))",term->m_parm[i].m_item[2].c_str(),term->m_parm[i].m_item[0].c_str(),term->m_parm[i].m_item[1].c_str());
         m_index[index].m_item.push_back(buf);
         strcat(buf,"+1");
         m_specifier[index+SPECIFIER_SRAM_DIM+(fork?1:0)].m_v=buf;
         count++;
      }
   } 
   if(count < dimSize)
   {
      assert(numParmRange==0);
      assert(count==(dimSize-1));
      index=term->getStrideRegisterIndex(count,dimSize,false);
      index -= (MAX_DP_STRIDE-dimSize);
      m_index[index].m_item.push_back("0");
      m_index[index].m_item.push_back("1");
      sprintf(buf,"%d",term->m_identifier->getLen()-1);
      m_index[index].m_item.push_back(buf);
      sprintf(buf,"%d+1",term->m_identifier->getLen()-1);
      m_specifier[index+SPECIFIER_SRAM_DIM+(fork?1:0)].m_v=buf;
      count++;
   }
}

// Reorder the transfer ordering to match the reorder of PCORE
void cMcoreTerm::ScratchReorder(cMcoreTerm *term,bool scatter)
{
   int i,oldindex,newindex;
   int dimSize;
   dimSize=m_index.size();
   if(scatter)
   {
      assert(term->m_id==cMcoreTerm::eMcoreTermTypePCORE);
      assert(term->m_scatter.size() > 0);
      if(term->m_scatter.size() > 0)
      {
         for(i=0;i < (int)m_index.size();i++)
         {
            oldindex=term->getStrideRegisterIndex(i,dimSize,false)-(MAX_DP_STRIDE-dimSize);
            newindex=term->getStrideRegisterIndex(i,dimSize,true)-(MAX_DP_STRIDE-dimSize);
            m_index[oldindex].m_forIndex=newindex;
         }
      }
   }
   else
   {
      for(i=0;i < (int)m_index.size();i++)
      {
         m_index[i].m_forIndex=-1;
      }
   }
}

void cMcoreTerm::Print()
{
   int i,j;
   printf("\r\n name=>%s< \r\n",m_name.c_str());
   printf("\r\n FuncName=>%s< \r\n",m_funcName.c_str());
   for(i=0;i < (int)m_index.size();i++)
   {
      for(j=0;j < (int)m_index[i].m_item.size();j++)
         printf("\r\n     index[%d,%d]=>%s< \r\n",i,j,m_index[i].m_item[j].c_str());
   }
   for(i=0;i < (int)m_parm.size();i++)
   {
      for(j=0;j < (int)m_parm[i].m_item.size();j++)
         printf("\r\n     parm[%d,%d]=>%s< \r\n",i,j,m_parm[i].m_item[j].c_str());
   }
}

// Constructor for class implement a range
// For example: p[0:1:2]
cMcoreRange::cMcoreRange()
{
   m_type=cMcoreRange::eMcoreRangeTypeRange;
   m_forIndex=-1;
   m_isParm = false;
}

cMcoreRange::~cMcoreRange()
{
}

// Validate range.
// Substitute values if range values not specified
bool cMcoreRange::validate(const char *range_min,const char *range_max)
{
   std::string item1,item2,item3;
   switch(m_item.size())
   {
   case 1:
      item1=m_item[0];
      item2="1";
      item3=item1;
      break;
   case 2:
      item1=m_item[0];
      item2="1";
      item3=m_item[1];
      break;
   case 3:
      item1=m_item[0];
      item2=m_item[1];
      item3=m_item[2];
      break;
   default:
      error(cMcore::M_currLine,"Invalid range"); 
   }
   if(item1=="")
   {
      char temp[MAX_LINE];
      if(!range_min)
         error(cMcore::M_currLine,"Invalid range");
      if(!range_min)
         error(cMcore::M_currLine, "Invalid range");
      sprintf(temp,"%s",range_min);
      item1=temp;
   }
   if(item2=="")
      item2="1";
   if(item3=="")
   {
      char temp[MAX_LINE];
      if(!range_max)
         error(cMcore::M_currLine,"Invalid range");
      if(!range_max)
         error(cMcore::M_currLine, "Invalid range");
      sprintf(temp,"%s",range_max);
      item3=temp;
   }
   m_item.clear();
   m_item.push_back(item1);
   m_item.push_back(item2);
   m_item.push_back(item3);
   return true;
}

// Skip all white spaces
char *cMcore::skipWS(char *line)
{
   for(;;)
   {
      if(!isWS(*line))
         return line;
      line++;
   }
}

// Scan buffer until reaching some defined characters
char *cMcore::scan(char *line,char *delimiter,char *token)
{
   char *p,*p2,*p3;
   p=line;
   p3=token;
   while(*p)
   {
      p2=delimiter;
      while(*p2)
      {
         if(*p2==*p)
         {
            *p3=0;
            return p;
         }
         p2++;
      }
      *p3=*p;
      p++;
      p3++;
   }
   return 0;
}

// Scan specifier section of a memory term
char *cMcore::scan_specifier(std::vector<cMcoreSpecifier> *_specifier,char *line,int _level)
{
   char *p2,*p3,*p4,*p5;
   int count,count2;
   char item[MAX_LINE];
   char temp[MAX_LINE];
   char temp2[MAX_LINE];
   char *token;
   bool plus,nested;
   int numNested=0;

   token=temp;
   line=skipWS(line);
   if(*line=='(')
   {
      line++;
      count=1;
      *token=0;
      while(*line)
      {
         if(*line==')')
         {
            count--;
            if(count==0)
            {
               *token=0;
               break;
            }
         }
         else if(*line=='(')
            count++;
         *token=*line;
         line++;
         token++;
      }
      if(*line==0)
         error(cMcore::M_currLine,"syntax error");
      line++;
      token=temp;
      strcat(token," ");
      p2=token;
      p2=scan_item(p2,item,',');
      while(p2)
      {
         p3=strstr(item,"|");
         if(p3)
            *p3=0;
         trim(item);
         if(strlen(item)>0 && item[strlen(item)-1]=='+')
         {
            item[strlen(item)-1]=0;
            plus=true;
         }
         else
            plus=false;
         if(p3)
         {
            _specifier->push_back(cMcoreSpecifier(item,skipWS(p3+1),plus));
         }
         else
         {
            // Check if this is a nested specifier
            p4=item;
            count2=0;
            nested=false;
            while(*p4) {
               if(*p4==')')
                  count2--;
               else if(*p4=='(') {
                  if(count2==0 && p4 != item) {
                     nested=true;
                     break;
                  }
                  count2++;
               }
               p4++;
            }
            if(nested) {
               // There is an open '(', nested is possible but check if the '(' might be just
               // part of an expression
               p5=p4-1;
               nested=false;
               while(p5 != item) {
                  if(!isWS(*p5)) {
                     if(isalnum(*p5) || *p5=='_' || *p5==')')
                        nested=true;
                     break;
                  }
                  p5--;
               }
            }
            if(nested) {
                int numItems;
                if(_level==0 && numNested > 0) {
                   error(cMcore::M_currLine,"Invalid dimension specification");
                }
                if(_level > 0) {
                   error(cMcore::M_currLine,"Invalid dimension specification");
                }
                numNested++;
                numItems=(*_specifier).size();
            	scan_specifier(_specifier,p4,_level++);
                *p4=0;
                trim(item);
                if(numItems==0) {
                    error(cMcore::M_currLine,"Invalid dimension specification");
                }
                else if(numItems==1) {
                   // Bound on total size
                   (*_specifier)[0].m_v2=item;
                } else {
                   // Bound on last 2 dimension
                   if(((*_specifier).size()-numItems) != 2) {
                       error(cMcore::M_currLine,"Invalid dimension specification");
                   }
                   sprintf(temp2,"((%s)-((%s)-1)*(%s))",item,
                                                        (*_specifier)[(*_specifier).size()-2].m_v.c_str(),
                                                        (*_specifier)[(*_specifier).size()-1].m_v.c_str());
                   (*_specifier)[(*_specifier).size()-1].m_v2=temp2;
                }
            } else {
                if(_level==0 && numNested > 0) {
                   error(cMcore::M_currLine,"Invalid dimension specification");
                }
               _specifier->push_back(cMcoreSpecifier(item,0,plus));
            }
         }
         p2=scan_item(p2,item,',');
      }
      return line;
   }
   else
      return line;
}

// Scan the name part of a memory reference term
char *cMcore::scan_name(char *line,char *token)
{
   char *retval=token;
   *token=0;
   line=skipWS(line);
   while(*line)
   {
      if(*line >= 'a' && *line <= 'z')
         *token++=*line;
      else if(*line >= 'A' && *line <= 'Z')
         *token++=*line;
      else if(*line >= '0' && *line <= '9')
         *token++=*line;
      else if(*line=='_' || *line=='.' || *line=='$' || *line==':')
         *token++=*line;
      else
      {
         *token=0;
         trim(retval);
         return line;
      }
      line++;
   }
   trim(retval);
   *token=0;
   return line;
}

// Scan the name part of a memory reference term
char *cMcore::scan_scoped_name(char *line,char *token)
{
   char *retval=token;
   *token=0;
   line=skipWS(line);
   while(*line)
   {
      if(*line >= 'a' && *line <= 'z')
         *token++=*line;
      else if(*line >= 'A' && *line <= 'Z')
         *token++=*line;
      else if(*line >= '0' && *line <= '9')
         *token++=*line;
      else if(*line=='_' || *line=='.' || *line=='$' || *line==':')
         *token++=*line;
      else
      {
         *token=0;
         trim(retval);
         return line;
      }
      line++;
   }
   trim(retval);
   *token=0;
   return line;
}

// Scan for FOR statement
char *cMcore::scan_for(char *line,std::vector<std::string> *_name,std::vector<cMcoreRange> *_range)
{
   char name[MAX_LINE];
   char item[MAX_LINE];
   char temp[MAX_LINE];
   char *p2;
   int count;
   char *token;
   token=temp;
   *token=0;
   line=skipWS(line);
   if(*line=='(')
   {
      line++;
      line=scan_name(line,name);
      line=skipWS(line);
      if(*line != '=')
         error(cMcore::M_currLine,"syntax error");
      line++;
      count=1;
      while(*line)
      {
         if(*line==')')
         {
            count--;
            if(count==0)
            {
               *token=0;
               break;
            }
         }
         else if(*line=='(')
            count++;
         *token=*line;
         line++;
         token++;
      }
      if(*line==0)
         error(cMcore::M_currLine,"syntax error");
      line++;
      token=temp;
      trim(token);
      if (token[0] == '$')
      {
         cMcoreRange range;
         range.m_item.push_back(std::string("0"));
         range.m_type=cMcoreRange::eMcoreRangeTypeSingle;
         range.m_isParm = true;
         _range->push_back(range);
         _name->push_back(std::string(name));
      }
      else if(strstr(token,":"))
      {
         cMcoreRange range;
         strcat(token," ");
         p2=token;
         p2=scan_item(p2,item,':');
         while(p2)
         {
            range.m_item.push_back(std::string(item));
            p2=scan_item(p2,item,':');
         }
         range.m_type=cMcoreRange::eMcoreRangeTypeRange;
         _range->push_back(range);
         _name->push_back(std::string(name));
      }
      else
      {
         error(cMcore::M_currLine,"syntax error");
      }
      return line;
   }
   else
   {
      error(cMcore::M_currLine,"syntax error");
      return 0;
   }
}

// Scan the indexing section of a memory reference term
char *cMcore::scan_array(char *line,std::vector<cMcoreRange> *_range,
                        std::vector<std::string> *_forName,std::vector<cMcoreRange> *_forRange)
{
   char item[MAX_LINE];
   char temp[MAX_LINE];
   char *p2;
   int count;
   int i;
   char *token;
   token=temp;
   *token=0;
   line=skipWS(line);
   if(*line=='[')
   {
      line++;
      count=1;
      while(*line)
      {
         if(*line==']')
         {
            count--;
            if(count==0)
            {
               *token=0;
               break;
            }
         }
         else if(*line=='[')
            count++;
         *token=*line;
         line++;
         token++;
      }
      if(*line==0)
         error(cMcore::M_currLine,"syntax error");
      line++;

      token=temp;
      trim(token);

      if(_forName)
      {
         for(i=0;i < (int)_forName->size();i++)
         {
            if(strcmp(token,_forName->at(i).c_str())==0)
               break;
         }
      }
      if( _forName && i < (int)_forName->size())
      {
         _range->push_back(_forRange->at(i)); 
         _range->at(_range->size()-1).m_forIndex=i;
      }
      else if(token[0]=='*')
      {
         // This is a broadcast 
         cMcoreRange range;
         range.m_item.push_back(std::string("0"));
         range.m_item.push_back(std::string("1"));
         range.m_item.push_back(std::string("0"));
         range.m_type=cMcoreRange::eMcoreRangeTypeWild;
         _range->push_back(range);
      }
      else if (token[0] == '$')
      {
         // This range is to substituted by variable parameter
         cMcoreRange range;
         range.m_item.push_back(std::string("0"));
         range.m_type=cMcoreRange::eMcoreRangeTypeSingle;
         range.m_isParm = true;
         _range->push_back(range);
      }
      else if(strstr(token,":"))
      {
         // This is a range
         cMcoreRange range;
         strcat(token," ");
         p2=token;
         p2=scan_item(p2,item,':');
         while(p2)
         {
            range.m_item.push_back(std::string(item));
            p2=scan_item(p2,item,':');
         }
         range.m_type=cMcoreRange::eMcoreRangeTypeRange;
         _range->push_back(range);
      }
      else
      {
         // This is a single index range
         cMcoreRange range;
         range.m_item.push_back(std::string(token));
         range.m_type=cMcoreRange::eMcoreRangeTypeSingle;
         _range->push_back(range);
      }
      return line;
   }
   else
      return 0;
}

// Scan a item in a range definition
char *cMcore::scan_item(char *line,char *item,char seperator)
{
   int count=0;
   char *retval=item;
   *item=0;
   if(*line==0)
      return 0;
   while(*line)
   {
      if(*line=='(')
         count++;
      else if(*line==')')
         count--;
      if(*line==seperator && count==0)
      {
         trim(retval);
         return line+1;
      }
      item[0]=*line;
      item[1]=0;
      item++;
      line++;
   }
   trim(retval);
   return line;
}

// Decode a memory variable definition
char *cMcore::scan_define(FILE *out,char *line)
{
   int var;
   char *varLine;
   cMcoreTerm term;
   char token[MAX_LINE];
   line=scan_name(line,token);

   cMcoreTerm::decodeVarName(token,&var);
   if (var >= 0)
   {
      // This is a define for source
      term.m_isSource = true;
   }
   else
      error(cMcore::M_currLine, "Invalid MCORE variable");     
   if(var < 0 || var >= ((DP_TEMPLATE_MAX/2)-1))
      error(cMcore::M_currLine, "Invalid MCORE variable");     

   line=skipWS(line);
   if (memcmp(line, ":=", 2) != 0)
      error(cMcore::M_currLine, "Invalid assignment statement");
   line += 2;
   line = skipWS(line);
   varLine = line;
   line=scan_term(line,&term);
   term.m_var = var;
   term.Validate();
   M_vars[var].set(varLine,term.m_varIndex); // Remember this variable definition...
   fprintf(out,"{");
   term.GenDef(out);
   term.Gen(out,-1,0);
   fprintf(out,"}");
   return line;
}

// Scan and generate an EXE command
char *cMcore::scan_exe(FILE *out,char *line,bool lockstep)
{
   cInstruction *instruction;
   int addr;
   char *funcName;
   const char *vm;
   char func[MAX_LINE];
   char token[MAX_LINE];
   char num_pcore[MAX_LINE];
   std::vector<cMcoreSpecifier> specifier;
   char p0[MAX_LINE];
   char p1[MAX_LINE];
   int attr;
   char num_tid[MAX_LINE];
   char dataModel[MAX_LINE];

   line=scan_name(line,token);
   line=skipWS(line);
   line=scan_specifier(&specifier,line);
   if(!line)
      error(cMcore::M_currLine,"syntax error");
   if(specifier.size()==1)
   {
      fprintf(out,"%s;ZTAM_GREG(0,%d,_task_curr2)=(%s);",
                              s_ztamFifoReady,REG_DP_RUN,(char *)specifier[0].m_v.c_str());
      return line;
   }
   vm=VM_STR;
   funcName=(char *)specifier[0].m_v.c_str();
   sprintf(num_pcore,"((%s)-1)",specifier[1].m_v.c_str());
   if(specifier.size() >= 3)
      sprintf(num_tid,"((%s)-1)",specifier[2].m_v.c_str());
   else
      sprintf(num_tid,"(%d)",TID_MAX-1);
   instruction=cInstruction::GetFunctionBegin(funcName);
   addr=instruction?instruction->m_addr:-1;
   if(addr < 0) 
   {
      assert(MAX_IREGISTER_AUTO_SIZE==2);
      // Extract starting address (bit 31-4) from function address
      sprintf(func,"EXE_FUNC_FIELD((%s))",funcName);
      // Extract auto register field (bit 1-0) from function address
      sprintf(p0,"EXE_P0_FIELD((%s))",funcName);
      sprintf(p1,"EXE_P1_FIELD((%s))",funcName);
      // Eztract data model field (bit 3-2) from function address
      sprintf(dataModel,"EXE_MODEL_FIELD((%s))",funcName);
      fprintf(out,"%s;ZTAM_GREG(0,%d,_task_curr2)=DP_EXE_CMD(%d,%s,%s,%s,%s,%s,%s,%s);",
                              s_ztamFifoReady,REG_DP_RUN,
                              lockstep?1:0,func,num_pcore,vm,p0,p1,num_tid,dataModel);
   }
   else
   {
      //assert(MAX_IREGISTER_AUTO_SIZE==2);
      attr=cInstruction::GetFunctionGlobalAttr(instruction);

      fprintf(out,"%s;ZTAM_GREG(0,%d,_task_curr2)=DP_EXE_CMD(%d,%d,%s,%s,%d,%d,%s,%d);",
                              s_ztamFifoReady,REG_DP_RUN,
                              lockstep?1:0,addr,num_pcore,vm,(attr&1),(attr>>1)&1,num_tid,instruction->m_dataModel);
   }
   return line;
}

// Scan and generate a NOTIFY command
char *cMcore::scan_notify(FILE *out,char *line,bool prio)
{
   std::vector<cMcoreSpecifier> specifier;
   char token[MAX_LINE];
   line=scan_name(line,token);
   line=skipWS(line);
   line=scan_specifier(&specifier,line);
   if(specifier.size() != 2)
      error(cMcore::M_currLine,"Invalid parameters");
   fprintf(out,"ZTAM_GREG(0,%d,0)=((uint32_t)((CallbackFunc)(%s)));",REG_DP_INDICATION_PARM0,specifier[0].m_v.c_str());
   fprintf(out,"ZTAM_GREG(0,%d,0)=(int)(%s);",REG_DP_INDICATION_PARM1,specifier[1].m_v.c_str());
   fprintf(out,"%s;ZTAM_GREG(0,%d,_task_curr2)=(%d+(%d<<3));",s_ztamFifoReady,prio?REG_DP_PRIORITY_RUN:REG_DP_RUN,
                DP_OPCODE_INDICATION,DP_CONDITION_ALL_FLUSH);
   return line;
}

// Scan and generate a PRINT command
char *cMcore::scan_export(char *line)
{
   std::vector<cMcoreSpecifier> specifier;
   char token[MAX_LINE];
   line=scan_name(line,token);
   line=skipWS(line);
   line=scan_specifier(&specifier,line);
   if(specifier.size() != 1)
      error(cMcore::M_currLine,"Invalid export");
   M_export.push_back(specifier[0].m_v.c_str());
   return line;
}

// Scan and generate a PRINT command
char *cMcore::scan_print(FILE *out,char *line)
{
   std::vector<cMcoreSpecifier> specifier;
   char token[MAX_LINE];
   line=scan_name(line,token);
   line=skipWS(line);
   line=scan_specifier(&specifier,line);
   if(specifier.size() != 2)
      error(cMcore::M_currLine,"Invalid parameters");
   fprintf(out,"ZTAM_GREG(0,%d,0)=((int)(%s));",REG_DP_INDICATION_PARM0,specifier[0].m_v.c_str());
   fprintf(out,"ZTAM_GREG(0,%d,0)=(int)(%s);",REG_DP_INDICATION_PARM1,specifier[1].m_v.c_str());
   fprintf(out,"%s;ZTAM_GREG(0,%d,_task_curr2)=(%d+(%d<<3));",s_ztamFifoReady,REG_DP_RUN,
                DP_OPCODE_PRINT,0);
   return line;
}


// Scan and generate a LOG_ON command
char *cMcore::scan_log_on(FILE *out,char *line,bool sync)
{
   char token[MAX_LINE];
   line=scan_name(line,token);
   fprintf(out,"%s;ZTAM_GREG(0,%d,_task_curr2)=(%d+(%d<<3));",s_ztamFifoReady,REG_DP_RUN,
                DP_OPCODE_LOG_ON,DP_CONDITION_ALL_FLUSH);
   return line;
}

// Scan and generate a LOG_OFF command
char *cMcore::scan_log_off(FILE *out,char *line,bool sync)
{
   char token[MAX_LINE];
   line=scan_name(line,token);
   fprintf(out,"%s;ZTAM_GREG(0,%d,_task_curr2)=(%d+(%d<<3));",s_ztamFifoReady,REG_DP_RUN,
                DP_OPCODE_LOG_OFF,DP_CONDITION_ALL_FLUSH);
   return line;
}

// Scan and generate a FLUSH command
char *cMcore::scan_flush(FILE *out,char *line)
{
   std::vector<std::string> specifier;
   char token[MAX_LINE];
   line=scan_name(line,token);
   fprintf(out,"%s;ZTAM_GREG(0,%d,0)=(%d+(%d<<3));",s_ztamFifoReady,REG_DP_RUN,
                DP_OPCODE_NULL,DP_CONDITION_ALL_FLUSH);
   return line;
}

char *cMcore::scan_cast(char *line, char *cast)
{
    char *p = line;
    p = skipWS(p);
    if (*p == '(')
    {
        if (cast[0])
            error(cMcore::M_currLine, "Invalid cast syntax");
        p++;
        p = skipWS(p);
        p = scan_name(p, cast);
        if (!cast[0])
            error(cMcore::M_currLine, "Invalid cast syntax");
        p = skipWS(p);
        if (*p != ')')
            error(cMcore::M_currLine, "Invalid cast syntax");
        p++;
        p = skipWS(p);
        return p;
    }
    else
        return line;
}

// Scan a memory reference term
char *cMcore::scan_term(char *line,cMcoreTerm *term)
{
   char *p;
   int i;
   char token[MAX_LINE];
   char cast[MAX_LINE];
   line=skipWS(line);

   if (line[0] == '$')
   {
      // This is a MCORE variable
      line=scan_name(line,token);
      term->m_name=token;
      line=skipWS(line);
      if (line[0] == '[')
      {
         line = scan_array(line, &term->m_varParameter, 0, 0);
         if (!line)
            error(cMcore::M_currLine, "syntax error");
         for (i = 0; i < (int)term->m_varParameter.size();i++)
            term->m_varParameter[i].validate(0,0);
         line=skipWS(line);
      }
      return line;
   }

   // Seach for memory space name
   
   cast[0] = 0;
   line=scan_cast(line,cast);
   line=scan_scoped_name(line,token);

   if(strstr(token,"."))
   {
      // This is a global variable reference...
      term->m_name="";
      term->m_funcName=token;
      line=skipWS(line);
      return line;
   }

   term->m_repeat = false;
   term->m_stream = false;

   for (;;)
   {
       if (strcasecmp(token, TOKEN_REPEAT) == 0)
       {
           if (term->m_repeat)
               error(cMcore::M_currLine, "Multiple REPEAT");
           term->m_repeat = true;
           line = scan_cast(line, cast);
           line = scan_name(line, token);
       }
       else if(strcasecmp(token, TOKEN_PAD) == 0)
       {
          line = skipWS(line);
          if(*line=='(')
             line = scan_specifier(&term->m_pad,line);
          else
             error(cMcore::M_currLine, "Invalid SCATTER specifier");             
          line = scan_cast(line, cast);
          line = scan_name(line, token);
       }
       else if(strcasecmp(token,TOKEN_SYNC)==0)
       {
           term->m_sync=true;
           line = scan_cast(line, cast);
           line = scan_name(line, token);
       }
       else if (strcasecmp(token, TOKEN_SCATTER) == 0)
       {
          if(term->m_scatter.size() > 0)
             error(cMcore::M_currLine, "Multiple SCATTER");
          line = skipWS(line);
          if(*line=='(')
             line = scan_specifier(&term->m_scatter,line);
          else
             error(cMcore::M_currLine, "Invalid SCATTER specifier");             
          line = scan_cast(line, cast);
          line = scan_name(line, token);
       }
       else
           break;
   }

   while(strcasecmp(token,TOKEN_FOR)==0)
   {
      line=skipWS(line);
      line=scan_for(line,&term->m_forVariable,&term->m_forRange);
      line=scan_cast(line, cast);
      line=scan_name(line,token);
   }
   if(!line)
      error(cMcore::M_currLine,"Syntax error");
   if (strcasecmp(token, TOKEN_ALL_HALF) == 0)
   {
       term->m_name = TOKEN_ALL_HALF;
       line = skipWS(line);
       line = scan_specifier(&term->m_specifier,line);
       if (!line)
           error(cMcore::M_currLine, "syntax error");
       return line;
   }
   else if(strcasecmp(token,TOKEN_ALL_INT)==0)
   {
      term->m_name=TOKEN_ALL_INT;
      line=skipWS(line);
      line=scan_specifier(&term->m_specifier,line);
      if(!line)
         error(cMcore::M_currLine,"syntax error");
      return line;
   }
   else if (strcasecmp(token, TOKEN_ALL_SHORT) == 0)
   {
       term->m_name = TOKEN_ALL_SHORT;
       line = skipWS(line);
       line = scan_specifier(&term->m_specifier,line);
       if (!line)
           error(cMcore::M_currLine, "syntax error");
       return line;
   }
   term->m_name=token;
   term->m_cast=cast;
   line=skipWS(line);
   line=scan_specifier(&term->m_specifier,line);
   line=skipWS(line);
   // Scan memory indexing
   for(;;)
   {
      p=scan_array(line,&term->m_index,&term->m_forVariable,&term->m_forRange);
      if(!p)
         break;
      line=p;
   }
   line=skipWS(line);

   // Scan for thread section if it's there
   if(*line=='.' && memcmp(&line[1],TOKEN_THREAD,strlen(TOKEN_THREAD))==0)
   {
      line += 1+strlen(TOKEN_THREAD);
      line=skipWS(line);     
      line=scan_specifier(&term->m_thread,line);
      line=skipWS(line);
      for(;;)
      {
          p=scan_array(line,&term->m_index,&term->m_forVariable,&term->m_forRange);
          if(!p)
              break;
          line=p;
      }
   }

   if(*line=='.')
   {
      line++;
      line=scan_scoped_name(line,token);
      if(!line)
         error(cMcore::M_currLine,"syntax error");
      term->m_funcName=token;
      line=skipWS(line);

      if(*line=='(')
      {
         line = scan_specifier(&term->m_parmSpecifier,line);
         line=skipWS(line);
      }

      // Scan parameter indexing section
      if(*line=='[')
      {
         line=skipWS(line);
         for(;;)
         {
            p=scan_array(line,&term->m_parm,&term->m_forVariable,&term->m_forRange);
            if(!p)
               break;
            line=p;
         }
      }
   }
   line=skipWS(line);
   return line;
}

// Retrieve the next token that can be a symbolic name
char *cMcore::get_token(char *line,char *token)
{
   while(*line)
   {
      if(*line >= 'a' && *line <= 'z')
         *token++=*line;
      else if(*line >= 'A' && *line <= 'Z')
         *token++=*line;
      else if(*line >= '0' && *line <= '9')
         *token++=*line;
      else if(*line=='_' || *line=='.')
         *token++=*line;
      else
      {
         *token=0;
         return line;
      }
      line++;
   }
   *token=0;
   return line;
}

// Perform macro expansion on defines
char *cMcore::substDefine(char *line,char *outLine)
{
   char token[MAX_LINE];
   cMcoreDefine *def;
   outLine[0]=0;
   for(;;)
   {
      if(!line[0])
         return line;
      line=get_token(line,token);
      if(token[0]==0)
      {
         token[0]=*line++;
         token[1]=0;
         strcat(outLine,token);
      }
      else
      {
         def=cMcoreDefine::find(token);
         if(def)
         {
            std::vector<cMcoreSpecifier> specifier;
            char temp[MAX_LINE];
            line=scan_specifier(&specifier,line);
            genDefine(def,&specifier,temp);
            strcat(outLine,temp);
            if(!line)
               error(cMcore::M_currLine,"syntax error");
         }
         else
            strcat(outLine,token);
      }
   }
}

// Generate macro expansion based on input parameter
char *cMcore::genDefine(cMcoreDefine *def,std::vector<cMcoreSpecifier> *specifier,char *outLine)
{
   char token[MAX_LINE];
   char *line;
   int i;
   outLine[0]=0;
   line=(char *)def->m_define.c_str();
   if(specifier->size() != def->m_specifier.size())
      error(cMcore::M_currLine,"Invalid parameters for variable");
   for(;;)
   {
      if(!line[0])
         return 0;
      line=get_token(line,token);
      if(token[0]==0)
      {
         token[0]=*line++;
         token[1]=0;
         strcat(outLine,token);
      }
      else
      {
         for(i=0;i < (int)def->m_specifier.size();i++)
         {
            if(def->m_specifier[i]==token)
            {
               strcat(outLine,specifier->at(i).m_v.c_str());
               break;
            }
         }
         if(i >= (int)def->m_specifier.size())
            strcat(outLine,token);
       }
   }
}

char *cMcore::scan_transfer(FILE *out,char *line)
{
   bool prio=false;
   char token[MAX_LINE];
   char c1[MAX_LINE],c2[MAX_LINE],c3[MAX_LINE];
   cMcoreTerm left,right;
   cMcoreTerm leftScratch,rightScratch;
   std::vector<cMcoreSpecifier> stream_id;
   std::string forkCount;
   int waitCondition;

   line=scan_term(line,&left);

   line=skipWS(line);
   if(memcmp(line,"<<=",3) == 0)
   {
      prio=true;
      line+=3;
   }
   else if(memcmp(line,"<=",2) == 0)
   {
      prio=false;
      line+=2;
   }
   else
      error(cMcore::M_currLine,"Syntax error");
   scan_name(line, token);
   if (strcasecmp(token,TOKEN_STREAM)==0)
   {
      line=scan_name(line,token);
      line = skipWS(line);
      if(*line=='(')
      {
         line = scan_specifier(&stream_id,line);
         if(stream_id.size() != 1 )
         {
            error(cMcore::M_currLine, "Invalid PROC specifier");     
         }
      }
      else
         error(cMcore::M_currLine, "Invalid PROC specifier");     
      line=skipWS(line);
      if(memcmp(line,"<=",2) != 0)
         error(cMcore::M_currLine,"Syntax error");
      line+=2;
   }

   line=scan_term(line,&right);

   left.Validate();
   right.Validate();     

   if(left.m_id==cMcoreTerm::eMcoreTermTypeGlobalRef)
   {
      gen_global_assign(out,left,right);
      return line;
   }
   forkCount=left.m_forkCount;
   waitCondition=0;
   if(right.m_sync)
   {
      if(right.m_id==cMcoreTerm::eMcoreTermTypePCORE)
         waitCondition=DP_CONDITION_REGISTER_FLUSH;
      else if(right.m_id==cMcoreTerm::eMcoreTermTypeSRAM)
         waitCondition=DP_CONDITION_SRAM_FLUSH;
      else if(right.m_id==cMcoreTerm::eMcoreTermTypeDDR)
         waitCondition=DP_CONDITION_DDR_FLUSH;
   }
   sprintf(c1,"((DP_CONDITION_SRAM_FLUSH)|%d)",waitCondition);
   sprintf(c2,"(DP_CONDITION_SRAM_FLUSH)");
   sprintf(c3,"(%d)",waitCondition);
   if((right.m_scatter.size() > 0 && !right.CanScatter()) && left.m_scatter.size()==0)
   {
      // Scatter transfer. Source is scattered and destination is not
      rightScratch.ScratchCreate(&right,(char *)left.m_cast.c_str(),(char *)right.m_scatter[0].m_v.c_str(),forkCount);
      rightScratch.Validate();
      rightScratch.ScratchReorder(&right, true);
      gen_transfer(out,rightScratch,right,c1,&stream_id,prio);
      rightScratch.ScratchReorder(0,false);
      gen_transfer(out,left,rightScratch,c2,0,prio);
   }
   else if(right.m_scatter.size()==0 && (left.m_scatter.size() > 0 && !left.CanScatter()))
   {
      // Scatter transfer. Destination is scattered and source is not
	   leftScratch.ScratchCreate(&left, (char *)right.m_cast.c_str(), (char *)left.m_scatter[0].m_v.c_str(),forkCount);
      leftScratch.Validate();
      leftScratch.ScratchReorder(0,false);
      gen_transfer(out,leftScratch,right,c1,&stream_id,prio);
      leftScratch.ScratchReorder(&left,true);
      gen_transfer(out,left,leftScratch,c2,0,prio);

   }
   else if((right.m_scatter.size() > 0 && !right.CanScatter()) && 
           (left.m_scatter.size()>0 && !left.CanScatter()))
   {
      // Scatter transfer. Source and destination are scattered
	   leftScratch.ScratchCreate(&left, 0, (char *)right.m_scatter[0].m_v.c_str(),forkCount);
      leftScratch.Validate();
	   leftScratch.ScratchReorder(&left, true);
	   rightScratch.ScratchCreate(&right, 0, (char *)right.m_scatter[0].m_v.c_str(),forkCount);
      rightScratch.Validate();
      rightScratch.ScratchReorder(&right,true);
      gen_transfer(out,rightScratch,right,c1,&stream_id,prio);
      gen_transfer(out,left,leftScratch,c2,0,prio);
   }
   else
      gen_transfer(out,left,right,c3,&stream_id,prio);
   return line;
}

void cMcore::gen_global_assign(FILE *out,cMcoreTerm &left,cMcoreTerm &right)
{
   char temp[MAX_LINE];
   char *funcName,*parmName;
   cIdentifier *id;
   int index;
   if(right.m_id != cMcoreTerm::eMcoreTermTypeALLInt)
      error(cMcore::M_currLine,"Syntax error");      
   strcpy(temp,left.m_funcName.c_str());
   funcName=strtok(temp,".");
   parmName=strtok(0,".");
   if(!funcName || !parmName)
      error(cMcore::M_currLine,"Syntax error");      
   id=cIdentifier::lookupParm(root,funcName,parmName);
   if(!id)
      error(cMcore::M_currLine,"Undefined variable");      
   if(!id->isKindOf(cIdentifierFixed::getCLID()))
      error(cMcore::M_currLine,"Invalid global reference");
   index=CAST(cIdentifierFixed,id)->m_persistentIndex; 
   if(index < 0)     
      error(cMcore::M_currLine,"Invalid global reference");
   fprintf(out,"ZTAM_GREG(0,%d,0)=(%s);",REG_DP_INDICATION_PARM0+index,right.m_specifier[0].m_v.c_str());
}

// Decode a transfer command
void cMcore::gen_transfer(FILE *out,cMcoreTerm &left,cMcoreTerm &right,char *flushCondition,std::vector<cMcoreSpecifier> *stream_id,bool priority)
{
   const char *proc_id;

   left.m_isSource = false;
   right.m_isSource = true;

   fprintf(out,"{");

   fprintf(out,"{");
   left.GenDef(out);
   left.Gen(out,-1,0);
   fprintf(out,"}");

   fprintf(out,"{");
   right.GenDef(out);
   right.Gen(out,-1,0);
   fprintf(out,"}");

   // Check if this transfer requires data conversion
   if (right.m_id != cMcoreTerm::eMcoreTermTypeVar && 
       left.m_id != cMcoreTerm::eMcoreTermTypeVar)
   {
      // No dynamic variable. Can check at compilation time...
      if (left.m_id != cMcoreTerm::eMcoreTermTypePCORE && right.m_id != cMcoreTerm::eMcoreTermTypePCORE)
      {
      }
   }
   if(stream_id && stream_id->size() > 0)
   {
      proc_id=(const char *)(*stream_id)[0].m_v.c_str();
   }
   else
   {
      proc_id="-1";
   }

   // Issue DP_TRANSFER_COMMAND

   fprintf(out, "%s;ZTAM_GREG(0,%d,_task_curr2)=DP_TRANSFER_CMD(%d,_task_curr2,%d,%d,%d,%d,%d,%d,((%s)>=0)?1:0,(%s)&(%d),",s_ztamFifoReady,
            priority?REG_DP_PRIORITY_RUN:REG_DP_RUN, DP_OPCODE_TRANSFER_SINGLE,0,0,0,0,0,0,proc_id,proc_id,SPU_NUM_STREAM-1);

   fprintf(out,"%s);",flushCondition);

   fprintf(out,"}");
}

// Decode and generate code for a MCORE instruction
char *cMcore::decode(char *line,FILE *out,int *cmd)
{
   char *p;
   char token[MAX_LINE];
   line=skipWS(line);

   p=scan_name(line,token);
   if(!p)
      error(cMcore::M_currLine,"syntax error");
   if(strcasecmp(token,TOKEN_NOP)==0)
   {
      *cmd=CMD_NOP;
      return p; 
   }
   else if(strcasecmp(token,TOKEN_EXPORT)==0)
   {
      *cmd=CMD_EXPORT;
      return scan_export(line);
   }
   else if(strcasecmp(token,TOKEN_EXE)==0)
   {
      *cmd=CMD_EXE;
      return scan_exe(out,line,false);
   }
   else if(strcasecmp(token,TOKEN_LOCKSTEP_EXE)==0)
   {
      *cmd=CMD_EXE;
      return scan_exe(out,line,true);
   }
   if(strcasecmp(token,TOKEN_NOTIFY)==0 || strcasecmp(token,TOKEN_NOTIFY_PRIO)==0)
   {
      *cmd=CMD_NOTIFY;
      return scan_notify(out,line,strcasecmp(token,TOKEN_NOTIFY_PRIO)==0);
   }
   if(strcasecmp(token,TOKEN_PRINT)==0)
   {
      *cmd=CMD_PRINT;
      return scan_print(out,line);
   }
   if(strcasecmp(token,TOKEN_LOG_ON)==0)
   {
      *cmd=CMD_LOG_ON;
      return scan_log_on(out,line,false);
   }
   if(strcasecmp(token,TOKEN_LOG_OFF)==0)
   {
      *cmd=CMD_LOG_OFF;
      return scan_log_off(out,line,false);
   }
   if(strcasecmp(token,TOKEN_FLUSH)==0)
   {
      *cmd=CMD_NOP;
      return scan_flush(out,line);
   }
   if(strstr(line,":="))
   {
      *cmd=CMD_ASSIGN;
      return scan_define(out,line);
   }
   if(strstr(line,"<=") || strstr(line,"<<="))
   {
      *cmd=CMD_TRANSFER;
      return scan_transfer(out,line);
   }
   error(cMcore::M_currLine,"Syntax error");
   *cmd=-1;
   return 0;
}

// Perform preprocessing.
// Remove comments
bool cMcore::preprocess(char *line)
{
   char *p2,*p3,*p4;
   for(;;)
   {
      p2=strstr(line,"/*");
      if(p2)
      {
         p3=strstr(p2,"*/");
         if(!p3)
            error(cMcore::M_currLine,"Invalid comment");
         for(p4=p2;p4 != (p3+2);p4++)
            *p4=' ';
      }
      else
         break;
   }
   p2=strstr(line,"//");
   if(p2)
      *p2=0;
   return true;
}

// Replace some keywords such as PCORE function address
bool cMcore::postProcessLine(char *line,FILE *out)
{
   cInstruction *instruction;
   char token[MAX_LINE];
   char line2[MAX_LINE];
   char *p=line;
   char *p2=line2;
   bool flag=false;
   while(*p)
   {
      if(*p=='$')
      {
         p=scan_name(p,token);
         assert(token[0]);
         instruction=cInstruction::GetFunctionBegin(token+1);
         if(instruction)
            sprintf(p2,"%d",instruction->GetEncodedFunctionAddress());
         else
            sprintf(p2,"%s",token);
         p2+=strlen(p2);
         flag=true;
      }
      else
         *p2++=*p++;
   }
   *p2=0;
   if(flag)
      strcpy(line,line2);
   return true;
}

// Process a MCORE instruction line.
// Instructions are seperated by ',' for concurrent instructions
// Group of instructions are termintate with ';'
bool cMcore::processLine(char *line,FILE *out)
{
   int count;
   int cmd;
   char *p;
   char temp[MAX_LINE];
   static char currLine[MAX_LINE]={0};
   if(line[strlen(line)-1] != '\n')
      strcat(line,"\n");
   p=line;
   count=0;
   while(*p != '\n')
   {
      if(*p=='>')
      {
         p++;
         preprocess(p);
         trim(p);
         strcat(currLine,p);
         if(currLine[strlen(currLine)-1]==';')
         {
            substDefine(currLine,temp);
            p=temp;
            for(;;)
            {
               p=decode(p,out,&cmd);
               p=skipWS(p);
               if(*p == ',')
               {
                  count++;
                  if(cmd != CMD_TRANSFER && cmd != CMD_NOP)
                     error(-1,"Only transfer commands can be concurrent");
                  M_beginBlock=false;
               }
               else if(*p==';')
               {
                  if(count > 0)
                  {
                     if(cmd != CMD_TRANSFER && cmd != CMD_NOP)
                        error(-1,"Only transfer commands can be concurrent");
                  }
                  count=0;
                  M_beginBlock=true;
               }
               else
                  error(cMcore::M_currLine,"Syntax error");
               p++;
               p=skipWS(p);
               if(*p==0 || *p=='\r' || *p=='\n')
                  break;
            }
            currLine[0]=0;
         }
         fprintf(out,"\n");
         return true;
      }
      if(!isWS(*p))
         break;
      p++;
   }
   return false;
}

// Entry point for MCORE instruction processing
// MCORE instructions begin with '>' and terminated with ';'
// Instructions that are concurrent are seperated with ','
int cMcore::Process(char *inFile,char *outFile)
{
   FILE *in;
   FILE *out;
   char line[MAX_LINE+1];
   in=fopen(inFile,"r");
   M_currLine=0;
   if(!in)
      error(cMcore::M_currLine,"Cannot open input M-file");
   out=fopen(outFile,"w+");
   if(!out)
      error(cMcore::M_currLine,"Cannot open output M-file");
   M_beginBlock=true;
   while(fgets(line,MAX_LINE,in) != 0)
   {
      M_currLine++;
      if(strlen(line) >= MAX_LINE)
         error(cMcore::M_currLine,"input file line too long");
      if(!cMcore::postProcessLine(line,out))
         error(cMcore::M_currLine,"Error parsing .m file");
      if(!cMcore::processLine(line,out))
         fputs(line,out);
   }
   fclose(in);
   fclose(out);
   return 0;
}

int cMcore::GenExport(FILE *fp)
{
   fprintf(fp,".EXPORT BEGIN\n");
   for(int i=0;i < (int)M_export.size();i++) {
      fprintf(fp,"%s\n",M_export[i].c_str());
   }
   fprintf(fp,".EXPORT END\n");
   return 0;
}
