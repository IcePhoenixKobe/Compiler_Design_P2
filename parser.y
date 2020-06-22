/*
	File description: a yacc file for course 
	NTUST 2020 Spring Compiler Design Project2.

	Information: This version can not use 
	relation operation to be the value that be 
	assigned.

	coder: Kobe (LIN GENG-SHEN)
	Date: 2020/06/08 01:45
*/
%{
#include"symbolTable.hpp"

using namespace std;

extern FILE* yyin;
extern unsigned int linenumber;

#ifdef __cplusplus
extern "C" {
#endif
	void yyerror(const char*);
	int yylex(void);
#ifdef __cplusplus
}
#endif

%}

%union
{
	int i_value;
	double d_value;
	char* s_value;
	int type;	// 0: void, 1: int, 2: char, 3: float, 4: string, 5: boolean
};

/* tokens */
%token <s_value> ID 
%token BIOP
/* reversed words */
%token BREAK CASE CLASS CONTINUE DEF DO ELSE EXIT FOR IF NULL_SCALA OBJECT PRINT PRINTLN READ REPEAT RETURN TO TYPE VAL VAR WHILE TRUE FALSE
/* data type */
%token <i_value> INT
%token CHAR
%token <d_value> FLOAT
%token <s_value> STRING
%token <b_value> BOOLEAN

/* Nonterminals */
%type <type> data type
%type <type> expression_list expression boolean_expression bool_expr
%type <i_value> par parameter

/* Operators */
%left '(' ')'
%left "||"
%left "&&"
%left '!'
%left '<' "<=" "==" "=>" '>' "!="
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS

%%

// Start symbol
program:	OBJECT ID '{'
			{ create(string($2)); }
			block_contents_obj '}'
		;

block_contents_obj:	block_content_obj
		|			block_contents_obj block_content_obj 
		;

block_content_obj:	declaration
		|			method
		;

method:	DEF ID '('
			{ create($2); }
		method_arg_con
			{ cur_table = cur_table->previous; }
	;

method_arg_con: method_arg '{' '}'
	|			method_arg '{' block_contents '}'
	;

method_arg:	')'
		{ set_par_type(0, 0); }
	|		parameter ')'
		{ set_par_type($1, 0); }
	|		')' ':' type
		{ set_par_type(0, $3); }
	|		parameter ')' ':' type
		{ set_par_type($1, $4); }
	;

parameter:	par					{ $$ = 1; }
	|		parameter ',' par	{ $$ = $1 + 1; }
	;

par:	ID ':' type	{ insert(1, $1, $3); }
	;

block_contents:	block_content
	|			block_contents block_content
	;

block_content:	declaration
	|			statement
	|			RETURN
		{
			if (cur_table != nullptr)
			{
				if (cur_table->type != 0)
					printf("Line %d: Error. return type of %s is not void", linenumber, cur_table->name.c_str());
			}
		}
	|			RETURN expression
		{
			if (cur_table != nullptr)
			{
				if (cur_table->type != $2)
					printf("Line %d: Error. return type of %s is not %d", linenumber, cur_table->name.c_str(), $2);
			}
		}
	|			'{'
		{ create("unknown"); }
				'}'
		{ cur_table = cur_table->previous; }	// no content
	|			'{'
		{ create("unknown"); }		
				block_contents '}'
		{ cur_table = cur_table->previous; }	// has content
	;

// All kind of declaration
declaration:	val
	|			var
	|			array
	;

// Constant Declaration
val:	VAL ID '=' expression
			{ insert(0, $2, $4);	/* data type is defined by expression. */ }
	|	VAL ID ':' type '=' expression
			{
				if ($4 != $6) 		/* check data between $4 and $6 */
					printf("Line %d: Warning: right value was not match to %d, the data type of ‘%s‘", linenumber, $4, $2);
				insert(0, $2, $4);
			}
	;

// Variable Declaration
var:	VAR ID
	{ insert(1, $2, 1);		/* insert constant, data type default as INT */ }
	|	VAR ID ':' type
	{ insert(1, $2, $4);	/* set data type */ }
	|	VAR ID '=' expression
	{ insert(1, $2, $4);	/* set ID's data type as $4 */ }
	|	VAR ID ':' type '=' expression
	{ insert(1, $2, $4); if ($4 != $6) printf("Line %d: Warning: right value was not match to %d, the data type of ‘%s‘", linenumber, $4, $2);	/* insert variable, and check the data type between $4 and $6. */ }
	;

// Array Declaration
array:	VAR ID ':' type '[' expression ']'	{ insert(2, $2, $4); }
	;

