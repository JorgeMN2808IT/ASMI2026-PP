.MODEL SMALL
.STACK 100h

.DATA
    titulo          DB 13,10,'========= BANKTEC =========',13,10,'$'
    opcion1         DB '1. Crear cuenta',13,10,'$'
    opcion2         DB '2. Depositar dinero',13,10,'$'
    opcion3         DB '3. Retirar dinero',13,10,'$'
    opcion4         DB '4. Consultar saldo',13,10,'$'
    opcion5         DB '5. Mostrar reporte general',13,10,'$'
    opcion6         DB '6. Desactivar cuenta',13,10,'$'
    opcion7         DB '7. Salir',13,10,'$'
    pedirOpcion     DB 13,10,'Seleccione una opcion (1-7): $'
    opcionInvalida  DB 13,10,'Opcion invalida. Intente de nuevo.',13,10,'$'

    msgCrear        DB 13,10,'[Crear cuenta]',13,10,'$'
    msgDepositar    DB 13,10,'[Depositar dinero]',13,10,'$'
    msgRetirar      DB 13,10,'[Retirar dinero]',13,10,'$'
    msgConsultar    DB 13,10,'[Consultar saldo]',13,10,'$'
    msgReporte      DB 13,10,'[Mostrar reporte general]',13,10,'$'
    msgDesactivar   DB 13,10,'[Desactivar cuenta]',13,10,'$'
    msgSalir        DB 13,10,'Saliendo del sistema...',13,10,'$'

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MENU_PRINCIPAL:
    CALL LIMPIAR_PANTALLA
    CALL MOSTRAR_MENU
    CALL LEER_OPCION

    CMP AL, '1'
    JE OP_CREAR

    CMP AL, '2'
    JE OP_DEPOSITAR

    CMP AL, '3'
    JE OP_RETIRAR

    CMP AL, '4'
    JE OP_CONSULTAR

    CMP AL, '5'
    JE OP_REPORTE

    CMP AL, '6'
    JE OP_DESACTIVAR

    CMP AL, '7'
    JE OP_SALIR

    ; Si no está entre 1 y 7
    LEA DX, opcionInvalida
    MOV AH, 09h
    INT 21h
    CALL ESPERAR_TECLA
    JMP MENU_PRINCIPAL

OP_CREAR:
    CALL LIMPIAR_PANTALLA
    LEA DX, msgCrear
    MOV AH, 09h
    INT 21h
    CALL ESPERAR_TECLA
    JMP MENU_PRINCIPAL

OP_DEPOSITAR:
    CALL LIMPIAR_PANTALLA
    LEA DX, msgDepositar
    MOV AH, 09h
    INT 21h
    CALL ESPERAR_TECLA
    JMP MENU_PRINCIPAL

OP_RETIRAR:
    CALL LIMPIAR_PANTALLA
    LEA DX, msgRetirar
    MOV AH, 09h
    INT 21h
    CALL ESPERAR_TECLA
    JMP MENU_PRINCIPAL

OP_CONSULTAR:
    CALL LIMPIAR_PANTALLA
    LEA DX, msgConsultar
    MOV AH, 09h
    INT 21h
    CALL ESPERAR_TECLA
    JMP MENU_PRINCIPAL

OP_REPORTE:
    CALL LIMPIAR_PANTALLA
    LEA DX, msgReporte
    MOV AH, 09h
    INT 21h
    CALL ESPERAR_TECLA
    JMP MENU_PRINCIPAL

OP_DESACTIVAR:
    CALL LIMPIAR_PANTALLA
    LEA DX, msgDesactivar
    MOV AH, 09h
    INT 21h
    CALL ESPERAR_TECLA
    JMP MENU_PRINCIPAL

OP_SALIR:
    LEA DX, msgSalir
    MOV AH, 09h
    INT 21h

    MOV AH, 4Ch
    INT 21h

MAIN ENDP

; --------------------------------------------------
; Procedimiento: MOSTRAR_MENU
; Muestra todas las opciones del menú principal
; --------------------------------------------------
MOSTRAR_MENU PROC
    LEA DX, titulo
    MOV AH, 09h
    INT 21h

    LEA DX, opcion1
    MOV AH, 09h
    INT 21h

    LEA DX, opcion2
    MOV AH, 09h
    INT 21h

    LEA DX, opcion3
    MOV AH, 09h
    INT 21h

    LEA DX, opcion4
    MOV AH, 09h
    INT 21h

    LEA DX, opcion5
    MOV AH, 09h
    INT 21h

    LEA DX, opcion6
    MOV AH, 09h
    INT 21h

    LEA DX, opcion7
    MOV AH, 09h
    INT 21h

    LEA DX, pedirOpcion
    MOV AH, 09h
    INT 21h

    RET
MOSTRAR_MENU ENDP

; --------------------------------------------------
; Procedimiento: LEER_OPCION
; Lee un carácter desde teclado y lo deja en AL
; --------------------------------------------------
LEER_OPCION PROC
    MOV AH, 01h
    INT 21h
    RET
LEER_OPCION ENDP

; --------------------------------------------------
; Procedimiento: ESPERAR_TECLA
; Espera una tecla antes de continuar
; --------------------------------------------------
ESPERAR_TECLA PROC
    MOV AH, 08h
    INT 21h
    RET
ESPERAR_TECLA ENDP

; --------------------------------------------------
; Procedimiento: LIMPIAR_PANTALLA
; Limpia pantalla usando BIOS
; --------------------------------------------------
LIMPIAR_PANTALLA PROC
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    RET
LIMPIAR_PANTALLA ENDP

END MAIN