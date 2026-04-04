 
//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]c
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

//
// This file parse FPU commands from .m files
//

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string>
#include <vector>
#include <assert.h>
#include "../base/zta.h"
#include "ast.h"
#include "ident.h"
#include "instruction.h"
#include "mcore.h"

// Different FPU instruction end mode

#define END_DONE  ';'
#define END_CONT  '.'
#define END_CONT_FAST ':'
#define END_DYNAMIC '_'

//
// Scan a FPU command
//
// FPU command have this syntax
//
//    FPU.XXX(p1=v1,p2=v2,...); // End of sequence of FPU operations
//
//    FPU.XXX(p1=v1,p2=v2,...)...; // FPU operation is part of a sequence of commands, more to follow
//
//    FPU.XXX(p1=v1,p2=v2,...):::; // FPU operation is part of a sequence of commands, more to follow, 
//                                    but dont wait for this operation to be completed before moving to next one.

static char *parse(char *line,
                    char &end,
                    std::string &opcode,
                    std::vector<std::string> &names,
                    std::vector<std::string> &parms,
                    std::vector<std::string> &types,
                    std::vector<bool> &isPointers)
{
   char name[MAX_LINE];
   char temp[MAX_LINE];
   char type[MAX_LINE];
   int count;
   bool isPointer;
   char *p,*p2,*p3;

   line = cMcore::skipWS(line);
   line = cMcore::scan_name(line, name);
   opcode = name;
   line = cMcore::skipWS(line);
   p = temp;
   if (*line != '(')
      error(cMcore::M_currLine, "syntax error");

   line++;
   count = 1;
   *p = 0;
   while (*line) {
      if (*line == ')') {
         count--;
         if (count == 0) {
            *p = 0;
            break;
         }
      } else if (*line == '(')
         count++;
      *p = *line;
      line++;
      p++;
   }
   if (*line == 0)
      error(cMcore::M_currLine, "syntax error");

   // We have the content within the bracket, now extract the parameters
   
   line++;
   line = cMcore::skipWS(line);
   
   p = temp;
   
   while(p) {
      p = cMcore::skipWS(p);
      if(*p==0)
         break;
      p = cMcore::scan_name(p,name);
      p = cMcore::skipWS(p);
      if(*p != '=')
         error(cMcore::M_currLine, "syntax error");
      p++;
      p = cMcore::skipWS(p);
      p2 = strstr(p,",");
      if(p2)
         *p2 = 0;

      if(*p=='(') {
         p++;
         strcpy(type,p);
         p3 = strstr(type,")");
         if(!p3)
            error(cMcore::M_currLine, "syntax error");
         *p3 = 0;
         p = p3+1;
         if(strstr(type,"*"))
            isPointer=true;
         else
            isPointer=false;
         strtok(type," *");
      } else {
         type[0] = 0;
         isPointer=false;
      }
      isPointers.push_back(isPointer);
      types.push_back(cMcore::skipWS(type));
      names.push_back(cMcore::skipWS(name));
      parms.push_back(cMcore::skipWS(p));
      p = p2?(p2+1):0;
   }

   //
   // Check the termination condition
   // 
   if(*line==';' || *line==0)
      end = END_DONE; // This command terminates a sequence of commands or this is a single command sequence
   else if(*line=='.')
      end = END_CONT; // This command is part of a sequence, there are more commands to follow.
   else if(*line==':')
      end = END_CONT_FAST; // This command is part of a sequence, more to follow, but dont wait 
                           // for this command to be completed before moving to next instruction.
   else if(*line=='_')
      end = END_DYNAMIC; // Termination condition is dynamic based on variable _end_
   while(*line && *line != ';') {
      line++;
   }
   return line;
} 

//----------------------
// Generate the FPU command execution
//-----------------------

