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

// Create objects that represents a parsing node for AST (abstract syntax tree)
// This is called from bison/flex framework
// Create the following types of nodes
// 
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <assert.h>
#include <string.h>
#include <assert.h>
#include <stdarg.h>
#include <vector>
#include "zta.h"
#include "ast.h"
#include "ident.h"

static const char *tokenStr[eTOKEN_max]=
{
   "eTOKEN_IDENTIFIER", 
   "eTOKEN_I_CONSTANT",
   "eTOKEN_F_CONSTANT",
   "eTOKEN_STRING_LITERAL",
   "eTOKEN_FUNC_NAME",
   "eTOKEN_SIZEOF",
   "eTOKEN_PTR_OP",
   "eTOKEN_INC_OP",
   "eTOKEN_DEC_OP",
   "eTOKEN_LEFT_OP",
   "eTOKEN_RIGHT_OP",
   "eTOKEN_LE_OP",
   "eTOKEN_GE_OP",
   "eTOKEN_EQ_OP",
   "eTOKEN_NE_OP",
   "eTOKEN_AND_OP",
   "eTOKEN_OR_OP",
   "eTOKEN_MUL_ASSIGN",
   "eTOKEN_DIV_ASSIGN",
   "eTOKEN_MOD_ASSIGN",
   "eTOKEN_ADD_ASSIGN",
   "eTOKEN_SUB_ASSIGN",
   "eTOKEN_LEFT_ASSIGN",
   "eTOKEN_RIGHT_ASSIGN",
   "eTOKEN_AND_ASSIGN",
   "eTOKEN_XOR_ASSIGN",
   "eTOKEN_OR_ASSIGN",
   "eTOKEN_TYPEDEF_NAME",
   "eTOKEN_ENUMERATION_CONSTANT",
   "eTOKEN_TYPEDEF",
   "eTOKEN_EXTERN",
   "eTOKEN_STATIC",
   "eTOKEN_AUTO",
   "eTOKEN_REGISTER", 
   "eTOKEN_INLINE",
   "eTOKEN_KERNEL",
   "eTOKEN_CLASS",
   "eTOKEN_NT1",
   "eTOKEN_NT2",
   "eTOKEN_NT4",
   "eTOKEN_NT8",
   "eTOKEN_NT16",
   "eTOKEN_CONST",
   "eTOKEN_RESTRICT", 
   "eTOKEN_VOLATILE",
   "eTOKEN_BOOL",
   "eTOKEN_CHAR",
   "eTOKEN_SHORT",
   "eTOKEN_INT",
   "eTOKEN_LONG",
   "eTOKEN_SIGNED",
   "eTOKEN_UNSIGNED",
   "eTOKEN_FLOAT",
   "eTOKEN_DOUBLE",
   "eTOKEN_VOID",
   "eTOKEN_RESULT",
   "eTOKEN_POINTER_SCOPE",
   "eTOKEN_COMPLEX",
   "eTOKEN_IMAGINARY", 
   "eTOKEN_STRUCT",
   "eTOKEN_UNION",
   "eTOKEN_ENUM",
   "eTOKEN_ELLIPSIS",
   "eTOKEN_CASE",
   "eTOKEN_DEFAULT",
   "eTOKEN_IF",
   "eTOKEN_ELSE", 
   "eTOKEN_SWITCH", 
   "eTOKEN_WHILE",
   "eTOKEN_DO",
   "eTOKEN_FOR",
   "eTOKEN_GOTO",
   "eTOKEN_CONTINUE", 
   "eTOKEN_BREAK",
   "eTOKEN_RETURN",
   "eTOKEN_ALIGNAS",
   "eTOKEN_ALIGNOF",
   "eTOKEN_ATOMIC",
   "eTOKEN_GENERIC",
   "eTOKEN_NORETURN",
   "eTOKEN_STATIC_ASSERT", 
   "eTOKEN_SHARE",
   "eTOKEN_GLOBAL",
   "eTOKEN_translation_unit",
   "eTOKEN_primary_expression",
   "eTOKEN_constant",
   "eTOKEN_enumeration_constant",
   "eTOKEN_string",
   "eTOKEN_generic_selection",
   "eTOKEN_generic_assoc_list",
   "eTOKEN_generic_association",
   "eTOKEN_postfix_expression1",
   "eTOKEN_postfix_expression2",
   "eTOKEN_postfix_expression3",
   "eTOKEN_postfix_expression4",
   "eTOKEN_postfix_expression5",
   "eTOKEN_postfix_expression6",
   "eTOKEN_postfix_expression7",
   "eTOKEN_postfix_expression8",
   "eTOKEN_postfix_expression9",
   "eTOKEN_postfix_expression10", 
   "eTOKEN_argument_expression_list",
   "eTOKEN_unary_expression",
   "eTOKEN_unary_operator",
   "eTOKEN_cast_expression",
   "eTOKEN_multiplicative_expression",
   "eTOKEN_multiplicative_expression_mul",
   "eTOKEN_multiplicative_expression_div",
   "eTOKEN_multiplicative_expression_mod",
   "eTOKEN_additive_expression",
   "eTOKEN_additive_expression_add",
   "eTOKEN_additive_expression_sub",
   "eTOKEN_shift_expression",
   "eTOKEN_shift_expression_shl",
   "eTOKEN_shift_expression_shr",
   "eTOKEN_relational_expression",
   "eTOKEN_relational_expression_lt",
   "eTOKEN_relational_expression_gt",
   "eTOKEN_relational_expression_le",
   "eTOKEN_relational_expression_ge",
   "eTOKEN_equality_expression",
   "eTOKEN_equality_expression_eq",
   "eTOKEN_equality_expression_ne",
   "eTOKEN_and_expression",
   "eTOKEN_exclusive_or_expression",
   "eTOKEN_inclusive_or_expression",
   "eTOKEN_logical_and_expression",
   "eTOKEN_logical_or_expression",
   "eTOKEN_conditional_expression",
   "eTOKEN_assignment_expression",
   "eTOKEN_assignment_operator",
   "eTOKEN_assignment_operator_mul",
   "eTOKEN_assignment_operator_div",
   "eTOKEN_assignment_operator_mod",
   "eTOKEN_assignment_operator_add",
   "eTOKEN_assignment_operator_sub",
   "eTOKEN_assignment_operator_left",
   "eTOKEN_assignment_operator_right",
   "eTOKEN_assignment_operator_and",
   "eTOKEN_assignment_operator_xor",
   "eTOKEN_assignment_operator_or",
   "eTOKEN_expression",
   "eTOKEN_constant_expression",
   "eTOKEN_declaration",
   "eTOKEN_declaration_specifiers",
   "eTOKEN_init_declarator_list",
   "eTOKEN_init_declarator",
   "eTOKEN_storage_class_specifier",
   "eTOKEN_type_specifier",
   "eTOKEN_struct_or_union_specifier",
   "eTOKEN_struct_or_union",
   "eTOKEN_struct_declaration_list",
   "eTOKEN_struct_declaration",
   "eTOKEN_specifier_qualifier_list",
   "eTOKEN_struct_declarator_list",
   "eTOKEN_struct_declarator",
   "eTOKEN_enum_specifier",
   "eTOKEN_enumerator_list",
   "eTOKEN_enumerator",
   "eTOKEN_atomic_type_specifier",
   "eTOKEN_type_qualifier",
   "eTOKEN_function_specifier",
   "eTOKEN_alignment_specifier",
   "eTOKEN_declarator",
   "eTOKEN_direct_declarator1",
   "eTOKEN_direct_declarator2",
   "eTOKEN_direct_declarator3",
   "eTOKEN_direct_declarator4",
   "eTOKEN_direct_declarator5",
   "eTOKEN_direct_declarator6",
   "eTOKEN_direct_declarator7",
   "eTOKEN_direct_declarator8",
   "eTOKEN_direct_declarator9",
   "eTOKEN_direct_declarator10",
   "eTOKEN_direct_declarator11",
   "eTOKEN_direct_declarator12",
   "eTOKEN_direct_declarator13",
   "eTOKEN_direct_declarator14",
   "eTOKEN_pointer",
   "eTOKEN_type_qualifier_list",
   "eTOKEN_parameter_type_list",
   "eTOKEN_parameter_list",
   "eTOKEN_parameter_declaration",
   "eTOKEN_identifier_list",
   "eTOKEN_type_name",
   "eTOKEN_abstract_declarator",
   "eTOKEN_direct_abstract_declarator",
   "eTOKEN_initializer",
   "eTOKEN_initializer_list",
   "eTOKEN_designation",
   "eTOKEN_designator_list",
   "eTOKEN_designator",
   "eTOKEN_static_assert_declaration",
   "eTOKEN_statement",
   "eTOKEN_labeled_statement",
   "eTOKEN_compound_statement",
   "eTOKEN_block_item_list",
   "eTOKEN_block_item",
   "eTOKEN_expression_statement",
   "eTOKEN_selection_statement",
   "eTOKEN_switch_statement",
   "eTOKEN_iteration_for_statement",
   "eTOKEN_iteration_while_statement",
   "eTOKEN_iteration_do_while_statement",
   "eTOKEN_jump_statement",
   "eTOKEN_external_declaration",
   "eTOKEN_function_definition1",
   "eTOKEN_function_definition2",
   "eTOKEN_declaration_list",
   "eTOKEN_pointer_scope_list",
   "eTOKEN_class_specifier",
   "eTOKEN_class_name",
   "eTOKEN_class_declaration",
   "eTOKEN_class_declaration_list"
};

