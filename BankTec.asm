.MODEL SMALL
.STACK 100h

; ==================================================
; CONSTANTES DE LA ESTRUCTURA "CUENTA"
; ==================================================
MAX_CUENTAS EQU 10
TAM_NOMBRE  EQU 20

OFF_NUMERO      EQU 0
OFF_NOMBRE      EQU 2
OFF_SALDO_ENT   EQU 22
OFF_SALDO_DEC   EQU 24
OFF_ESTADO      EQU 26
TAM_CUENTA      EQU 27

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
    ; MENSAJES DE REPORTE
    ; -------------------------------
    msgTotalActivas     DB 13,10,'Cuentas activas: $'
    msgTotalInactivas   DB 13,10,'Cuentas inactivas: $'
    msgSaldoBanco       DB 13,10,'Saldo total del banco: $'
    msgMayorSaldo       DB 13,10,'Mayor saldo: $'
    msgMenorSaldo       DB 13,10,'Menor saldo: $'

    ; -------------------------------
    ; MENSAJES DE DESACTIVAR
    ; -------------------------------
    msgPedirCuentaDes   DB 13,10,'Ingrese numero de cuenta a desactivar: $'
    msgCuentaYaInactiva DB 13,10,'Error: la cuenta ya esta inactiva.',13,10,'$'
    msgDesactivarOK     DB 13,10,'Cuenta desactivada correctamente.',13,10,'$'

    ; -------------------------------
    ; MENSAJES GENERALES
    ; -------------------------------
    msgPresioneTecla    DB 13,10,'Presione una tecla para continuar...$'

    ; -------------------------------
    ; ESTRUCTURA EN MEMORIA
    ; [0-1]   numero      WORD
    ; [2-21]  nombre      20 bytes
    ; [22-23] saldo ent   WORD
    ; [24-25] saldo dec   WORD (0..9999)
    ; [26]    estado      BYTE
    ; -------------------------------
    cuentas             DB MAX_CUENTAS * TAM_CUENTA DUP(0)
    totalCuentas        DB 0

    ; -------------------------------
    ; BUFFERS DE ENTRADA
    ; -------------------------------
    bufferNumero        DB 5,0,5 DUP(0)
    bufferNombre        DB 20,0,20 DUP(0)
    bufferMonto         DB 15,0,15 DUP(0)

    ; -------------------------------
    ; VARIABLES AUXILIARES
    ; -------------------------------
    tempNumero          DW 0
    tempDirCuenta       DW 0

    tempSaldoEnt        DW 0
    tempSaldoDec        DW 0

    tempMontoEnt        DW 0
    tempMontoDec        DW 0

    tempDigito          DW 0

    reporteActivas      DW 0
    reporteInactivas    DW 0
    reporteSaldoEnt     DW 0
    reporteSaldoDec     DW 0
    reporteMayorEnt     DW 0
    reporteMayorDec     DW 0
    reporteMenorEnt     DW 0
    reporteMenorDec     DW 0

    flagPunto           DB 0
    cantDecimales       DB 0
    huboDigito          DB 0

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
    CALL DESACTIVAR_CUENTA
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
; CREAR CUENTA
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

    MOV [tempSaldoEnt], AX
    MOV [tempSaldoDec], BX

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

    MOV AX, [tempSaldoEnt]
    MOV [DI + OFF_SALDO_ENT], AX

    MOV AX, [tempSaldoDec]
    MOV [DI + OFF_SALDO_DEC], AX

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
; DEPOSITAR DINERO
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
    MOV [tempDirCuenta], DI

    MOV DI, [tempDirCuenta]
    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JNE CUENTA_INACTIVA_DEP

    LEA DX, msgPedirMontoDep
    MOV AH, 09h
    INT 21h

    CALL LEER_MONTO4
    JC MONTO_INVALIDO_DEP

    CMP AX, 0
    JNE MONTO_OK_DEP
    CMP BX, 0
    JE MONTO_INVALIDO_DEP

MONTO_OK_DEP:
    MOV [tempMontoEnt], AX
    MOV [tempMontoDec], BX

    MOV DI, [tempDirCuenta]

    ; sumar decimales
    MOV AX, [DI + OFF_SALDO_DEC]
    ADD AX, [tempMontoDec]
    CMP AX, 10000
    JB SIN_ACARREO_DEP

    SUB AX, 10000
    MOV [DI + OFF_SALDO_DEC], AX

    MOV AX, [DI + OFF_SALDO_ENT]
    ADD AX, [tempMontoEnt]
    INC AX
    MOV [DI + OFF_SALDO_ENT], AX
    JMP FIN_DEP

