.MODEL SMALL
.STACK 100h

; ==================================================
; CONSTANTES DE LA ESTRUCTURA "CUENTA"
; ==================================================
MAX_CUENTAS EQU 10
TAM_NOMBRE  EQU 20

OFF_NUMERO  EQU 0
OFF_NOMBRE  EQU 2
OFF_SALDO   EQU 22
OFF_ESTADO  EQU 26
TAM_CUENTA  EQU 27

.DATA
    ; -------------------------------
    ; MENÚ
    ; -------------------------------
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

    ; -------------------------------
    ; MENSAJES DE CREAR CUENTA
    ; -------------------------------
    msgPedirNumero      DB 13,10,'Ingrese numero de cuenta: $'
    msgPedirNombre      DB 13,10,'Ingrese nombre del titular (max 20): $'
    msgPedirSaldo       DB 13,10,'Ingrese saldo inicial (ej: 123.4567): $'
    msgCuentaCreada     DB 13,10,'Cuenta creada correctamente.',13,10,'$'
    msgCuentaRepetida   DB 13,10,'Error: numero de cuenta repetido.',13,10,'$'
    msgBancoLleno       DB 13,10,'Error: ya no se pueden crear mas cuentas.',13,10,'$'
    msgNombreInvalido   DB 13,10,'Error: nombre invalido.',13,10,'$'
    msgNumeroInvalido   DB 13,10,'Error: valor numerico invalido.',13,10,'$'

    ; -------------------------------
    ; MENSAJES DE DEPOSITAR
    ; -------------------------------
    msgPedirCuentaDep   DB 13,10,'Ingrese numero de cuenta a depositar: $'
    msgPedirMontoDep    DB 13,10,'Ingrese monto a depositar (ej: 10.5000): $'
    msgCuentaNoExiste   DB 13,10,'Error: la cuenta no existe.',13,10,'$'
    msgCuentaInactiva   DB 13,10,'Error: la cuenta esta inactiva.',13,10,'$'
    msgMontoInvalido    DB 13,10,'Error: el monto debe ser positivo o tener formato valido.',13,10,'$'
    msgDepositoOK       DB 13,10,'Deposito realizado correctamente.',13,10,'$'

    ; -------------------------------
    ; MENSAJES DE RETIRAR
    ; -------------------------------
    msgPedirCuentaRet   DB 13,10,'Ingrese numero de cuenta a retirar: $'
    msgFondosInsuficientes DB 13,10,'Error: fondos insuficientes.',13,10,'$'
    msgRetiroOK         DB 13,10,'Retiro realizado correctamente.',13,10,'$'
    msgPedirMontoRet    DB 13,10,'Ingrese monto a retirar (ej: 5.2500): $'

    ; -------------------------------
    ; MENSAJES DE CONSULTAR
    ; -------------------------------
    msgPedirCuentaCon   DB 13,10,'Ingrese numero de cuenta a consultar: $'
    msgSaldoActual      DB 13,10,'Saldo actual: $'

    ; -------------------------------
    ; MENSAJES DE MOSTRAR REPORTE
    ; -------------------------------
    msgTotalActivas     DB 13,10,'Cuentas activas: $'
    msgTotalInactivas   DB 13,10,'Cuentas inactivas: $'
    msgSaldoBanco       DB 13,10,'Saldo total del banco: $'
    msgMayorSaldo       DB 13,10,'Mayor saldo: $'
    msgMenorSaldo       DB 13,10,'Menor saldo: $'

    ; -------------------------------
    ; MENSAJES GENERALES
    ; -------------------------------
    msgPresioneTecla    DB 13,10,'Presione una tecla para continuar...$'

    ; -------------------------------
    ; ESTRUCTURA EN MEMORIA
    ; Cada cuenta ocupa 27 bytes:
    ; [0-1]   numero   (WORD)
    ; [2-21]  nombre   (20 bytes)
    ; [22-25] saldo    (DWORD escalado x10000)
    ; [26]    estado   (1=activa, 0=inactiva)
    ; -------------------------------
    cuentas         DB MAX_CUENTAS * TAM_CUENTA DUP(0)
    totalCuentas    DB 0

    ; -------------------------------
    ; BUFFERS DE ENTRADA
    ; INT 21h / AH=0Ah
    ; -------------------------------
    bufferNumero    DB 5,0,5 DUP(0)
    bufferNombre    DB 20,0,20 DUP(0)
    bufferMonto     DB 15,0,15 DUP(0)

    ; -------------------------------
    ; VARIABLES AUXILIARES
    ; -------------------------------
    tempNumero          DW 0
    tempSaldoLo         DW 0
    tempSaldoHi         DW 0
    tempMontoLo         DW 0
    tempMontoHi         DW 0

    reporteActivas      DW 0
    reporteInactivas    DW 0
    reporteSaldoTotalLo DW 0
    reporteSaldoTotalHi DW 0
    reporteMayorLo      DW 0
    reporteMayorHi      DW 0
    reporteMenorLo      DW 0
    reporteMenorHi      DW 0

    flagPunto       DB 0
    cantDecimales   DB 0
    huboDigito      DB 0
    digitoActual    DB 0

    bufferImpresion DB 16 DUP(0)

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

    LEA DX, opcionInvalida
    MOV AH, 09h
    INT 21h
    CALL PAUSA
    JMP MENU_PRINCIPAL

