/*
* r2
*  - valor de retorno de READ_WRITEBACK (valor lido na uart): conteúdo DATA do data register (bits 0 a 7)
* r3
*  - usado na RTE para checar quem gerou a interrupção
* r4
*  - indica se a próxima interrupção é de 0,5 (0) ou 1 (1) segundo
* r5
*  - indica se a interrupção do led está ativa (1) ou não (0)
* r6
*  - indica se a interrupção do cronômetro está ativa (1) ou não (0)
* r8
*   - endereço base da uart (data register)
* r9
*   - valor no data register da uart
* r10
*   - valor de rvalid (indica se o campo data tem caracteres válidos)
* r11
*   - auxiliar para verificar o valor lido na uart
* r13
*   - usado para setar o ienable
*/

.equ STACK, 0x10000 # endereço da pilha
.equ UART_BASE, 0x10001000 # uart data register
.equ UART_CONTROL, 0x04 # uart control register offset

.org 0x20
RTE:
  # prólogo - configurar stack frame
  addi sp, sp, -12  # stack frame de 12 bytes
	stw ra, 8(sp) # guarda o endereço de retorno
	stw r3, 4(sp) 
  stw fp, (sp) # guarda o frame pointer
  mov fp, sp # seta o novo frame pointer

  rdctl et, ipending  # copia o valor de ipending -> saber quem gerou a interrupção
	beq et, r0, SOFTWARE_EXCEPTIONS # se ipending é 0, a interrupção é de software
	subi ea, ea, 4 # subtrai 4 do endereço de retorno - regra do nios2

  andi r3, et, 1 # checa se o irq0 (temporizador) gerou a interrupção
	beq r3, r0, CHECK_IRQ1 # se não foi o irq0, verificar se foi o irq1
  
  # checando exceções do temporizador
  CHECK_IRQ0:
    beq r5, r0, CHECK_TIMER # se não há interrupções do led, checa do cronômetro
    call EXCEPTION_TEMP_LED # exceção do led

    CHECK_TIMER:
      beq r4, r0, END_CHECK_IRQ0 # se a interrupção é de 0,5s sai da RTE
      beq r6, r0, END_CHECK_IRQ0 # se não há interrupções do cronômetro, sai da RTE
      call EXCEPTION_TEMP_TIMER # exceção do cronômetro

    END_CHECK_IRQ0:
      beq r4, r0, SET_1S # se r4 = 0 (interrupção era de 0,5s), fala que a próxima é de 1s
      movi r4, 0 # a interrupção era de 1s, então a próxima é de 0,5s
      br END_RTE

      SET_1S:
        movi r4, 1 # fala que a próxima interrupção é de 1s
        br END_RTE
      

  CHECK_IRQ1:
    andi r3, et, 2 # checa se o irq1 (push button) gerou a interrupção
    beq r3, r0, OTHER_INTERRUPTIONS # se não foi o irq1, lidar com outras interrupções
    call EXCEPTION_PUSH_BUTTON # se o irq1 gerou a interrupção, chamar a função para tratá-la
    br END_RTE

  OTHER_INTERRUPTIONS:
		# lidar com outras interrupções
		br END_RTE

  SOFTWARE_EXCEPTIONS:
    # lidar com exceções de software

  END_RTE:
    # epílogo - limpar stack frame
    ldw ra, 8(sp)
    ldw r3, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 12
    eret # retorna da exceção


.global _start
_start:
  START_PROGRAM:
    movia sp, STACK
    movia r8, UART_BASE

    ### permitindo interrupções no sistema
    wrctl	status, r13 # seta o PIE para permitir interrupções

    rdctl r13, ienable # copia o ienable para r13
    ori r13, r13, 0b11 # seta o IRQ0 e IRQ1 como 1 (permitir interrupção do temporizador e push button)
    wrctl ienable, r13 # escreve no ienable

    call WRITE_MESSAGE

    LOOP_READ_UART:
      call READ_WRITEBACK
      beq r2, r0, FIRST_ZERO
      
      movi r11, 1
      beq r2, r11, FIRST_ONE

      movi r11, 2
      beq r2, r11, FIRST_TWO

      # não começa com caracter válido - erro
      ERROR:
        br END_LOOP

      FIRST_ZERO: # 0x
        call READ_WRITEBACK
        
        beq r2, r0, SECOND_ZERO_ZERO
    
        movi r11, 1
        beq r2, r11, SECOND_ZERO_ONE

        br ERROR # não é 00 nem 01

        SECOND_ZERO_ZERO: # 00xx
          call SET_ACTIVE_LED
          br END_LOOP

        SECOND_ZERO_ONE: # 01xx
          call REMOVE_ACTIVE_LED
          br END_LOOP


      FIRST_ONE: # 1x
        call READ_WRITEBACK
  
        beq r2, r0, SECOND_ONE_ZERO

        br ERROR # não é 10

        SECOND_ONE_ZERO: #10
          call CALC_TRIANGULAR
          br END_LOOP


      FIRST_TWO: # 2x
        call READ_WRITEBACK
        
        beq r2, r0, SECOND_TWO_ZERO

        movi r11, 1
        beq r2, r11, SECOND_TWO_ONE

        br ERROR # não é 20 nem 21

        SECOND_TWO_ZERO: #20
          call START_TIMER
          br END_LOOP

        SECOND_TWO_ONE: #21
          call STOP_TIMER
          br END_LOOP

      END_LOOP:

  br START_PROGRAM

.org 0x800
ACTIVE_LEDS:
.skip   18*4 # vetor de 17 posições


