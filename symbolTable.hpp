/*
	File description: a hpp file for course 
	NTUST 2020 Spring Compiler Design Project2.

	coder: Kobe (LIN GENG-SHEN)
	Date: 2020/06/08 02:03
*/
#ifndef SYMBOLTABLE_HPP
#define SYMBOLTABLE_HPP

#include<string.h>
#include<iostream>
#include<string>
#include<vector>

using namespace std;

typedef struct IDENT
{
	int lry = 0;	// 0: val, 1: var, 2: array
	string name;	// identifier's name
	// identifier's data type(0: void, 1: int, 2: char, 3: float, 4: string, 5: boolean
	int data_type;
	IDENT() : lry(0), data_type(0) { name = ""; }
	IDENT(int vva, const char* s, int type) : lry(vva), name(s), data_type(type) {}
}ident;

typedef struct SymbolTable STable;
struct SymbolTable
{
	size_t layer;	// number of layer, 0 stand for head
	string name;	// symbol table's name
	int parameter;	// the amount of paramenter
	int type;		// return type of method
	vector<ident> identifier;	// identifier
	STable *previous;			// upper layer
	vector<STable*> next;		// next layer
	
	// spare constructor
	/*SymbolTable(size_t lay, const char* s, int t) : layer(lay), name(s), parameter(0), type(t), previous(nullptr)
	{
		identifier.clear();
		next.clear();
	}*/
};

int num_arg = 0;
STable * head = nullptr;
STable * cur_table = head;
STable * temp_table = nullptr;
ident * cur_identifier = nullptr;
vector<int> arguments_type;

/* Symbol table's function declaration */
void create(string);
void set_par_type(int, int);
ident lookup_id(const char*);
STable* lookup_table(const char*);
void insert(int, const char*, int);
void dump();
void dump_next(STable*);
void output_tab(size_t);
void output_type(size_t);

/* warning and error message */
void Not_Declared(int, const char*);
void Type_Not_Match(int, const char*, const char*);
void Not_Array(int, const char*);
void Index_Type_Error(int);
void Assign_Type_Error(int, ident);
void Data_Type_Not_Match(int, int, int);
void Few_Par(int, STable*);
void Amount_Argument_Check(int);
void Arguments_Type_Check(int);
void Constant_Not_Change(int, const char*);

/* Symbol table's function defination */

// Create new symbol table and link to current symbol table
void create(string str)
{
	STable * new_table = new STable;
	new_table->layer = 0;
	new_table->name = str;
	new_table->parameter = 0;
	new_table->type = 0;
	new_table->identifier.clear();
	new_table->previous = nullptr;
	new_table->next.clear();

	if (head == nullptr && cur_table == head)
	{
		// Initialize head
		head = new_table;
		// current table point to head
		cur_table = head;
	}
	else
	{
		// head has been initial, add new symbol table below current symbol table.
		// set new symbol table
		new_table->layer = cur_table->layer + 1;
		new_table->previous = cur_table;

		// set current table
		cur_table->next.push_back(new_table);
		cur_table = new_table;
	}
	return;
}

void set_par_type(int par, int type)
{
	cur_table->parameter = par;
	cur_table->type = type;
	return;
}

ident lookup_id(const char* s)
{
	STable * table_index = cur_table;
	while (table_index != nullptr)
	{
		for (size_t i = 0; i < table_index->identifier.size(); i++)
			if (table_index->identifier[i].name == s)
				return table_index->identifier[i];
		table_index = table_index->previous;
	}

	return ident(0, "", -1);	// not found
}

STable* lookup_table(const char* s)
{
	STable * table_index = cur_table;
	while (table_index != nullptr)
	{
		if (strcmp(table_index->name.c_str(), s) == 0)
			return table_index;
		for (size_t i = 0; i < table_index->next.size(); i++)
			if (strcmp(table_index->next[i]->name.c_str(), s) == 0)
				return table_index->next[i];
		table_index = table_index->previous;
	}

	return nullptr;	// not found
}

void insert(int vv, const char* s, int type)
{
	ident new_id = ident(vv, s, type);
	cur_table->identifier.push_back(new_id);
	return;
}

void dump()
{
	if (head != nullptr)
	{
		printf("Table Name: %s\n", head->name.c_str());
		printf("Amount of parameter: %d\n", head->parameter);
		printf("Return Type: ");
		output_type(head->type);
		printf("\nDeclaration: \n");
		for (size_t i = 0; i < head->identifier.size(); i++)
		{
			printf("  %s, ", head->identifier[i].name.c_str());
			if (head->identifier[i].lry == 0)		// output constant
				printf("constant, ");
			else if (head->identifier[i].lry == 1)	// output variable
				printf("variable, ");
			else
				printf("array, ");					// output array
			output_type(head->identifier[i].data_type);
			puts("");
		}
		
		for (size_t i = 0; i < head->next.size(); i++)
			dump_next(head->next[i]);
	}
	return;
}