char pragma[256]="";
int pragmaDefined=-1;
int pragmaUsed=-1;

// Invokes whenever there is an error constructing/parsing/processing the AST
int yyerror(const char *s)
{
   extern int yylineno;
   printf("\r\n%s lineNo=%d\r\n",s?s:"",yylineno);
   exit(-1);
   return 0;
}

// Pragma is decoded
void ast_pragma(char *s)
{
   extern int yylineno;
   char *p;
   p=strtok(s," \t");
   if(p)
      p=strtok(0," \t");
   if(p)
      strcpy(pragma,p);
   else
      pragma[0]=0;
   pragmaDefined=yylineno;
   pragmaUsed=-1;
}

// Call by Parser.y to create a composite node
// Composite nodes are node that are not leaf node. 
cAstCompositeNode *ast_newnode(eTOKEN token,int numnodes,...)
{
   va_list arguments;
   cAstCompositeNode *p;
   cAstNode *node2;
   cAstNode *lst[16];
   int i;
   assert(numnodes < (int)DIM(lst));
   va_start(arguments,numnodes); 
   for(i=0;i < numnodes;i++)
   {
      node2=va_arg(arguments,cAstNode *);
      lst[i]=node2;
   }
   p=new cAstCompositeNode(token,numnodes,lst);
   va_end(arguments);
   return p;
}