OP_CREAR:
    CALL LIMPIAR_PANTALLA
    CALL CREAR_CUENTA
    CALL PAUSA
    JMP MENU_PRINCIPAL

OP_DEPOSITAR:
    CALL LIMPIAR_PANTALLA
    CALL DEPOSITAR_DINERO
    CALL PAUSA
    JMP MENU_PRINCIPAL

OP_RETIRAR:
    CALL LIMPIAR_PANTALLA
    CALL RETIRAR_DINERO
    CALL PAUSA
    JMP MENU_PRINCIPAL

OP_CONSULTAR:
    CALL LIMPIAR_PANTALLA
    CALL CONSULTAR_SALDO
    CALL PAUSA
    JMP MENU_PRINCIPAL

OP_REPORTE:
    CALL LIMPIAR_PANTALLA
    CALL REPORTE_GENERAL
    CALL PAUSA
    JMP MENU_PRINCIPAL

OP_DESACTIVAR:
    CALL LIMPIAR_PANTALLA
    LEA DX, msgDesactivar
    MOV AH, 09h
    INT 21h
    CALL PAUSA
    JMP MENU_PRINCIPAL

OP_SALIR:
    LEA DX, msgSalir
    MOV AH, 09h
    INT 21h

    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; ==================================================
; BUSCAR_CUENTA
; Busca por numero en tempNumero
; Salida:
;   CF = 0 si encuentra
;   CF = 1 si no encuentra
;   DI = direccion base de la cuenta
; ==================================================
BUSCAR_CUENTA:
    LEA DI, cuentas
    XOR CH, CH
    MOV CL, [totalCuentas]

    CMP CL, 0
    JE NO_ENCONTRADA

BUSCAR_LOOP:
    MOV AX, [DI + OFF_NUMERO]
    CMP AX, [tempNumero]
    JE ENCONTRADA

    ADD DI, TAM_CUENTA
    LOOP BUSCAR_LOOP

NO_ENCONTRADA:
    STC
    RET

ENCONTRADA:
    CLC
    RET

; ==================================================
; 4.2.1 CREAR CUENTA
; ==================================================
CREAR_CUENTA PROC
    LEA DX, msgCrear
    MOV AH, 09h
    INT 21h

    MOV AL, [totalCuentas]
    CMP AL, MAX_CUENTAS
    JAE BANCO_LLENO

    LEA DX, msgPedirNumero
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_CREAR
    MOV [tempNumero], AX

    CALL BUSCAR_CUENTA
    JNC CUENTA_REPETIDA

    LEA DX, msgPedirNombre
    MOV AH, 09h
    INT 21h

    CALL LEER_NOMBRE
    JC NOMBRE_INVALIDO_CREAR

    LEA DX, msgPedirSaldo
    MOV AH, 09h
    INT 21h

    CALL LEER_MONTO4
    JC MONTO_INVALIDO_CREAR

    MOV [tempSaldoLo], AX
    MOV [tempSaldoHi], DX

    CALL OBTENER_DIRECCION_NUEVA_CUENTA

    MOV AX, [tempNumero]
    MOV [DI + OFF_NUMERO], AX

    PUSH DI
    MOV CX, TAM_NOMBRE
    ADD DI, OFF_NOMBRE

