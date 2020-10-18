#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <vector>
#include "zta.h"
#include "ast.h"
#include "util.h"
#include "config.h"
#include "ident.h"
#include "const.h"

std::vector<float> cConstant::M_space;

int cConstant::Init()
{
   return 0;
}

int cConstant::Size()
{
   return (int)M_space.size();
}

int cConstant::Find(float constant)
{
   int i;
   for(i=0;i < (int)M_space.size();i++)
   {
      if(M_space[i]==constant)
         return i;
   }
   return -1;
}

int cConstant::Add(float constant)
{
   int index;
   index=Find(constant);
   if(index >= 0)
      return index;
   index=M_space.size();
   M_space.push_back(constant);
   return index;
}

RETCODE cConstant::Allocate(cAstNode *_root)
{
   cInstruction *instruction;
   // Calculate code address
   instruction=(cInstruction *)PROGRAM.getFirst();
   while(instruction)
   {      
      if(instruction->m_alu1.oc > 0 && instruction->m_alu1.x1->isKindOf(cTerm_MU_Constant::getCLID())) 
      {
         Add((float)instruction->m_alu1.x1->getConstant());
      }
      if(instruction->m_alu1.oc > 0 && instruction->m_alu1.x2->isKindOf(cTerm_MU_Constant::getCLID())) 
      {
         Add((float)instruction->m_alu1.x2->getConstant());
      }
      if(instruction->m_alu2.oc > 0 && instruction->m_alu2.x1->isKindOf(cTerm_MU_Constant::getCLID()))
      {
         Add((float)instruction->m_alu2.x1->getConstant());
      }
      if(instruction->m_alu2.oc > 0 && instruction->m_alu2.x2->isKindOf(cTerm_MU_Constant::getCLID()))
      {
         Add((float)instruction->m_alu2.x2->getConstant());
      }
      instruction=(cInstruction *)instruction->getNext();
   }
   return OK;
}

// Generate constant space
void cConstant::Gen(FILE *fp)
{
   int i;
   float val;
   unsigned int val2;
   for(i=0;i < (int)cConstant::Size();i++)
   {
      val=(float)cConstant::M_space[i];
      val2= (unsigned int)((int)val);
      fprintf(fp,"%08X\n",val2);
   }
}
