/*
* r2
*  -  valor de retorno : valor lido na uart, conteúdo DATA do data register (bits 0 a 7)
* r8
*   - endereço base dos switchs
* r9
*   - valor dos 8 primeiros switchs
* r10
*   - valor em hexa para mostrar no display 
* r11
*   - endereço dos segmentos
* r12
*   - endereco dos displays
* r13
*   - valor triangular http://www.osfantasticosnumerosprimos.com.br/014-008-calculadora-ordem-posicao-numero-triangular.html
*/

.equ SWITCH_BASE, 0x10000040
.equ DISPLAY_7_SEG_BASE1, 0x10000020
.equ DISPLAY_7_SEG_BASE2, 0x10000030


.global CALC_TRIANGULAR
CALC_TRIANGULAR:

# prólogo - configurar stack frame
  addi sp, sp, -48  # stack frame de 28 bytes
  stw ra, 44(sp)    # guarda o endereço de retorno
  stw r17, 40(sp)
  stw r16, 36(sp)
  stw r15, 32(sp)
  stw r14, 28(sp)
  stw r13, 24(sp)
  stw r12, 20(sp)
  stw r11, 16(sp)
  stw r10, 12(sp)   	# guardando r8 na stack
  stw r9, 8(sp)   	# guardando r8 na stack
  stw r8, 4(sp)   	# guardando r8 na stack
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp       	# seta o novo frame pointer

  movia r8, SWITCH_BASE
  movia r11, SEG_LIST
  movia r12, DISPLAY_7_SEG_BASE1
  movia r17, DISPLAY_7_SEG_BASE2

  
  ldwio r9, 0(r8)   # pega valor do switch
  andi r9, r9, 0xFF # aplica máscara para pegar os 8 primeiros


  mov r13, r0 # inicia acumulador com 0
  movi r8, 1 # registrador para ficar vendo se o r9 lido pelo switch vai ser igual a 1

  LOOP_TRIANGULAR:
    beq r9, r8, EXIT_LOOP_TRIANGULAR
    add r13, r13, r9
    addi r9, r9, -1
    br LOOP_TRIANGULAR

  EXIT_LOOP_TRIANGULAR:
    addi r13, r13, 1 # precisa somar 1 no final pq ele sai do loop quando r9 for 1 ( mas ele não estava somando, logo soma quando sair do loop)

    movi r8, 10
    movi r10, 0

    # r14 = resultado da divisao
    # r15 = resto da divisao

     mov r14, r13 # inicializo o r14 com o valor
     movi r16, 0

     LOOP_DISPLAY: # a ideia eh montar um loop para exibir cada numero
       beq r14, r0, EXIT_LOOP_DISPLAY # se o resultado da divisao for 0, para o loop
    
       div r16, r14, r8 # calcula o resultado da divisao (r14/10)
       mul r15, r16, r8
       sub r15, r14, r15 # pega o resto
       
       mov r14, r16
       movi r16, 4 # (comparar r10 sendo maior ou igual a 4 para pegar DISPLAY_7_SEG_BASE1 ou DISPLAY_7_SEG_BASE2 )

       #Xo dígito
       add r9, r15, r11 # pega o endereço do item na lista
       ldbio r9, 0(r9) # valor correspondente da tabela

       bge r10, r16, SET_BASE_DISPLAY2
       
       add r13, r10, r12 # calculo o endereço dinamico da tabela, r12 é a base do 7seg
       stb r9, 0(r13) # define o valor de HEX0 como o valor obtido da tabela
       addi r10, r10, 1
       br LOOP_DISPLAY

       SET_BASE_DISPLAY2:
        subi r16, r10, 4
        add r13, r16, r17
        stb r9, 0(r13)
        addi r10, r10, 1
        br LOOP_DISPLAY

    EXIT_LOOP_DISPLAY:

	  END_READ_WRITEBACK:
    # epílogo - limpar stack frame
    ldw ra, 44(sp)
    ldw r17, 40(sp)
    ldw r16, 36(sp)  
    ldw r15, 32(sp)
    ldw r14, 28(sp)
    ldw r13, 24(sp)
    ldw r12, 20(sp)
    ldw r11, 16(sp)
    ldw r10, 12(sp)   	# guardando r8 na stack
    ldw r9, 8(sp)   	# guardando r8 na stack
    ldw r8, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 48
    ret

SEG_LIST:
	.byte	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71