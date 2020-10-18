%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
extern int yyerror(char *s);
extern int yylex(void);
extern char *yytext;
extern cAstNode *root;
%}
%union {
 void *a;
}

%token	IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
%token	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN
%token	TYPEDEF_NAME ENUM_CONSTANT

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE KERNEL CLASS NT1 NT2 NT4 NT8 NT16
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT FLOAT2 FLOAT4 FLOAT8 FLOAT16 DOUBLE VOID RESULT POINTER_SCOPE
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM ELLIPSIS

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT SHARE GLOBAL

%type <a> identifier i_constant f_constant string_literal func_name sizeof
%type <a> ptr_op inc_op dec_op left_op right_op le_op ge_op eq_op ne_op
%type <a> and_op or_op mul_assign div_assign mod_assign add_assign
%type <a> sub_assign left_assign right_assign and_assign
%type <a> xor_assign or_assign
%type <a> typedef_name enum_constant
%type <a> typedef extern static auto register inline kernel
%type <a> nt1 nt2 nt4 nt8 nt16 class_declaration class_specifier class class_declaration_list class_name
%type <a> const restrict volatile
%type <a> bool char short int long signed unsigned float float2 float4 float8 float16 double void result pointer_scope
%type <a> complex imaginary 
%type <a> struct union enum ellipsis
%type <a> case default if else switch while do for goto continue break return
%type <a> alignas alignof atomic generic noreturn static_assert share global

%type <a> primary_expression constant enumeration_constant string generic_selection generic_assoc_list
%type <a> generic_association postfix_expression argument_expression_list unary_expression unary_operator
%type <a> cast_expression multiplicative_expression additive_expression shift_expression relational_expression
%type <a> equality_expression and_expression exclusive_or_expression inclusive_or_expression logical_and_expression
%type <a> logical_or_expression conditional_expression assignment_expression assignment_operator expression
%type <a> constant_expression declaration declaration_specifiers init_declarator_list init_declarator
%type <a> storage_class_specifier type_specifier struct_or_union_specifier struct_or_union struct_declaration_list
%type <a> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator enum_specifier enumerator_list
%type <a> enumerator atomic_type_specifier type_qualifier function_specifier alignment_specifier declarator
%type <a> direct_declarator pointer type_qualifier_list parameter_type_list parameter_list parameter_declaration
%type <a> identifier_list type_name abstract_declarator direct_abstract_declarator initializer initializer_list
%type <a> designation designator_list designator static_assert_declaration statement labeled_statement compound_statement
%type <a> block_item_list block_item expression_statement selection_statement iteration_statement jump_statement
%type <a> translation_unit external_declaration function_definition declaration_list
%type <a> pointer_scope_list
%start translation_unit

%%

