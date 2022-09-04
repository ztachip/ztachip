/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    IDENTIFIER = 258,              /* IDENTIFIER  */
    I_CONSTANT = 259,              /* I_CONSTANT  */
    F_CONSTANT = 260,              /* F_CONSTANT  */
    STRING_LITERAL = 261,          /* STRING_LITERAL  */
    FUNC_NAME = 262,               /* FUNC_NAME  */
    SIZEOF = 263,                  /* SIZEOF  */
    PTR_OP = 264,                  /* PTR_OP  */
    INC_OP = 265,                  /* INC_OP  */
    DEC_OP = 266,                  /* DEC_OP  */
    LEFT_OP = 267,                 /* LEFT_OP  */
    RIGHT_OP = 268,                /* RIGHT_OP  */
    LE_OP = 269,                   /* LE_OP  */
    GE_OP = 270,                   /* GE_OP  */
    EQ_OP = 271,                   /* EQ_OP  */
    NE_OP = 272,                   /* NE_OP  */
    AND_OP = 273,                  /* AND_OP  */
    OR_OP = 274,                   /* OR_OP  */
    MUL_ASSIGN = 275,              /* MUL_ASSIGN  */
    DIV_ASSIGN = 276,              /* DIV_ASSIGN  */
    MOD_ASSIGN = 277,              /* MOD_ASSIGN  */
    ADD_ASSIGN = 278,              /* ADD_ASSIGN  */
    SUB_ASSIGN = 279,              /* SUB_ASSIGN  */
    LEFT_ASSIGN = 280,             /* LEFT_ASSIGN  */
    RIGHT_ASSIGN = 281,            /* RIGHT_ASSIGN  */
    AND_ASSIGN = 282,              /* AND_ASSIGN  */
    XOR_ASSIGN = 283,              /* XOR_ASSIGN  */
    OR_ASSIGN = 284,               /* OR_ASSIGN  */
    TYPEDEF_NAME = 285,            /* TYPEDEF_NAME  */
    ENUM_CONSTANT = 286,           /* ENUM_CONSTANT  */
    TYPEDEF = 287,                 /* TYPEDEF  */
    EXTERN = 288,                  /* EXTERN  */
    STATIC = 289,                  /* STATIC  */
    AUTO = 290,                    /* AUTO  */
    REGISTER = 291,                /* REGISTER  */
    INLINE = 292,                  /* INLINE  */
    KERNEL = 293,                  /* KERNEL  */
    CLASS = 294,                   /* CLASS  */
    NT1 = 295,                     /* NT1  */
    NT2 = 296,                     /* NT2  */
    NT4 = 297,                     /* NT4  */
    NT8 = 298,                     /* NT8  */
    NT16 = 299,                    /* NT16  */
    CONST = 300,                   /* CONST  */
    RESTRICT = 301,                /* RESTRICT  */
    VOLATILE = 302,                /* VOLATILE  */
    BOOL = 303,                    /* BOOL  */
    CHAR = 304,                    /* CHAR  */
    SHORT = 305,                   /* SHORT  */
    INT = 306,                     /* INT  */
    LONG = 307,                    /* LONG  */
    SIGNED = 308,                  /* SIGNED  */
    UNSIGNED = 309,                /* UNSIGNED  */
    FLOAT = 310,                   /* FLOAT  */
    FLOAT2 = 311,                  /* FLOAT2  */
    FLOAT4 = 312,                  /* FLOAT4  */
    FLOAT8 = 313,                  /* FLOAT8  */
    FLOAT16 = 314,                 /* FLOAT16  */
    DOUBLE = 315,                  /* DOUBLE  */
    VOID = 316,                    /* VOID  */
    RESULT = 317,                  /* RESULT  */
    POINTER_SCOPE = 318,           /* POINTER_SCOPE  */
    COMPLEX = 319,                 /* COMPLEX  */
    IMAGINARY = 320,               /* IMAGINARY  */
    STRUCT = 321,                  /* STRUCT  */
    UNION = 322,                   /* UNION  */
    ENUM = 323,                    /* ENUM  */
    ELLIPSIS = 324,                /* ELLIPSIS  */
    CASE = 325,                    /* CASE  */
    DEFAULT = 326,                 /* DEFAULT  */
    IF = 327,                      /* IF  */
    ELSE = 328,                    /* ELSE  */
    SWITCH = 329,                  /* SWITCH  */
    WHILE = 330,                   /* WHILE  */
    DO = 331,                      /* DO  */
    FOR = 332,                     /* FOR  */
    GOTO = 333,                    /* GOTO  */
    CONTINUE = 334,                /* CONTINUE  */
    BREAK = 335,                   /* BREAK  */
    RETURN = 336,                  /* RETURN  */
    ALIGNAS = 337,                 /* ALIGNAS  */
    ALIGNOF = 338,                 /* ALIGNOF  */
    ATOMIC = 339,                  /* ATOMIC  */
    GENERIC = 340,                 /* GENERIC  */
    NORETURN = 341,                /* NORETURN  */
    STATIC_ASSERT = 342,           /* STATIC_ASSERT  */
    SHARE = 343,                   /* SHARE  */
    GLOBAL = 344                   /* GLOBAL  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 10 "Parser.y"

 void *a;

#line 157 "Parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
