//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
//
// Author: Vuong Nguyen
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

#ifndef _MCORE_H_
#define _MCORE_H_

#include <vector>

#define MAX_MCORE_DEFINE   100

class cMcoreRange;

class cMcoreSpecifier
{
public:
   cMcoreSpecifier(const char *_v=0,const char *_v2=0,bool plus=false);
   cMcoreSpecifier(const cMcoreSpecifier &other);
   ~cMcoreSpecifier();
   std::string m_v;
   std::string m_v2;
   bool m_plus;
};

class cMcoreTerm;
class cMcoreVariable
{
public:
   cMcoreVariable();
   ~cMcoreVariable();
   bool IsDeclared() {return m_name.length()>0;}
   bool IsDefined() {return m_line.length()>0;}
   void Declare(char *name,int depth);
   void Clear();
   std::string getLine(cMcoreRange &range);
   int getParmIndex() { return m_parmIndex; }
public:
   std::string m_name;
   int m_depth;
   int m_parmIndex;
   std::string m_line;
   cMcoreTerm *m_term;
};

// Class to define a range (For example SRAM[0:2:100])
class cMcoreRange
{
public:
   enum eMcoreRangeType
   {
   eMcoreRangeTypeRange, // This is a range
   eMcoreRangeTypeSingle, // This is a single element
   eMcoreRangeTypeWild // Wild card. Means broadcast
   };
public:
   cMcoreRange();
   ~cMcoreRange();
   bool validate(const char *range_min,const char *range_max);
   std::vector<std::string> m_item;
   eMcoreRangeType m_type;
   int m_forIndex;
   int m_isParm;
};

// Class to define a destination or source term.
// For example: PCORE[0][0:1:2][2:1:5]
class cMcoreTerm
{
public:
   enum eMcoreTermType
   {
   eMcoreTermTypePCORE, // Reference PCORE
   eMcoreTermTypeSRAM,  // Reference SRAM
   eMcoreTermTypeDDR,   // Reference DDR
   eMcoreTermTypeALLInt, // Reference constants
   eMcoreTermTypeVar, // Saved variable
   eMcoreTermTypeGlobalRef, // Reference global variable
   eMcoreTermTypeSPU, // Program SPU unit...
   eMcoreTermTypePcoreProg // Program PCORE code memory
   };
public:
   cMcoreTerm();
   ~cMcoreTerm();
   void Print();
   static bool decodeVarName(char *name,int *var);
   void ScratchCreate(cMcoreTerm *term,char *cast,char *scratchAddr,std::string &forkCount);
   void ScratchReorder(cMcoreTerm *term,bool concurrent);
   int GetParmRange();
   int GetNumDim(cIdentifier *id);
   std::string GetDim(cIdentifier *id,int index);
   int GetDim();
   cMcoreTerm *GetDef();
   bool CanScatter();
   std::string GetDimSize(cIdentifier *id,int index);
   int GenDef(FILE *out);
   int GenVariableTensor(FILE *out, int _parm, cMcoreRange *_parmRange);
   int GenConstantTensor(FILE *out, int _parm, cMcoreRange *_parmRange);
   int GenPcoreTensor(FILE *out, int _parm, cMcoreRange *_parmRange,char *maskStr,int &maskMode);
   int GenSpuTensor(FILE *out, int _parm, cMcoreRange *_parmRange);
   int GenPcoreProgTensor(FILE *out, int _parm, cMcoreRange *_parmRange);
   int GenSramDDRTensor(FILE *out, int _parm, cMcoreRange *_parmRange);
   int Gen(FILE *out,int _parm,cMcoreRange *_parmRange);
   int Validate();
   int getStrideRegisterIndex(int index,int dimSize,bool concurrent);
   void GEN(FILE *fp, int p1, int p2, int p3, char *s);
   std::string m_name;
   std::vector<cMcoreSpecifier> m_concurrent;
   std::vector<cMcoreSpecifier> m_pad;
   std::string m_dtype;
   std::vector<std::string> m_forVariable;
   std::vector<cMcoreRange> m_forRange;
   std::vector<cMcoreSpecifier> m_specifier;
   std::vector<std::string> m_specifierQualifier;
   std::vector<cMcoreRange> m_index;
   std::vector<cMcoreSpecifier> m_thread;
   std::string m_funcName;
   std::vector<cMcoreRange> m_parm;
   std::vector<cMcoreSpecifier> m_parmSpecifier;
   eMcoreTermType m_id;
   std::string m_forkCount;
   std::vector<std::string> m_dim;
   cIdentifier *m_identifier;
   std::vector<cMcoreRange> m_varParameter;
   int m_varIndex;
   int m_maxNumThreads;
   int m_dataModel;
   bool m_repeat;
   bool m_latest;
   bool m_stream;
   std::string m_datatype;
   int m_pcoreDim;
   int m_pcoreSize;
   int m_var;
   bool m_isSource;
   int m_spuCount;
   std::vector<cMcoreSpecifier> m_remap;
};

class cMcoreTerm;
class cMcore
{
public:
   static int Process(char *inFile,char *outFile);
   static int GenExport(FILE *fp);
   static bool postProcessLine(char *line,FILE *out);
   static bool processLine(char *line,FILE *out);
   static bool preprocess(char *line);
   static char *substDefine(char *line,char *outLine);
   static char *get_token(char *line,char *token);
   static void gen_transfer(FILE *out,cMcoreTerm &left,cMcoreTerm &right,char *flushCondition,std::vector<cMcoreSpecifier> *stream_id);
   static void gen_global_assign(FILE *out,cMcoreTerm &left,cMcoreTerm &right);
   static char *decode(char *line,FILE *out,int *cmd);
   static char *scan_array(char *line,std::vector<cMcoreRange> *_range,
                           std::vector<std::string> *_forName,std::vector<cMcoreRange> *_forRange);
   static char *scan_for(char *line,std::vector<std::string> *_name,std::vector<cMcoreRange> *_range);
   static char *scan_dtype(char *line, char *cast);
   static char *scan_remap(char *line, std::vector<cMcoreSpecifier> *remap);
   static char *scan_name(char *line,char *token);
   static char *scan_scoped_name(char *line,char *token);
   static char *scan_item(char *line,char *item,char seperator);
   static char *scan(char *line,char *delimiter,char *token);
   static char *scan_term(char *line,cMcoreTerm *term);
   static char *scan_exe(FILE *out,char *line,bool lockstep);
   static char *scan_barrier(FILE *out,char *line);
   static char *scan_notify(FILE *out,char *line);
   static char *scan_print(FILE *out,char *line);
   static char *scan_log_on(FILE *out,char *line,bool sync);
   static char *scan_log_off(FILE *out,char *line,bool sync);
   static char *scan_export(char *line);
   static char *scan_include(char *line);
   static char *scan_define(FILE *out,char *line);
   static char *scan_var(FILE *out,char *line);
   static char *scan_transfer(FILE *out,char *line);
   static char *scan_specifier(std::vector<cMcoreSpecifier> *_specifier,char *line,int _level=0);
   static char *skipWS(char *line);
private:
   static bool M_beginBlock;
public:
   static int M_currLine;
   static int M_currDepth;
   static cMcoreVariable M_vars[DP_TEMPLATE_MAX];
   static std::vector<std::string> M_export;
};

#endif
