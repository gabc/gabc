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
  node *mkfun(node *name, node *block);
  node *mkfncall(node *, node *, node *);
  node *mknil(void);
  void printtree(node *tree);
  void output(node *);

#define YYSTYPE struct node *
  int ifcmd;
  node *global;
%}

%start lines

%token IF EQL FUN LBRAK RBRAK VAR THEN IDENT
%token	NUMBER NIL
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
	| func END	{ global = $1; return;}
	| t END		{ global = $1; return;}
	;

exp    : term             {$$ = $1;}
	| exp EQL term      {$$ = mknode($1, $3, "==", EQL);}
        | exp PLUS term     {$$ = mknode($1, $3, "+", PLUS);}
        | exp MINUS term    {$$ = mknode($1, $3, "-", MINUS);}
	;

cond	: IF LEFT_PARENTHESIS exp RIGHT_PARENTHESIS block  {$$ = mkif($3, $5, NULL);}
        ;

func	: FUN fun block {$$ = mkfun($2, $3);}
	;

block	: LBRAK cmds RBRAK {$$ = $2;}
	;

t	: t cmd {$$ = mkfncall(0x0, $1, $2);}
	| cmd {$$ = $1;}
	;

cmds	: cmds cmd {$$ = mkfncall(0, $1, $2);}
	| cmd {$$ = $1;}
	;

args	: exp {$$ = $1;}
	| /* nothing */ {$$ = mknil();}
	;

cmd	: fun LEFT_PARENTHESIS args RIGHT_PARENTHESIS END {$$ = mkfncall($3, 0, $1);}
	;

fun	: IDENT  {$$ = mknode(0, 0, (char *)yylval, IDENT);}
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
	printf(".text\n");
	while(yyparse()){
		//printtree(global);
		output(global);
	}
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

	new = mknode(test, mknode(then, 0, "then", THEN), "test", IF);

	return new;
}

node *
mkfun(node *fun, node *block)
{
	node *new;

	new = mknode(block, 0, fun->token, FUN);

	return new;
}

node *
mkfncall(node *args, node *rest, node *add)
{
	node *new;
	new = mknode(args, rest, add->token, IDENT);
	return new;
}

node *
mknil(void)
{
	node *new;
	new = mknode(0, 0, "nil", NIL);
	return new;
}

void
output(node *tree)
{
	if(!tree)
		return;

	switch(tree->type){
	case IF:
		output(tree->left);
		printf("jne .else\n");
		output(tree->right);
		printf(".else:\n");
		return;
	case FUN:
		printf(".globl %s\n", tree->token);
		printf("%s:\n", tree->token);
		output(tree->left);
		return;
	}

	if(tree->left)
		output(tree->left);
	if(tree->right)
		output(tree->right);

	switch(tree->type){
	case IDENT:
		if(strcmp(tree->token, "ret") == 0){
			output(tree->left);
			printf("mov $1, %%eax\nint $0x80\n");
		}else
			printf("call %s\n", tree->token);
		break;
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
	case EQL:
		printf("pop %%eax\npop %%ebx\n");
		printf("cmp %%eax, %%ebx\n");
		ifcmd = EQL;
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

int yyerror (char *s) {fprintf (stderr, "Error: %s\n", s);}


