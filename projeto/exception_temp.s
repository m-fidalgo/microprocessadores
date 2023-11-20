/*
* r12
*   - endereço do registrador status do temporizador
* r13
*   - vetor de leds ativos
* r14
*  - 17 - tamanho do vetor active leds
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
*  - 1 -> valor para acender o led
*/

.equ TEMP_STATUS_REGISTER_BASE, 0x10002000
.equ ACTIVE_LEDS_BASE, 0x800 # endereço inicial do vetor active leds
.equ RED_LED_BASE, 0x10000000

.global EXCEPTION_TEMP
EXCEPTION_TEMP:
  # prólogo - configurar stack frame
  addi sp, sp, -44  # stack frame de 32 bytes
  stw ra, 40(sp)    # guarda o endereço de retorno
  stw r12, 36(sp)
  stw r13, 32(sp)
  stw r14, 28(sp)
  stw r15, 24(sp)
  stw r16, 20(sp)
  stw r17, 16(sp)
  stw r18, 12(sp)
  stw r19, 8(sp)
  stw r20, 4(sp)
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp       	# seta o novo frame pointer

	movia r12, TEMP_STATUS_REGISTER_BASE
  movia r13, ACTIVE_LEDS_BASE
  movia r15, RED_LED_BASE
  movi r14, 17 # índice máximo no vetor de leds ativos
  movi r16, 0
  movi r20, 1

  LOOP_LEDS:
    add r17, r16, r13 # endereço de active_led[i]
    ldb r17, 0(r17) # pega o valor de active_led[i]
    beq r17, r0, EXIT_LOOP_LEDS # vai para o próximo se o led não é ativo

    # inverte valor do led
    addi r18, r15, r16 # endereço do led i
    ldwio r19, 0(r18)   # valor do led i
    beq r19, r0, TURN_ON_LED # se o valor é 0, o led deve ser aceso

    stwio r0, 0(r18) # apaga o led (valor 0)
    br EXIT_LOOP_LEDS

    TURN_ON_LED:
      stwio r20, 0(r18) # acende o led (valor 1)

    EXIT_LOOP_LEDS:
      addi r16, r16, 1 # incrementa o contador
      beq r16, r14, EXIT_TEMP # sai após o último led

    br LOOP_LEDS

  EXIT_TEMP:
    stwio r0, 0(r12)  # seta o valor de TO no registrador status do temporizador

    # epílogo - limpar stack frame
    ldw ra, 40(sp)
    ldw r12, 36(sp)
    ldw r13, 32(sp)
    ldw r14, 28(sp)
    ldw r15, 24(sp)
    ldw r16, 20(sp)
    ldw r17, 16(sp)
    ldw r18, 12(sp)
    ldw r19, 8(sp)
    ldw r20, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 44
    ret