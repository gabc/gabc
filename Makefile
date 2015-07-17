prog:	gabc.c gabc.l
	flex gabc.l
	gcc gabc.c
