/*
* r12
*   - endereço do registrador status do temporizador
* r13
*   - vetor de leds ativos
* r14
*  - espelho
* r15
*  - endereço base dos leds vermelhos
* r16
*   - contador do loop
* r17
*   - valor do active_led[i]
* r18
*   - endereço do led i]
* r19
*   - valor armazenado no led i
* r20
*  - índice * 4
*/

.equ TEMP_STATUS_REGISTER_BASE, 0x10002000
.equ ACTIVE_LEDS_BASE, 0x800 # endereço inicial do vetor active leds
.equ RED_LED_BASE, 0x10000000

.global EXCEPTION_TEMP_LED
EXCEPTION_TEMP_LED:
  # prólogo - configurar stack frame
  addi sp, sp, -40  # stack frame de 32 bytes
  stw ra, 36(sp)    # guarda o endereço de retorno
  stw r12, 32(sp)
  stw r13, 28(sp)
  stw r14, 24(sp)
  stw r15, 20(sp)
  stw r16, 16(sp)
  stw r17, 12(sp)
  stw r18, 8(sp)
  stw r19, 4(sp)
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp       	# seta o novo frame pointer

	movia r12, TEMP_STATUS_REGISTER_BASE
  movia r13, ACTIVE_LEDS_BASE
  movia r15, RED_LED_BASE
  movi r14, 0
  movi r16, 17 #esse valor n deveria ser 16 por causa do intervalo do RED LED ser de 0 a F  ????????
  movi r20, 17*4 # no vetor ele esta em 4 em 4, por isso precisamos multiplicar por 4

  LOOP_LEDS:
    add r17, r20, r13 # endereço de active_led[i] (ACTIVE_LEDS_BASE)
    ldb r17, 0(r17) # pega o valor de active_led[i] (ACTIVE_LEDS_BASE)
    slli r14, r14, 1 # moveu o espelho 1 para esquerda (mesmo se for 0)
    beq r17, r0, EXIT_LOOP_LEDS # vai para o próximo se o led não é ativo

    # inverte valor do led
    ldwio r18, 0(r15) # carrega o valor inteiro do RED_LED_BASE
    srl r19, r18, r16 # corta ele {contador} vezes para ele ficar apenas o valor do bit que queremos
    bne r19, r0, EXIT_LOOP_LEDS # se o valor é != 0, não precisamos fazer nada pois ao mover para direita ele eh 0

    addi r14, r14, 1 #se o valor é = 0, precisamos acender o led: adicionar 1 no espelho

    EXIT_LOOP_LEDS:
      beq r20, r0, EXIT_TEMP # sai após o último led
      addi r20, r20, -4 # decrementa o contador
      addi r16, r16, -1 # decrementa o contador

    br LOOP_LEDS  

  EXIT_TEMP:
    stwio r14, 0(r15) # acender os leds, basicamente colocar o espelho no RED_LED_BASE
    stwio r0, 0(r12)  # seta o valor de TO no registrador status do temporizador

    # epílogo - limpar stack frame
    ldw ra, 36(sp)
    ldw r12, 32(sp)
    ldw r13, 28(sp)
    ldw r14, 24(sp)
    ldw r15, 20(sp)
    ldw r16, 16(sp)
    ldw r17, 12(sp)
    ldw r18, 8(sp)
    ldw r19, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 40
    ret