LIMPIAR_NOMBRE_NUEVO:
    MOV BYTE PTR [DI], 0
    INC DI
    LOOP LIMPIAR_NOMBRE_NUEVO

    POP DI

    LEA SI, bufferNombre + 2
    ADD DI, OFF_NOMBRE
    XOR CH, CH
    MOV CL, [bufferNombre + 1]

COPIAR_NOMBRE_NUEVO:
    CMP CL, 0
    JE FIN_COPIAR_NOMBRE_NUEVO
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    DEC CL
    JMP COPIAR_NOMBRE_NUEVO

FIN_COPIAR_NOMBRE_NUEVO:
    CALL OBTENER_DIRECCION_NUEVA_CUENTA

    MOV AX, [tempSaldoLo]
    MOV [DI + OFF_SALDO], AX

    MOV AX, [tempSaldoHi]
    MOV [DI + OFF_SALDO + 2], AX

    MOV BYTE PTR [DI + OFF_ESTADO], 1

    INC BYTE PTR [totalCuentas]

    LEA DX, msgCuentaCreada
    MOV AH, 09h
    INT 21h
    RET

BANCO_LLENO:
    LEA DX, msgBancoLleno
    MOV AH, 09h
    INT 21h
    RET

CUENTA_REPETIDA:
    LEA DX, msgCuentaRepetida
    MOV AH, 09h
    INT 21h
    RET

NUMERO_INVALIDO_CREAR:
    LEA DX, msgNumeroInvalido
    MOV AH, 09h
    INT 21h
    RET

MONTO_INVALIDO_CREAR:
    LEA DX, msgMontoInvalido
    MOV AH, 09h
    INT 21h
    RET

NOMBRE_INVALIDO_CREAR:
    LEA DX, msgNombreInvalido
    MOV AH, 09h
    INT 21h
    RET
CREAR_CUENTA ENDP

; ==================================================
; 4.2.2 DEPOSITAR DINERO
; ==================================================
DEPOSITAR_DINERO PROC
    LEA DX, msgDepositar
    MOV AH, 09h
    INT 21h

    LEA DX, msgPedirCuentaDep
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_DEP

    MOV [tempNumero], AX

    CALL BUSCAR_CUENTA
    JC CUENTA_NO_EXISTE_DEP

    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JNE CUENTA_INACTIVA_DEP

    LEA DX, msgPedirMontoDep
    MOV AH, 09h
    INT 21h

    CALL LEER_MONTO4
    JC MONTO_INVALIDO_DEP

    OR DX, AX
    JZ MONTO_INVALIDO_DEP

    MOV [tempMontoLo], AX
    MOV [tempMontoHi], DX

    MOV AX, [DI + OFF_SALDO]
    ADD AX, [tempMontoLo]
    MOV [DI + OFF_SALDO], AX

    MOV AX, [DI + OFF_SALDO + 2]
    ADC AX, [tempMontoHi]
    MOV [DI + OFF_SALDO + 2], AX

    LEA DX, msgDepositoOK
    MOV AH, 09h
    INT 21h
    RET

CUENTA_NO_EXISTE_DEP:
    LEA DX, msgCuentaNoExiste
    MOV AH, 09h
    INT 21h
    RET

CUENTA_INACTIVA_DEP:
    LEA DX, msgCuentaInactiva
    MOV AH, 09h
    INT 21h
    RET

MONTO_INVALIDO_DEP:
    LEA DX, msgMontoInvalido
    MOV AH, 09h
    INT 21h
    RET

