/*
* r7
*	 - flag que indica se a contagem do cronômetro está pausada (0) ou ativa (1)
*/

.global EXCEPTION_TEMP_TIMER
EXCEPTION_TEMP_TIMER:
	beq r7, r0, EXIT_EXCEPTION_TEMP_TIMER # se r7=0, a contagem está pausada (não fazer nada)

	# essa funcao é chamada a cada 1s, aqui a gnt tem que usar um contador (memória) pra somar +1s e aí mostrar no display de 7seg
	# o valor total desse contador. 

	EXIT_EXCEPTION_TEMP_TIMER:
	ret