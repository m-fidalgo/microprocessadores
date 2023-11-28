/*
* r7
*		- flag que indica se a contagem do cronômetro está pausada (0) ou ativa (1)
 */

.global EXCEPTION_PUSH_BUTTON
EXCEPTION_PUSH_BUTTON:
	beq r7, r0, RESUME_TIMER # se r7 = 0, a contagem está pausada e deve ser continuada
	mov r7, r0 # se r7 != 0, a contagem deve ser pausada
	br EXIT_EXCEPTION_PUSH_BUTTON

	RESUME_TIMER:
		movi r7, 1

	EXIT_EXCEPTION_PUSH_BUTTON:
	ret