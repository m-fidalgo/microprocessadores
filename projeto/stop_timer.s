/*
* r5
*  - indica se a interrupção do led está ativa (1) ou não (0)
* r6
*  - indica se a interrupção do cronômetro está ativa (1) ou não (0)
* r12
*  - endereço base do registrador control do temporizador
*/

.equ TEMP_CONTROL_REGISTER_BASE, 0x10002004 # control do temporizador
.equ DISPLAY_7_SEG_BASE1, 0x10000020
.equ DISPLAY_7_SEG_BASE2, 0x10000030
# todo: stack frame com r12

.global STOP_TIMER
STOP_TIMER:
	# prólogo - configurar stack frame
    addi sp, sp, -20  
	stw ra, 16(sp) # guarda o endereço de retorno
	stw r12, 12(sp)
	stw r13, 8(sp)
	stw r14, 4(sp)
    stw fp, (sp) # guarda o frame pointer
    mov fp, sp # seta o novo frame pointer

	
	movia r13, DISPLAY_7_SEG_BASE1
	movia r14, DISPLAY_7_SEG_BASE2
	mov r6, r0 # não há interrupções de timer

	# todo: limpar display de 7 segmentos
	# limpar todos os diplays
	stbio r0, 0(r13)
	stbio r0, 1(r13)
	stbio r0, 2(r13)
	stbio r0, 3(r13)

	stbio r0, 0(r14)
	stbio r0, 1(r14)
	stbio r0, 2(r14)
	stbio r0, 3(r14)

	bne r5, r0, EXIT_STOP_TIMER # se r5 != 0 (há interrupção do led), não faz nada

	# se não há interrupção do led, limpa o temporizador
	movia r12, TEMP_CONTROL_REGISTER_BASE
 	stwio r0, 0(r12)

	EXIT_STOP_TIMER:
		# epílogo - limpar stack frame
		ldw ra, 16(sp)
		ldw r12, 12(sp)
		ldw r13, 8(sp)
		ldw r14, 4(sp)
		ldw fp, (sp)
		addi sp, sp, 20
		ret