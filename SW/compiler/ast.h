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

#ifndef __AST_H__
#define __AST_H__

#include <stdio.h>
#include "object.h"
#include "util.h"

typedef enum
{
   eTOKEN_IDENTIFIER=0,
   eTOKEN_I_CONSTANT,
   eTOKEN_F_CONSTANT,
   eTOKEN_STRING_LITERAL,
   eTOKEN_FUNC_NAME,
   eTOKEN_SIZEOF,
   eTOKEN_PTR_OP,
   eTOKEN_INC_OP,
   eTOKEN_DEC_OP,
   eTOKEN_LEFT_OP,
   eTOKEN_RIGHT_OP,
   eTOKEN_LE_OP,
   eTOKEN_GE_OP,
   eTOKEN_EQ_OP,
   eTOKEN_NE_OP,
   eTOKEN_AND_OP,
   eTOKEN_OR_OP,
   eTOKEN_MUL_ASSIGN,
   eTOKEN_DIV_ASSIGN,
   eTOKEN_MOD_ASSIGN,
   eTOKEN_ADD_ASSIGN,
   eTOKEN_SUB_ASSIGN,
   eTOKEN_LEFT_ASSIGN,
   eTOKEN_RIGHT_ASSIGN,
   eTOKEN_AND_ASSIGN,
   eTOKEN_XOR_ASSIGN,
   eTOKEN_OR_ASSIGN,
   eTOKEN_TYPEDEF_NAME,
   eTOKEN_ENUMERATION_CONSTANT,
   eTOKEN_TYPEDEF,
   eTOKEN_EXTERN,
   eTOKEN_STATIC,
   eTOKEN_AUTO,
   eTOKEN_REGISTER, 
   eTOKEN_INLINE,
   eTOKEN_KERNEL,
   eTOKEN_CLASS,
   eTOKEN_NT1,
   eTOKEN_NT2,
   eTOKEN_NT4,
   eTOKEN_NT8,
   eTOKEN_NT16,
   eTOKEN_CONST,
   eTOKEN_RESTRICT, 
   eTOKEN_VOLATILE,
   eTOKEN_BOOL,
   eTOKEN_CHAR,
   eTOKEN_SHORT,
   eTOKEN_INT,
   eTOKEN_LONG,
   eTOKEN_SIGNED,
   eTOKEN_UNSIGNED,
   eTOKEN_FLOAT,
   eTOKEN_DOUBLE,
   eTOKEN_VOID,
   eTOKEN_RESULT,
   eTOKEN_POINTER_SCOPE,
   eTOKEN_COMPLEX,
   eTOKEN_IMAGINARY, 
   eTOKEN_STRUCT,
   eTOKEN_UNION,
   eTOKEN_ENUM,
   eTOKEN_ELLIPSIS,
   eTOKEN_CASE,
   eTOKEN_DEFAULT,
   eTOKEN_IF,
   eTOKEN_ELSE, 
   eTOKEN_SWITCH, 
   eTOKEN_WHILE,
   eTOKEN_DO,
   eTOKEN_FOR,
   eTOKEN_GOTO,
   eTOKEN_CONTINUE, 
   eTOKEN_BREAK,
   eTOKEN_RETURN,
   eTOKEN_ALIGNAS,
   eTOKEN_ALIGNOF,
   eTOKEN_ATOMIC,
   eTOKEN_GENERIC,
   eTOKEN_NORETURN,
   eTOKEN_STATIC_ASSERT, 
   eTOKEN_SHARE,
   eTOKEN_GLOBAL,

   eTOKEN_translation_unit,
   eTOKEN_primary_expression,
   eTOKEN_constant,
   eTOKEN_enumeration_constant,
   eTOKEN_string,
   eTOKEN_generic_selection,
   eTOKEN_generic_assoc_list,
   eTOKEN_generic_association,
   eTOKEN_postfix_expression1,
   eTOKEN_postfix_expression2,
   eTOKEN_postfix_expression3,
   eTOKEN_postfix_expression4,
   eTOKEN_postfix_expression5,
   eTOKEN_postfix_expression6,
   eTOKEN_postfix_expression7,
   eTOKEN_postfix_expression8,
   eTOKEN_postfix_expression9,
   eTOKEN_postfix_expression10,   
   eTOKEN_argument_expression_list,
   eTOKEN_unary_expression,
   eTOKEN_unary_operator,
   eTOKEN_cast_expression,
   
   eTOKEN_multiplicative_expression,
   eTOKEN_multiplicative_expression_mul,
   eTOKEN_multiplicative_expression_div,
   eTOKEN_multiplicative_expression_mod,
   
   eTOKEN_additive_expression,
   eTOKEN_additive_expression_add,
   eTOKEN_additive_expression_sub,

   eTOKEN_shift_expression,
   eTOKEN_shift_expression_shl,
   eTOKEN_shift_expression_shr,

   eTOKEN_relational_expression,
   eTOKEN_relational_expression_lt,
   eTOKEN_relational_expression_gt,
   eTOKEN_relational_expression_le,
   eTOKEN_relational_expression_ge,

   eTOKEN_equality_expression,
   eTOKEN_equality_expression_eq,
   eTOKEN_equality_expression_ne,

   eTOKEN_and_expression,
   eTOKEN_exclusive_or_expression,
   eTOKEN_inclusive_or_expression,
   eTOKEN_logical_and_expression,
   eTOKEN_logical_or_expression,
   eTOKEN_conditional_expression,
   eTOKEN_assignment_expression,
   eTOKEN_assignment_operator,
   eTOKEN_assignment_operator_mul,
   eTOKEN_assignment_operator_div,
   eTOKEN_assignment_operator_mod,
   eTOKEN_assignment_operator_add,
   eTOKEN_assignment_operator_sub,
   eTOKEN_assignment_operator_left,
   eTOKEN_assignment_operator_right,
   eTOKEN_assignment_operator_and,
   eTOKEN_assignment_operator_xor,
   eTOKEN_assignment_operator_or,
   eTOKEN_expression,
   eTOKEN_constant_expression,
   eTOKEN_declaration,
   eTOKEN_declaration_specifiers,
   eTOKEN_init_declarator_list,
   eTOKEN_init_declarator,
   eTOKEN_storage_class_specifier,
   eTOKEN_type_specifier,
   eTOKEN_struct_or_union_specifier,
   eTOKEN_struct_or_union,
   eTOKEN_struct_declaration_list,
   eTOKEN_struct_declaration,
   eTOKEN_specifier_qualifier_list,
   eTOKEN_struct_declarator_list,
   eTOKEN_struct_declarator,
   eTOKEN_enum_specifier,
   eTOKEN_enumerator_list,
   eTOKEN_enumerator,
   eTOKEN_atomic_type_specifier,
   eTOKEN_type_qualifier,
   eTOKEN_function_specifier,
   eTOKEN_alignment_specifier,
   eTOKEN_declarator,
   eTOKEN_direct_declarator1,
   eTOKEN_direct_declarator2,
   eTOKEN_direct_declarator3,
   eTOKEN_direct_declarator4,
   eTOKEN_direct_declarator5,
   eTOKEN_direct_declarator6,
   eTOKEN_direct_declarator7,
   eTOKEN_direct_declarator8,
   eTOKEN_direct_declarator9,
   eTOKEN_direct_declarator10,
   eTOKEN_direct_declarator11,
   eTOKEN_direct_declarator12,
   eTOKEN_direct_declarator13,
   eTOKEN_direct_declarator14,
   eTOKEN_pointer,
   eTOKEN_type_qualifier_list,
   eTOKEN_parameter_type_list,
   eTOKEN_parameter_list,
   eTOKEN_parameter_declaration,
   eTOKEN_identifier_list,
   eTOKEN_type_name,
   eTOKEN_abstract_declarator,
   eTOKEN_direct_abstract_declarator,
   eTOKEN_initializer,
   eTOKEN_initializer_list,
   eTOKEN_designation,
   eTOKEN_designator_list,
   eTOKEN_designator,
   eTOKEN_static_assert_declaration,
   eTOKEN_statement,
   eTOKEN_labeled_statement,
   eTOKEN_compound_statement,
   eTOKEN_block_item_list,
   eTOKEN_block_item,
   eTOKEN_expression_statement,
   eTOKEN_selection_statement,
   eTOKEN_switch_statement,
   eTOKEN_iteration_for_statement,
   eTOKEN_iteration_while_statement,
   eTOKEN_iteration_do_while_statement,
   eTOKEN_jump_statement,
   eTOKEN_external_declaration,
   eTOKEN_function_definition1,
   eTOKEN_function_definition2,
   eTOKEN_declaration_list,
   eTOKEN_pointer_scope_list,

   eTOKEN_class_specifier,
   eTOKEN_class_name,
   eTOKEN_class_declaration,
   eTOKEN_class_declaration_list,

   eTOKEN_max
} eTOKEN;

