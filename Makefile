# coder:Kobe
# Date:	2020/06/07 18:32
C = gcc
CC = g++
LEX = flex
YACC = bison
#OBJS = lex.yy.o y.tab.o
PARSERFLAGS = -lfl -ly
FLAGS = -Wall -Wextra -ansi -g

all: parser

# generate parser for Project2
parser: lex.yy.o y.tab.o
	$(CC) -o $@ lex.yy.o y.tab.o $(FLAGS) $(PARSERFLAGS)
	rm -rf *.o

# generate lex.yy.o for parser
lex.yy.o: lex.yy.c y.tab.o symbolTable.hpp
	$(CC) -c lex.yy.c

# generate y.tab.o for parser
y.tab.o: y.tab.c symbolTable.hpp
	$(CC) -c y.tab.c

# generate y.tab.h for lex.yy.c, and y.tab.c for y.tab.o
y.tab.c y.tab.h: parser.y
	$(YACC) -y -v -d $<

# generate lex.yy.cc for lex.yy.o
lex.yy.c: scanner.l
	$(LEX) $<

clean:
	rm -rf parser *.o y.tab.h *.c *.output
