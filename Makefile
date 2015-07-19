stuff:	gabc.y gabc.l
	flex gabc.l
	yacc -d gabc.y
	gcc y.tab.c lex.yy.c -g 

prog:	gabc.c gabc.l
	flex gabc.l
	gcc gabc.c