identifier : IDENTIFIER {$$=ast_newidentifier(eTOKEN_IDENTIFIER,yytext);}; 
i_constant : I_CONSTANT {$$=ast_newint(eTOKEN_I_CONSTANT,yytext);};
f_constant : F_CONSTANT {$$=ast_newfloat(eTOKEN_F_CONSTANT,yytext);};
string_literal : STRING_LITERAL {$$=ast_newstring(eTOKEN_STRING_LITERAL,yytext);};
func_name : FUNC_NAME  {$$=ast_newtoken(eTOKEN_FUNC_NAME,0);};
sizeof : SIZEOF {$$=ast_newtoken(eTOKEN_SIZEOF,0);};
ptr_op : PTR_OP {$$=ast_newtoken(eTOKEN_PTR_OP,0);};
inc_op : INC_OP {$$=ast_newtoken(eTOKEN_INC_OP,0);};
dec_op : DEC_OP {$$=ast_newtoken(eTOKEN_DEC_OP,0);};
left_op : LEFT_OP {$$=ast_newtoken(eTOKEN_LEFT_OP,0);};
right_op : RIGHT_OP {$$=ast_newtoken(eTOKEN_RIGHT_OP,0);};
le_op : LE_OP {$$=ast_newtoken(eTOKEN_LE_OP,0);};
ge_op : GE_OP {$$=ast_newtoken(eTOKEN_GE_OP,0);};
eq_op : EQ_OP {$$=ast_newtoken(eTOKEN_EQ_OP,0);};
ne_op : NE_OP {$$=ast_newtoken(eTOKEN_NE_OP,0);};
and_op : AND_OP {$$=ast_newtoken(eTOKEN_AND_OP,0);};
or_op : OR_OP {$$=ast_newtoken(eTOKEN_OR_OP,0);};
mul_assign : MUL_ASSIGN {$$=ast_newtoken(eTOKEN_MUL_ASSIGN,0);};
div_assign : DIV_ASSIGN {$$=ast_newtoken(eTOKEN_DIV_ASSIGN,0);};
mod_assign : MOD_ASSIGN {$$=ast_newtoken(eTOKEN_MOD_ASSIGN,0);};
add_assign : ADD_ASSIGN {$$=ast_newtoken(eTOKEN_ADD_ASSIGN,0);};
sub_assign : SUB_ASSIGN {$$=ast_newtoken(eTOKEN_SUB_ASSIGN,0);};
left_assign : LEFT_ASSIGN {$$=ast_newtoken(eTOKEN_LEFT_ASSIGN,0);};
right_assign : RIGHT_ASSIGN {$$=ast_newtoken(eTOKEN_RIGHT_ASSIGN,0);};
and_assign : AND_ASSIGN {$$=ast_newtoken(eTOKEN_AND_ASSIGN,0);};
xor_assign : XOR_ASSIGN {$$=ast_newtoken(eTOKEN_XOR_ASSIGN,0);};
or_assign : OR_ASSIGN {$$=ast_newtoken(eTOKEN_OR_ASSIGN,0);};
typedef_name : TYPEDEF_NAME {$$=ast_newstring(eTOKEN_TYPEDEF_NAME,yytext);};
enum_constant : ENUM_CONSTANT {$$=ast_newstring(eTOKEN_ENUMERATION_CONSTANT,yytext);};
typedef : TYPEDEF {$$=ast_newtoken(eTOKEN_TYPEDEF,0);};
extern : EXTERN {$$=ast_newtoken(eTOKEN_EXTERN,0);};
static : STATIC {$$=ast_newtoken(eTOKEN_STATIC,0);};
auto : AUTO {$$=ast_newtoken(eTOKEN_AUTO,0);};
register : REGISTER {$$=ast_newtoken(eTOKEN_REGISTER,0);}; 
inline : INLINE {$$=ast_newtoken(eTOKEN_INLINE,0);};
kernel : KERNEL {$$=ast_newtoken(eTOKEN_KERNEL,0);};
class : CLASS {$$=ast_newtoken(eTOKEN_CLASS,0);};
nt1 : NT1 {$$=ast_newtoken(eTOKEN_NT1,0);};
nt2 : NT2 {$$=ast_newtoken(eTOKEN_NT2,0);};
nt4 : NT4 {$$=ast_newtoken(eTOKEN_NT4,0);};
nt8 : NT8 {$$=ast_newtoken(eTOKEN_NT8,0);};
nt16 : NT16 {$$=ast_newtoken(eTOKEN_NT16,0);};
const : CONST {$$=ast_newtoken(eTOKEN_CONST,0);};
restrict : RESTRICT {$$=ast_newtoken(eTOKEN_RESTRICT,0);}; 
volatile : VOLATILE {$$=ast_newtoken(eTOKEN_VOLATILE,0);};
bool : BOOL {$$=ast_newtoken(eTOKEN_BOOL,0);};
char : CHAR {$$=ast_newtoken(eTOKEN_CHAR,0);};
short : SHORT {$$=ast_newtoken(eTOKEN_SHORT,0);};
int : INT {$$=ast_newtoken(eTOKEN_INT,0);};
long : LONG {$$=ast_newtoken(eTOKEN_LONG,0);};
signed : SIGNED {$$=ast_newtoken(eTOKEN_SIGNED,0);};
unsigned : UNSIGNED {$$=ast_newtoken(eTOKEN_UNSIGNED,0);};
float : FLOAT {$$=ast_newtoken(eTOKEN_FLOAT,0);};
float2 : FLOAT2 {$$=ast_newtoken(eTOKEN_FLOAT,1);};
float4 : FLOAT4 {$$=ast_newtoken(eTOKEN_FLOAT,2);};
float8 : FLOAT8 {$$=ast_newtoken(eTOKEN_FLOAT,3);};
float16 : FLOAT16 {$$=ast_newtoken(eTOKEN_FLOAT,4);};
double : DOUBLE {$$=ast_newtoken(eTOKEN_DOUBLE,0);};
void : VOID {$$=ast_newtoken(eTOKEN_VOID,0);};
result : RESULT {$$=ast_newtoken(eTOKEN_RESULT,0);};
complex : COMPLEX {$$=ast_newtoken(eTOKEN_COMPLEX,0);};
imaginary : IMAGINARY {$$=ast_newtoken(eTOKEN_IMAGINARY,0);}; 
struct : STRUCT {$$=ast_newtoken(eTOKEN_STRUCT,0);};
union : UNION {$$=ast_newtoken(eTOKEN_UNION,0);};
enum : ENUM {$$=ast_newtoken(eTOKEN_ENUM,0);};
ellipsis : ELLIPSIS {$$=ast_newtoken(eTOKEN_ELLIPSIS,0);};
case : CASE {$$=ast_newtoken(eTOKEN_CASE,0);};
default : DEFAULT {$$=ast_newtoken(eTOKEN_DEFAULT,0);};
if : IF {$$=ast_newtoken(eTOKEN_IF,0);};
else : ELSE {$$=ast_newtoken(eTOKEN_ELSE,0);}; 
switch : SWITCH {$$=ast_newtoken(eTOKEN_SWITCH,0);}; 
while : WHILE  {$$=ast_newtoken(eTOKEN_WHILE,0);};
do : DO  {$$=ast_newtoken(eTOKEN_DO,0);};
for : FOR  {$$=ast_newtoken(eTOKEN_FOR,0);};
goto : GOTO  {$$=ast_newtoken(eTOKEN_GOTO,0);};
continue : CONTINUE {$$=ast_newtoken(eTOKEN_CONTINUE,0);}; 
break : BREAK  {$$=ast_newtoken(eTOKEN_BREAK,0);};
return : RETURN {$$=ast_newtoken(eTOKEN_RETURN,0);};
alignas : ALIGNAS  {$$=ast_newtoken(eTOKEN_ALIGNAS,0);};
alignof : ALIGNOF {$$=ast_newtoken(eTOKEN_ALIGNOF,0);};
atomic : ATOMIC  {$$=ast_newtoken(eTOKEN_ATOMIC,0);};
generic : GENERIC  {$$=ast_newtoken(eTOKEN_GENERIC,0);};
noreturn : NORETURN  {$$=ast_newtoken(eTOKEN_NORETURN,0);};
static_assert : STATIC_ASSERT {$$=ast_newtoken(eTOKEN_STATIC_ASSERT,0);}; 
share : SHARE {$$=ast_newtoken(eTOKEN_SHARE,0);};
global : GLOBAL {$$=ast_newtoken(eTOKEN_GLOBAL,0);};

