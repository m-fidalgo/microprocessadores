/*
* r2
*  - valor de retorno de READ_WRITEBACK (valor lido na uart): conteúdo DATA do data register (bits 0 a 7)
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


.equ UART_BASE, 0x10001000 # uart data register
.equ UART_CONTROL, 0x04 # uart control register offset


.global _start
_start:
  START_PROGRAM:
    movia sp, 0x10000
    movia r8, UART_BASE

    ### permitindo interrupções no sistema
    wrctl	status, r13 # seta o PIE para permitir interrupções

    rdctl r13, ienable # copia o ienable para r13
    ori r13, r13, 0b1 # seta o IRQ0 como 1 (permitir interrupção do temporizador)
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
          # call READ_WRITEBACK # pega o 1o dígito do número do led (em ASCII)

          # # obtendo o valor do 1o dígito * 10 (valor da dezena)
          # addi r2, r2, -48 # transformando ASCII em int
          # slli r12, r2, 3 # multiplica por 8
          # add r12, r12, r2 # soma o valor (r2 * 9)
          # add r12, r12, r2 # soma o valor (r2 * 10) -> valor equivalente em dezena

          # call READ_WRITEBACK # pega o 2o dígito do número do led (em ASCII)
          # addi r2, r2, -48 # transformando ASCII em int
          # add r12, r12, r2 # valor da dezena + da unidade

          # # TODO: ligar o led r12
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
          # TODO: iniciar cronômetro
          br END_LOOP

        SECOND_TWO_ONE: #21
          # TODO: parar cronômetro
          br END_LOOP

      END_LOOP:

  br START_PROGRAM

.org 0x800
ACTIVE_LEDS:
.skip   17*4 # vetor de 17 posições