NUMERO_INVALIDO_DEP:
    LEA DX, msgNumeroInvalido
    MOV AH, 09h
    INT 21h
    RET
DEPOSITAR_DINERO ENDP

; ==================================================
; 4.2.3 RETIRAR DINERO
; ==================================================
RETIRAR_DINERO PROC
    LEA DX, msgRetirar
    MOV AH, 09h
    INT 21h

    LEA DX, msgPedirCuentaRet
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_RET

    MOV [tempNumero], AX

    CALL BUSCAR_CUENTA
    JC CUENTA_NO_EXISTE_RET

    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JNE CUENTA_INACTIVA_RET

    LEA DX, msgPedirMontoRet
    MOV AH, 09h
    INT 21h

    CALL LEER_MONTO4
    JC MONTO_INVALIDO_RET

    OR DX, AX
    JZ MONTO_INVALIDO_RET

    MOV [tempMontoLo], AX
    MOV [tempMontoHi], DX

    MOV BX, [DI + OFF_SALDO + 2]
    CMP BX, [tempMontoHi]
    JB FONDOS_INSUFICIENTES
    JA RETIRO_OK_COMPARACION

    MOV BX, [DI + OFF_SALDO]
    CMP BX, [tempMontoLo]
    JB FONDOS_INSUFICIENTES

RETIRO_OK_COMPARACION:
    MOV AX, [DI + OFF_SALDO]
    SUB AX, [tempMontoLo]
    MOV [DI + OFF_SALDO], AX

    MOV AX, [DI + OFF_SALDO + 2]
    SBB AX, [tempMontoHi]
    MOV [DI + OFF_SALDO + 2], AX

    LEA DX, msgRetiroOK
    MOV AH, 09h
    INT 21h
    RET

CUENTA_NO_EXISTE_RET:
    LEA DX, msgCuentaNoExiste
    MOV AH, 09h
    INT 21h
    RET

CUENTA_INACTIVA_RET:
    LEA DX, msgCuentaInactiva
    MOV AH, 09h
    INT 21h
    RET

MONTO_INVALIDO_RET:
    LEA DX, msgMontoInvalido
    MOV AH, 09h
    INT 21h
    RET

FONDOS_INSUFICIENTES:
    LEA DX, msgFondosInsuficientes
    MOV AH, 09h
    INT 21h
    RET

NUMERO_INVALIDO_RET:
    LEA DX, msgNumeroInvalido
    MOV AH, 09h
    INT 21h
    RET
RETIRAR_DINERO ENDP

; ==================================================
; 4.2.4 CONSULTAR SALDO
; ==================================================
CONSULTAR_SALDO PROC
    LEA DX, msgConsultar
    MOV AH, 09h
    INT 21h

    LEA DX, msgPedirCuentaCon
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_CON

    MOV [tempNumero], AX

    CALL BUSCAR_CUENTA
    JC CUENTA_NO_EXISTE_CON

    LEA DX, msgSaldoActual
    MOV AH, 09h
    INT 21h

    MOV AX, [DI + OFF_SALDO]
    MOV DX, [DI + OFF_SALDO + 2]
    CALL IMPRIMIR_FIJO4
    RET

CUENTA_NO_EXISTE_CON:
    LEA DX, msgCuentaNoExiste
    MOV AH, 09h
    INT 21h
    RET

NUMERO_INVALIDO_CON:
    LEA DX, msgNumeroInvalido
    MOV AH, 09h
    INT 21h
    RET
CONSULTAR_SALDO ENDP

; ==================================================
; 4.2.5 REPORTE GENERAL
; ==================================================
REPORTE_GENERAL PROC
    LEA DX, msgReporte
    MOV AH, 09h
    INT 21h

    MOV WORD PTR [reporteActivas], 0
    MOV WORD PTR [reporteInactivas], 0
    MOV WORD PTR [reporteSaldoTotalLo], 0
    MOV WORD PTR [reporteSaldoTotalHi], 0
    MOV WORD PTR [reporteMayorLo], 0
    MOV WORD PTR [reporteMayorHi], 0
    MOV WORD PTR [reporteMenorLo], 0
    MOV WORD PTR [reporteMenorHi], 0

    XOR CH, CH
    MOV CL, [totalCuentas]
    CMP CL, 0
    JE MOSTRAR_RESULTADOS

    LEA DI, cuentas

    MOV AX, [DI + OFF_SALDO]
    MOV [reporteMayorLo], AX
    MOV [reporteMenorLo], AX

    MOV AX, [DI + OFF_SALDO + 2]
    MOV [reporteMayorHi], AX
    MOV [reporteMenorHi], AX

