/*
* r5
*  - indica se a interrupção do led está ativa (1) ou não (0)
* r6
*  - indica se a interrupção do cronômetro está ativa (1) ou não (0)
* r7
*	 - flag que indica se a contagem do cronômetro está pausada (0) ou ativa (1)
*/

.global START_TIMER
START_TIMER:
  movi r7, 1 # indica que a contagem do timer está ativa

  bne r6, r0, EXIT_START_TIMER # se r6 != 0, a interrupção já está ativa
  movi r6, 1 # indica que agora a interrupção do timer está ativa

  bne r5, r0, EXIT_START_TIMER # se r5 != 0 (há interrupção do led), não faz nada
  call START_TEMP_COUNTER # se não há interrupção do led, inicia o temporizador

  EXIT_START_TIMER:
  ret