void genEXE(FILE *out,uint32_t opcode,char end) {
   if(end==END_DONE) {
      // This command is the end of a sequence of commands or it is the single command sequence
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=%d;",opcode,REG_FPU_EXE,1);
      fprintf(out,"ZTAM_GREG(0,%d,0)=(%d+(%d<<3));",REG_DP_RUN,DP_OPCODE_FPU_EXE,0);
   }
   else if(end==END_CONT)
      // More command to follow, this command must be completed before moving to next in the sequencce
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=%d;",opcode,REG_FPU_EXE,0);
   else if(end==END_CONT_FAST)
      // More command to follow, dont have to wait for this command to be completed before moving to 
      // next one in the sequence
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=%d;",opcode,REG_FPU_EXE,2);
   else {
      // Termination condition is dynamc based on variable _end_
      // If _end_ = 0 -> Same as END_DONE
      // If _end_ = '.' -> Same as END_CONT
      // If _end_ = ':' -> Same as END_CONT_FAST
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(_end_==0)?1:((_end_=='.')?0:2);",opcode,REG_FPU_EXE);
      fprintf(out,"{if(_end_== 0)ZTAM_GREG(0,%d,0)=(%d+(%d<<3));}",REG_DP_RUN,DP_OPCODE_FPU_EXE,0);
   }
}

//--------------------------
// Generate FPU parameter description
//---------------------------

static void genParm(FILE *out,uint32_t _attr,std::string &type,std::string &parm,bool isPointer) {
   char *e;
   bool _attrDynamic=false;
   bool _isConstant=false;
   bool _isConstantFloat=false;
   float _v=0;
   int v2;

   if(type.length()==0)
      _attr |= FPU_SET_W_FP32;
   else if(strcasecmp(type.c_str(),"bfloat")==0)
      _attr |= FPU_SET_W_BFLOAT; 
   else if(strcasecmp(type.c_str(),"zfloat")==0)
      _attr |= FPU_SET_W_ZFP16; 
   else if(strcasecmp(type.c_str(),"float16")==0)
      _attr |= FPU_SET_W_FP16; 
   else if(strcasecmp(type.c_str(),"float")==0) 
      _attr |= FPU_SET_W_FP32;
   else if(strcasecmp(type.c_str(),"int16")==0) 
      _attr |= FPU_SET_W_INT16;
   else
      _attrDynamic = true;
   if(isPointer) {
      if(!_attrDynamic)
         _attr |= FPU_SET_M_ADDR;
      else
         error(cMcore::M_currLine, "Invalid paramter type.");
      _isConstant = false;
   } else {
      if(!_attrDynamic)
         _attr |= FPU_SET_M_VALUE;
      _v = strtof(parm.c_str(),&e);
      if(e==parm.c_str())
         _isConstant = false;
      else {
         _isConstant = true;
         if(strcasestr(parm.c_str(),".") || strcasestr(parm.c_str(),"e"))
            _isConstantFloat = true;
         else {
            _isConstantFloat = false;
            v2 = (int)_v;
         }
      }
   }

   if(!_isConstant) {
      if(_attrDynamic)
         fprintf(out,"ZTAM_GREG(0x%x|(%s),0x%x,0)=(uint32_t)(%s);",_attr,type.c_str(),REG_FPU_SET,parm.c_str());
      else {
         if(isPointer)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",_attr,REG_FPU_SET,parm.c_str());
         else {
            if(strcasecmp(type.c_str(),"float")==0)
               fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=*((uint32_t *)&(%s));",_attr,REG_FPU_SET,parm.c_str());
            else
               fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",_attr,REG_FPU_SET,parm.c_str());
         }
      }
   } else {
      if(_isConstantFloat) {
         if(_attrDynamic)
            fprintf(out,"ZTAM_GREG(0x%x|(%s),0x%x,0)=0x%x;",_attr,type.c_str(),REG_FPU_SET,*((uint32_t *)&_v));
         else
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0x%x;",_attr,REG_FPU_SET,*((uint32_t *)&_v));
      } else {
         if(_attrDynamic)
            fprintf(out,"ZTAM_GREG(0x%x|(%s),0x%x,0)=%d;",_attr,type.c_str(),REG_FPU_SET,v2);
         else
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=%d;",_attr,REG_FPU_SET,v2);
      }
   }
}

//--------------
// Generate
//   FPU.FMA-> y=a+sum(c*x1[i]*x2[i])
//   FPU.FMA.FLOOR-> y=a+sum(floor(c*x1[i]*x2[i]))
//   FPU.FMA.ABS-> y=a+sum(abs(c*x1[i]*x2[i]))
//---------------

