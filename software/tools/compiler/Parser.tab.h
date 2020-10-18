/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IDENTIFIER = 258,
    I_CONSTANT = 259,
    F_CONSTANT = 260,
    STRING_LITERAL = 261,
    FUNC_NAME = 262,
    SIZEOF = 263,
    PTR_OP = 264,
    INC_OP = 265,
    DEC_OP = 266,
    LEFT_OP = 267,
    RIGHT_OP = 268,
    LE_OP = 269,
    GE_OP = 270,
    EQ_OP = 271,
    NE_OP = 272,
    AND_OP = 273,
    OR_OP = 274,
    MUL_ASSIGN = 275,
    DIV_ASSIGN = 276,
    MOD_ASSIGN = 277,
    ADD_ASSIGN = 278,
    SUB_ASSIGN = 279,
    LEFT_ASSIGN = 280,
    RIGHT_ASSIGN = 281,
    AND_ASSIGN = 282,
    XOR_ASSIGN = 283,
    OR_ASSIGN = 284,
    TYPEDEF_NAME = 285,
    ENUM_CONSTANT = 286,
    TYPEDEF = 287,
    EXTERN = 288,
    STATIC = 289,
    AUTO = 290,
    REGISTER = 291,
    INLINE = 292,
    KERNEL = 293,
    CLASS = 294,
    NT1 = 295,
    NT2 = 296,
    NT4 = 297,
    NT8 = 298,
    NT16 = 299,
    CONST = 300,
    RESTRICT = 301,
    VOLATILE = 302,
    BOOL = 303,
    CHAR = 304,
    SHORT = 305,
    INT = 306,
    LONG = 307,
    SIGNED = 308,
    UNSIGNED = 309,
    FLOAT = 310,
    FLOAT2 = 311,
    FLOAT4 = 312,
    FLOAT8 = 313,
    FLOAT16 = 314,
    DOUBLE = 315,
    VOID = 316,
    RESULT = 317,
    POINTER_SCOPE = 318,
    COMPLEX = 319,
    IMAGINARY = 320,
    STRUCT = 321,
    UNION = 322,
    ENUM = 323,
    ELLIPSIS = 324,
    CASE = 325,
    DEFAULT = 326,
    IF = 327,
    ELSE = 328,
    SWITCH = 329,
    WHILE = 330,
    DO = 331,
    FOR = 332,
    GOTO = 333,
    CONTINUE = 334,
    BREAK = 335,
    RETURN = 336,
    ALIGNAS = 337,
    ALIGNOF = 338,
    ATOMIC = 339,
    GENERIC = 340,
    NORETURN = 341,
    STATIC_ASSERT = 342,
    SHARE = 343,
    GLOBAL = 344
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 10 "Parser.y" /* yacc.c:1909  */

 void *a;

#line 148 "Parser.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
