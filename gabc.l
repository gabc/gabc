%{
enum tok {
	IF	/* if */
	,WHILE	/* while */
	,PLUS	/* + */
	,MULT	/* * */
	,DIV	/* / */
	,OPAR	/* ( */
	,EPAR	/* ) */
	,OCOM	/* /* */
	,ECOM	/* * / */
	,LCOM	/* // */
	,MIN	/* - */
	,THEN	/* then */
	,FI	/* fi */
	,EQL	/* == */
	,NEQL	/* != */
	,GRT	/* > */
	,LSS	/* < */
	,FUN	/* [a-zA-Z]+( */
	,NUM	/* 0-9+ */
	,ASSIN	/* = */
	,OBLK	/* { */
	,EBLK	/* } */
	,IDENT	/* [a-zA-Z]+ */
	,SEMICOLON /* ; */
};
%}

%%
"then"	return THEN;
"fi"	return FI;
"if"	return IF;
"while"	return WHILE;
"+"	return PLUS;
"*"	return MULT;
"-"	return MIN;
"/"	return DIV;
"("	return OPAR;
")"	return EPAR;
"=="	return EQL;
">"	return GRT;
"<"	return LSS;
"!="	return NEQL;
"{"	return OBLK;
";"	return SEMICOLON;
"}"	return EBLK;
"="	return ASSIN;
[0-9]+	return NUM;
[a-zA-Z]+	return IDENT;
[a-zA-Z]+\(\)	return FUN;
[\n| |\t]+	/* Do nothing */
.	{ printf("dude.\n"); exit(1); }
%%
int
yywrap()
{
	return 1;
}