statement:	ID	// single identifier, nothing to do
	|	ID '=' expression	
			{
				ident identifier = lookup_id($1);
				if (identifier.name == "") Not_Declared(linenumber, $1);
				if (identifier.lry == 0) Constant_Not_Change(linenumber, $1);
				if (identifier.data_type != $3) printf("Line %d: Warning: data type not the same.", linenumber);	// must be modified again!!!
				/* 1. find $1(id). | 2. type check */ }
	|	ID '(' ')'
			{
				STable *table = lookup_table($1);
				if (table == nullptr) Not_Declared(linenumber, $1);
				if (table->parameter > 0) Few_Par(linenumber, table);
				/* 1. find $1(STable). | 2. check parameter */
			}
	|	ID '=' ID '(' ')'
			{
				/* 1. find $1(id). */
				ident identifier = lookup_id($1);
				if (identifier.name == "") Not_Declared(linenumber, $1);
				if (identifier.lry == 0) Constant_Not_Change(linenumber, $1);
				/* 2. find $3(STable). */
				STable *table = lookup_table($1);
				if (table == nullptr) Not_Declared(linenumber, $1);
				if (table->parameter > 0) Few_Par(linenumber, table);
				/* 3. check parameter */
				if (identifier.data_type != table->type) Type_Not_Match(linenumber, $1, $3);
			}
	|	ID '(' 
			{
				/* 1. find $1(STable). */
				temp_table = lookup_table($1);
				if (temp_table == nullptr) Not_Declared(linenumber, $1);
				else num_arg = temp_table->parameter;
			}
		expression_list ')'
			{
				Amount_Argument_Check(linenumber);
				Arguments_Type_Check(linenumber);
				temp_table = nullptr;
				num_arg = 0;
			}
	|	ID '=' ID '(' 
			{
				/* 1. find $3(STable). */
				temp_table = lookup_table($3);
				if (temp_table == nullptr) Not_Declared(linenumber, $3);
				else num_arg = temp_table->parameter;
			}
		expression_list ')'
			{
				/* 2. check argumenti of $3. */
				Amount_Argument_Check(linenumber);
				Arguments_Type_Check(linenumber);
				/* 3. find $1(id). */
				ident identifier = lookup_id($1);
				if (identifier.name == "") Not_Declared(linenumber, $1);
				if (identifier.lry == 0) Constant_Not_Change(linenumber, $1);
				/* 4. type check $1 and $3. */
				if (identifier.data_type != temp_table->type) Type_Not_Match(linenumber, $1, $3);
				temp_table = nullptr;
				num_arg = 0;
			}
	|	ID '[' expression ']' '=' expression
			{
				/* 1. find $1 and check array. */
				ident identifier = lookup_id($1);
				if (identifier.name == "") Not_Declared(linenumber, $1);
				if (identifier.lry != 2) Not_Array(linenumber, $1);
				/* 2. type check $3. */
				if ($3 != 1) Index_Type_Error(linenumber);
				/* 3. type ckeck $1 and $6 */
				if ($6 != identifier.data_type) Assign_Type_Error(linenumber, identifier);
			}
	|	ID '[' expression ']' '=' ID '(' ')'
			{ 
				/* 1. find $1 and check array. */
				ident identifier = lookup_id($1);
				if (identifier.name == "") Not_Declared(linenumber, $1);
				if (identifier.lry != 2) Not_Array(linenumber, $1);
				/* 2. type check $3. */
				if ($3 != 1) Index_Type_Error(linenumber);
				/* 3. find $6 and check parameter. */
				STable *table = lookup_table($6);
				if (table == nullptr) Not_Declared(linenumber, $6);
				if (table->parameter > 0) Few_Par(linenumber, table);
				/* 4. type check $1 and $6. */
				if (identifier.data_type != table->type) Type_Not_Match(linenumber, $1, $6);
			}
	|	ID '[' expression ']' '=' ID '('
			{
				/* 1. find $6(STable). */
				temp_table = lookup_table($6);
				if (temp_table == nullptr) Not_Declared(linenumber, $6);
				else num_arg = temp_table->parameter;
			}
		expression_list ')'
			{
				/* 2. find $1 and check array. */
				ident identifier = lookup_id($1);
				if (identifier.name == "") Not_Declared(linenumber, $1);
				if (identifier.lry != 2) Not_Array(linenumber, $1);
				/* 3. type check $3. */
				if ($3 != 1) Index_Type_Error(linenumber);
				/* 4. check argument of $6. */
				Amount_Argument_Check(linenumber);
				Arguments_Type_Check(linenumber);
				/* 5. type check $1 and $6. */
				if (identifier.data_type != temp_table->type) Type_Not_Match(linenumber, $1, $6);
				temp_table = nullptr;
				num_arg = 0;
			}
	|	PRINT '(' expression ')'
	|	PRINTLN '(' expression ')'
	|	READ ID
			{ if (lookup_id($2).name == "") Not_Declared(linenumber, $2); }
	|	IF '(' boolean_expression ')' block_or_statement
	|	IF '(' boolean_expression ')' block_or_statement ELSE block_or_statement
	|	FOR '(' ID '<' '-' INT TO INT ')' block_or_statement
	|	WHILE '(' boolean_expression ')' block_or_statement
	;