// Call by Parser.y to create node that represents a 
// code block (eTOKEN_block_item_list)
// or begin of the program (eTOKEN_translation_unit)

cAstCodeBlockNode *ast_newcodeblock(eTOKEN token,int numnodes,...)
{
   va_list arguments;
   cAstCodeBlockNode *p;
   cAstNode *node2;
   cAstNode *lst[16];
   int i;
   assert(numnodes < (int)DIM(lst));
   va_start(arguments,numnodes); 
   for(i=0;i < numnodes;i++)
   {
      node2=va_arg(arguments,cAstNode *);
      lst[i]=node2;
   }
   p=new cAstCodeBlockNode(token,numnodes,lst);
   va_end(arguments);
   return p;
}

// Call by Parser.y to to create an leaf node that represents 
// an integer constant

cAstIntNode *ast_newint(eTOKEN token,const char *d)
{
   return new cAstIntNode(token,d);
}

// Call by Parser.y to to create a leaf node that represents 
// a float constant

cAstFloatNode *ast_newfloat(eTOKEN token,const char *d)
{
   return new cAstFloatNode(token,(float)atof(d));
}

// Call by Parser.y to create a leaf node that represents 
// a string literal 

cAstStringNode *ast_newstring(eTOKEN token,const char *s)
{
   return new cAstStringNode(token,s);
}

// Call by Parser.y to create a leaf node that is not 
// constants or identifier

cAstTokenNode *ast_newtoken(eTOKEN token,int parm)
{
   return new cAstTokenNode(token,parm);
}

// Call by Parser.y to to create a leaf node that represents 
// an identifier

cAstIdentifierNode *ast_newidentifier(eTOKEN token,const char *s)
{
   return new cAstIdentifierNode(token,s);
}