primary_expression
	: identifier {$$=ast_newnode(eTOKEN_primary_expression,1,$1);}
	| constant {$$=ast_newnode(eTOKEN_primary_expression,1,$1);}
	| string {$$=ast_newnode(eTOKEN_primary_expression,1,$1);}
	| '(' expression ')' {$$=ast_newnode(eTOKEN_primary_expression,1,$2);}
	| generic_selection {$$=ast_newnode(eTOKEN_primary_expression,1,$1);}
	;

constant
	: i_constant {$$=ast_newnode(eTOKEN_constant,1,$1);}
	| f_constant {$$=ast_newnode(eTOKEN_constant,1,$1);}
	| enum_constant {$$=ast_newnode(eTOKEN_constant,1,$1);}	/* after it has been defined as such */
	;

enumeration_constant		/* before it has been defined as such */
	: identifier {$$=ast_newnode(eTOKEN_enumeration_constant,1,$1);}
	;

string
	: string_literal {$$=ast_newnode(eTOKEN_string,1,$1);}
	| func_name {$$=ast_newnode(eTOKEN_string,1,$1);}
	;

generic_selection
	: generic '(' assignment_expression ',' generic_assoc_list ')' {$$=ast_newnode(eTOKEN_generic_selection,3,$1,$3,$5);}
	;

generic_assoc_list
	: generic_association {$$=ast_newnode(eTOKEN_generic_assoc_list,1,$1);}
	| generic_assoc_list ',' generic_association {$$=ast_newnode(eTOKEN_generic_assoc_list,2,$1,$3);}
	;

generic_association
	: type_name ':' assignment_expression {$$=ast_newnode(eTOKEN_generic_association,2,$1,$3);}
	| default ':' assignment_expression {$$=ast_newnode(eTOKEN_generic_association,2,$1,$3);}
	;

postfix_expression
	: primary_expression {$$=ast_newnode(eTOKEN_postfix_expression1,1,$1);}
	| postfix_expression '[' expression ']' {$$=ast_newnode(eTOKEN_postfix_expression2,2,$1,$3);}
	| postfix_expression '(' ')' {$$=ast_newnode(eTOKEN_postfix_expression3,1,$1);}
	| postfix_expression '(' argument_expression_list ')' {$$=ast_newnode(eTOKEN_postfix_expression4,2,$1,$3);}
	| postfix_expression '.' identifier {$$=ast_newnode(eTOKEN_postfix_expression5,2,$1,$3);}
	| postfix_expression ptr_op identifier {$$=ast_newnode(eTOKEN_postfix_expression6,3,$1,$2,$3);}
	| postfix_expression inc_op {$$=ast_newnode(eTOKEN_postfix_expression7,2,$1,$2);}
	| postfix_expression dec_op {$$=ast_newnode(eTOKEN_postfix_expression8,2,$1,$2);}
	| '(' type_name ')' '{' initializer_list '}' {$$=ast_newnode(eTOKEN_postfix_expression9,2,$2,$5);}
	| '(' type_name ')' '{' initializer_list ',' '}' {$$=ast_newnode(eTOKEN_postfix_expression10,2,$2,$5);}
	;

argument_expression_list
	: assignment_expression {$$=ast_newnode(eTOKEN_argument_expression_list,1,$1);}
	| argument_expression_list ',' assignment_expression {$$=ast_newnode(eTOKEN_argument_expression_list,2,$1,$3);}
	;

unary_expression
	: postfix_expression {$$=ast_newnode(eTOKEN_unary_expression,1,$1);}
	| inc_op unary_expression {$$=ast_newnode(eTOKEN_unary_expression,2,$1,$2);}
	| dec_op unary_expression {$$=ast_newnode(eTOKEN_unary_expression,2,$1,$2);}
	| unary_operator cast_expression {$$=ast_newnode(eTOKEN_unary_expression,2,$1,$2);}
	| sizeof unary_expression {$$=ast_newnode(eTOKEN_unary_expression,2,$1,$2);}
	| sizeof '(' type_name ')' {$$=ast_newnode(eTOKEN_unary_expression,2,$1,$3);}
	| alignof '(' type_name ')' {$$=ast_newnode(eTOKEN_unary_expression,2,$1,$3);}
	;

unary_operator
	: '&' {$$=ast_newstring(eTOKEN_unary_operator,"&");}
	| '*' {$$=ast_newstring(eTOKEN_unary_operator,"*");}
	| '+' {$$=ast_newstring(eTOKEN_unary_operator,"+");}
	| '-' {$$=ast_newstring(eTOKEN_unary_operator,"-");}
	| '~' {$$=ast_newstring(eTOKEN_unary_operator,"~");}
	| '!' {$$=ast_newstring(eTOKEN_unary_operator,"!");}
	;

cast_expression
	: unary_expression {$$=ast_newnode(eTOKEN_cast_expression,1,$1);}
	| '(' type_name ')' cast_expression {$$=ast_newnode(eTOKEN_cast_expression,2,$2,$4);}
	;

