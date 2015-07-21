%{
#include "y.tab.h"
%}


%%

[0-9]+                {yylval = (int)yytext; return NUMBER;} 
[ \t\n]               ;
"=="	 return(EQL);
"+"      return(PLUS);
"-"      return(MINUS);
"*"      return(TIMES);
"/"      return(DIVIDE);
"^"      return(POWER);
"("      return(LPAR);
")"      return(RPAR);
";"      return(END);
"{"	 return(LBRAK);
"}"	 return(RBRAK);
"if"	 return(IF);
"else"	 return(ELSE);
"fun"	 return(FUN);
","	 return(SEP);
\$[a-z]+ {yylval = (int)yytext; return(VAR);}
[a-z]+	 {yylval = (int)yytext; return(IDENT);}

%%

int yywrap (void) {return 1;}

