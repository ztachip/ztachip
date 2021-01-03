//----------------------------------------------------------------------------
// Copyright [2014] [Ztachip Technologies Inc]
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
#include "zta.h"
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

int buildKernelFile(const char *kernelFileName,int numFiles,char **fileName)
{
   FILE *outfp,*infp;
   int len;
   uint8_t buf[1000];
   outfp=fopen(kernelFileName,"wb");
   if(!outfp)
      return -1;
   // Concatenate all input files...
   for(int i=0;i < numFiles;i++) {
      infp=fopen(fileName[i],"rb");
      if(!infp)
         return -1;
      while((len=fread(buf,1,sizeof(buf),infp))>0) {
         fwrite(buf,1,len,outfp);
      }
      fclose(infp);
   }
   fclose(outfp);
   return 0;
}

int buildLdFile(char *ldFileName,int numFiles,char **fileName)
{
   FILE *fp=0;
   char *p;
   fp=fopen(ldFileName,"w");
   if(!fp)
      return -1;

   fprintf(fp,"ENTRY(_start)\n");
   fprintf(fp,"STARTUP(crt0.o)\n");
   fprintf(fp,"OUTPUT_FORMAT(\"elf32-bigmips\",\"elf32-bigmips\",\"elf32-littlemips\")\n");
   fprintf(fp,"GROUP(-lc -lidt -lgcc)\n");
   fprintf(fp,"SEARCH_DIR(./mips-elf/lib)\n");
   fprintf(fp,"__DYNAMIC  =  0;\n");

   fprintf(fp,"PROVIDE (hardware_exit_hook = 0);\n");
   fprintf(fp,"PROVIDE (hardware_hazard_hook = 0);\n");
   fprintf(fp,"PROVIDE (hardware_init_hook = 0);\n");
   fprintf(fp,"PROVIDE (software_init_hook = 0);\n");


   fprintf(fp,"SECTIONS\n");
   fprintf(fp,"{\n");
   fprintf(fp,". = 0x00000200;\n");
   fprintf(fp,".gcc_except_table : { *(.gcc_except_table) }\n");
   fprintf(fp,".jcr : { KEEP (*(.jcr)) }\n");
   fprintf(fp,".ctors :\n");
   fprintf(fp,"{\n");

   fprintf(fp,"KEEP (*crtbegin.o(.ctors))\n");

   fprintf(fp,"KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))\n");
   fprintf(fp,"KEEP (*(SORT(.ctors.*)))\n");
   fprintf(fp,"KEEP (*(.ctors))\n");
   fprintf(fp,"}");

   fprintf(fp,".dtors :\n");
   fprintf(fp,"{\n");
   fprintf(fp,"KEEP (*crtbegin.o(.dtors))\n");
   fprintf(fp,"KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))\n");
   fprintf(fp,"KEEP (*(SORT(.dtors.*)))\n");
   fprintf(fp,"KEEP (*(.dtors))\n");
   fprintf(fp,"}\n");

   fprintf(fp,". = . + 0x400;\n");
   fprintf(fp,"PROVIDE (__stack = .);\n");

   fprintf(fp,".rodata : {\n");
   fprintf(fp,"*(.rdata)\n");
   fprintf(fp,"*(.rodata)\n");
   fprintf(fp,"*(.rodata.*)\n");
   fprintf(fp,"*(.gnu.linkonce.r.*)\n");
   fprintf(fp,"}\n");
   fprintf(fp,"_fdata = ALIGN(16);\n");
   fprintf(fp,".data : {\n");
   fprintf(fp,"*(.data)\n");
   fprintf(fp,"*(.data.*)\n");
   fprintf(fp,"*(.gnu.linkonce.d.*)\n");
   fprintf(fp,"}\n");
   fprintf(fp,". = ALIGN(8);\n");
   fprintf(fp,"_gp = . + 0x100;\n");
   fprintf(fp,"__global = _gp;\n");
   fprintf(fp,".lit8 : {\n");
   fprintf(fp,"*(.lit8)\n");
   fprintf(fp,"}\n");
   fprintf(fp,".lit4 : {\n");
   fprintf(fp,"*(.lit4)\n");
   fprintf(fp,"}\n");
   fprintf(fp,".sdata : {\n");
   fprintf(fp,"*(.sdata)\n");
   fprintf(fp,"*(.sdata.*)\n");
   fprintf(fp,"*(.gnu.linkonce.s.*)\n");
   fprintf(fp,"}\n");
   fprintf(fp,". = ALIGN(4);\n");
   fprintf(fp,"PROVIDE (edata  =  .);\n");
   fprintf(fp,"_edata  =  .;\n");
   fprintf(fp,"_fbss = .;\n");
   fprintf(fp,".sbss : {\n");
   fprintf(fp,"*(.sbss)\n");
   fprintf(fp,"*(.sbss.*)\n");
   fprintf(fp,"*(.gnu.linkonce.sb.*)\n");
   fprintf(fp,"*(.scommon)\n");
   fprintf(fp,"}\n");
   fprintf(fp,".bss : {\n");
   fprintf(fp,"_bss_start = . ;\n");
   fprintf(fp,"*(.bss)\n");
   fprintf(fp,"*(.bss.*)\n");
   fprintf(fp,"*(.gnu.linkonce.b.*)\n");
   fprintf(fp,"*(COMMON)\n");
   fprintf(fp,"}\n");

   fprintf(fp,"PROVIDE (end = .);\n");
   fprintf(fp,"_end = .;\n");
   fprintf(fp,"}\n");

   fprintf(fp,"SECTIONS\n");
   fprintf(fp,"{\n");
   fprintf(fp,". = 0x%08X;\n",kMcoreCodeSpaceAddr+0x10);
   fprintf(fp,".text : {\n");
   fprintf(fp,"_ftext = . ;\n");
   fprintf(fp,"PROVIDE (eprol = .);\n");
   if(numFiles > 0) {
      fprintf(fp,"*(EXCLUDE_FILE (\n");
      for(int i=0;i < numFiles;i++) {
         char fname[256];
         strcpy(fname,fileName[i]);
         p=strstr(fname,".hex");
         if(!p)
            return -1;
         strcpy(p,".o");
         fprintf(fp,"%s\n",fname);
      }
      fprintf(fp,").text*)\n");
   }
   fprintf(fp,"}\n");
   fprintf(fp,".init : {\n");
   fprintf(fp,"KEEP (*(.init))\n");
   fprintf(fp,"}\n");
   fprintf(fp,".fini : {\n");
   fprintf(fp,"KEEP (*(.fini))\n");
   fprintf(fp,"}\n");
   fprintf(fp,".rel.sdata : {\n");
   fprintf(fp,"PROVIDE (__runtime_reloc_start = .);\n");
   fprintf(fp,"*(.rel.sdata)\n");
   fprintf(fp,"PROVIDE (__runtime_reloc_stop = .);\n");
   fprintf(fp,"}\n");
   fprintf(fp,"PROVIDE (zta_ox_begin = .);\n");
   fprintf(fp,"OVERLAY : AT (0x%08X)\n",kMcoreCodeSpaceAddr+MCORE_OVERLAY_ADDRESS);
   fprintf(fp,"{\n");
   for(int i=0;i < numFiles;i++) {
      char fname[256];
      strcpy(fname,fileName[i]);
      p=strstr(fname,".hex");
      if(!p)
         return -1;
      strcpy(p,".o");
      fprintf(fp,".text%d {%s(.text)}\n",i,fname);
   }
   fprintf(fp,"}\n");
   fprintf(fp,"PROVIDE (zta_o0_end = 0x%08X+SIZEOF(.text0));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o1_end = 0x%08X+SIZEOF(.text1));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o2_end = 0x%08X+SIZEOF(.text2));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o3_end = 0x%08X+SIZEOF(.text3));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o4_end = 0x%08X+SIZEOF(.text4));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o5_end = 0x%08X+SIZEOF(.text5));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o6_end = 0x%08X+SIZEOF(.text6));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o7_end = 0x%08X+SIZEOF(.text7));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (zta_o8_end = 0x%08X+SIZEOF(.text8));\n",kMcoreCodeSpaceAddr);
   fprintf(fp,"PROVIDE (etext = .);\n");
   fprintf(fp,"_etext  =  .;\n");
   fprintf(fp,"}\n");
   fclose(fp);
   return 0;
}