multiplicative_expression
	: cast_expression {$$=ast_newnode(eTOKEN_multiplicative_expression,1,$1);}
	| multiplicative_expression '*' cast_expression {$$=ast_newnode(eTOKEN_multiplicative_expression_mul,2,$1,$3);}
	| multiplicative_expression '/' cast_expression {$$=ast_newnode(eTOKEN_multiplicative_expression_div,2,$1,$3);}
	| multiplicative_expression '%' cast_expression {$$=ast_newnode(eTOKEN_multiplicative_expression_mod,2,$1,$3);}
	;

additive_expression
	: multiplicative_expression {$$=ast_newnode(eTOKEN_additive_expression,1,$1);}
	| additive_expression '+' multiplicative_expression {$$=ast_newnode(eTOKEN_additive_expression_add,2,$1,$3);}
	| additive_expression '-' multiplicative_expression {$$=ast_newnode(eTOKEN_additive_expression_sub,2,$1,$3);}
	;

shift_expression
	: additive_expression {$$=ast_newnode(eTOKEN_shift_expression,1,$1);}
	| shift_expression left_op additive_expression {$$=ast_newnode(eTOKEN_shift_expression_shl,2,$1,$3);}
	| shift_expression right_op additive_expression {$$=ast_newnode(eTOKEN_shift_expression_shr,2,$1,$3);}
	;

relational_expression
	: shift_expression {$$=ast_newnode(eTOKEN_relational_expression,1,$1);}
	| relational_expression '<' shift_expression {$$=ast_newnode(eTOKEN_relational_expression_lt,2,$1,$3);}
	| relational_expression '>' shift_expression {$$=ast_newnode(eTOKEN_relational_expression_gt,2,$1,$3);}
	| relational_expression le_op shift_expression {$$=ast_newnode(eTOKEN_relational_expression_le,2,$1,$3);}
	| relational_expression ge_op shift_expression {$$=ast_newnode(eTOKEN_relational_expression_ge,2,$1,$3);}
	;

equality_expression
	: relational_expression {$$=ast_newnode(eTOKEN_equality_expression,1,$1);}
	| equality_expression eq_op relational_expression {$$=ast_newnode(eTOKEN_equality_expression_eq,2,$1,$3);}
	| equality_expression ne_op relational_expression {$$=ast_newnode(eTOKEN_equality_expression_ne,2,$1,$3);}
	;

and_expression
	: equality_expression {$$=ast_newnode(eTOKEN_and_expression,1,$1);}
	| and_expression '&' equality_expression {$$=ast_newnode(eTOKEN_and_expression,2,$1,$3);}
	;

exclusive_or_expression
	: and_expression {$$=ast_newnode(eTOKEN_exclusive_or_expression,1,$1);}
	| exclusive_or_expression '^' and_expression {$$=ast_newnode(eTOKEN_exclusive_or_expression,2,$1,$3);}
	;

inclusive_or_expression
	: exclusive_or_expression {$$=ast_newnode(eTOKEN_inclusive_or_expression,1,$1);}
	| inclusive_or_expression '|' exclusive_or_expression {$$=ast_newnode(eTOKEN_inclusive_or_expression,2,$1,$3);}
	;

logical_and_expression
	: inclusive_or_expression {$$=ast_newnode(eTOKEN_logical_and_expression,1,$1);}
	| logical_and_expression and_op inclusive_or_expression {$$=ast_newnode(eTOKEN_logical_and_expression,2,$1,$3);}
	;

logical_or_expression
	: logical_and_expression {$$=ast_newnode(eTOKEN_logical_or_expression,1,$1);}
	| logical_or_expression or_op logical_and_expression {$$=ast_newnode(eTOKEN_logical_or_expression,2,$1,$3);}
	;

conditional_expression
	: logical_or_expression {$$=ast_newnode(eTOKEN_conditional_expression,1,$1);}
	| logical_or_expression '?' expression ':' conditional_expression {$$=ast_newnode(eTOKEN_conditional_expression,3,$1,$3,$5);}
	;

assignment_expression
	: conditional_expression {$$=ast_newnode(eTOKEN_assignment_expression,1,$1);}
	| unary_expression assignment_operator assignment_expression {$$=ast_newnode(eTOKEN_assignment_expression,3,$1,$2,$3);}
	;

assignment_operator
	: '=' {$$=ast_newtoken(eTOKEN_assignment_operator,0);}
	| mul_assign {$$=ast_newnode(eTOKEN_assignment_operator_mul,1,$1);}
	| div_assign {$$=ast_newnode(eTOKEN_assignment_operator_div,1,$1);}
	| mod_assign {$$=ast_newnode(eTOKEN_assignment_operator_mod,1,$1);}
	| add_assign {$$=ast_newnode(eTOKEN_assignment_operator_add,1,$1);}
	| sub_assign {$$=ast_newnode(eTOKEN_assignment_operator_sub,1,$1);}
	| left_assign {$$=ast_newnode(eTOKEN_assignment_operator_left,1,$1);}
	| right_assign {$$=ast_newnode(eTOKEN_assignment_operator_right,1,$1);}
	| and_assign {$$=ast_newnode(eTOKEN_assignment_operator_and,1,$1);}
	| xor_assign {$$=ast_newnode(eTOKEN_assignment_operator_xor,1,$1);}
	| or_assign {$$=ast_newnode(eTOKEN_assignment_operator_or,1,$1);}
	;