REPORTE_LOOP:
    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JE ES_ACTIVA

    INC WORD PTR [reporteInactivas]
    JMP PROCESAR_SALDO

ES_ACTIVA:
    INC WORD PTR [reporteActivas]

PROCESAR_SALDO:
    MOV AX, [reporteSaldoTotalLo]
    ADD AX, [DI + OFF_SALDO]
    MOV [reporteSaldoTotalLo], AX

    MOV AX, [reporteSaldoTotalHi]
    ADC AX, [DI + OFF_SALDO + 2]
    MOV [reporteSaldoTotalHi], AX

    MOV AX, [DI + OFF_SALDO + 2]
    CMP AX, [reporteMayorHi]
    JA ACTUALIZAR_MAYOR
    JB VERIFICAR_MENOR
    MOV AX, [DI + OFF_SALDO]
    CMP AX, [reporteMayorLo]
    JA ACTUALIZAR_MAYOR
    JMP VERIFICAR_MENOR

ACTUALIZAR_MAYOR:
    MOV AX, [DI + OFF_SALDO]
    MOV [reporteMayorLo], AX
    MOV AX, [DI + OFF_SALDO + 2]
    MOV [reporteMayorHi], AX

VERIFICAR_MENOR:
    MOV AX, [DI + OFF_SALDO + 2]
    CMP AX, [reporteMenorHi]
    JB ACTUALIZAR_MENOR
    JA SIGUIENTE_CUENTA
    MOV AX, [DI + OFF_SALDO]
    CMP AX, [reporteMenorLo]
    JB ACTUALIZAR_MENOR
    JMP SIGUIENTE_CUENTA

ACTUALIZAR_MENOR:
    MOV AX, [DI + OFF_SALDO]
    MOV [reporteMenorLo], AX
    MOV AX, [DI + OFF_SALDO + 2]
    MOV [reporteMenorHi], AX

SIGUIENTE_CUENTA:
    ADD DI, TAM_CUENTA
    LOOP REPORTE_LOOP

MOSTRAR_RESULTADOS:
    LEA DX, msgTotalActivas
    MOV AH, 09h
    INT 21h
    MOV AX, [reporteActivas]
    CALL IMPRIMIR_NUMERO

    LEA DX, msgTotalInactivas
    MOV AH, 09h
    INT 21h
    MOV AX, [reporteInactivas]
    CALL IMPRIMIR_NUMERO

    LEA DX, msgSaldoBanco
    MOV AH, 09h
    INT 21h
    MOV AX, [reporteSaldoTotalLo]
    MOV DX, [reporteSaldoTotalHi]
    CALL IMPRIMIR_FIJO4

    LEA DX, msgMayorSaldo
    MOV AH, 09h
    INT 21h
    MOV AX, [reporteMayorLo]
    MOV DX, [reporteMayorHi]
    CALL IMPRIMIR_FIJO4

    LEA DX, msgMenorSaldo
    MOV AH, 09h
    INT 21h
    MOV AX, [reporteMenorLo]
    MOV DX, [reporteMenorHi]
    CALL IMPRIMIR_FIJO4

    RET
REPORTE_GENERAL ENDP

; ==================================================
; OBTENER_DIRECCION_NUEVA_CUENTA
; Salida:
;   DI = direccion del siguiente espacio libre
; ==================================================
OBTENER_DIRECCION_NUEVA_CUENTA PROC
    LEA DI, cuentas

    XOR AX, AX
    MOV AL, [totalCuentas]

    MOV BL, TAM_CUENTA
    MUL BL

    ADD DI, AX
    RET