struct SymbolInfo
{
   std::string name;
   uint32_t addr;
   uint8_t page;
};

int buildMapFile(char *hexFile,char *mapFile,char *outputFile)
{
   char line[256];
   FILE *mapfp;
   FILE *outfp;
   FILE *infp;
   int len;
   std::vector<struct SymbolInfo> symbols;
   struct SymbolInfo symbol;
   int page;
   outfp=fopen(outputFile,"r");
   if(!outfp) {
      printf("Unable to open output file \n");
      exit(-1);
   }
   // Get all export symbol names
   for(page=0;;page++) {
      char *p;
      while((p=fgets(line,sizeof(line)-1,outfp))) {
         if(strstr(line,".EXPORT BEGIN"))
            break;
      }
      if(!p)
         break;
      while(fgets(line,sizeof(line)-1,outfp)) {
         if(strstr(line,".EXPORT END"))
            break;
         symbol.name=strtok(line," \r\n\t");
         symbol.addr=0;
         symbol.page=page;
         symbols.push_back(symbol);
      }
   }
#if 0
   symbol.name="zta_ox_begin";
   symbol.addr=0;
   symbol.page=0;
   symbols.push_back(symbol);
   for(int i=1;i < page;i++) {
      char symbolName[100];
      sprintf(symbolName,"zta_o%d_end",i-1);
      symbol.name=symbolName;
      symbol.addr=0;
      symbol.page=i;
      symbols.push_back(symbol);
   }
#endif
   fclose(outfp);
   outfp=fopen(outputFile,"a");
   if(!outfp) {
      printf("Unable to open output file \n");
      exit(-1);
   }
   mapfp=fopen(mapFile,"r");
   if(!mapfp) {
      printf("Unable to open map file \n");
      exit(-1);
   }
   fprintf(outfp,".MAP BEGIN\n");
   while(fgets(line,sizeof(line)-1,mapfp)) {
      for(int i=0;i < (int)symbols.size();i++) {
         char *p;
         uint32_t addr;
         if((p=strstr(line,symbols[i].name.c_str()))) {
            if(isWS(p[symbols[i].name.length()]) && (p!=line) && isWS(p[-1])) {
            // Found a perfect match
               p=strtok(line,"\r\n\t ");
               addr=strtol(p,0,16);
//               if(symbols[i].page > 0)
//                  addr+=0x10;
               addr |= (symbols[i].page<<24);
               fprintf(outfp,"%s@%08X\n",symbols[i].name.c_str(),addr);
               break;
            }
         }
      }   
   }
   fprintf(outfp,".MAP END\n");
   fclose(mapfp);
   fclose(outfp);

   // Append main hex file to output
   outfp=fopen(outputFile,"ab");
   if(!outfp) {
      printf("Unable to open file %s \n",outputFile);
      return -1;
   }
   infp=fopen(hexFile,"rb");
   if(!infp) {
      printf("Unable to open file %s \n",hexFile);
      return -1;
   }
   fprintf(outfp,".MAIN BEGIN\n");
   while((len=fread(line,1,sizeof(line)-1,infp))>0) {
     fwrite(line,1,len,outfp);
   }
   fprintf(outfp,".MAIN END\n");
   fclose(outfp);
   fclose(infp);
   return 0;
}

