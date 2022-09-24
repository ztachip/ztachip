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

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <malloc.h>
#include <assert.h>
#include <string.h>
#include <assert.h>
#include <stdarg.h>
#include <vector>
#include "../base/zta.h"
#include "ast.h"
#include "util.h"
#include "config.h"
#include "class.h"
#include "ident.h"
#include "const.h"
#include "instruction.h"
#include "gen.h"
#include "graph.h"
#include "mcore.h"


cAstNode *root=0;
cInstructions PROGRAM;
bool M_ISFLOAT=true;
bool M_VERBOSE=false;

extern void prune(cAstNode *_root,bool full);
extern int compress(cAstNode *_root);
extern void print_instruction();

// Invoked when trying to do an illegal pointer casting using CAST macro
void *cast_error(const char *errString)
{
   printf("\n%s\n",errString);
   assert(0);
   return 0;
}
int error(int lineNo,const char *s)
{
   if(lineNo >= 0)
      printf("\n%s lineNo=%d \n",s?s:"",lineNo);
   else
      printf("\n%s \n",s?s:"");
   exit(-1);
   return 0;
}
int warning(int lineNo,const char *s)
{
   if(lineNo >= 0)
      printf("\n%s lineNo=%d \n",s?s:"",lineNo);
   else
      printf("\n%s \n",s?s:"");
   return 0;
}

int main(int argc,char *argv[])
{
   FILE *outfp;
   FILE *outfp2;
   char *fname;
   int i,len;
   int firstArg;
   char mfileInput[100];
   char mfileOutput[100];
   char pfileInput[100];
   char pfileOutput[100];
   char pfileOutput2[100];
   char pfileConstant[100];
   char pfileHeader[100];
   int lvlFlag[64];

   // Perform some static initialization...
   cConstant::Init();
   cIdentifier::Init();

   if(argc >= 2 && strcasecmp(argv[1], "-L")==0)
   {
      if(argc < 5) {
         printf("\n Invalid argument. Usage compiler2 -L LD_FIILE_NAME OUTPUT_FILE FILES... \n");
         exit(-1);
      }
      assert(0); // No longer supported
      return 0;
   }
   if(argc >= 2 && strcasecmp(argv[1], "-M")==0)
   {
      if(argc < 5) {
         printf("\n Invalid argument. Usage compiler2 -M hex-file map-file output-file... \n");
         exit(-1);
      }
      assert(0); // No longer supported
      return 0;
   }

#if 1
   if(argc < 3)
   {
      printf("\nError1: Usage compiler2 [-v] file1.m file2.p ");
      return -1;
   }
   if(strcasecmp(argv[1],"-V")==0) {
      firstArg=2;
      M_VERBOSE=true;
      if(argc < 4) {
         printf("\nError1: Usage compiler2 [-v] file1.m file2.p ");
         return -1;
      }
   } else {
      firstArg=1;
      M_VERBOSE=false;
      if(argc < 3) {
         printf("\nError1: Usage compiler2 [-v] file1.m file2.p ");
         return -1;
      }
   }
   M_ISFLOAT=false;
   mfileInput[0]=0;
   mfileOutput[0]=0;
   pfileInput[0]=0;
   pfileOutput[0]=0;
   pfileOutput2[0]=0;
   pfileConstant[0]=0;
   pfileHeader[0]=0;
   for(i=firstArg;i < argc;i++)
   {
      fname=argv[i];
      len=strlen(fname);
      if(len < 3)
         error(-1,"Invalid filename");
      if(fname[len-1]=='m' && fname[len-2]=='.')
      {
         if(mfileInput[0])
            error(-1,"Only one mfile can be specified");
         strcpy(mfileInput,argv[i]);
         strcpy(mfileOutput,argv[i]);
         strcat(mfileOutput,".c");

         strcpy(pfileOutput,fname);
         pfileOutput[len-1]=0;
         strcat(pfileOutput,"hex");

         strcpy(pfileOutput2,fname);
         pfileOutput2[len-1]=0;
         strcat(pfileOutput2,"p.img");

         strcpy(pfileHeader,fname);
         pfileHeader[len-1]=0;
         strcat(pfileHeader,"p.h");

         strcpy(pfileConstant,fname);
         pfileConstant[len-1]=0;
         strcat(pfileConstant,"b");
      }
      else if(fname[len-1]=='p' && fname[len-2]=='.')
      {
         if(pfileInput[0])
            error(-1,"Only one pfile can be specified");
         strcpy(pfileInput,fname);
      }
      else
         error(-1,"Invalid file specified. Must .m and .p ");
   }
   if(pfileInput[0]==0 || mfileInput[0]==0)
      printf("\nError2: Usage compiler2 file1.m file2.p config.xml");

#endif
   yyin=fopen(pfileInput,"r");
   if(!yyin)
   {
      printf("\n Unable to open input file ");
      return -1;
   }

   if(cConfig::Load(0,0) != 0)
      error(-1,"Error open/process config.xml \n");

   outfp=fopen(pfileOutput,"wb");
   if(!outfp)
   {
      printf("\nUnable to open output file ");
		return -1;
   }
   outfp2=fopen(pfileOutput2,"wb");
   if(!outfp2)
   {
      printf("\nUnable to open output file 2");
      return -1;
   }

   fprintf(outfp,".MODULE BEGIN\n");
   printf("Process p-file %s\n",pfileInput);
   if(yyparse()==0)
   {
      // Reduce AST tree
      // remove non-information node
      // Calculate constant arithmetic
      prune(root,true);

      // Print the AST tree. For debugging
//      cAstNode::Print(root,0,lvlFlag);

      // Identify all class definitions
      cClass::scan(root);

      // Identify all variables from analyzing the AST
      cIdentifier::Process(root);

      // Reduce AST tree if possible

      prune(root,false);

      // Generate codes from AST

      cGEN::gen(root);

      // Perform various optimization
      cInstruction::Optimize(root);

      // Allocate constant space ....

      cConstant::Allocate(root);

      // Build a register allocation graph. Allocate space for
      // all identifiers
      cGraph::Build((cInstruction *)PROGRAM.getFirst());

      // Print generated instructions. For debugging

//      if(M_VERBOSE) {
//         printf("Print assembly instructions\r\n");
//         cInstruction::Print();
//      }

      // Generate constant file

//      cConstant::Gen(pfileConstant);

      // Generate final output file.
      cInstruction::Generate(outfp,outfp2);
   }
   else
      printf("\n Parse fail \n");
   
   printf("Process m-file %s\n",mfileInput);
   cMcore::Process(mfileInput,mfileOutput);
   cMcore::GenExport(outfp);
   fprintf(outfp,".MODULE END\n");
   fclose(outfp);
   fclose(outfp2);
   return 0;
}
