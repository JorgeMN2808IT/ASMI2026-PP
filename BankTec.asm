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
OFF_ESTADO  EQU 24
TAM_CUENTA  EQU 25

.CODE

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
    msgPedirSaldo       DB 13,10,'Ingrese saldo inicial: $'
    msgCuentaCreada     DB 13,10,'Cuenta creada correctamente.',13,10,'$'
    msgCuentaRepetida   DB 13,10,'Error: numero de cuenta repetido.',13,10,'$'
    msgBancoLleno       DB 13,10,'Error: ya no se pueden crear mas cuentas.',13,10,'$'
    msgNombreInvalido   DB 13,10,'Error: nombre invalido.',13,10,'$'
    msgNumeroInvalido   DB 13,10,'Error: valor numerico invalido.',13,10,'$'

    ; -------------------------------
    ; MENSAJES DE DEPOSITAR
    ; -------------------------------
    msgPedirCuentaDep   DB 13,10,'Ingrese numero de cuenta a depositar: $'
    msgPedirMontoDep    DB 13,10,'Ingrese monto a depositar: $'
    msgCuentaNoExiste   DB 13,10,'Error: la cuenta no existe.',13,10,'$'
    msgCuentaInactiva   DB 13,10,'Error: la cuenta esta inactiva.',13,10,'$'
    msgMontoInvalido    DB 13,10,'Error: el monto debe ser positivo.',13,10,'$'
    msgDepositoOK       DB 13,10,'Deposito realizado correctamente.',13,10,'$'
    
    ; -------------------------------
    ; MENSAJES DE RETIRAR
    ; -------------------------------
    msgPedirCuentaRet   DB 13,10,'Ingrese numero de cuenta a retirar: $'
    msgFondosInsuficientes DB 13,10,'Error: fondos insuficientes.',13,10,'$' 
    msgRetiroOK DB 13,10,'Retiro realizado correctamente.',13,10,'$'
    msgPedirMontoRet    DB 13,10,'Ingrese monto a retirar: $'
           
    ; -------------------------------
    ; MENSAJES DE CONSULTAR
    ; -------------------------------
    msgPedirCuentaCon DB 13,10,'Ingrese numero de cuenta a consultar: $'
    msgSaldoActual    DB 13,10,'Saldo actual: $'

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
    saltoLinea          DB 13,10,'$'     

    ; -------------------------------
    ; ESTRUCTURA EN MEMORIA
    ; Cada cuenta ocupa 25 bytes:
    ; [0-1]   numero   (WORD)
    ; [2-21]  nombre   (20 bytes)
    ; [22-23] saldo    (WORD)
    ; [24]    estado   (1=activa, 0=inactiva)
    ; -------------------------------
    cuentas         DB MAX_CUENTAS * TAM_CUENTA DUP(0)
    totalCuentas    DB 0

    ; -------------------------------
    ; BUFFERS DE ENTRADA
    ; INT 21h / AH=0Ah
    ; -------------------------------
    bufferNumero    DB 5,0,5 DUP(0)      ; hasta 5 digitos
    bufferNombre    DB 20,0,20 DUP(0)    ; hasta 20 chars

    ; -------------------------------
    ; VARIABLES AUXILIARES
    ; -------------------------------
    tempNumero      DW 0
    tempSaldo       DW 0
    tempMonto       DW 0 
    
    reporteActivas      DW 0   ; Variable de reporte, puede explotar no tocar.
    reporteInactivas    DW 0   ; Variable de reporte, puede explotar no tocar.
    reporteSaldoTotal   DW 0   ; Variable de reporte, puede explotar no tocar.
    reporteMayor        DW 0   ; Variable de reporte, puede explotar no tocar.
    reporteMenor        DW 0   ; Variable de reporte, puede explotar no tocar.


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
; 4.2.1 CREAR CUENTA
; Reglas:
; - no numeros repetidos
; - saldo inicial >= 0
; - inicia activa
; ==================================================
CREAR_CUENTA PROC
    LEA DX, msgCrear
    MOV AH, 09h
    INT 21h

    ; Verificar si ya hay 10 cuentas
    MOV AL, totalCuentas
    CMP AL, MAX_CUENTAS
    JAE BANCO_LLENO

PEDIR_NUMERO_CUENTA:
    LEA DX, msgPedirNumero
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_CREAR

    MOV tempNumero, AX

    ; Verificar que no exista repetido
    CALL BUSCAR_CUENTA
    JNC CUENTA_REPETIDA   ; si la encontró, está repetida

PEDIR_NOMBRE_CUENTA:
    LEA DX, msgPedirNombre
    MOV AH, 09h
    INT 21h

    CALL LEER_NOMBRE
    JC NOMBRE_INVALIDO_CREAR

