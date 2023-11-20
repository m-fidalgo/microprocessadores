/*
* r8
*   - endereço base da uart (data register)
* r9
*   - bit da mensagem a ser escrita no começo do programa
* r11
*   - valor do control register da uart
* r12
*   - wspace da uart
* r13
*  - mensagem escrita no começo do programa
*/


.equ UART_BASE, 0x10001000 # uart data register
.equ UART_CONTROL, 0x04 # uart control register offset

.global WRITE_MESSAGE
WRITE_MESSAGE:
  # prólogo - configurar stack frame
  addi sp, sp, -32  # stack frame de 32 bytes
  stw ra, 28(sp)    # guarda o endereço de retorno
  stw r13, 24(sp)		# guardando r13 na stack
  stw r8, 20(sp)   	# guardando r8 na stack
  stw r9, 16(sp)		 	# guardando r9 na stack
  stw r10, 12(sp)		# guardando r10 na stack
  stw r11, 8(sp)		# guardando r11 na stack
  stw r12, 4(sp)		# guardando r12 na stack
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp       	# seta o novo frame pointer

  movia r8, UART_BASE
  movia r13, MESSAGE

  LOOP_WRITE_UART:
    ldb r9, 0(r13)
    beq r9, r0, END_LOOP_WRITE_UART # mensagem acabou, portanto começa a receber os comandos

    LOOP_WRITE_BIT:
      ldwio r11, UART_CONTROL(r8) # control register
      andhi r12, r11, 0b1111111111111111 # bits wspace do control register
      beq r12, r0, LOOP_WRITE_BIT # retorna se o buffer de escrita estiver cheio (wspace = 0)
      stwio r9, 0(r8)

    addi r13, r13, 1 # pega próximo bit
    br LOOP_WRITE_UART

  END_LOOP_WRITE_UART:
    # epílogo - limpar stack frame
    ldw ra, 28(sp)
    ldw r13, 24(sp)
    ldw r8, 20(sp)
    ldw r9, 16(sp)
    ldw r10, 12(sp)
    ldw r11, 8(sp)
    ldw r12, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 32
    ret

MESSAGE:
.asciz "\nEntre com o comando: "