expression_list:	expression
			{
				arguments_type.clear();
				arguments_type.push_back($1);
			}
	|				expression_list ',' expression
			{
				arguments_type.push_back($3);
			}
	;	// No Do Type check at argument

expression:	expression '+' expression	{ /* use default */ }
	|		expression '-' expression	{ /* use default */ }
	|		expression '*' expression	{ /* use default */ }
	|		expression '/' expression	{ /* use default */ }
	|		expression '%' expression	{ /* use default */ }
	|		'-' expression %prec UMINUS	{ $$ = $2; }
	|		'(' expression ')'	{ $$ = $2; }
	|		data		{ /* use default */ }
	|		ID
			{
				ident identifier = lookup_id($1);
				if (identifier.name == "")
				{
					printf("Line %d: Error. Identifier \"%s\" was not declared\n", linenumber, $1);
					exit(-1);
				}
				$$ = identifier.data_type;
			}
	;

boolean_expression:	bool_expr
			{
				if ($$ != 5)
				{
					printf("Line %d: Error: expression must be ‘bool‘ type\n", linenumber);
					exit(-1);
				}
				else $$ = 5;
			}
	|				bool_expr biop bool_expr	
			{
				if ($1 == $3) $$ = 5;
				else Data_Type_Not_Match(linenumber, $1, $3);
			}
	;

bool_expr:	'!' bool_expr	{ $$ = $2; }
	|		'(' boolean_expression ')'	{ $$ = $2; }
	|		ID
	{
		ident identifier = lookup_id($1);
		if (identifier.name == "") Not_Declared(linenumber, $1);
		else $$ = identifier.data_type;
	}
	|		INT				{ $$ = 1; }
	|		CHAR			{ $$ = 2; }
	|		FLOAT			{ $$ = 3; }
	|		TRUE			{ $$ = 5; }
	|		FALSE			{ $$ = 5; }
	;

biop:	BIOP
	|	'<'
	|	'>'
	;

block_or_statement:	'{' '}'
	|				'{'
			{ create("unknown"); }
					block_contents '}'
			{ cur_table = cur_table->previous; }
	|				statement
	;

// Data Type
type:	INT		{ $$ = 1; }
	|	CHAR	{ $$ = 2; }
	|	FLOAT	{ $$ = 3; }
	|	STRING	{ $$ = 4; }
	|	BOOLEAN	{ $$ = 5; }
	;

data:	INT		{ $$ = 1; }
	|	CHAR	{ $$ = 2; }
	|	FLOAT	{ $$ = 3; }
	|	STRING	{ $$ = 4; }
	|	TRUE	{ $$ = 5; }
	|	FALSE	{ $$ = 5; }
	;

%%

int main(int argc, char* argv[])
{
	FILE *yyout;

    /* open the source program file */
	if (argc == 1) {
		/* notice user to key in data and end of input by ^D. */
		yyparse();
	}
	else if (argc > 1) {
		// Open a file called argv[1] for reading
		if ((yyin = fopen(argv[1], "r")) == NULL) {
			printf("file %s can't open for read!\n", argv[1]);
			exit(0);
		}
		if (argc > 2) {
			// Create a file named argv[2] for read/write
			if ((yyout = fopen(argv[2],"w")) == NULL) {
				printf("file %s can't open for write!\n", argv[1]);
				exit(0);
			}
			yyparse();
			fclose(yyout);
		}
		else
			yyparse();
		fclose(yyin);
	}
	
	bool has_main = false;
	for (size_t t = 0; t < head->next.size(); t++)
		if (head->next[t]->name == "main") has_main = true;
	if (!has_main)
	{
		cout << "error: There is no ‘main‘ method in program.\n";
		exit(-1);
	}
	dump();
	return 0;
}

void yyerror(char* msg)
{
    fprintf(stderr, "line %d: %s\n", linenumber, msg);
}