OBTENER_DIRECCION_NUEVA_CUENTA ENDP

; ==================================================
; LEER_NUMERO
; Entrada:
;   bufferNumero
; Salida:
;   AX = numero
;   CF = 0 si correcto
;   CF = 1 si invalido
; ==================================================
LEER_NUMERO PROC
    LEA DX, bufferNumero
    MOV AH, 0Ah
    INT 21h

    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX

    MOV CL, [bufferNumero + 1]
    CMP CL, 0
    JE NUMERO_INVALIDO

    LEA SI, bufferNumero + 2
    XOR AX, AX

CONVERTIR_LOOP:
    MOV BL, [SI]

    CMP BL, '0'
    JB NUMERO_INVALIDO

    CMP BL, '9'
    JA NUMERO_INVALIDO

    SUB BL, '0'

    MOV DX, 0
    MOV CX, 10
    MUL CX
    CMP DX, 0
    JNE NUMERO_INVALIDO

    XOR BH, BH
    ADD AX, BX
    JC NUMERO_INVALIDO

    INC SI
    DEC BYTE PTR [bufferNumero + 1]
    JNZ CONVERTIR_LOOP

    CLC
    RET

NUMERO_INVALIDO:
    STC
    RET
LEER_NUMERO ENDP

; ==================================================
; LEER_MONTO4
; Lee un monto con hasta 4 decimales
; Devuelve DX:AX escalado por 10000
; ==================================================
LEER_MONTO4 PROC
    LEA DX, bufferMonto
    MOV AH, 0Ah
    INT 21h

    MOV CL, [bufferMonto + 1]
    CMP CL, 0
    JE MONTO4_INVALIDO

    LEA SI, bufferMonto + 2

    MOV BYTE PTR [flagPunto], 0
    MOV BYTE PTR [cantDecimales], 0
    MOV BYTE PTR [huboDigito], 0

    XOR AX, AX
    XOR DX, DX

PARSE_MONTO_LOOP:
    MOV BL, [SI]

    CMP BL, '.'
    JE ES_PUNTO_MONTO

    CMP BL, '0'
    JB MONTO4_INVALIDO
    CMP BL, '9'
    JA MONTO4_INVALIDO

    MOV BYTE PTR [huboDigito], 1

    SUB BL, '0'
    MOV [digitoActual], BL

    CALL MUL32X10

    MOV BL, [digitoActual]
    XOR BH, BH
    ADD AX, BX
    ADC DX, 0
    JC MONTO4_INVALIDO

    CMP BYTE PTR [flagPunto], 0
    JE SIG_CHAR_MONTO

    INC BYTE PTR [cantDecimales]
    CMP BYTE PTR [cantDecimales], 4
    JA MONTO4_INVALIDO
    JMP SIG_CHAR_MONTO

ES_PUNTO_MONTO:
    CMP BYTE PTR [flagPunto], 0
    JNE MONTO4_INVALIDO
    MOV BYTE PTR [flagPunto], 1

SIG_CHAR_MONTO:
    INC SI
    DEC CL
    JNZ PARSE_MONTO_LOOP

    CMP BYTE PTR [huboDigito], 1
    JNE MONTO4_INVALIDO

    MOV BL, 4
    SUB BL, [cantDecimales]

ESCALAR_A_4:
    CMP BL, 0
    JE MONTO4_OK
    CALL MUL32X10
    DEC BL
    JMP ESCALAR_A_4

MONTO4_OK:
    CLC
    RET

MONTO4_INVALIDO:
    STC
    RET
LEER_MONTO4 ENDP

; ==================================================
; MUL32X10
; Multiplica DX:AX por 10
; ==================================================
MUL32X10 PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    MOV BX, AX
    MOV CX, DX

    SHL AX, 1
    RCL DX, 1
    MOV SI, AX
    MOV DI, DX

    MOV AX, BX
    MOV DX, CX

    SHL AX, 1
    RCL DX, 1
    SHL AX, 1
    RCL DX, 1
    SHL AX, 1
    RCL DX, 1

    ADD AX, SI
    ADC DX, DI

    POP DI
    POP SI
    POP CX
    POP BX
    RET
