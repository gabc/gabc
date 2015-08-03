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
  node *mkfun(node *, node *, node *);
  node *mkfncall(node *, node *, node *);
  node *mknil(void);
  void printtree(node *tree);

  void output(node *);
  void outargs(node *);
  void outblk(node *);
#define YYSTYPE struct node *
  int ifcmd;
  node *global;
%}

%start lines

%token IF EQL FUN LBRAK RBRAK VAR THEN IDENT
%token	NUMBER NIL ELSE SEP ARGS FARGS
%token	PLUS	MINUS	TIMES	DIVIDE	POWER
%token	LPAR	RPAR
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
	| func		{ global = $1; return;}
	;

exp     : term              {$$ = $1;}
	| exp EQL term      {$$ = mknode($1, $3, "==", EQL);}
        | exp PLUS term     {$$ = mknode($1, $3, "+", PLUS);}
        | exp MINUS term    {$$ = mknode($1, $3, "-", MINUS);}
	;

cond	: IF LPAR exp RPAR block  {$$ = mkif($3, $5, NULL);}
	| IF LPAR exp RPAR block ELSE block {$$ = mkif($3, $5, $7);}
        ;

func	: FUN fun LPAR fargs RPAR block {$$ = mkfun($2, $4, $6);}
	;

block	: LBRAK cmds RBRAK {$$ = $2;}
	;

cmds	: cmd {$$ = $1;}
	| cmds cmd {$$ = mkfncall($2->left, $1, $2);}
	;

/* We don't want function argument be number. */
fargs	: fargs SEP var {$$ = mknode($1, $3, "fargs", FARGS);}
	| var	{$$ = mknode($1, NULL, "fargs", FARGS);}
	| /* nothing */ {$$ = mknil();}
	;

args	: args SEP exp {$$ = mknode($1, $3, "args", ARGS);}
	| args SEP var {$$ = mknode($1, $3, "args", ARGS);}
	| var	{$$ = mknode($1, NULL, "args", ARGS);}
	| exp	{$$ = mknode($1, NULL, "args", ARGS);} // May not be the right one.
	| /* nothing */ {$$ = mknil();}
	;

var	: VAR  {$$ = mknode(0, 0, (char *)yylval, VAR);}
	;

cmd	: fun LPAR args RPAR END {$$ = mkfncall($3, 0, $1);}
	| cond			 {$$ = $1;}
	;

fun	: IDENT  {$$ = mknode(0, 0, (char *)yylval, IDENT);}
	;

term    : factor           {$$ = $1;}
        | term TIMES factor  {$$ = mknode($1, $3, "*", TIMES);}
	| term DIVIDE factor {$$ = mknode($1, $3, "/", TIMES);} 
        ;

factor  : NUMBER           {$$ = mknode(0,0,(char *)yylval, NUMBER);}
        | LPAR exp RPAR {$$ = $2;}
        ;
%%

int 
main(void) 
{
	while(yyparse()){
		//printtree(global);
		output(global);
	}
	return 0;
}

node *
mknode(node *left, node *right, char *token, int type)
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

	new = mknode(test, mknode(then, elsse ? mknode(elsse, 0, "else", ELSE) : 0, "then", THEN), "if", IF);

	return new;
}

node *
mkfun(node *fun, node *args,  node *block)
{
	node *new;

	new = mknode(args, block, fun->token, FUN);

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
	node *tmp;

	if(!tree)
		return;

	if(tree->left)
		output(tree->left);
	if(tree->right)
		output(tree->right);

	switch(tree->type){
	case FUN:
		printf("int\n%s(", tree->token);
		outargs(tree->left);
		printf("\b)\n{\n");
		outblk(tree->right);
		printf("}\n");
		break;
	}
}

void
outargs(node *tree)
{
	if(!tree)
		return;
	
	if(tree->type == VAR)
		printf("int %s,", tree->token);
	outargs(tree->left);
	outargs(tree->right);
}

void
outblk(node *tree)
{
	if(!tree || tree->type == NIL)
		return;

	
	printf("%s\n", tree->token);
	outblk(tree->left);
	outblk(tree->right);
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