// Base class for all AST node

INSTANTIATE_OBJECT(cAstNode);
cAstNode::cAstNode(eTOKEN token)
{
   m_tokenid=token;
   m_code=0;
   m_lineNo=yylineno;
   if(pragmaDefined >= 0)
   {
      if(pragmaUsed < 0)
      {
         pragmaUsed=yylineno;
         m_pragma=pragma;
      }
      else if(pragmaUsed==yylineno)
         m_pragma=pragma;
      else
      {
         pragmaDefined=-1;
         pragmaUsed=-1;
      }
   }
}

cAstNode::~cAstNode()
{
}

void cAstNode::print()
{
}

// To be implemented by derived class cAstCompositeNode

cAstNode *cAstNode::getChildList()
{
   return 0;
}

// cAstCompositeNode represents a composite (non-leaf) AST node.

INSTANTIATE_OBJECT(cAstCompositeNode);
cAstCompositeNode::cAstCompositeNode(eTOKEN token,int numnodes,cAstNode **lst) :
   cAstNode(token)
{
   cAstNode *node2;
   int i;

   for(i=0;i < numnodes;i++)
   {
      node2=lst[i];
      m_childLst.append(node2);
   }
}

cAstNode *cAstCompositeNode::getChildList()
{
   return (cAstNode *)m_childLst.getFirst();
}

void cAstCompositeNode::setChildList(cAstNode *node,cAstNode *beforeItem)
{
   m_childLst.insert(node,beforeItem);
}

void cAstCompositeNode::setChildrenList(cAstNode *node,cAstNode *beforeItem)
{
   m_childLst.insertList(node,beforeItem);
}

void cAstCompositeNode::print()
{
   printf("%s",tokenStr[getID()]);
}

// cAstCodeBlockNode is composite node that represents a code block ({...}) 
// or root

INSTANTIATE_OBJECT(cAstCodeBlockNode);
cAstCodeBlockNode::cAstCodeBlockNode(eTOKEN token,int numnodes,cAstNode **lst)
   : cAstCompositeNode(token,numnodes,lst)
{
}

cIdentifier *cAstCodeBlockNode::getIdentifierList()
{
   return (cIdentifier *)m_attrLst.getFirst();
}

bool cAstCodeBlockNode::setIdentifierList(cIdentifier *id)
{
   cIdentifier *id2;
   id2=(cIdentifier *)m_attrLst.getFirst();
   while(id2)
   {
      if(id->m_name.size()>0 && id2->m_name.size()>0 && !id2->getAlias() && !id->getAlias())
      {
         if((strcmp(id2->m_name.c_str(),id->m_name.c_str())==0) &&
            (strcmp(id2->m_context.c_str(),id->m_context.c_str())==0))
            return false;
      }
      id2=(cIdentifier *)id2->getNext();
   }
   m_attrLst.append((cListItem *)id);
   return true;
}

void cAstCodeBlockNode::print()
{
   printf("%s",tokenStr[getID()]);
}

// cAstIntNode is leaf node that represents an integer constant 

INSTANTIATE_OBJECT(cAstIntNode);
cAstIntNode::cAstIntNode(eTOKEN token,const char * d) :
cAstTokenNode(token)
{
   if(memcmp(d,"0x",2)==0 || memcmp(d,"0X",2)==0)
   {
      if(sscanf(d,"%x",&m_i) != 1)
         yyerror("Invalid numeric constant");
      m_isUnsigned=true;
   }
   else
   {
      m_i=atoi(d);
      m_isUnsigned=false;
   }
   m_genIdentifier=0;
}

cAstIntNode::cAstIntNode(eTOKEN token,int d) :
cAstTokenNode(token)
{
   m_i=d;
   m_isUnsigned=false;
   m_genIdentifier=0;
}

int cAstIntNode::getIntValue()
{
   return m_i;
}

void cAstIntNode::print()
{
   printf("%s:%d",tokenStr[getID()],getIntValue());
}

// cAstFloatNode is leaf node that represents a float constant

INSTANTIATE_OBJECT(cAstFloatNode);
cAstFloatNode::cAstFloatNode(eTOKEN token,float d) :
   cAstTokenNode(token)
{
   m_tokenid=token;
   m_f=d;
}

