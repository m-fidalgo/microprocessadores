/*
* r2
*  - valor de retorno de READ_WRITEBACK (valor lido na uart): conteúdo DATA do data register (bits 0 a 7)
* r5
*  - indica se a interrupção do led está ativa (1) ou não (0)
* r6
*  - indica se a interrupção do cronômetro está ativa (1) ou não (0)
* r12
*   - número do led
* r13
*   - vetor de leds ativos
* r14
*   - 1 - valor do LED ativo no vetor
* r15
*   - contador do loop para checar se há leds ativos
*   - endereço base do registrador control do temporizador
*   - endereço base do red led base
* r16
*   - valor do active_led[i]
* r17
*  - 17 - tamanho do vetor active leds
*/

.equ ACTIVE_LEDS_BASE, 0x800 # endereço inicial do vetor active leds
.equ TEMP_CONTROL_REGISTER_BASE, 0x10002004 # control do temporizador
.equ RED_LED_BASE, 0x10000000 # endereço base dos leds

.global REMOVE_ACTIVE_LED
REMOVE_ACTIVE_LED:
  # prólogo - configurar stack frame
  addi sp, sp, -32 # stack frame de 32 bytes
  stw ra, 28(sp) # guarda o endereço de retorno
  stw r12, 24(sp)	
  stw r13, 20(sp)  
  stw r14, 16(sp)	
  stw r15, 12(sp)
  stw r16, 8(sp)
  stw r17, 4(sp)
  stw fp, (sp) # guarda o frame pointer
  mov fp, sp	# seta o novo frame pointer

  movia r13, ACTIVE_LEDS_BASE
  movi r14, 1
  movi r17, 17 # tamanho do vetor de leds ativos

  call READ_WRITEBACK # pega o 1o dígito do número do led (em ASCII)

  # obtendo o valor do 1o dígito * 10 (valor da dezena)
  slli r12, r2, 3 # multiplica por 8
  add r12, r12, r2 # soma o valor (r2 * 9)
  add r12, r12, r2 # soma o valor (r2 * 10) -> valor equivalente em dezena

  call READ_WRITEBACK # pega o 2o dígito do número do led (em ASCII)
  add r12, r12, r2 # valor da dezena + da unidade

  ## setando o led escolhido como inativo no vetor
  slli r12, r12, 2 # multiplica por 4 = offset do led selecionado
  add r12, r12, r13 # endereço do led escolhido no vetor
  stb r0, 0(r12) # active_leds[r12] = 0

  # checa se o vetor está vazio - se sim, remove o counter do temporizador
  movi r15, 0
  LOOP_ACTIVE_LEDS:
    add r16, r15, r13 # endereço de active_led[i]
    ldb r16, 0(r16) # pega o valor de active_led[i]
    beq r16, r14, EXIT_REMOVE_LED # sai do loop se há led ativo

    addi r15, r15, 1 # incrementa o contador
    beq r15, r17, EMPTY_VECTOR
    br LOOP_ACTIVE_LEDS

  EMPTY_VECTOR:
    movi r5, 0 # não há mais interrupções do led
  
    movia r15, RED_LED_BASE
    stwio r0, 0(r15) # desliga todos os leds

    bne r6, r0, EXIT_REMOVE_LED # se há interrupções do cronômetro, não faz nada

    # não há leds ativos e não há interrupção do cronômetro: limpa o temporizador
    movia r15, TEMP_CONTROL_REGISTER_BASE
    stwio r0, 0(r15)

  EXIT_REMOVE_LED:
    # epílogo - limpar stack frame
    ldw ra, 28(sp)
    ldw r12, 24(sp)
    ldw r13, 20(sp)
    ldw r14, 16(sp)
    ldw r15, 12(sp)
    ldw r16, 8(sp)
    ldw r17, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 32
    ret