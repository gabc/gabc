#include <stdio.h>
#include <stdlib.h>

#include "lex.yy.c"

void
pif()
{
	int c;

	while((c = yylex()) != THEN)
		printf("expr: %s\n", yytext);
	while((c = yylex()) != FI)
		printf("block: %s\n", yytext);
}

void
num(void)
{
	printf("mov $%s, %%eax\n", yytext);
}

void
plus(void)
{
	int c;
	
	c = yylex();
	
	if(c != NUM && c != IDENT && c != FUN){
		printf("What. %d %s\n", c == NUM, yytext);
		exit(1);
	}

	printf("mov %%eax, %%ebx\n");
	printf("mov $%s, %%eax\n", yytext);
	printf("add %%ebx\n");
}

void
sub(void)
{
	printf("sub %%eax, %%ebx\n");
}

int
main()
{
	int c;

	while((c = yylex()) != EOF)
	switch(c){
	case NUM:
		num();
		break;
	case PLUS:
		plus();
		break;
	case MIN:
		sub();
		break;
	case IF:
		pif();
		break;
	case IDENT:
		printf("%s y\n", yytext);
		break;
	case FUN:
		printf("call: %s\n", yytext);
		break;
	default:
		printf("thefuck\n");
	}
	return 0;
}
