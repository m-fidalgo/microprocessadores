.global STOP_TIMER
STOP_TIMER:
    # é parecido com o remove_active_led: se tiver interrupção do led, não faz nada,
    # caso contrário limpa o registrador control do temporizador
    # seta r6 como 0 pra indicar que agora não tem mais interrupção do timer
    ret