/*
* r5
*  - indica se a interrupção do led está ativa (1) ou não (0)
* r6
*  - indica se a interrupção do cronômetro está ativa (1) ou não (0)
* r7
*	 - flag que indica se a contagem do cronômetro está pausada (0) ou ativa (1)
* r12
*  - contador do timer (quantos segundos se passaram)
*/

.equ TIMER_COUNTER_BASE, 0x900 # endereço do contador do timer
.equ PUSHBUTTON_INTERRUPT_MASK, 0x10000058

.global START_TIMER
START_TIMER:
  # prólogo - configurar stack frame
  addi sp, sp, -20  # stack frame de 12 bytes
	stw ra, 16(sp) # guarda o endereço de retorno
	stw r14, 12(sp) 
	stw r13, 8(sp) 
	stw r12, 4(sp) 
  stw fp, (sp) # guarda o frame pointer
  mov fp, sp # seta o novo frame pointer

  movi r7, 1 # indica que a contagem do timer está ativa

  bne r6, r0, EXIT_START_TIMER # se r6 != 0, a interrupção já está ativa
  movi r6, 1 # indica que agora a interrupção do timer está ativa

  movia r12, TIMER_COUNTER_BASE # contador do temporizador
  stw	r0,	0(r12) # limpa o contador (0s)

  movia r13, PUSHBUTTON_INTERRUPT_MASK # endereço do interrupt mask
	ldwio r14, 0(r13) # pega o valor do interrupt mask
	ori r14, r14, 0b10 # seta os bits 1 como 1 (permitir interrupção no key1)
	stwio r14, 0(r13) # escreve no interrupt mask

  bne r5, r0, EXIT_START_TIMER # se r5 != 0 (há interrupção do led), não faz nada
  call START_TEMP_COUNTER # se não há interrupção do led, inicia o temporizador

  EXIT_START_TIMER:
    # epílogo - limpar stack frame
    ldw ra, 16(sp)
    ldw r14, 12(sp)
    ldw r13, 8(sp)
    ldw r12, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 20
    ret