static int scan_fma(
   FILE *out,
   std::string &opcode,
   std::vector<std::string> &names,
   std::vector<std::string> &parms,
   std::vector<std::string> &types,
   std::vector<bool> &isPointers,
   char end) 
{
   uint32_t _attr=0;
   int i;
   bool y_valid=false;
   bool a_valid=false;
   bool x1_valid=false;
   bool x2_valid=false;
   bool c_valid=false;
   uint32_t postProc=0;
   bool vector=false;

   if(strcasestr(opcode.c_str(),"FLOOR")) {
      postProc=FPU_EXE_FLOOR;
   }
   if(strcasestr(opcode.c_str(),"ABS")) {
      postProc+=FPU_EXE_ABS;
   }
   if(strcasestr(opcode.c_str(),TOKEN_FPU_VECTOR)) {
      vector = true;
   }
   for(i=0;i < (int)names.size();i++) {
      if(strcasecmp(names[i].c_str(),"N")==0) {
         if(!vector)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNT,REG_FPU_SET,parms[i].c_str());  
         else
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNTV,REG_FPU_SET,parms[i].c_str());                
      } else {
         if(strcasecmp(names[i].c_str(),"y")==0) {
            _attr = FPU_SET_P_A;
            y_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"a")==0) {
            _attr = FPU_SET_P_C2;
            a_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x1")==0) {
            _attr = FPU_SET_P_X;
            x1_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x2")==0) {
            _attr = FPU_SET_P_Y;
            x2_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"c")==0) {
            _attr = FPU_SET_P_C;
            c_valid = true;
         }
         else
            error(cMcore::M_currLine, "Invalid parameter");
         genParm(out,_attr,types[i],parms[i],isPointers[i]);
      }
   }
   if(!y_valid)
      error(cMcore::M_currLine, "Missing parameter");
   if(!c_valid && !x1_valid && !x2_valid)
      error(cMcore::M_currLine, "Missing parameter");
   fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0;",FPU_SET_W_FP32|FPU_SET_M_VALUE|FPU_SET_P_B,REG_FPU_SET);

   if(!a_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_C2,REG_FPU_SET);
   if(!x1_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0x3f80;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_X,REG_FPU_SET);
   if(!x2_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0x3f80;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_Y,REG_FPU_SET);
   if(!c_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0x3f80;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_C,REG_FPU_SET);

   genEXE(out,FPU_EXE_FMA+postProc,end);
   fprintf(out,"\n");
   return 0;
}

//--------------
// Generate 
//   FPU.MAC       --> y[i] = a+c*x1[i]*x2[i]
//   FPU.MAC.FLOOR --> y[i] = floor(a+c*x1[i]*x2[i])
//   FPU.MAC.ABS   --> y[i] = abs(a+c*x1[i]*x2[i])
//---------------

