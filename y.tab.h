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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
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
    ID = 258,
    BIOP = 259,
    BREAK = 260,
    CASE = 261,
    CLASS = 262,
    CONTINUE = 263,
    DEF = 264,
    DO = 265,
    ELSE = 266,
    EXIT = 267,
    FOR = 268,
    IF = 269,
    NULL_SCALA = 270,
    OBJECT = 271,
    PRINT = 272,
    PRINTLN = 273,
    READ = 274,
    REPEAT = 275,
    RETURN = 276,
    TO = 277,
    TYPE = 278,
    VAL = 279,
    VAR = 280,
    WHILE = 281,
    TRUE = 282,
    FALSE = 283,
    INT = 284,
    CHAR = 285,
    FLOAT = 286,
    STRING = 287,
    BOOLEAN = 288,
    UMINUS = 295
  };
#endif
/* Tokens.  */
#define ID 258
#define BIOP 259
#define BREAK 260
#define CASE 261
#define CLASS 262
#define CONTINUE 263
#define DEF 264
#define DO 265
#define ELSE 266
#define EXIT 267
#define FOR 268
#define IF 269
#define NULL_SCALA 270
#define OBJECT 271
#define PRINT 272
#define PRINTLN 273
#define READ 274
#define REPEAT 275
#define RETURN 276
#define TO 277
#define TYPE 278
#define VAL 279
#define VAR 280
#define WHILE 281
#define TRUE 282
#define FALSE 283
#define INT 284
#define CHAR 285
#define FLOAT 286
#define STRING 287
#define BOOLEAN 288
#define UMINUS 295

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 32 "parser.y" /* yacc.c:1909  */

	int i_value;
	double d_value;
	char* s_value;
	int type;	// 0: void, 1: int, 2: char, 3: float, 4: string, 5: boolean

#line 129 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
