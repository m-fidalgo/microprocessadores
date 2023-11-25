.global START_TIMER
START_TIMER:
    # é parecido com o set_active_led: se nao tiver interrupção do led, chama o START_TEMP_COUNTER
    # seta r6 como 1 pra indicar que agora tem interrupção do timer
    ret