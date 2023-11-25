.global EXCEPTION_TEMP_TIMER
EXCEPTION_TEMP_TIMER:
	# checar a flag r7 pra ver se o contador tá pausado ou não
	# essa funcao é chamada a cada 1s, aqui a gnt tem que usar um contador pra somar +1s e aí mostrar no display de 7seg
	# o valor total desse contador. 
	ret