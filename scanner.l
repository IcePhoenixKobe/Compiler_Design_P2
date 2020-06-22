/*
	file description: a lex file for course 
	NTUST 2020 Spring Compiler Design Project2.

	coder: Kobe (LIN GENG-SHEN)
	Date: 2020/06/02 22:50
*/
%{
#include<iostream>
#include<cstring>
#include<string>
#include<vector>
#include"y.tab.h"

using namespace std;

#define LIST			strcat(buf, yytext);
#define newline			printf("%u: ", linenumber);
#define token(t)		{ LIST; printf("<%s>\n", #t); }
#define tokenRevWord(t)	{ LIST; printf("<%s>\n", #t); return(t); }
#define tokenID(s)		{ LIST; printf("<id: %s>\n", s); yylval.s_value = strdup(s); return(ID); }
#define tokenInteger(i)	{ LIST; printf("<integer: %d>\n", i); yylval.i_value = i; return(INT); }
#define tokenReal(f)	{ LIST; printf("<real: %lf>\n", f); yylval.d_value = f; return(FLOAT); }
#define tokenString(s)	{ printf("<string: %s>\n", s); yylval.s_value = strdup(s); }

#define MAX_LINE_LENG 256

unsigned int linenumber = 1;
char buf[MAX_LINE_LENG];
string str_temp;

extern "C" int yylex(void);
%}
%option noyywrap
%x		COMMENT

digit	[0-9]
alpha	[A-Za-z_]
/* Arithmetic, Relational, and Logical Operators */
ARLO	\+|-|\*|\/|%|<|<=|>=|>|==|!=|&&|"||"|!
float	{digit}+\.{digit}*
expon	{digit}+\.?{digit}+([eE][-+]?{digit}+)?

/* Identifiers */
id		{alpha}({alpha}|{digit})*
/* Integer Constants */
integer	{digit}+
/* Real Constants */
real	{float}|{expon}
/* white space: ' ' & '\t' */
ws		[ \t]+

%%

	/* ' ' & '\t' */
{ws}   	LIST;

	/* single comment */
"//".*	LIST;
"//".*\n	{
			LIST;
			newline;
			printf("%s", buf);
			linenumber++;
			str_temp.clear();
			buf[0] = '\0';		// clean buffer
			}

	/* multiple somment */
"/*"	{
		LIST;
		BEGIN COMMENT;
		}
<COMMENT>.*\*\/		{
					LIST;
					BEGIN 0;
					}
<COMMENT>.*\*\/\n	{
					LIST;
					BEGIN 0;
					newline;
					printf("%s", buf);
					linenumber++;
					str_temp.clear();
					buf[0] = '\0';		// clean buffer
					}
<COMMENT>[^(*|\n)]*	{
					LIST;
					char c;
					if ((c = yyinput()) != 0)
					{
						if (c == '*')
							strcat(buf, "*");
						else
							unput(c);
					}
					}
<COMMENT>\n	{
			newline;
			cout << buf << endl;
			buf[0] = '\0';
			linenumber++;
			}

	/* Assignment */
"="		{ token('='); return('='); }

	/* Delimiters */
","		{ token(','); return(','); }
":"		{ token(':'); return(':'); }
"."		{ token('.'); return('.'); }
";"		{ token(';'); return(';'); }
"("		{ token('('); return('('); }
")"		{ token(')'); return(')'); }
"["		{ token('['); return('['); }
"]"		{ token(']'); return(']'); }
"{"		{ token('{'); return('{'); }
"}"		{ token('}'); return('}'); }

	/* Arithmetic, Relational, and Logical Operators */
"+"		{ token('+'); return('+'); }
"-"		{ token('-'); return('-'); }
"*"		{ token('*'); return('*'); }
"/"		{ token('/'); return('/'); }
"%"		{ token('%'); return('%'); }
"<"		{ token('<'); return('<'); }
">"		{ token('>'); return('>'); }
"<="	{ token("<="); return(BIOP); }
">="	{ token(">="); return(BIOP); }
"=="	{ token("=="); return(BIOP); }
"!="	{ token("!="); return(BIOP); }
"&&"	{ token("&&"); return(BIOP); }
"||"	{ token("||"); return(BIOP); }
"!"		{ token('!'); return('!'); }

	/* Reversed words */
boolean		{ tokenRevWord(BOOLEAN); }
break		{ tokenRevWord(BREAK); }
char		{ tokenRevWord(CHAR); }
case		{ tokenRevWord(CASE); }
class		{ tokenRevWord(CLASS); }
continue	{ tokenRevWord(CONTINUE); }
def			{ tokenRevWord(DEF); }
do			{ tokenRevWord(DO); }
else		{ tokenRevWord(ELSE); }
exit		{ tokenRevWord(EXIT); }
false		{ yylval.i_value = 0; tokenRevWord(FALSE); }
float		{ tokenRevWord(FLOAT); }
for			{ tokenRevWord(FOR); }
if			{ tokenRevWord(IF); }
int			{ tokenRevWord(INT); }
null		{ tokenRevWord(NULL_SCALA); }
object		{ tokenRevWord(OBJECT); }
print		{ tokenRevWord(PRINT); }
println		{ tokenRevWord(PRINTLN); }
read		{ tokenRevWord(READ); }
repeat		{ tokenRevWord(REPEAT); }
return		{ tokenRevWord(RETURN); }
string		{ tokenRevWord(STRING); }
to			{ tokenRevWord(TO); }
true		{ yylval.i_value = 1; tokenRevWord(TRUE); }
type		{ tokenRevWord(TYPE); }
val			{ tokenRevWord(VAL); }
var			{ tokenRevWord(VAR); }
while		{ tokenRevWord(WHILE); }

	/* Identifiers */
{id}		tokenID(yytext);

	/* Number */
{integer}	tokenInteger(atoi(yytext));
{real}		tokenReal(atof(yytext));

	/* String */
\"[^"]*\"	{
			str_temp += yytext;
			char c = 0;
			if ((c = yyinput()) != 0)
			{
				LIST;
				if (c == '\"')
				{
					str_temp.erase(str_temp.end() - 1);
					unput(c);
				}
				else
				{
					str_temp.erase(0, 1);
					str_temp.erase(str_temp.end() - 1);
					tokenString(str_temp.c_str());
					unput(c);
					return(STRING);
				}
			}
			}

\n			{
			LIST;
			newline;
			printf("%s", buf);
			linenumber++;
			str_temp.clear();
			buf[0] = '\0';		// clean buffer
			}

	/* Error String */
\"[^(\"|\n)]*\n	{
				strncat(buf, yytext, yyleng - 1);
				printf("%u: error: string has newline '%s'\n", linenumber, buf);
				exit(-1);
				}

	/* Other character */
.	{
	LIST;
	printf("%d:%s\n", linenumber, buf);
	printf("bad character:’%s’\n",yytext);
	exit(-1);
	}

%%