MUL32X10 ENDP

; ==================================================
; DIV32X10
; Divide DX:AX entre 10
; Salida:
;   DX:AX = cociente
;   BL = residuo
; ==================================================
DIV32X10 PROC
    PUSH SI
    PUSH CX

    MOV SI, AX
    MOV BX, 10

    MOV AX, DX
    XOR DX, DX
    DIV BX
    MOV CX, AX

    MOV AX, SI
    DIV BX
    MOV BL, DL

    MOV DX, CX

    POP CX
    POP SI
    RET
DIV32X10 ENDP

; ==================================================
; IMPRIMIR_FIJO4
; Imprime DX:AX con 4 decimales
; ==================================================
IMPRIMIR_FIJO4 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    LEA DI, bufferImpresion + 16
    MOV CX, 0

    OR DX, AX
    JNE CONVERTIR_32

    DEC DI
    MOV BYTE PTR [DI], '0'
    INC CX
    JMP FORMATEAR_4

CONVERTIR_32:
    CALL DIV32X10
    DEC DI
    ADD BL, '0'
    MOV [DI], BL
    INC CX
    OR DX, AX
    JNE CONVERTIR_32

FORMATEAR_4:
    MOV SI, DI

    CMP CX, 4
    JA IMPR_ENTERO_DEC

    MOV DL, '0'
    MOV AH, 02h
    INT 21h

    MOV DL, '.'
    MOV AH, 02h
    INT 21h

    MOV BX, 4
    SUB BX, CX

PONER_CEROS:
    CMP BX, 0
    JE IMPR_RESTO_DEC
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    DEC BX
    JMP PONER_CEROS

IMPR_RESTO_DEC:
    MOV BX, CX

IMPR_DEC_CORTO:
    CMP BX, 0
    JE FIN_IMP_FIJO4
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI
    DEC BX
    JMP IMPR_DEC_CORTO

IMPR_ENTERO_DEC:
    MOV BX, CX
    SUB BX, 4

IMPR_ENTERO:
    CMP BX, 0
    JE PONER_PUNTO_DEC
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI
    DEC BX
    JMP IMPR_ENTERO

PONER_PUNTO_DEC:
    MOV DL, '.'
    MOV AH, 02h
    INT 21h

    MOV BX, 4

IMPR_DEC_LARGO:
    CMP BX, 0
    JE FIN_IMP_FIJO4
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI
    DEC BX
    JMP IMPR_DEC_LARGO

FIN_IMP_FIJO4:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_FIJO4 ENDP

; ==================================================
; LEER_NOMBRE
; ==================================================
LEER_NOMBRE PROC
    LEA DX, bufferNombre
    MOV AH, 0Ah
    INT 21h

    MOV AL, [bufferNombre + 1]
    CMP AL, 0
    JE NOMBRE_INVALIDO

    CLC
    RET

NOMBRE_INVALIDO:
    STC
    RET
LEER_NOMBRE ENDP

; ==================================================
; MOSTRAR_MENU
; ==================================================
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

; ==================================================
; LEER_OPCION
; ==================================================
LEER_OPCION PROC
    MOV AH, 01h
    INT 21h
    RET
LEER_OPCION ENDP

; ==================================================
; PAUSA
; ==================================================
PAUSA PROC
    LEA DX, msgPresioneTecla
    MOV AH, 09h
    INT 21h

    MOV AH, 08h
    INT 21h
    RET
PAUSA ENDP

; ==================================================
; LIMPIAR_PANTALLA
; ==================================================
LIMPIAR_PANTALLA PROC
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    RET
LIMPIAR_PANTALLA ENDP

; ==================================================
; IMPRIMIR_NUMERO
; Imprime AX en decimal
; ==================================================
IMPRIMIR_NUMERO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

DIVISION_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIVISION_LOOP

IMPRIMIR_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP IMPRIMIR_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_NUMERO ENDP

END MAIN