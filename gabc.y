%{

#include <stdio.h>
#include <string.h>
  typedef struct node
  {
    struct node *left;
    struct node *right;
    char *token;
    int type;
  } node;
  node *mknode(node *left, node *right, char *token, int type);
  node *mkif(node *test, node *then, node *elsse);
  void printtree(node *tree);
  void output(node *);

#define YYSTYPE struct node *
  node *global;
%}

%start lines

%token IF EQL FUN LBRAK RBRAK VAR
%token	NUMBER
%token	PLUS	MINUS	TIMES	DIVIDE	POWER
%token	LEFT_PARENTHESIS	RIGHT_PARENTHESIS
%token	END

%left	PLUS	MINUS
%left	TIMES	DIVIDE
%right	POWER

%%

lines:  /* empty */
        | lines line /* do nothing */

line:   exp END		{ global = $1; return; }
	| cond END	{ global = $1; return;}
	| block END	{ global = $1; return;}
	;

exp    : term             {$$ = $1;}
	| exp EQL term      {$$ = mknode($1, $3, "==", EQL);}
        | exp PLUS term     {$$ = mknode($1, $3, "+", PLUS);}
        | exp MINUS term    {$$ = mknode($1, $3, "-", MINUS);}
	;

cond	: IF LEFT_PARENTHESIS exp RIGHT_PARENTHESIS block  {$$ = mkif($3, $5, NULL);}
        ;

block	: LBRAK cmds RBRAK {$$ = $2;}
	;

cmds	: cmds cmd {$$ = mknode($2, mknode($1, 0, "funcall", FUN), "funcall", FUN);}
	| cmd	{$$ = $1;}
	;

cmd	: fun END {$$ = $1;}
	;

fun	: FUN {$$ = mknode(0, 0, (char *)yylval, FUN);}
	;

term   : factor           {$$ = $1;}
        | term TIMES factor  {$$ = mknode($1, $3, "*", TIMES);}
	| term DIVIDE factor {$$ = mknode($1, $3, "/", TIMES);} 
        ;

factor : NUMBER           {$$ = mknode(0,0,(char *)yylval, NUMBER);}
        | LEFT_PARENTHESIS exp RIGHT_PARENTHESIS {$$ = $2;}
        ;
%%

int main (void) 
{
	printf(".text\n.globl main\nmain:\n");
	while(yyparse()){
		//printtree(global);
		output(global);
	}
	printf("mov $1, %%eax\nint $0x80\n");
	return 0;
}

node *mknode(node *left, node *right, char *token, int type)
{
  /* malloc the node */
  node *newnode = (node *)malloc(sizeof(node));
  char *newstr = (char *)malloc(strlen(token)+1);
  strcpy(newstr, token);
  newnode->left = left;
  newnode->right = right;
  newnode->token = newstr;
  newnode->type = type;
  return(newnode);
}

node *
mkif(node *test, node *then, node *elsse)
{
	node *new;

	new = mknode(test, mknode(then, 0, "then", IF), "test", IF);

	return new;
}

void
output(node *tree)
{
	if(!tree)
		return;

	if(tree->left)
		output(tree->left);
	if(tree->right)
		output(tree->right);

	switch(tree->type){
	case MINUS:
		printf("pop %%eax\npop %%ebx\n");
		printf("sub %%eax, %%ebx\n");
		printf("push %%ebx\n");
		break;
	case TIMES:
		printf("pop %%eax\n");
		printf("pop %%ebx\n");
		printf("imul %%eax, %%ebx\n");
		printf("push %%ebx\n");
		break;
	case PLUS:
		printf("pop %%eax\npop %%ebx\n");
		printf("add %%eax, %%ebx\n");
		printf("push %%ebx\n");
		break;
	case NUMBER:
		printf("push $%s\n", tree->token);
		break;
	}

}

void printtree(node *tree)
{
  int i;

  if(!tree)
	return;

  if (tree->left || tree->right)
    printf("(");

  printf(" %s ", tree->token);

  if (tree->left)
    printtree(tree->left);
  if (tree->right)
    printtree(tree->right);

  if (tree->left || tree->right)
    printf(")");
}

int yyerror (char *s) {fprintf (stderr, "%s\n", s);}