expression
	: assignment_expression {$$=ast_newnode(eTOKEN_expression,1,$1);}
	| expression ',' assignment_expression {$$=ast_newnode(eTOKEN_expression,2,$1,$3);}
	;

constant_expression
	: conditional_expression {$$=ast_newnode(eTOKEN_constant_expression,1,$1);}	/* with constraints */
	;

declaration
	: declaration_specifiers ';' {$$=ast_newnode(eTOKEN_declaration,1,$1);}
	| declaration_specifiers init_declarator_list ';' {$$=ast_newnode(eTOKEN_declaration,2,$1,$2);}
	| static_assert_declaration {$$=ast_newnode(eTOKEN_declaration,1,$1);}
	| class_declaration {$$=ast_newnode(eTOKEN_declaration,1,$1);}
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers {$$=ast_newnode(eTOKEN_declaration_specifiers,2,$1,$2);}
	| storage_class_specifier {$$=ast_newnode(eTOKEN_declaration_specifiers,1,$1);}
	| type_specifier declaration_specifiers {$$=ast_newnode(eTOKEN_declaration_specifiers,2,$1,$2);}
	| type_specifier {$$=ast_newnode(eTOKEN_declaration_specifiers,1,$1);}
	| type_qualifier declaration_specifiers {$$=ast_newnode(eTOKEN_declaration_specifiers,2,$1,$2);}
	| type_qualifier {$$=ast_newnode(eTOKEN_declaration_specifiers,1,$1);}
	| function_specifier declaration_specifiers {$$=ast_newnode(eTOKEN_declaration_specifiers,2,$1,$2);}
	| function_specifier {$$=ast_newnode(eTOKEN_declaration_specifiers,1,$1);}
	| alignment_specifier declaration_specifiers {$$=ast_newnode(eTOKEN_declaration_specifiers,2,$1,$2);}
	| alignment_specifier {$$=ast_newnode(eTOKEN_declaration_specifiers,1,$1);}
	;

init_declarator_list
	: init_declarator {$$=ast_newnode(eTOKEN_init_declarator_list,1,$1);}
	| init_declarator_list ',' init_declarator {$$=ast_newnode(eTOKEN_init_declarator_list,2,$1,$3);}
	;

init_declarator
	: declarator '=' initializer {$$=ast_newnode(eTOKEN_init_declarator,2,$1,$3);}
	| declarator {$$=ast_newnode(eTOKEN_init_declarator,1,$1);}
	;

storage_class_specifier
	: typedef {$$=ast_newnode(eTOKEN_storage_class_specifier,1,$1);}	/* identifiers must be flagged as typedef_name */
	| extern {$$=ast_newnode(eTOKEN_storage_class_specifier,1,$1);}
	| static {$$=ast_newnode(eTOKEN_storage_class_specifier,1,$1);}
	| share {$$=ast_newnode(eTOKEN_storage_class_specifier,1,$1);}
	| global {$$=ast_newnode(eTOKEN_storage_class_specifier,1,$1);}
	| auto {$$=ast_newnode(eTOKEN_storage_class_specifier,1,$1);}
	| register {$$=ast_newnode(eTOKEN_storage_class_specifier,1,$1);}
	;