SIN_ACARREO_DEP:
    MOV [DI + OFF_SALDO_DEC], AX
    MOV AX, [DI + OFF_SALDO_ENT]
    ADD AX, [tempMontoEnt]
    MOV [DI + OFF_SALDO_ENT], AX

FIN_DEP:
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
; RETIRAR DINERO
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
    MOV [tempDirCuenta], DI

    MOV DI, [tempDirCuenta]
    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JNE CUENTA_INACTIVA_RET

    LEA DX, msgPedirMontoRet
    MOV AH, 09h
    INT 21h

    CALL LEER_MONTO4
    JC MONTO_INVALIDO_RET

    CMP AX, 0
    JNE MONTO_OK_RET
    CMP BX, 0
    JE MONTO_INVALIDO_RET

MONTO_OK_RET:
    MOV [tempMontoEnt], AX
    MOV [tempMontoDec], BX

    MOV DI, [tempDirCuenta]

    ; comparar saldo con monto
    MOV AX, [DI + OFF_SALDO_ENT]
    CMP AX, [tempMontoEnt]
    JB FONDOS_INSUFICIENTES
    JA RETIRO_PERMITIDO

    MOV AX, [DI + OFF_SALDO_DEC]
    CMP AX, [tempMontoDec]
    JB FONDOS_INSUFICIENTES

RETIRO_PERMITIDO:
    MOV AX, [DI + OFF_SALDO_DEC]
    CMP AX, [tempMontoDec]
    JAE SIN_PRESTAMO_RET

    ADD AX, 10000
    SUB AX, [tempMontoDec]
    MOV [DI + OFF_SALDO_DEC], AX

    MOV AX, [DI + OFF_SALDO_ENT]
    SUB AX, [tempMontoEnt]
    DEC AX
    MOV [DI + OFF_SALDO_ENT], AX
    JMP FIN_RET

SIN_PRESTAMO_RET:
    SUB AX, [tempMontoDec]
    MOV [DI + OFF_SALDO_DEC], AX

    MOV AX, [DI + OFF_SALDO_ENT]
    SUB AX, [tempMontoEnt]
    MOV [DI + OFF_SALDO_ENT], AX

FIN_RET:
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
; CONSULTAR SALDO
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
    MOV [tempDirCuenta], DI

    LEA DX, msgSaldoActual
    MOV AH, 09h
    INT 21h

    MOV DI, [tempDirCuenta]

    MOV AX, [DI + OFF_SALDO_ENT]
    CALL IMPRIMIR_NUMERO

    MOV DL, '.'
    MOV AH, 02h
    INT 21h

    MOV BX, [DI + OFF_SALDO_DEC]
    CALL IMPRIMIR_4DIGITOS
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
; REPORTE GENERAL
; ==================================================
REPORTE_GENERAL PROC
    LEA DX, msgReporte
    MOV AH, 09h
    INT 21h

    MOV WORD PTR [reporteActivas], 0
    MOV WORD PTR [reporteInactivas], 0
    MOV WORD PTR [reporteSaldoEnt], 0
    MOV WORD PTR [reporteSaldoDec], 0
    MOV WORD PTR [reporteMayorEnt], 0
    MOV WORD PTR [reporteMayorDec], 0
    MOV WORD PTR [reporteMenorEnt], 0
    MOV WORD PTR [reporteMenorDec], 0

    XOR CH, CH
    MOV CL, [totalCuentas]
    CMP CL, 0
    JE MOSTRAR_RESULTADOS

    LEA DI, cuentas

    MOV AX, [DI + OFF_SALDO_ENT]
    MOV [reporteMayorEnt], AX
    MOV [reporteMenorEnt], AX

    MOV AX, [DI + OFF_SALDO_DEC]
    MOV [reporteMayorDec], AX
    MOV [reporteMenorDec], AX

REPORTE_LOOP:
    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JE CUENTA_ACTIVA_REP

    INC WORD PTR [reporteInactivas]
    JMP PROCESAR_SALDO_REP

CUENTA_ACTIVA_REP:
    INC WORD PTR [reporteActivas]

PROCESAR_SALDO_REP:
    ; sumar saldo total
    MOV AX, [reporteSaldoDec]
    ADD AX, [DI + OFF_SALDO_DEC]
    CMP AX, 10000
    JB REP_SIN_ACARREO

    SUB AX, 10000
    MOV [reporteSaldoDec], AX
    INC WORD PTR [reporteSaldoEnt]
    JMP REP_SUMAR_ENTERO

