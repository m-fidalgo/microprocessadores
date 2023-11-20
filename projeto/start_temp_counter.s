/*
* r13
* 	- usado para gerenciar a interrupção
*   - registrador para o valor de ciclos
*		  - bits START, CONT, ITO do registrador control do temporizador
* r14
* 	- parte baixa e em seguida parte alta de r13
* r15
*  - endereço do registrador control do temporizador
*/

.equ TEMP_CONTROL_REGISTER_BASE, 0x10002004 # control do temporizador
.equ COUNTER_LOW_REGISTER_OFFSET, 0x04 # parte baixa do contador
.equ COUNTER_HIGH_REGISTER_OFFSET, 0x08 # parte alta do contador

.global START_TEMP_COUNTER
START_TEMP_COUNTER:
  # prólogo - configurar stack frame
  addi sp, sp, -20  # stack frame de 20 bytes
  stw ra, 16(sp)    # guarda o endereço de retorno
  stw r13, 12(sp)		# guardando r12 na stack
  stw r14, 8(sp)		# guardando r14 na stack
  stw r15, 4(sp)		# guardando r15 na stack
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp       	# seta o novo frame pointer

  movia r15, TEMP_CONTROL_REGISTER_BASE

	### configurando o temporizador
	# pegando o valor de ciclos e dividindo na parte alta e baixa (valor mt alto)
	movia r13, 25000000
	andi r14, r13, 0xFFFF
	stwio r14, COUNTER_LOW_REGISTER_OFFSET(r15)   # seta o counter start value low
	srli r14, r13, 0x10
	stwio r14, COUNTER_HIGH_REGISTER_OFFSET(r15)   # seta o counter start value high

	# setando os bits do temporizador
	movia r13, 0b111 # valores para os bits START, CONT, ITO
	stwio r13, 0(r15)  # seta os valores dos bits do registrador control do temporizador
	
	# epílogo - limpar stack frame
	ldw ra, 16(sp)
	ldw r13, 12(sp)
	ldw r14, 8(sp)
	ldw r15, 4(sp)
	ldw fp, (sp)
	addi sp, sp, 20

	ret