type_specifier
	: void {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| char {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| short {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| int {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| long {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| float {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| float2 {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| float4 {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| float8 {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| float16 {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| double {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| signed {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| unsigned {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| bool {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| complex {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| imaginary	 {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}  	/* non-mandated extension */
	| atomic_type_specifier {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| struct_or_union_specifier {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| enum_specifier {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| typedef_name {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}		/* after it has been defined as such */
	| result {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	| pointer_scope {$$=ast_newnode(eTOKEN_type_specifier,1,$1);}
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}' {$$=ast_newnode(eTOKEN_struct_or_union_specifier,2,$1,$3);}
	| struct_or_union identifier '{' struct_declaration_list '}' {$$=ast_newnode(eTOKEN_struct_or_union_specifier,3,$1,$2,$4);}
	| struct_or_union identifier {$$=ast_newnode(eTOKEN_struct_or_union_specifier,2,$1,$2);}
	;

struct_or_union
	: struct {$$=ast_newnode(eTOKEN_struct_or_union,1,$1);}
	| union {$$=ast_newnode(eTOKEN_struct_or_union,1,$1);}
	;

struct_declaration_list
	: struct_declaration {$$=ast_newnode(eTOKEN_struct_declaration_list,1,$1);}
	| struct_declaration_list struct_declaration {$$=ast_newnode(eTOKEN_struct_declaration_list,2,$1,$2);}
	;

struct_declaration
	: specifier_qualifier_list ';' {$$=ast_newnode(eTOKEN_struct_declaration,1,$1);}	/* for anonymous struct/union */
	| specifier_qualifier_list struct_declarator_list ';' {$$=ast_newnode(eTOKEN_struct_declaration,2,$1,$2);}
	| static_assert_declaration {$$=ast_newnode(eTOKEN_struct_declaration,1,$1);}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {$$=ast_newnode(eTOKEN_specifier_qualifier_list,2,$1,$2);}
	| type_specifier {$$=ast_newnode(eTOKEN_specifier_qualifier_list,1,$1);}
	| type_qualifier specifier_qualifier_list {$$=ast_newnode(eTOKEN_specifier_qualifier_list,2,$1,$2);}
	| type_qualifier {$$=ast_newnode(eTOKEN_specifier_qualifier_list,1,$1);}
	;

struct_declarator_list
	: struct_declarator {$$=ast_newnode(eTOKEN_struct_declarator_list,1,$1);}
	| struct_declarator_list ',' struct_declarator {$$=ast_newnode(eTOKEN_struct_declarator_list,2,$1,$3);}
	;

struct_declarator
	: ':' constant_expression {$$=ast_newnode(eTOKEN_struct_declarator,1,$2);}
	| declarator ':' constant_expression {$$=ast_newnode(eTOKEN_struct_declarator,2,$1,$3);}
	| declarator {$$=ast_newnode(eTOKEN_struct_declarator,1,$1);}
	;

enum_specifier
	: enum '{' enumerator_list '}' {$$=ast_newnode(eTOKEN_enum_specifier,1,$3);}
	| enum '{' enumerator_list ',' '}' {$$=ast_newnode(eTOKEN_enum_specifier,1,$3);}
	| enum identifier '{' enumerator_list '}' {$$=ast_newnode(eTOKEN_enum_specifier,2,$2,$4);}
	| enum identifier '{' enumerator_list ',' '}' {$$=ast_newnode(eTOKEN_enum_specifier,2,$2,$4);}
	| enum identifier {$$=ast_newnode(eTOKEN_enum_specifier,1,$2);}
	;

enumerator_list
	: enumerator {$$=ast_newnode(eTOKEN_enumerator_list,1,$1);}
	| enumerator_list ',' enumerator {$$=ast_newnode(eTOKEN_enumerator_list,2,$1,$3);}
	;

enumerator	/* identifiers must be flagged as enum_constant */
	: enumeration_constant '=' constant_expression {$$=ast_newnode(eTOKEN_enumerator,2,$1,$3);}
	| enumeration_constant {$$=ast_newnode(eTOKEN_enumerator,1,$1);}
	;

atomic_type_specifier
	: atomic '(' type_name ')' {$$=ast_newnode(eTOKEN_atomic_type_specifier,1,$3);}
	;

type_qualifier
	: const {$$=ast_newnode(eTOKEN_type_qualifier,1,$1);}
	| restrict {$$=ast_newnode(eTOKEN_type_qualifier,1,$1);}
	| volatile {$$=ast_newnode(eTOKEN_type_qualifier,1,$1);}
	| atomic {$$=ast_newnode(eTOKEN_type_qualifier,1,$1);}
	;

function_specifier
	: inline {$$=ast_newnode(eTOKEN_function_specifier,1,$1);}
	| kernel {$$=ast_newnode(eTOKEN_function_specifier,1,$1);}
	| noreturn {$$=ast_newnode(eTOKEN_function_specifier,1,$1);}
	;

class_specifier
	: nt1 {$$=ast_newnode(eTOKEN_class_specifier,1,$1);}
	| nt2 {$$=ast_newnode(eTOKEN_class_specifier,1,$1);}
	| nt4 {$$=ast_newnode(eTOKEN_class_specifier,1,$1);}
	| nt8 {$$=ast_newnode(eTOKEN_class_specifier,1,$1);}
	| nt16 {$$=ast_newnode(eTOKEN_class_specifier,1,$1);}
	;

alignment_specifier
	: alignas '(' type_name ')' {$$=ast_newnode(eTOKEN_alignment_specifier,2,$1,$3);}
	| alignas '(' constant_expression ')' {$$=ast_newnode(eTOKEN_alignment_specifier,2,$1,$3);}
	;

declarator
	: pointer direct_declarator {$$=ast_newnode(eTOKEN_declarator,2,$1,$2);}
	| direct_declarator {$$=ast_newnode(eTOKEN_declarator,1,$1);}
	;

direct_declarator
	: identifier {$$=ast_newnode(eTOKEN_direct_declarator1,1,$1);}
	| '(' declarator ')' {$$=ast_newnode(eTOKEN_direct_declarator2,1,$2);}
	| direct_declarator '[' ']' {$$=ast_newnode(eTOKEN_direct_declarator3,1,$1);}
	| direct_declarator '[' '*' ']' {$$=ast_newnode(eTOKEN_direct_declarator4,1,$1);}
	| direct_declarator '[' static type_qualifier_list assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_declarator5,4,$1,$3,$4,$5);}
	| direct_declarator '[' static assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_declarator6,3,$1,$3,$4);}
	| direct_declarator '[' type_qualifier_list '*' ']' {$$=ast_newnode(eTOKEN_direct_declarator7,2,$1,$3);}
	| direct_declarator '[' type_qualifier_list static assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_declarator8,4,$1,$3,$4,$5);}
	| direct_declarator '[' type_qualifier_list assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_declarator9,3,$1,$3,$4);}
	| direct_declarator '[' type_qualifier_list ']' {$$=ast_newnode(eTOKEN_direct_declarator10,2,$1,$3);}
	| direct_declarator '[' assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_declarator11,2,$1,$3);}
	| direct_declarator '(' parameter_type_list ')' {$$=ast_newnode(eTOKEN_direct_declarator12,2,$1,$3);}
	| direct_declarator '(' ')' {$$=ast_newnode(eTOKEN_direct_declarator13,1,$1);}
	| direct_declarator '(' identifier_list ')' {$$=ast_newnode(eTOKEN_direct_declarator14,2,$1,$3);}
	;

pointer
	: '*' type_qualifier_list pointer {$$=ast_newnode(eTOKEN_pointer,2,$2,$3);}
	| '*' type_qualifier_list {$$=ast_newnode(eTOKEN_pointer,1,$2);}
	| '*' pointer {$$=ast_newnode(eTOKEN_pointer,1,$2);}
	| '*' {$$=ast_newnode(eTOKEN_pointer,0);}
	;

type_qualifier_list
	: type_qualifier {$$=ast_newnode(eTOKEN_type_qualifier_list,1,$1);}
	| type_qualifier_list type_qualifier {$$=ast_newnode(eTOKEN_type_qualifier_list,2,$1,$2);}
	;


parameter_type_list
	: parameter_list ',' ellipsis {$$=ast_newnode(eTOKEN_type_qualifier_list,1,$1);}
	| parameter_list {$$=ast_newnode(eTOKEN_type_qualifier_list,1,$1);}
	;

parameter_list
	: parameter_declaration {$$=ast_newnode(eTOKEN_parameter_list,1,$1);}
	| parameter_list ',' parameter_declaration {$$=ast_newnode(eTOKEN_parameter_list,2,$1,$3);}
	;

parameter_declaration
	: declaration_specifiers declarator {$$=ast_newnode(eTOKEN_parameter_declaration,2,$1,$2);}
	| declaration_specifiers abstract_declarator {$$=ast_newnode(eTOKEN_parameter_declaration,2,$1,$2);}
	| declaration_specifiers {$$=ast_newnode(eTOKEN_parameter_declaration,1,$1);}
	;

identifier_list
	: identifier {$$=ast_newnode(eTOKEN_identifier_list,1,$1);}
	| identifier_list ',' identifier {$$=ast_newnode(eTOKEN_identifier_list,2,$1,$3);}
	;

type_name
	: specifier_qualifier_list abstract_declarator {$$=ast_newnode(eTOKEN_type_name,2,$1,$2);}
	| specifier_qualifier_list {$$=ast_newnode(eTOKEN_type_name,1,$1);}
	;

abstract_declarator
	: pointer direct_abstract_declarator {$$=ast_newnode(eTOKEN_abstract_declarator,2,$1,$2);}
	| pointer {$$=ast_newnode(eTOKEN_abstract_declarator,1,$1);}
	| direct_abstract_declarator {$$=ast_newnode(eTOKEN_abstract_declarator,1,$1);}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,1,$2);}
	| '[' ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,0);}
	| '[' '*' ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,0);}
	| '[' static type_qualifier_list assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,3,$2,$3,$4);}
	| '[' static assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,2,$2,$3);}
	| '[' type_qualifier_list static assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,3,$2,$3,$4);}
	| '[' type_qualifier_list assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,2,$2,$3);}
	| '[' type_qualifier_list ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,1,$2);}
	| '[' assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,1,$2);}
	| direct_abstract_declarator '[' ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,1,$1);}
	| direct_abstract_declarator '[' '*' ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,1,$1);}
	| direct_abstract_declarator '[' static type_qualifier_list assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,3,$1,$3,$4);}
	| direct_abstract_declarator '[' static assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,3,$1,$3,$4);}
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,3,$1,$3,$4);}
	| direct_abstract_declarator '[' type_qualifier_list static assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,4,$1,$3,$4,$5);}
	| direct_abstract_declarator '[' type_qualifier_list ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,2,$1,$3);}
	| direct_abstract_declarator '[' assignment_expression ']' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,2,$1,$3);}
	| '(' ')' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,0);}
	| '(' parameter_type_list ')' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,1,$2);}
	| direct_abstract_declarator '(' ')' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,1,$1);}
	| direct_abstract_declarator '(' parameter_type_list ')' {$$=ast_newnode(eTOKEN_direct_abstract_declarator,2,$1,$3);}
	;

