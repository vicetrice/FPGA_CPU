; ejemplo.asm


.sect text 0x00EE
    __start:
        MOV R0, 0x05
        MOV R1, 0x03
        CMP R0, R1
    locotron:
        STR [R2], R4
        PUSHF R0
        LEA R5, 0xFFFF
    label_loop:
        LDR R5, [R2]
        CMP R0, 0x00
        JNZ pruebi

.sect locotron 0x0005
    pruebi:
        MOV R0, R1

.sect data 0x00bb
        locote:
        STR [0xFF12], R5


        


        
