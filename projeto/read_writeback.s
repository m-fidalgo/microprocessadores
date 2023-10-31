/*
* r2
*  -  valor de retorno : valor lido na uart, conteúdo DATA do data register (bits 0 a 7)
* r8
*   - endereço base da uart (data register)
* r9
*   - valor no data register da uart
* r10
*   - valor do control register da uart
* r11
*   - wspace da uart
*/



.equ UART_BASE, 0x10001000 # uart data register
.equ UART_CONTROL, 0x04 # uart control register offset

.global READ_WRITEBACK
READ_WRITEBACK:
	# prólogo - configurar stack frame
  addi sp, sp, -28  # stack frame de 28 bytes
  stw ra, 24(sp)    # guarda o endereço de retorno
  stw r8, 20(sp)   	# guardando r8 na stack
  stw r9, 16(sp)		 	# guardando r9 na stack
  stw r10, 12(sp)		# guardando r10 na stack
  stw r11, 8(sp)		# guardando r11 na stack
  stw r12, 4(sp)		# guardando r12 na stack
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp       	# seta o novo frame pointer

	movia r8, UART_BASE

	LOOP_READ:
		ldwio r9, 0(r8)
		andi r12, r9, 0x8000 # aplica máscara para pegar o valor do rvalid
		beq r12, r0, LOOP_READ  # retorna no início do loop se não for válido

    andi r12, r9, 0b11111111 # pega bits 0 a 7 do data register

    LOOP_WRITEBACK:
			ldwio r10, UART_CONTROL(r8)  # pega valor do control register
			andhi r11, r10, 0b1111111111111111 # pega bits 16-31 do control register (0xFFFF)
			beq r11, r0, LOOP_WRITEBACK  # retorna no início do loop se o buffer de escrita estiver cheio (wspace = 0)
      mov r2, r12
      addi r2, r2, -48
			stwio r12, 0(r8)  # escreve no data register

	END_READ_WRITEBACK:
    # epílogo - limpar stack frame
    ldw ra, 24(sp)
    ldw r8, 20(sp)
    ldw r9, 16(sp)
    ldw r10, 12(sp)
    ldw r11, 8(sp)
    ldw r12, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 28
    ret
  