static int scan_mac(
   FILE *out,
   std::string &opcode,
   std::vector<std::string> &names,
   std::vector<std::string> &parms,
   std::vector<std::string> &types,
   std::vector<bool> &isPointers,
   char end) 
{
   uint32_t _attr=0;
   int i;
   bool y_valid=false;
   bool a_valid=false;
   bool x1_valid=false;
   bool x2_valid=false;
   bool c_valid=false;
   uint32_t postProc=0;
   bool vector=false;

   if(strcasestr(opcode.c_str(),"FLOOR")) {
      postProc=FPU_EXE_FLOOR;
   }
   if(strcasestr(opcode.c_str(),"ABS")) {
      postProc+=FPU_EXE_ABS;
   }
   if(strcasestr(opcode.c_str(),TOKEN_FPU_VECTOR)) {
      vector = true;
   }
   for(i=0;i < (int)names.size();i++) {
      if(strcasecmp(names[i].c_str(),"N")==0) {
         if(!vector)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNT,REG_FPU_SET,parms[i].c_str());    
         else
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNTV,REG_FPU_SET,parms[i].c_str());    
      } else {
         if(strcasecmp(names[i].c_str(),"y")==0) {
            _attr = FPU_SET_P_A;
            y_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"a")==0) {
            _attr = FPU_SET_P_B;
            a_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x1")==0) {
            _attr = FPU_SET_P_X;
            x1_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x2")==0) {
            _attr = FPU_SET_P_Y;
            x2_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"c")==0) {
            _attr = FPU_SET_P_C;
            c_valid = true;
         }
         else
            error(cMcore::M_currLine, "Invalid parameter");
         genParm(out,_attr,types[i],parms[i],isPointers[i]);
      }
   }
   if(!y_valid)
      error(cMcore::M_currLine, "Missing parameter");
   if(!c_valid && !x1_valid && !x2_valid)
      error(cMcore::M_currLine, "Missing parameter");

   if(!a_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_B,REG_FPU_SET);
   if(!x1_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0x3f80;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_X,REG_FPU_SET);
   if(!x2_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0x3f80;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_Y,REG_FPU_SET);
   if(!c_valid)
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0x3f80;",FPU_SET_W_BFLOAT|FPU_SET_M_VALUE|FPU_SET_P_C,REG_FPU_SET);

   genEXE(out,FPU_EXE_MAC+postProc,end);
   fprintf(out,"\n");
   return 0;
}

//--------------
// Generate 
//   FPU.EXP --> y[i]=2**x[i] where x[i] is INT8 number
//---------------

static int scan_exp(
   FILE *out,
   std::string &opcode,
   std::vector<std::string> &names,
   std::vector<std::string> &parms,
   std::vector<std::string> &types,
   std::vector<bool> &isPointers,
   char end) 
{
   uint32_t _attr=0;
   int i;
   bool y_valid=false;
   bool x_valid=false;
   uint32_t oc;
   bool vector=false;

   oc = FPU_EXE_EXP;

   if(strcasestr(opcode.c_str(),TOKEN_FPU_VECTOR)) {
      vector = true;
   }
   for(i=0;i < (int)names.size();i++) {
      if(strcasecmp(names[i].c_str(),"N")==0) {
         if(!vector)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNT,REG_FPU_SET,parms[i].c_str());    
         else
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNTV,REG_FPU_SET,parms[i].c_str());    
      } else {
         if(strcasecmp(names[i].c_str(),"y")==0) {
            _attr = FPU_SET_P_A;
            y_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x")==0) {           
            _attr = FPU_SET_P_B;
            x_valid = true;
         }
         else
            error(cMcore::M_currLine, "Invalid parameter");
         genParm(out,_attr,types[i],parms[i],isPointers[i]);
      }
   }
   if(!y_valid || !x_valid)
      error(cMcore::M_currLine, "Missing parameter");
   genEXE(out,oc,end);
   fprintf(out,"\n");
   return 0;
}

//--------------
// Generate 
//   FPU.RECIPROCAL --> approximate y=1/x
//---------------

static int scan_reciprocal(
   FILE *out,
   std::string &opcode,
   std::vector<std::string> &names,
   std::vector<std::string> &parms,
   std::vector<std::string> &types,
   std::vector<bool> &isPointers,
   char end)
{
   uint32_t _attr=0;
   int i;
   bool y_valid=false;
   bool x_valid=false;
   uint32_t oc;
   bool vector=false;

   oc = FPU_EXE_RECIPROCAL;

   if(strcasestr(opcode.c_str(),TOKEN_FPU_VECTOR)) {
      vector = true;
   }
   for(i=0;i < (int)names.size();i++) {
      if(strcasecmp(names[i].c_str(),"N")==0) {
         if(!vector)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNT,REG_FPU_SET,parms[i].c_str());    
         else
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNTV,REG_FPU_SET,parms[i].c_str());    
      } else {
         if(strcasecmp(names[i].c_str(),"y")==0) {
            _attr = FPU_SET_P_A;
            y_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x")==0) {          
            _attr = FPU_SET_P_B;
            x_valid = true;
         }
         else
            error(cMcore::M_currLine, "Invalid parameter");
         genParm(out,_attr,types[i],parms[i],isPointers[i]);
      }
   }
   if(!y_valid || !x_valid)
      error(cMcore::M_currLine, "Missing parameter");
   genEXE(out,oc,end);
   fprintf(out,"\n");
   return 0;
}

