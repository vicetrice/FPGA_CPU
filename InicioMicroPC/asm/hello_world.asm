



.sect text 0x0005
    ; Configuración inicial GPIO
    MOV R3, 0x04
    STR [0xFFF2], R3      ; Configura GPIO como entrada/salida
    STR [0xFFF3], R3      ; Pone GPIO3 en 1

    ; Preparar puntero a cadena

    LEA R2, hola_mundo    ; R2 apunta a la cadena "Hola mundo"

    READ_GPIO_RX:
    LDR R1, [0xFFF4]      ; Leer GPIO RX
    CMP R1, 0x05          ; Espera KEY2
    JNZ READ_GPIO_RX      ; Reintentar hasta detectar tecla

    SEND_LOOP:
    LDR R0, [R2]          ; Cargar siguiente byte de la cadena
    CMP R0, 0xFF          ; Fin de cadena?
    JNZ CONTINUE          ; Saltar si fin de cadena
    
    LEA IP,NEAR_END
    
    CONTINUE:
    STR [0xFFF0], R0      ; Enviar por UART

    WAIT_CONFIRM:
    LDR R1, [0xFFF4]      ; Esperar confirmación
    CMP R1, 0x06          ; KEY1 como confirmación
    JNZ WAIT_CONFIRM  ; Reintentar hasta confirmación

    STR [0xFFF1],R0
    ADD R2, 1             ; Avanzar puntero
    LEA R6, READ_GPIO_RX  ; Repetir

    NEAR_END:
    MOV R3, 0x00
    STR [0xFFF3], R3       ; Apagar GPIO3
    LEA R6, END            ; Bucle infinito

    END:
    LEA R6, END            ; Bucle infinito


.sect data 0x00bb
    hola_mundo:
    .DB "Hola mundo",0x00,0xFF