extern int error(int lineNo,const char *s);
extern int warning(int lineNo,const char *s);

#define MAX_VAR_DIM  3

class cAstNode;

typedef enum
{ 
   eMemSpacePriv_c=0,
   eMemSpaceShare_c,
   eMemSpaceInteger_c,
   eMemSpacePointer_c,
   eMemSpaceResult_c
} eMemSpace;


class cIdentifier;
class cAstCodeBlockNode;
class cAstNode : public cListItem
{
DECLARE_ROOT_OBJECT(cAstNode);
public:
   cAstNode(eTOKEN token);
   virtual ~cAstNode();
public:
   cAstNode *getChild(int numnodes,...);
   int getID() {return m_tokenid;}
   static void Print(cAstNode *node,int lvl,int *lvlFlag);
   static cAstNode *GetFunction(cAstNode *_root,char *funcName);
   void setCodeBlock(cAstNode *code) {m_code=code;}
   cAstNode *getCodeBlock() {return m_code;}
public:
   // Virtual functions to be override by derived classes
   virtual void print();
   virtual cAstNode *getChildList();
public:
   int m_lineNo;
   std::string m_pragma;
protected:
   eTOKEN m_tokenid;
   cAstNode *m_code;
};

class cAstCompositeNode : public cAstNode
{
DECLARE_OBJECT(cAstCompositeNode,cAstNode);
public:
   cAstCompositeNode(eTOKEN token,int numnodes,cAstNode **lst);
   virtual ~cAstCompositeNode() {}
   virtual cAstNode *getChildList();
   virtual void setChildList(cAstNode *node,cAstNode *beforeItem);
   virtual void setChildrenList(cAstNode *node,cAstNode *beforeItem);
   virtual void print();
private:
   cList m_childLst;
};