//--------------
// Generate 
//   FPU.INVSQRT --> approximate y=1/sqrt(x)
//---------------

static int scan_invsqrt(
   FILE *out,
   std::string &opcode,
   std::vector<std::string> &names,
   std::vector<std::string> &parms,
   std::vector<std::string> &types,
   std::vector<bool> &isPointers,
   char end)
{
   uint32_t _attr=0;
   int i;
   bool y_valid=false;
   bool x_valid=false;
   uint32_t oc;
   bool vector=false;

   oc = FPU_EXE_INVSQRT;

   if(strcasestr(opcode.c_str(),TOKEN_FPU_VECTOR)) {
      vector = true;
   }

   for(i=0;i < (int)names.size();i++) {
      if(strcasecmp(names[i].c_str(),"N")==0) {
         if(!vector)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNT,REG_FPU_SET,parms[i].c_str());  
         else  
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNTV,REG_FPU_SET,parms[i].c_str());    
      } else {
         if(strcasecmp(names[i].c_str(),"y")==0) {
            _attr = FPU_SET_P_A;
            y_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x")==0) {          
            _attr = FPU_SET_P_B;
            x_valid = true;
         }
         else
            error(cMcore::M_currLine, "Invalid parameter");
         genParm(out,_attr,types[i],parms[i],isPointers[i]);
      }
   }
   if(!y_valid || !x_valid)
      error(cMcore::M_currLine, "Missing parameter");
   genEXE(out,oc,end);
   fprintf(out,"\n");
   return 0;
}

//--------------
// Generate 
//    FPU.MAX --> y=Max(a,max(x[i])) 
//    FPU.MAX.ABS --> y=Max(a,max(abs(x[i])))
// If g parameter present, then this is to find max per group
// of g elements
//---------------

static int scan_max(
   FILE *out,
   std::string &opcode,
   std::vector<std::string> &names,
   std::vector<std::string> &parms,
   std::vector<std::string> &types,
   std::vector<bool> &isPointers,
   char end) 
{
   uint32_t _attr=0;
   int i;
   bool abs=false;
   bool y_valid=false;
   bool x_valid=false;
   bool a_valid=false;
   bool group_valid=false;
   uint32_t postProc=0;
   bool vector=false;

   if(strcasestr(opcode.c_str(),"ABS")) {
      postProc = FPU_EXE_ABS;
      abs=true;
   }
   if(strcasestr(opcode.c_str(),TOKEN_FPU_VECTOR)) {
      vector = true;
   }
   for(i=0;i < (int)names.size();i++) {
      if(strcasecmp(names[i].c_str(),"N")==0) {
         if(!vector)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNT,REG_FPU_SET,parms[i].c_str());  
         else  
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNTV,REG_FPU_SET,parms[i].c_str());    
      } else {
         if(strcasecmp(names[i].c_str(),"y")==0) {
            _attr = FPU_SET_P_A;
            y_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x")==0) {          
            _attr = FPU_SET_P_B;
            x_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"A")==0) {          
            _attr = FPU_SET_P_C;
            a_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"g")==0) {          
            _attr = FPU_SET_P_C;
            group_valid = true;
         }
         else
            error(cMcore::M_currLine, "Invalid parameter");
         genParm(out,_attr,types[i],parms[i],isPointers[i]);
      }
   }
   if(a_valid && group_valid)
      error(cMcore::M_currLine, "Invalid parameter");
   if(!y_valid || !x_valid)
      error(cMcore::M_currLine, "Missing parameter");
   if(!a_valid && !group_valid) {
      // Set initial max value smallest value possible
      if(abs)
         fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0;",FPU_SET_W_FP32|FPU_SET_M_VALUE|FPU_SET_P_C,REG_FPU_SET);
      else
         fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0xFF7FFFFF;",FPU_SET_W_FP32|FPU_SET_M_VALUE|FPU_SET_P_C,REG_FPU_SET);
   }
   genEXE(out,(group_valid?FPU_EXE_GROUP_MAX:FPU_EXE_MAX)+postProc,end);
   fprintf(out,"\n");
   return 0;
}