PEDIR_SALDO_CUENTA:
    LEA DX, msgPedirSaldo
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_CREAR

    ; saldo inicial >= 0
    MOV tempSaldo, AX

    ; calcular direccion del nuevo registro
    CALL OBTENER_DIRECCION_NUEVA_CUENTA
    ; retorna DI apuntando al nuevo espacio

    ; guardar numero
    MOV AX, tempNumero
    MOV [DI + OFF_NUMERO], AX

    ; limpiar nombre del registro
    PUSH DI
    LEA SI, bufferNombre + 2
    MOV CX, TAM_NOMBRE
    ADD DI, OFF_NOMBRE

LIMPIAR_NOMBRE_NUEVO:
    MOV BYTE PTR [DI], 0
    INC DI
    LOOP LIMPIAR_NOMBRE_NUEVO

    POP DI

    ; copiar nombre
    LEA SI, bufferNombre + 2
    ADD DI, OFF_NOMBRE
    XOR CH, CH
    MOV CL, bufferNombre + 1

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
    ; guardar saldo
    CALL OBTENER_DIRECCION_NUEVA_CUENTA
    MOV AX, tempSaldo
    MOV [DI + OFF_SALDO], AX

    ; estado = activa
    MOV BYTE PTR [DI + OFF_ESTADO], 1

    ; aumentar total
    INC totalCuentas

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

NOMBRE_INVALIDO_CREAR:
    LEA DX, msgNombreInvalido
    MOV AH, 09h
    INT 21h
    RET

CREAR_CUENTA ENDP

; ==================================================
; 4.2.2 DEPOSITAR DINERO
; Reglas:
; - solo cuentas activas
; - monto positivo
; ==================================================
DEPOSITAR_DINERO PROC
    LEA DX, msgDepositar
    MOV AH, 09h
    INT 21h

    ; pedir numero de cuenta
    LEA DX, msgPedirCuentaDep
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_DEP

    MOV tempNumero, AX

    ; buscar cuenta
    CALL BUSCAR_CUENTA
    JC CUENTA_NO_EXISTE_DEP

    ; DI queda apuntando a la cuenta encontrada
    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JNE CUENTA_INACTIVA_DEP

    ; pedir monto
    LEA DX, msgPedirMontoDep
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_DEP

    CMP AX, 0
    JE MONTO_INVALIDO_DEP

    MOV tempMonto, AX

    ; saldo = saldo + monto
    MOV AX, [DI + OFF_SALDO]
    ADD AX, tempMonto
    MOV [DI + OFF_SALDO], AX

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
; Reglas:
; - solo cuentas activas
; - no permitir sobregiro
; - mostrar error si fondos insuficientes
; ==================================================
RETIRAR_DINERO PROC

    LEA DX, msgRetirar
    MOV AH, 09h
    INT 21h

    ; pedir numero de cuenta
    LEA DX, msgPedirCuentaRet
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_RET

    MOV tempNumero, AX

    ; buscar cuenta
    CALL BUSCAR_CUENTA
    JC CUENTA_NO_EXISTE_RET

    ; verificar estado
    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JNE CUENTA_INACTIVA_RET

    ; pedir monto a retirar
    LEA DX, msgPedirMontoRet
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_RET

    CMP AX, 0
    JE MONTO_INVALIDO_RET

    MOV tempMonto, AX

    ; verificar fondos suficientes
    MOV AX, [DI + OFF_SALDO]
    CMP AX, tempMonto
    JB FONDOS_INSUFICIENTES

    ; saldo = saldo - monto
    SUB AX, tempMonto
    MOV [DI + OFF_SALDO], AX

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

; ==================================================
; 4.2.4 CONSULTAR SALDO
; Busca una cuenta y muestra su saldo
; ==================================================
CONSULTAR_SALDO PROC

    LEA DX, msgConsultar
    MOV AH, 09h
    INT 21h

    ; pedir numero de cuenta
    LEA DX, msgPedirCuentaCon
    MOV AH, 09h
    INT 21h

    CALL LEER_NUMERO
    JC NUMERO_INVALIDO_CON

    MOV tempNumero, AX

    ; buscar cuenta
    CALL BUSCAR_CUENTA
    JC CUENTA_NO_EXISTE_CON

    ; mostrar mensaje
    LEA DX, msgSaldoActual
    MOV AH, 09h
    INT 21h

    ; cargar saldo
    MOV AX, [DI + OFF_SALDO]

    ; imprimir numero
    CALL IMPRIMIR_NUMERO

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


BUSCAR_CUENTA PROC
    LEA DI, cuentas
    XOR CH, CH
    MOV CL, totalCuentas

    CMP CL, 0
    JE NO_ENCONTRADA

