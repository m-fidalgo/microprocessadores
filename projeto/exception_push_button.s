/*
* r7
*	- flag que indica se a contagem do cronômetro está pausada (0) ou ativa (1)
 */

.equ PUSHBUTTON_BASE, 0x1000005C

.global EXCEPTION_PUSH_BUTTON
EXCEPTION_PUSH_BUTTON:
	# prólogo - configurar stack frame
 	 addi sp, sp, -12  # stack frame de 8 bytes
	stw r12, 8(sp) # guarda o endereço de retorno
	stw ra, 4(sp) # guarda o endereço de retorno
	stw fp, (sp) # guarda o frame pointer
	mov fp, sp # seta o novo frame pointer

	movia r12, PUSHBUTTON_BASE
	stwio r0, 0(r12)   # reseta valor do push button

	beq r7, r0, RESUME_TIMER # se r7 = 0, a contagem está pausada e deve ser continuada
	mov r7, r0 # se r7 != 0, a contagem deve ser pausada
	br EXIT_EXCEPTION_PUSH_BUTTON

	RESUME_TIMER:
		movi r7, 1

	EXIT_EXCEPTION_PUSH_BUTTON:
	 	# epílogo - limpar stack frame
		ldw r12, 8(sp)
		ldw ra, 4(sp)
		ldw fp, (sp)
		addi sp, sp, 12
	ret