//--------------
// Generate command
//    FPU.SUM --> y=A+sum(x[i])
//    FPU.SUM.ABS -> y=A+sum(abs(x[i]))
//---------------

static int scan_sum(
   FILE *out,
   std::string &opcode,
   std::vector<std::string> &names,
   std::vector<std::string> &parms,
   std::vector<std::string> &types,
   std::vector<bool> &isPointers,
   char end)
{
   uint32_t _attr=0;
   int i;
   bool y_valid=false;
   bool x_valid=false;
   bool a_valid=false;
   uint32_t postProc=0;
   bool vector=false;

   if(strcasestr(opcode.c_str(),"ABS")) {
      postProc = FPU_EXE_ABS;
   }
   if(strcasestr(opcode.c_str(),TOKEN_FPU_VECTOR)) {
      vector = true;
   }
   for(i=0;i < (int)names.size();i++) {
      if(strcasecmp(names[i].c_str(),"N")==0) {
         if(!vector)
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNT,REG_FPU_SET,parms[i].c_str()); 
         else   
            fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=(uint32_t)(%s);",FPU_SET_P_CNTV,REG_FPU_SET,parms[i].c_str());    
      } else {
         if(strcasecmp(names[i].c_str(),"y")==0) {
            _attr = FPU_SET_P_A;
            y_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"x")==0) {          
            _attr = FPU_SET_P_B;
            x_valid = true;
         }
         else if(strcasecmp(names[i].c_str(),"A")==0) {          
            _attr = FPU_SET_P_C;
            a_valid = true;
         }
         else
            error(cMcore::M_currLine, "Invalid parameter");
         genParm(out,_attr,types[i],parms[i],isPointers[i]);
      }
   }
   if(!y_valid || !x_valid)
      error(cMcore::M_currLine, "Missing parameter");
   if(!a_valid) {
      fprintf(out,"ZTAM_GREG(0x%x,0x%x,0)=0;",FPU_SET_W_FP32|FPU_SET_M_VALUE|FPU_SET_P_C,REG_FPU_SET);
   }
   genEXE(out,FPU_EXE_SUM+postProc,end);
   fprintf(out,"\n");
   return 0;
}

//--------------
// Generate FPU.XXX command
//---------------

char *cMcore::scan_fpu(FILE *out, char *line) {
   std::string opcode;
   std::vector<std::string> names;
   std::vector<std::string> parms;
   std::vector<std::string> types;
   std::vector<bool> isPointers;
   char end;

   line = parse(line,end,opcode,names,parms,types,isPointers);
   if(strcasestr(opcode.c_str(),TOKEN_FPU_FMA)) {
      if(scan_fma(out,opcode,names,parms,types,isPointers,end) != 0)
         return 0;
   }
   else if(strcasestr(opcode.c_str(),TOKEN_FPU_MAC)) {
      if(scan_mac(out,opcode,names,parms,types,isPointers,end) != 0)
         return 0;
   }
   else if(strcasestr(opcode.c_str(),TOKEN_FPU_EXP)) {
      if(scan_exp(out,opcode,names,parms,types,isPointers,end) != 0)
         return 0;   
   } else if(strcasestr(opcode.c_str(),TOKEN_FPU_RECIPROCAL)) {
      if(scan_reciprocal(out,opcode,names,parms,types,isPointers,end) != 0)
         return 0;
   } else if(strcasestr(opcode.c_str(),TOKEN_FPU_INVSQRT)) {
      if(scan_invsqrt(out,opcode,names,parms,types,isPointers,end) != 0)
         return 0;   
   } else if(strcasestr(opcode.c_str(),TOKEN_FPU_MAX)) {
      if(scan_max(out,opcode,names,parms,types,isPointers,end) != 0)
         return 0;  
   } else if(strcasestr(opcode.c_str(),TOKEN_FPU_SUM)) {
      if(scan_sum(out,opcode,names,parms,types,isPointers,end) != 0)
         return 0;  
   } else {
      error(cMcore::M_currLine, "Undefined opcode");
   }
   return line;
}