REP_SIN_ACARREO:
    MOV [reporteSaldoDec], AX

REP_SUMAR_ENTERO:
    MOV AX, [reporteSaldoEnt]
    ADD AX, [DI + OFF_SALDO_ENT]
    MOV [reporteSaldoEnt], AX

    ; mayor saldo
    MOV AX, [DI + OFF_SALDO_ENT]
    CMP AX, [reporteMayorEnt]
    JA ACTUALIZAR_MAYOR
    JB VERIFICAR_MENOR

    MOV AX, [DI + OFF_SALDO_DEC]
    CMP AX, [reporteMayorDec]
    JA ACTUALIZAR_MAYOR

VERIFICAR_MENOR:
    MOV AX, [DI + OFF_SALDO_ENT]
    CMP AX, [reporteMenorEnt]
    JB ACTUALIZAR_MENOR
    JA SIGUIENTE_REP

    MOV AX, [DI + OFF_SALDO_DEC]
    CMP AX, [reporteMenorDec]
    JB ACTUALIZAR_MENOR
    JMP SIGUIENTE_REP

ACTUALIZAR_MAYOR:
    MOV AX, [DI + OFF_SALDO_ENT]
    MOV [reporteMayorEnt], AX
    MOV AX, [DI + OFF_SALDO_DEC]
    MOV [reporteMayorDec], AX
    JMP VERIFICAR_MENOR

ACTUALIZAR_MENOR:
    MOV AX, [DI + OFF_SALDO_ENT]
    MOV [reporteMenorEnt], AX
    MOV AX, [DI + OFF_SALDO_DEC]
    MOV [reporteMenorDec], AX

SIGUIENTE_REP:
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
    MOV AX, [reporteSaldoEnt]
    CALL IMPRIMIR_NUMERO
    MOV DL, '.'
    MOV AH, 02h
    INT 21h
    MOV BX, [reporteSaldoDec]
    CALL IMPRIMIR_4DIGITOS

    LEA DX, msgMayorSaldo
    MOV AH, 09h
    INT 21h
    MOV AX, [reporteMayorEnt]
    CALL IMPRIMIR_NUMERO
    MOV DL, '.'
    MOV AH, 02h
    INT 21h
    MOV BX, [reporteMayorDec]
    CALL IMPRIMIR_4DIGITOS

    LEA DX, msgMenorSaldo
    MOV AH, 09h
    INT 21h
    MOV AX, [reporteMenorEnt]
    CALL IMPRIMIR_NUMERO
    MOV DL, '.'
    MOV AH, 02h
    INT 21h
    MOV BX, [reporteMenorDec]
    CALL IMPRIMIR_4DIGITOS

    RET
REPORTE_GENERAL ENDP

; ==================================================
; DESACTIVAR CUENTA
; ==================================================
DESACTIVAR_CUENTA PROC
    LEA DX, msgDesactivar
    MOV AH, 09h
    INT 21h

    LEA DX, msgPedirCuentaDes
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_DES
    MOV [tempNumero], AX

    CALL BUSCAR_CUENTA
    JC CUENTA_NO_EXISTE_DES
    MOV [tempDirCuenta], DI

    MOV DI, [tempDirCuenta]
    CMP BYTE PTR [DI + OFF_ESTADO], 0
    JE CUENTA_YA_INACTIVA

    MOV BYTE PTR [DI + OFF_ESTADO], 0

    LEA DX, msgDesactivarOK
    MOV AH, 09h
    INT 21h
    RET

CUENTA_NO_EXISTE_DES:
    LEA DX, msgCuentaNoExiste
    MOV AH, 09h
    INT 21h
    RET

CUENTA_YA_INACTIVA:
    LEA DX, msgCuentaYaInactiva
    MOV AH, 09h
    INT 21h
    RET

NUMERO_INVALIDO_DES:
    LEA DX, msgNumeroInvalido
    MOV AH, 09h
    INT 21h
    RET
DESACTIVAR_CUENTA ENDP

; ==================================================
; OBTENER_DIRECCION_NUEVA_CUENTA
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
; Devuelve AX
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

CONVERTIR_LOOP_NUM:
    MOV BL, [SI]

    CMP BL, '0'
    JB NUMERO_INVALIDO

    CMP BL, '9'
    JA NUMERO_INVALIDO

    SUB BL, '0'

    PUSH CX
    MOV CX, 10
    MUL CX
    POP CX

    CMP DX, 0
    JNE NUMERO_INVALIDO

    XOR BH, BH
    ADD AX, BX
    JC NUMERO_INVALIDO

    INC SI
    DEC CL
    JNZ CONVERTIR_LOOP_NUM

    CLC
    RET