BUSCAR_LOOP:
    MOV AX, [DI + OFF_NUMERO]
    CMP AX, tempNumero
    JE ENCONTRADA

    ADD DI, TAM_CUENTA
    LOOP BUSCAR_LOOP

NO_ENCONTRADA:
    STC
    RET

ENCONTRADA:
    CLC
    RET

BUSCAR_CUENTA ENDP
; ==================================================  

; ==================================================
; 4.2.5 REPORTE GENERAL
; Recorre todas las cuentas y calcula estadísticas
; ==================================================
REPORTE_GENERAL PROC

    LEA DX, msgReporte
    MOV AH, 09h
    INT 21h

    ; reiniciar contadores
    MOV reporteActivas, 0
    MOV reporteInactivas, 0
    MOV reporteSaldoTotal, 0

    MOV AX, 0FFFFh
    MOV reporteMenor, AX

    MOV reporteMayor, 0

    ; preparar recorrido
    LEA DI, cuentas
    XOR CH, CH
    MOV CL, totalCuentas

    CMP CL, 0
    JE MOSTRAR_RESULTADOS

REPORTE_LOOP:

    ; verificar estado
    CMP BYTE PTR [DI + OFF_ESTADO], 1
    JE CUENTA_ACTIVA

CUENTA_INACTIVA:
    INC reporteInactivas
    JMP PROCESAR_SALDO

CUENTA_ACTIVA:
    INC reporteActivas

PROCESAR_SALDO:

    MOV AX, [DI + OFF_SALDO]

    ; sumar saldo total
    ADD reporteSaldoTotal, AX

    ; verificar mayor saldo
    CMP AX, reporteMayor
    JBE VERIFICAR_MENOR
    MOV reporteMayor, AX

VERIFICAR_MENOR:

    CMP AX, reporteMenor
    JAE SIGUIENTE_CUENTA
    MOV reporteMenor, AX

SIGUIENTE_CUENTA:

    ADD DI, TAM_CUENTA
    LOOP REPORTE_LOOP

MOSTRAR_RESULTADOS:

    ; mostrar activas
    LEA DX, msgTotalActivas
    MOV AH, 09h
    INT 21h

    MOV AX, reporteActivas
    CALL IMPRIMIR_NUMERO

    ; mostrar inactivas
    LEA DX, msgTotalInactivas
    MOV AH, 09h
    INT 21h

    MOV AX, reporteInactivas
    CALL IMPRIMIR_NUMERO

    ; mostrar saldo total
    LEA DX, msgSaldoBanco
    MOV AH, 09h
    INT 21h

    MOV AX, reporteSaldoTotal
    CALL IMPRIMIR_NUMERO

    ; mostrar mayor saldo
    LEA DX, msgMayorSaldo
    MOV AH, 09h
    INT 21h

    MOV AX, reporteMayor
    CALL IMPRIMIR_NUMERO

    ; mostrar menor saldo
    LEA DX, msgMenorSaldo
    MOV AH, 09h
    INT 21h

    MOV AX, reporteMenor
    CALL IMPRIMIR_NUMERO

    RET

REPORTE_GENERAL ENDP
; ==================================================
                                                       
                                                       
; ==================================================
; OBTENER_DIRECCION_NUEVA_CUENTA
; Salida:
;   DI = direccion del siguiente espacio libre
; ==================================================
OBTENER_DIRECCION_NUEVA_CUENTA PROC
    LEA DI, cuentas

    XOR AX, AX
    MOV AL, totalCuentas

    MOV BL, TAM_CUENTA
    MUL BL          ; AX = totalCuentas * TAM_CUENTA

    ADD DI, AX
    RET
OBTENER_DIRECCION_NUEVA_CUENTA ENDP

; ==================================================
; LEER_NUMERO
; Lee un numero positivo desde teclado
; usando buffer DOS y convierte ASCII -> numero
;
; Salida:
;   AX = valor
;   CF = 0 correcto
;   CF = 1 invalido
; ==================================================
LEER_NUMERO PROC
    LEA DX, bufferNumero
    MOV AH, 0Ah
    INT 21h

    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX

    MOV CL, bufferNumero + 1
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
    MUL CX              ; AX = AX * 10
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
; LEER_NOMBRE
; Lee nombre con buffer DOS.
; Debe tener al menos 1 caracter.
; Salida:
;   CF = 0 correcto
;   CF = 1 invalido
; ==================================================
LEER_NOMBRE PROC
    LEA DX, bufferNombre
    MOV AH, 0Ah
    INT 21h

    MOV AL, bufferNombre + 1
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
; Imprime el valor en AX en decimal
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