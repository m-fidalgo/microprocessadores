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
*   - 1 - valor para "ativar" o LED no vetor
* r15
*   - contador do loop para checar se há leds ativos
* r16
*   - valor do active_led[i]
* r17
*  - 18 - tamanho do vetor active leds
*/

.equ ACTIVE_LEDS_BASE, 0x800 # endereço inicial do vetor active leds

.global SET_ACTIVE_LED
SET_ACTIVE_LED:
  # prólogo - configurar stack frame
  addi sp, sp, -32  # stack frame de 32 bytes
  stw ra, 28(sp)    # guarda o endereço de retorno
  stw r12, 24(sp)	
  stw r13, 20(sp)  
  stw r14, 16(sp)	
  stw r15, 12(sp)
  stw r16, 8(sp)
  stw r17, 4(sp)
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp       	# seta o novo frame pointer

  movia r13, ACTIVE_LEDS_BASE
  movi r14, 1
  movi r17, 18 # tamanho do vetor de leds ativos

  call READ_WRITEBACK # pega o 1o dígito do número do led (em ASCII)

  # obtendo o valor do 1o dígito * 10 (valor da dezena)
  slli r12, r2, 3 # multiplica por 8
  add r12, r12, r2 # soma o valor (r2 * 9)
  add r12, r12, r2 # soma o valor (r2 * 10) -> valor equivalente em dezena

  call READ_WRITEBACK # pega o 2o dígito do número do led (em ASCII)
  add r12, r12, r2 # valor da dezena + da unidade

  # checa se o vetor está vazio - se sim, inicia o temporizador
  movi r15, 0
  LOOP_CHECK_ACTIVE_LEDS:
    add r16, r15, r13 # endereço de active_led[i]
    ldb r16, 0(r16) # pega o valor de active_led[i]
    beq r16, r14, SET_LED # sai do loop se há led ativo

    addi r15, r15, 1 # incrementa o contador
    beq r15, r17, NO_ACTIVE_LED
    br LOOP_CHECK_ACTIVE_LEDS

  NO_ACTIVE_LED: # não há leds ativos -> configura o temporizador se necessário
    movi r5, 1 # indica que agora a interrupção dos leds está ativa
    bne r6, r0, SET_LED # se a interrupção do cronômetro está ativa não configura o led
    call START_TEMP_COUNTER

  SET_LED:

  ## setando o led escolhido como ativo no vetor
  slli r12, r12, 2 # multiplica por 4 = offset do led selecionado
  add r12, r12, r13 # endereço do led escolhido no vetor
  stb r14, 0(r12) # active_leds[r12] = 1

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