void dump_next(STable* table)
{
	output_tab(table->layer);
	printf("Table Name: %s\n", table->name.c_str());
	output_tab(table->layer);
	printf("Amount of parameter: %d\n", table->parameter);
	output_tab(table->layer);
	printf("Return Type: ");
	output_type(table->type);
	puts("");
	output_tab(table->layer);
	printf("Declaration: \n");
	for (size_t i = 0; i < table->identifier.size(); i++)
	{
		output_tab(table->layer);
		printf("  %s, ", table->identifier[i].name.c_str());
		if (table->identifier[i].lry == 0)		// output constant
			printf("constant, ");
		else if (table->identifier[i].lry == 1)	// output variable
			printf("variable, ");
		else
			printf("array, ");					// output array
		output_type(table->identifier[i].data_type);
		puts("");
	}
	
	for (size_t i = 0; i < table->next.size(); i++)
	{
		dump_next(table->next[i]);
	}
	output_tab(table->layer);
	puts("====================");
	return;
}

void output_tab(size_t num)
{
	for (size_t i = 0; i < num; i++) printf("\t");
	return;
}

void output_type(size_t type)
{
	switch (type)
	{
	case 0:
		printf("void");
		break;
	case 1:
		printf("int");
		break;
	case 2:
		printf("char");
		break;
	case 3:
		printf("float");
		break;
	case 4:
		printf("string");
		break;
	case 5:
		printf("boolean");
		break;
	default:
		puts("unknown type");
		exit(-1);
		break;
	}
	return;
}

void Not_Declared(int linenum, const char* s)
{
	printf("Line %d: Error: ‘%s‘ was not declared in this scope\n", linenum, s);
	exit(-1);
}

void Type_Not_Match(int linenum, const char* s1, const char* s2)
{
	printf("Line %d: Warning: data type of ‘%s‘is not match the data type of ‘%s‘\n", linenum, s1, s2);
}

void Not_Array(int linenum, const char* s)
{
	printf("Line %d: Error: ‘%s‘ is not an array.\n", linenum, s);
	exit(-1);
}

void Index_Type_Error(int linenum)
{
	printf("Line %d: Error: index must be the data type of integer(int)\n", linenum);
	exit(-1);
}

void Assign_Type_Error(int linenum, ident id)
{
	printf("Line %d: Error: the data that be assigned is not the same as ‘", linenum);
	output_type(id.data_type);
	printf("‘ type of ‘%s‘\n", id.name.c_str());
	exit(-1);
}

void Data_Type_Not_Match(int linenum, int d1, int d2)
{
	printf("Line %d: Warning. ‘", linenum);
	output_type(d1);
	printf("‘ is mot match ‘");
	output_type(d2);
	puts("‘");
	exit(-1);
}

void Few_Par(int linenum, STable* table)
{
	printf("Line %d: Error: too few arguments to method ‘", linenum);      
	output_type(table->type);
	printf("%s‘\n", table->name.c_str());
	exit(-1);
	return;
}


void Amount_Argument_Check(int linenum)
{
	if (temp_table != nullptr && arguments_type.size() != 0)
	{
		if (temp_table->parameter > static_cast<int>(arguments_type.size()))
		{
			printf("Line %d: Error: too few arguments to method ‘", linenum);
			output_type(temp_table->type);
			printf("%s‘\n", temp_table->name.c_str());
			exit(-1);
		}
		else if (temp_table->parameter < static_cast<int>(arguments_type.size()))
		{
			printf("Line %d: Error: too many arguments to method ‘", linenum);
			output_type(temp_table->type);
			printf(" %s‘\n", temp_table->name.c_str());
			exit(-1);
		}
	}
}

void Arguments_Type_Check(int linenum)
{
	for (size_t i = 0; i < arguments_type.size(); i++)
	{
		if (temp_table->identifier[i].data_type != arguments_type[i])
		{
			printf("Line %d: Error: the type of argument %d of ‘%s‘is ‘", linenum, static_cast<int>(i), temp_table->name.c_str());
			output_type(temp_table->identifier[i].data_type);
			printf("‘. it's not ‘");
			puts("‘.");
			exit(-1);
		}
	}
}

void Constant_Not_Change(int linenum, const char* s)
{
	printf("Line %d: error: assignment of read-only variable ‘%s‘\n", linenum, s);
	exit(-1);
}

#endif