NUMERO_INVALIDO:
    STC
    RET
LEER_NUMERO ENDP

; ==================================================
; LEER_MONTO4
; Devuelve:
;   AX = parte entera
;   BX = parte decimal (0..9999)
; Acepta:
;   123
;   123.4
;   123.45
;   123.456
;   123.4567
; ==================================================
LEER_MONTO4 PROC
    LEA DX, bufferMonto
    MOV AH, 0Ah
    INT 21h

    XOR AX, AX            ; entero
    XOR BX, BX            ; decimal

    MOV BYTE PTR [flagPunto], 0
    MOV BYTE PTR [cantDecimales], 0
    MOV BYTE PTR [huboDigito], 0

    XOR CH, CH
    MOV CL, [bufferMonto + 1]
    CMP CL, 0
    JE MONTO4_INVALIDO

    LEA SI, bufferMonto + 2

PARSE_MONTO_LOOP:
    MOV DL, [SI]

    CMP DL, '.'
    JE ES_PUNTO_MONTO

    CMP DL, '0'
    JB MONTO4_INVALIDO
    CMP DL, '9'
    JA MONTO4_INVALIDO

    MOV BYTE PTR [huboDigito], 1

    SUB DL, '0'
    XOR DH, DH
    MOV [tempDigito], DX

    CMP BYTE PTR [flagPunto], 0
    JE ACUMULAR_ENTERO

    ; decimal = decimal * 10 + digito
    CMP BYTE PTR [cantDecimales], 4
    JAE MONTO4_INVALIDO

    PUSH AX
    PUSH CX
    MOV AX, BX
    MOV CX, 10
    MUL CX
    POP CX
    CMP DX, 0
    JNE ERROR_DECIMAL
    ADD AX, [tempDigito]
    JC ERROR_DECIMAL
    MOV BX, AX
    POP AX

    INC BYTE PTR [cantDecimales]
    JMP SIG_CHAR_MONTO

ERROR_DECIMAL:
    POP AX
    JMP MONTO4_INVALIDO

ACUMULAR_ENTERO:
    ; entero = entero * 10 + digito
    PUSH BX
    PUSH CX
    MOV CX, 10
    MUL CX
    POP CX
    CMP DX, 0
    JNE ERROR_ENTERO
    ADD AX, [tempDigito]
    JC ERROR_ENTERO
    POP BX
    JMP SIG_CHAR_MONTO

ERROR_ENTERO:
    POP BX
    JMP MONTO4_INVALIDO

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

    ; completar a 4 decimales
PAD_DECIMALES:
    CMP BYTE PTR [cantDecimales], 4
    JE MONTO4_OK

    PUSH AX
    PUSH CX
    MOV AX, BX
    MOV CX, 10
    MUL CX
    POP CX
    CMP DX, 0
    JNE ERROR_PAD
    MOV BX, AX
    POP AX

    INC BYTE PTR [cantDecimales]
    JMP PAD_DECIMALES

ERROR_PAD:
    POP AX
    JMP MONTO4_INVALIDO

MONTO4_OK:
    CLC
    RET

MONTO4_INVALIDO:
    STC
    RET
LEER_MONTO4 ENDP

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
; ==================================================
IMPRIMIR_NUMERO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

    CMP AX, 0
    JNE DIVISION_LOOP_NUM
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP FIN_IMP_NUM

DIVISION_LOOP_NUM:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIVISION_LOOP_NUM

IMPRIMIR_LOOP_NUM:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP IMPRIMIR_LOOP_NUM

FIN_IMP_NUM:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_NUMERO ENDP

; ==================================================
; IMPRIMIR_4DIGITOS
; Imprime BX con 4 digitos y ceros a la izquierda
; ==================================================
IMPRIMIR_4DIGITOS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; -------------------------
    ; Miles
    ; -------------------------
    MOV AX, BX
    XOR DX, DX
    MOV CX, 1000
    DIV CX              ; AX = millares, DX = residuo
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; -------------------------
    ; Centenas
    ; -------------------------
    MOV AX, DX
    XOR DX, DX
    MOV CX, 100
    DIV CX              ; AX = centenas, DX = residuo
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; -------------------------
    ; Decenas
    ; -------------------------
    MOV AX, DX
    XOR DX, DX
    MOV CX, 10
    DIV CX              ; AX = decenas, DX = unidades
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; -------------------------
    ; Unidades
    ; -------------------------
    MOV AL, DL          ; tomar residuo final
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_4DIGITOS ENDP

END MAIN