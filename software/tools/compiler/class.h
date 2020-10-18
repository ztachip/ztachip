#ifndef _CLASS_H_
#define _CLASS_H_
#include <vector>
#include "util.h"
#include "object.h"
#include "ast.h"

class cClass
{
public:
   cClass(char *_name,int _maxThreads);
   ~cClass();
   static int scan(cAstNode *_root);
   static cClass *Find(char *className);
public:
   static std::vector<cClass *> M_list;
   std::string m_name;
   int m_maxThreads;
};


#endif
