; blink.asm


.sect text 0x00EE

    start:
    MOV R3, 0x04
    STR [0xFFF2], R3      ; Configura GPIO como entrada/salida
    STR [0xFFF3], R3      ; Pone GPIO3 en 1

    
    READ_GPIO_RX_ON:

    LDR R1, [0xFFF4]      ; Leer GPIO RX
    CMP R1, 0x05          ; Espera KEY2
    JNZ READ_GPIO_RX_ON      ; Reintentar hasta detectar tecla
    LEA IP, LED_OFF


    READ_GPIO_RX_OFF:

    LDR R1, [0xFFF4]      ; Leer GPIO RX
    CMP R1, 0x01          ; Espera KEY2
    JNZ READ_GPIO_RX_OFF      ; Reintentar hasta detectar tecla
    LEA IP, LED_ON


    

    LED_OFF:
    MOV R3, 0x00
    STR [0xFFF3], R3       ; Apagar GPIO3
    ESPERAR_HASTA_SOLTAR:
    LDR R1, [0xFFF4]      ; Leer GPIO RX
    CMP R1, 0x03          ; Espera KEY2
    JNZ ESPERAR_HASTA_SOLTAR ; Reintentar hasta detectar tecla
    LEA IP, READ_GPIO_RX_OFF

    LED_ON:
    MOV R3, 0x04
    STR [0xFFF3], R3       ; encender GPIO3
    ESPERAR_HASTA_SOLTAR_2:
    LDR R1, [0xFFF4]      ; Leer GPIO RX
    CMP R1, 0x07          ; Espera KEY2
    JNZ ESPERAR_HASTA_SOLTAR_2 ; Reintentar hasta detectar tecla
    LEA IP, READ_GPIO_RX_ON


    END:
    LEA R6, END            ; Bucle infinito