#define MAX_STACK_SIZE  32

class cAstCodeBlockNode : public cAstCompositeNode
{
DECLARE_OBJECT(cAstCodeBlockNode,cAstCompositeNode);
public:
   cAstCodeBlockNode(eTOKEN token,int numnodes,cAstNode **lst);
   virtual ~cAstCodeBlockNode() {}
   virtual cIdentifier *getIdentifierList();
   virtual bool setIdentifierList(cIdentifier *id);
   virtual void print();
public:
   cList m_attrLst;
};

class cAstTokenNode : public cAstNode
{
DECLARE_OBJECT(cAstTokenNode,cAstNode);
public:
   cAstTokenNode(eTOKEN token,int tokenParm=0);
   virtual ~cAstTokenNode() {}
   virtual void print();
public:
   int m_tokenParm;
};

class cIdentifierInteger;
class cAstIntNode : public cAstTokenNode
{
DECLARE_OBJECT(cAstIntNode,cAstTokenNode);
public:
   cAstIntNode(eTOKEN token,const char *d);
   cAstIntNode(eTOKEN token,int d);
   virtual ~cAstIntNode() {}
   virtual int getIntValue();
   virtual void print();
public:
   bool m_isUnsigned;
   cIdentifierInteger *m_genIdentifier;
   int m_i;
};

class cAstFloatNode : public cAstTokenNode
{
DECLARE_OBJECT(cAstFloatNode,cAstTokenNode);
public:
   cAstFloatNode(eTOKEN token,float d);
   virtual ~cAstFloatNode() {}
   virtual float getFloatValue();
   virtual void print();
private:
   float m_f;
};

class cAstStringNode : public cAstTokenNode
{
DECLARE_OBJECT(cAstStringNode,cAstTokenNode);
public:
   cAstStringNode(eTOKEN token,const char *s);
   virtual ~cAstStringNode();
   virtual char *getStringValue();
   virtual void print();
private:
   char *m_s;
};

class cAstIdentifierNode: public cAstStringNode
{
DECLARE_OBJECT(cAstIdentifierNode,cAstStringNode);
public:
   cAstIdentifierNode(eTOKEN token,const char *s);
   virtual ~cAstIdentifierNode();
   virtual cIdentifier *getIdentifier();
   virtual void setIdentifier(cIdentifier *attr);
   virtual void print();
public:
   cIdentifier *m_id;
};

extern void ast_pragma(char *s);
extern cAstCompositeNode *ast_newnode(eTOKEN token,int numnodes,...);
extern cAstCodeBlockNode *ast_newcodeblock(eTOKEN token,int numnodes,...);
extern cAstIntNode *ast_newint(eTOKEN token,const char *d);
extern cAstFloatNode *ast_newfloat(eTOKEN token,const char *d);
extern cAstStringNode *ast_newstring(eTOKEN token,const char *s);
extern cAstTokenNode *ast_newtoken(eTOKEN token,int parm);
extern cAstIdentifierNode *ast_newidentifier(eTOKEN token,const char *s);
extern cAstNode *root;
extern char pragma[];
extern int pragmaDefined;
extern int pragmaUsed;
extern int yylineno;
extern int yyerror(const char *s);
extern int yyparse(void);
extern FILE *yyin;


#endif