float cAstFloatNode::getFloatValue()
{
   return m_f;
}

void cAstFloatNode::print()
{
   printf("%s:%f",tokenStr[getID()],getFloatValue());
}

// cAstStringNode is leaf node that represents a string literal

INSTANTIATE_OBJECT(cAstStringNode);
cAstStringNode::cAstStringNode(eTOKEN token,const char *_s) :
   cAstTokenNode(token),m_s(0)
{
   char *s2;
   s2=new char[strlen(_s)+1];
   strcpy(s2,_s);
   m_s=s2;
}

cAstStringNode::~cAstStringNode()
{
   if(m_s)
      delete [] m_s;
}

char *cAstStringNode::getStringValue()
{
   return m_s;
}

void cAstStringNode::print()
{
   printf("%s:%s",tokenStr[getID()],getStringValue());
}

// cAstIdentifierNode is leaf node that represents identifier such as
// variables.

INSTANTIATE_OBJECT(cAstIdentifierNode);
cAstIdentifierNode::cAstIdentifierNode(eTOKEN token,const char *s) :
   cAstStringNode(token,s),m_id(0)
{
}

cAstIdentifierNode::~cAstIdentifierNode()
{
   if(m_id)
      delete m_id;
}

cIdentifier *cAstIdentifierNode::getIdentifier()
{
   return m_id;
}

void cAstIdentifierNode::setIdentifier(cIdentifier *_id)
{
   m_id=_id;
}

void cAstIdentifierNode::print()
{
   printf("%s:%s",tokenStr[getID()],getStringValue());
}

// cAstTokenNode is leaf node that is not identifier or constants

INSTANTIATE_OBJECT(cAstTokenNode);
cAstTokenNode::cAstTokenNode(eTOKEN token,int tokenParm) :
   cAstNode(token)
{
   m_tokenParm=tokenParm;
}

void cAstTokenNode::print()
{
   printf("%s:",tokenStr[getID()]);
}


// Return the AST definition of a function

cAstNode *cAstNode::GetFunction(cAstNode *_root,char *funcName)
{
   cAstNode *func;
   cAstNode *node;
   func=(cAstNode *)_root->getChildList();
   while(func)
   {
      if(func->getID()==eTOKEN_function_definition2)
      {
         node=func->getChild(3,eTOKEN_declarator,eTOKEN_direct_declarator12,eTOKEN_IDENTIFIER);
         if(!node)
            node=func->getChild(2,eTOKEN_declarator,eTOKEN_IDENTIFIER);
         if(strcmp(CAST(cAstStringNode,node)->getStringValue(),funcName)==0)
            return func;
      }
      func=(cAstNode *)func->getNext();
   }
   return 0;
}

// Display AST tree

void cAstNode::Print(cAstNode *node,int lvl,int *lvlFlag)
{
   int i;
   cAstNode *node2;

   printf("\n");
   for(i=0;i < lvl;i++)
   {
      if(i==(lvl-1))
         printf("  +");
      else
      {
         if(lvlFlag[i])
         {
            printf("  |");
         }
         else
            printf("   ");
      }
   }
   node->print();
   node2=(cAstNode *)node->getChildList();
   while(node2)
   {
      if( !node2->getNext())
         lvlFlag[lvl]=0;
      else
         lvlFlag[lvl]=1;
      cAstNode::Print(node2,lvl+1,lvlFlag);
      node2=(cAstNode *)node2->getNext();
   }
}

// Find an AST node by navigating the AST tree

cAstNode *cAstNode::getChild(int numnodes,...)
{
   cAstNode *parent;
   va_list arguments; 
   cAstNode *node;
   eTOKEN id;
   int i;
   bool found;
   parent=this;
   va_start(arguments,numnodes); 
   for(i=0;i < numnodes;i++)
   {
      id=(eTOKEN)va_arg(arguments,int);
      node=(cAstNode *)parent->getChildList();
      found=false;
      while(node)
      {
         if(node->m_tokenid==id)
         {
            if(i==(numnodes-1))
               return node;
            else
            {
               found=true;
               parent=node;
               node=0;
               break;
            }
         }
         if(node)
            node=(cAstNode *)node->getNext();
      }
      if(!found)
         return 0;
   }
   va_end(arguments);
   return 0;
}
