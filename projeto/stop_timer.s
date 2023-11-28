/*
* r5
*  - indica se a interrupção do led está ativa (1) ou não (0)
* r6
*  - indica se a interrupção do cronômetro está ativa (1) ou não (0)
* r12
*  - endereço base do registrador control do temporizador
*/

.equ TEMP_CONTROL_REGISTER_BASE, 0x10002004 # control do temporizador
# todo: stack frame com r12

.global STOP_TIMER
STOP_TIMER:
	mov r6, r0 # não há interrupções de timer

	# todo: limpar display de 7 segmentos

	bne r5, r0, EXIT_STOP_TIMER # se r5 != 0 (há interrupção do led), não faz nada

	# se não há interrupção do led, limpa o temporizador
	movia r12, TEMP_CONTROL_REGISTER_BASE
  stwio r0, 0(r12)

	EXIT_STOP_TIMER:
	ret