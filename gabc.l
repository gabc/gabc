%%
ASDF	{ printf("fd"); }
f	{ return 3; }
%%
int
yywrap()
{
	return 1;
}
	
int
main()
{
	return yylex();
}