int main(int argc,char *argv[])
{
   FILE *outfp;
   char *fname;
   int i,len;
   int firstArg;
   char mfileInput[100];
   char mfileOutput[100];
   char pfileInput[100];
   char pfileOutput[100];
   char pfileConstant[100];
   char pfileHeader[100];

   // Perform some static initialization...
   cConstant::Init();
   cIdentifier::Init();

   if(argc >= 2 && strcasecmp(argv[1], "-L")==0)
   {
      if(argc < 5) {
         printf("\n Invalid argument. Usage compiler2 -L LD_FIILE_NAME OUTPUT_FILE FILES... \n");
         exit(-1);
      }
      buildLdFile(argv[2],argc-5,&argv[5]);
      buildKernelFile(argv[3],argc-4,&argv[4]);
      return 0;
   }
   if(argc >= 2 && strcasecmp(argv[1], "-M")==0)
   {
      if(argc < 5) {
         printf("\n Invalid argument. Usage compiler2 -M hex-file map-file output-file... \n");
         exit(-1);
      }
      buildMapFile(argv[2],argv[3],argv[4]);
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
#if 0
   M_ISFLOAT=true;
   strcpy(pfileInput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test_v8\\pcore2.p");
   strcpy(pfileOutput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test_v8\\pcore2.hex");
   strcpy(pfileHeader,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test_v8\\pcore2.h");
   strcpy(pfileConstant,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test_v8\\pcore2.b");
   strcpy(mfileInput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test_v8\\mmain.m");
   strcpy(mfileOutput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test_v8\\main2.c");
#endif
#if 0
   M_ISFLOAT=true;
   strcpy(pfileInput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\matrix_mul\\pcore.p");
   strcpy(pfileOutput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\matrix_mul\\pcore.hex");
   strcpy(pfileHeader,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\matrix_mul\\pcore.h");
   strcpy(pfileConstant,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\matrix_mul\\pcore.b");
   strcpy(mfileInput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\matrix_mul\\mcore.m");
   strcpy(mfileOutput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\matrix_mul\\mcore.c");
#endif
#if 0
   M_ISFLOAT = false;
   strcpy(pfileInput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test2\\temp.p");
   strcpy(pfileOutput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test2\\pcore.hex");
   strcpy(pfileHeader,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test2\\pcore.h");
   strcpy(pfileConstant,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test2\\pcore.b");
   strcpy(mfileInput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test2\\mcore.m");
   strcpy(mfileOutput,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\test2\\mcore.c");
#endif
#if 0
   M_ISFLOAT=true;
   strcpy(pfileInput,"c:\\cygwin\\home\\vnguyen\\ZTA\\examples\\math\\temp.p");
   strcpy(pfileOutput,"c:\\cygwin\\home\\vnguyen\\ZTA\\examples\\math\\pcore.hex");
   strcpy(pfileHeader,"c:\\cygwin\\home\\vnguyen\\ZTA\\examples\\math\\pcore.h");
   strcpy(pfileConstant,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\math\\pcore.b");
   strcpy(mfileInput,"c:\\cygwin\\home\\vnguyen\\ZTA\\examples\\math\\mmain.m");
   strcpy(mfileOutput,"c:\\cygwin\\home\\vnguyen\\ZTA\\examples\\math\\mcore.c");
#endif
#if 0
   M_ISFLOAT=true;
   strcpy(pfileInput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\cnn\\pcore.p");
   strcpy(pfileOutput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\cnn\\pcore.hex");
   strcpy(pfileHeader, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\cnn\\pcore.h");
   strcpy(pfileConstant,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\cnn\\pcore.b");
   strcpy(mfileInput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\cnn\\mcore.m");
   strcpy(mfileOutput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\cnn\\mcore.c");
#endif
#if 0
   M_ISFLOAT=false;
   strcpy(pfileInput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\alexi\\o0\\temp.p");
   strcpy(pfileOutput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\alexi\\o0\\pcore.hex");
   strcpy(pfileHeader, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\alexi\\o0\\pcore.h");
   strcpy(pfileConstant,"c:\\cygwin\\home\\Vuong\\ZTA\\examples\\alexi\\o0\\pcore.b");
   strcpy(mfileInput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\alexi\\o0\\mcore.m");
   strcpy(mfileOutput, "c:\\cygwin\\home\\Vuong\\ZTA\\examples\\alexi\\o0\\mcore.c");
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
      cInstruction::Generate(outfp);
   }
   else
      printf("\n Parse fail \n");
   
   printf("Process m-file %s\n",mfileInput);
   cMcore::Process(mfileInput,mfileOutput);
   cMcore::GenExport(outfp);
   fprintf(outfp,".MODULE END\n");
   fclose(outfp);
   return 0;
}
