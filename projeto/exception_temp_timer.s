/*
* r7
*  - flag que indica se a contagem do cronômetro está pausada (0) ou ativa (1)
* r12
*  - endereço do contador do timer (quantos segundos se passaram)
* r13
* - novo valor do contador
* r14
* - endereço do display de 7 segmentos
*/

.equ TIMER_COUNTER_BASE, 0x900 # endereço do contador do timer
.equ DISPLAY_7_SEG_BASE1, 0x10000020
.equ DISPLAY_7_SEG_BASE2, 0x10000030

.global EXCEPTION_TEMP_TIMER
EXCEPTION_TEMP_TIMER:
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
  stw r10, 12(sp)   
  stw r9, 8(sp)   	
  stw r8, 4(sp)   	
  stw fp, (sp)     	# guarda o frame pointer
  mov fp, sp    

	beq r7, r0, EXIT_EXCEPTION_TEMP_TIMER # se r7=0, a contagem está pausada (não fazer nada)

  # essa funcao é chamada a cada 1s, aqui a gnt tem que usar um contador (memória) pra somar +1s e aí mostrar no display de 7seg
	# o valor total desse contador. 

  movia r12, TIMER_COUNTER_BASE # endereço do contador
  movia r17, DISPLAY_7_SEG_BASE1
  movia r18, DISPLAY_7_SEG_BASE2
  movia r11, SEG_LIST

  ldw r13, 0(r12) # valor atual do contador
  addi r13, r13, 1 # incrementa o contador
  stw r13, 0(r12) # armazena o novo valor

  # comecaaqui o codigo referecia tirado do triangular
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
       
       add r13, r10, r17 # calculo o endereço dinamico da tabela, r12 é a base do 7seg
       stb r9, 0(r13) # define o valor de HEX0 como o valor obtido da tabela
       addi r10, r10, 1
       br LOOP_DISPLAY

       SET_BASE_DISPLAY2:
        subi r16, r10, 4
        add r13, r16, r18
        stb r9, 0(r13)
        addi r10, r10, 1
        br LOOP_DISPLAY
  
  EXIT_LOOP_DISPLAY:


	EXIT_EXCEPTION_TEMP_TIMER:
    # epílogo - limpar stack frame
    ldw ra, 44(sp)
    ldw r17, 40(sp)
    ldw r16, 36(sp)  
    ldw r15, 32(sp)
    ldw r14, 28(sp)
    ldw r13, 24(sp)
    ldw r12, 20(sp)
    ldw r11, 16(sp)
    ldw r10, 12(sp) 
    ldw r9, 8(sp)   	
    ldw r8, 4(sp)
    ldw fp, (sp)
    addi sp, sp, 48
	ret

SEG_LIST:
	.byte	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71