initializer
	: '{' initializer_list '}' {$$=ast_newnode(eTOKEN_initializer,1,$2);}
	| '{' initializer_list ',' '}' {$$=ast_newnode(eTOKEN_initializer,1,$2);}
	| assignment_expression {$$=ast_newnode(eTOKEN_initializer,1,$1);}
	;

initializer_list
	: designation initializer {$$=ast_newnode(eTOKEN_initializer_list,2,$1,$2);}
	| initializer {$$=ast_newnode(eTOKEN_initializer_list,1,$1);}
	| initializer_list ',' designation initializer {$$=ast_newnode(eTOKEN_initializer_list,2,$1,$3);}
	| initializer_list ',' initializer {$$=ast_newnode(eTOKEN_initializer_list,2,$1,$3);}
	;

designation
	: designator_list '=' {$$=ast_newnode(eTOKEN_designation,1,$1);}
	;

designator_list
	: designator {$$=ast_newnode(eTOKEN_designator_list,1,$1);}
	| designator_list designator {$$=ast_newnode(eTOKEN_designator_list,2,$1,$2);}
	;

designator
	: '[' constant_expression ']' {$$=ast_newnode(eTOKEN_designator,1,$2);}
	| '.' identifier {$$=ast_newnode(eTOKEN_designator,1,$2);}
	;

static_assert_declaration
	: static_assert '(' constant_expression ',' string_literal ')' ';' {$$=ast_newnode(eTOKEN_static_assert_declaration,3,$1,$3,$5);}
	;

