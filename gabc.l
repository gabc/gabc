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
"("      return(LEFT_PARENTHESIS);
")"      return(RIGHT_PARENTHESIS);
";"      return(END);
"{"	 return(LBRAK);
"}"	 return(RBRAK);
"if"	 return(IF);
\$[a-z]+ {yylval = (int)yytext; return(VAR);}
[a-z]+	 {yylval = (int)yytext; return(FUN);}

%%

int yywrap (void) {return 1;}