statement
	: labeled_statement {$$=ast_newnode(eTOKEN_statement,1,$1);}
	| compound_statement {$$=ast_newnode(eTOKEN_statement,1,$1);}
	| expression_statement {$$=ast_newnode(eTOKEN_statement,1,$1);}
	| selection_statement {$$=ast_newnode(eTOKEN_statement,1,$1);}
	| iteration_statement {$$=ast_newnode(eTOKEN_statement,1,$1);}
	| jump_statement {$$=ast_newnode(eTOKEN_statement,1,$1);}
	;

labeled_statement
	: identifier ':' statement {$$=ast_newnode(eTOKEN_labeled_statement,2,$1,$3);}
	| case constant_expression ':' statement {$$=ast_newnode(eTOKEN_labeled_statement,2,$2,$4);}
	| default ':' statement {$$=ast_newnode(eTOKEN_labeled_statement,2,$1,$3);}
	;

compound_statement
	: '{' '}' {$$=ast_newnode(eTOKEN_compound_statement,0);}
	| '{'  block_item_list '}' {$$=ast_newnode(eTOKEN_compound_statement,1,$2);}
	;

block_item_list
	: block_item {$$=ast_newcodeblock(eTOKEN_block_item_list,1,$1);}
	| block_item_list block_item {$$=ast_newcodeblock(eTOKEN_block_item_list,2,$1,$2);}
	;

block_item
	: declaration {$$=ast_newnode(eTOKEN_block_item,1,$1);}
	| statement {$$=ast_newnode(eTOKEN_block_item,1,$1);}
	;

expression_statement
	: ';' {$$=ast_newnode(eTOKEN_expression_statement,0);}
	| expression ';' {$$=ast_newnode(eTOKEN_expression_statement,1,$1);}
	;

selection_statement
	: if '(' expression ')' statement else statement {$$=ast_newnode(eTOKEN_selection_statement,3,$3,$5,$7);}
	| if '(' expression ')' statement {$$=ast_newnode(eTOKEN_selection_statement,2,$3,$5);}
	| switch '(' expression ')' statement {$$=ast_newnode(eTOKEN_switch_statement,2,$3,$5);}
	;

iteration_statement
	: while '(' expression ')' statement {$$=ast_newnode(eTOKEN_iteration_while_statement,2,$3,$5);}
	| do statement while '(' expression ')' ';' {$$=ast_newnode(eTOKEN_iteration_do_while_statement,2,$2,$5);}
	| for '(' expression_statement expression_statement ')' statement {$$=ast_newnode(eTOKEN_iteration_for_statement,4,$1,$3,$4,$6);}
	| for '(' expression_statement expression_statement expression ')' statement {$$=ast_newnode(eTOKEN_iteration_for_statement,5,$1,$3,$4,$5,$7);}
	| for '(' declaration expression_statement ')' statement {$$=ast_newnode(eTOKEN_iteration_for_statement,4,$1,$3,$4,$6);}
	| for '(' declaration expression_statement expression ')' statement {$$=ast_newnode(eTOKEN_iteration_for_statement,5,$1,$3,$4,$5,$7);}
	;

jump_statement
	: goto identifier ';' {$$=ast_newnode(eTOKEN_jump_statement,2,$1,$2);}
	| continue ';' {$$=ast_newnode(eTOKEN_jump_statement,1,$1);}
	| break ';' {$$=ast_newnode(eTOKEN_jump_statement,1,$1);}
	| return ';' {$$=ast_newnode(eTOKEN_jump_statement,1,$1);}
	| return expression ';' {$$=ast_newnode(eTOKEN_jump_statement,2,$1,$2);}
	;

translation_unit
	: external_declaration {$$=ast_newcodeblock(eTOKEN_translation_unit,1,$1);root=$$;}
	| translation_unit external_declaration  {$$=ast_newcodeblock(eTOKEN_translation_unit,2,$1,$2);root=$$;}
	;

external_declaration
	: function_definition {$$=ast_newnode(eTOKEN_external_declaration,1,$1);}
	| declaration {$$=ast_newnode(eTOKEN_external_declaration,1,$1);}
	;

class_name
	: identifier {$$=ast_newnode(eTOKEN_class_name,1,$1);}
	;

class_declaration_list 
	: class_name {$$=ast_newcodeblock(eTOKEN_class_declaration_list,1,$1);}
	| class_declaration_list ',' class_name {$$=ast_newcodeblock(eTOKEN_class_declaration_list,2,$1,$3);}
	;

class_declaration
	: class_specifier class class_declaration_list ';' {$$=ast_newnode(eTOKEN_class_declaration,2,$1,$3);}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement {$$=ast_newnode(eTOKEN_function_definition1,4,$1,$2,$3,$4);}
	| declaration_specifiers declarator compound_statement {$$=ast_newnode(eTOKEN_function_definition2,3,$1,$2,$3);}

declaration_list
	: declaration {$$=ast_newnode(eTOKEN_declaration_list,1,$1);}
	| declaration_list declaration {$$=ast_newnode(eTOKEN_declaration_list,2,$1,$2);}
	;

pointer_scope : POINTER_SCOPE '<' pointer_scope_list '>' {$$=ast_newnode(eTOKEN_POINTER_SCOPE,1,$3);}
    | POINTER_SCOPE {$$=ast_newtoken(eTOKEN_POINTER_SCOPE,0);}
    ;

pointer_scope_list
	: identifier {$$=ast_newnode(eTOKEN_pointer_scope_list,1,$1);}
	| pointer_scope_list ',' identifier {$$=ast_newnode(eTOKEN_pointer_scope_list,2,$1,$3);}
	;


%%
#include <stdio.h>
