; **************************INICIO DECLARACION DE MACROS**************************
mLeerCaracter MACRO
    mov ah,01h    ; se carga en la parte alta el servicio 01h, que lee un caracter de la entrada y lo guarda en el registro al.
    int 21h       ; se ejecuta el servicio cargado en ah, ejecuta 01h.
ENDM

mImprimirChar MACRO char
    mov al, char
    mov ah, 0eh
    int 10h
ENDM

mImprimirCadena MACRO cadena
    mov dx, offset cadena ; offset obtiene la direccion de cadena
    mov ah, 09h        ; se carga en la parte alta el servicio 09H, el cual despliega una cadena, que es imprimir n columnas hacia adelante.
    int 21h            ; Peticion de funcion al DOS. se ejecuta el servicio cargado en ah. Ejecutar funcion 09,
    ENDM
mLimpiarPantalla MACRO
    mov ah, 0Fh     ; se carga en la parte alta el servicio 0Fh, lee el modo actual de video.
    int 10h         ; Se utiliza la interrupcion 10h, esta maneja casi todos los servicios de la pantalla; Video Service.
    mov ah, 0       ; Activa modo de video
    int 10h         ; Se utiliza la interrupcion 10h, esta maneja casi todos los servicios de la pantalla; Video Service.
    ENDM

mLeerCadenaConsola MACRO cadena
    mov bx, 00      ; Posicion inicial para capturar caracteres
    mov cx, 100     ; Limite de caracteres como entrada
    mov dx, offset cadena ; Direccion de la variable que almacena los datos de entrada
    mov ah, 3fh     ; se carga en la parte alta el servicio 3fh, lee los datos de la consola
    int 21h         ; Peticion de funcion al DOS. se ejecuta el servicio cargado en ah. Ejecutar funcion 09,
    ENDM

mLeerTresCaracteres MACRO cadena
    mov bx, 00              ; Posicion inicial para capturar caracteres
    mov cx, 0002            ; Limite de caracteres como entrada
    mov dx, offset cadena   ; Direccion de la variable que almacena los datos de entrada
    mov ah, 3fh             ; se carga en la parte alta el servicio 3fh, lee los datos de la consola
    int 21h                 ; Peticion de funcion al DOS. se ejecuta el servicio cargado en ah. Ejecutar funcion 09,
ENDM

;---------------------------------------------------------
mIsDigit MACRO errorNoEsDigito
    local lContinuar, lError
; En caso de error salta a errorNoEsDigito
; Receives: [Al] char en el registro.
; Returns: ZF = 1, si [Al] contiene un digito y así.
;---------------------------------------------------------
    cmp al,'0'
    jb lError ; ZF = 0 when jump taken
    cmp al,'9'
    ja lError ; ZF = 0 when jump taken
    jmp lContinuar
    lError:
        jmp errorNoEsDigito
    lContinuar:
        test ax,0 ; set ZF = 1, recordar que el test algo, 0; nos garantiza retornar ZF = 1    
ENDM

mLimpiarVariableByte MACRO variable
    mov si, offset variable
    mov word ptr[si], 0000
ENDM
;---------------------------------------------------------
; imprimir el registro en variable
; Use: [Dl]
mImprimirValorRegistroByte MACRO variable
;---------------------------------------------------------
    mov ah,02h
    mov dl, variable
    add dl, 30h
    int 21h
ENDM

mRepetirSaltoSiNoEs MACRO cadena, salto
    local lRepetir
    lRepetir:
    mov dx, offset cadena ; offset obtiene la direccion de cadena
    mov ah, 09h        ; se carga en la parte alta el servicio 09H, el cual despliega una cadena, que es imprimir n columnas hacia adelante.
    int 21h            ; Peticion de funcion al DOS. se ejecuta el servicio cargado en ah. Ejecutar funcion 09,
    mov ah,01h    ; se carga en la parte alta el servicio 01h, que lee un caracter de la entrada y lo guarda en el registro al.
    int 21h       ; se ejecuta el servicio cargado en ah, ejecuta 01h.
    cmp al, 0dh     ; Compara si el valor en el registro al es un Enter. al = Enter y 0dh = Enter, entonces ZF = 1, de lo contrario ZF = 0.
    jne lRepetir  ; jne -> if ZF = 0 then jump. Si no es un Enter salta a la etiqueta lPrint1.
    jmp salto
ENDM

;---------------------------------------------------------
mIntToString MACRO salida, entrada 
    local lUnsigned_IntWrite, lPrint_Minus, lLoopWrite, lConvDesdePila, lSalirImprimir
; Para Escribir el número se tiene que seguir esta lógica
; if (x < 0) {
;     write('-');   // or just was_negative = 1
;     x = -x;
; }   
; unsigned_intwrite(x)
; Receives: 
;   [Si] variable con el offset de una cadena que va a almacenar el resultado
;   [Bx] variable con el entero con signo de 16 bit's 
; Returns: ...
; Use:  
;   [Di] como base 10 para poder dividir
;   [Cx] como contador de números almacenados en la pila
;---------------------------------------------------------
    mov bx, word ptr[entrada]
    mov si, offset salida
    xor cx, cx
    xor di, di
    cmp bx, 0
    je lUnsigned_IntWrite ; si es cero, no imprimir (+) ni (-)
    cmp bx, 0
    jl lPrint_Minus ; bx < 0
    ; Si no, Escribir más (bx > 0)
    mov byte ptr[si], 43  
    inc si
    neg bx      ; -bx = +bx * -1
    jmp lUnsigned_IntWrite
    
    lPrint_Minus:
    mov byte ptr[si], 45
    inc si
    ; -bx = -bx
    jmp lUnsigned_IntWrite

    lUnsigned_IntWrite:
        neg bx          ; bx = -bx * -1
        mov ax, bx
        mov di, 10
        lLoopWrite:
            xor dx, dx
            div di      ; Como es un word entonces [Ax] = división, [Dx] = resto
            push dx
            inc cx      ; Incrementamos el número de elementos en la pila
            cmp ax, 0
            jne lLoopWrite
        
        lConvDesdePila:
            pop dx
            add dx, 48
            mov byte ptr[si], dl
            dec cx
            cmp cx, 00
            je lSalirImprimir
            inc si
            jmp lConvDesdePila

    lSalirImprimir:
ENDM


;---------------------------------------------------------
mDoubleToString MACRO salida, entrada 
    local lUnsigned_IntWrite, lPrint_Minus, lLoopWrite, lConvDesdePila, lSalirImprimir
; Para Escribir el número se tiene que seguir esta lógica
; if (x < 0) {
;     write('-');   // or just was_negative = 1
;     x = -x;
; }   
; unsigned_intwrite(x)
; Receives: 
;   [Si] variable con el offset de una cadena que va a almacenar el resultado
;   [Bx] variable con el entero con signo de 16 bit's 
; Returns: ...
; Use:  
;   [Di] como base 10 para poder dividir
;   [Cx] como contador de números almacenados en la pila
;---------------------------------------------------------
    mov bx, word ptr[entrada]
    mov si, offset salida
    xor cx, cx
    xor di, di
    cmp bx, 0
    je lUnsigned_IntWrite ; si es cero, no imprimir (+) ni (-)
    cmp bx, 0
    jl lPrint_Minus ; bx < 0
    ; Si no, Escribir más (bx > 0)
    ;mov byte ptr[si], 43  
    ;inc si
    neg bx      ; -bx = +bx * -1
    jmp lUnsigned_IntWrite
    
    lPrint_Minus:
    ;mov byte ptr[si], 45
    ;inc si
    ; -bx = -bx
    jmp lUnsigned_IntWrite

    lUnsigned_IntWrite:
        neg bx          ; bx = -bx * -1
        mov ax, bx
        mov di, 10
        lLoopWrite:
            xor dx, dx
            div di      ; Como es un word entonces [Ax] = división, [Dx] = resto
            push dx
            inc cx      ; Incrementamos el número de elementos en la pila
            cmp ax, 0
            jne lLoopWrite
        
        lConvDesdePila:
            pop dx
            add dx, 48
            mov byte ptr[si], dl
            dec cx
            cmp cx, 00
            je lSalirImprimir
            inc si
            jmp lConvDesdePila

    lSalirImprimir:
ENDM

;---------------------------------------------------------
mLimpiarCadena MACRO variable
    local lLimpiarCadena, lTerminarLimpieza
    ; Use: [Ah]
    ; Receives: [Bx] variable como offset de la cadena a limpiar
    ;---------------------------------------------------------
    mov bx, offset variable
    lLimpiarCadena:
        mov ah, byte ptr [bx]
        cmp ah, 24h
        je lTerminarLimpieza
        mov byte ptr [bx], 0
        inc bx
        jmp lLimpiarCadena
    lTerminarLimpieza:
ENDM

mLimpiarCadenaEntero MACRO variable
    local lLimpiarCadena, lTerminarLimpieza
    ; Use: [Ah]
    ; Receives: [Bx] variable como offset de la cadena a limpiar
    ;---------------------------------------------------------
    mov bx, offset variable
    lLimpiarCadena:
        mov ah, byte ptr [bx]
        cmp ah, 24h
        je lTerminarLimpieza
        mov byte ptr [bx], 24h
        inc bx
        jmp lLimpiarCadena
    lTerminarLimpieza:
ENDM


; MACROS FASE 2

mActivarModoVideo MACRO
    push ax             ; extrayendo el valor de ax para no perderlo cuando se use la macro
    mov ax, 0013h       ; servicio requerido 13h 
    int 10h             
    mov ax, 0A000h      ; Nos posicionamos en la direccion de las variables del modo vídeo
    mov es, ax          
    pop ax
ENDM
mDesactivarModoVideo MACRO
    push ax
    mov ax, 0003h       ; servicio requerido 0003h
    int 10h
    pop ax
ENDM
mDibujarEjeY macro
LOCAL LOOP_I
    push dx
    push di

    mov dl, 1d
    mov di, 159d
    LOOP_I:
        mov es:[di], dl
        add di, 320d         ; ubicarnos en el mismo punto solo que un nivel abajo
        cmp di, 64000d       ; 320 * 200, límite de la pantalla
        jb LOOP_I 
    pop di
    pop dx
endm

mDibujarEjeX macro
LOCAL LOOP_I
    push dx
    push di
    xor dl, dl
    mov dl, 1d              ; color de los pixeles del eje X
    mov di, 32000d          ; 320 * 100 
    LOOP_I:
        xor ax, ax
        mov es:[di], dl
        inc di              ; al incrementar di, nos desplazamos a la derecha
        cmp di, 32320d      ; 320 * 101
        jb LOOP_I 

    pop di
    pop dx
endm
;Ambos parametros tienen signo (x,y) y color que es el código de colores
mDibujarPixelColor macro x, y, color
    push ax
    push bx
    push di
    push si
    push dx
    FINIT

    xor ax, ax
    xor bx, bx
    xor di, di
    xor si, si
    xor dx, dx
    mov ax, 32159d ; nos posicionamos en el centro Y: 320 * 100 X: +159
    ; Parte para manejar coordenada: "X"
    mov si, offset numeroEntero1
    mov word ptr[si], ax 
    FILD numeroEntero1

    xor ax, ax
    mov si, offset numeroEntero2
    mov ax, word ptr[si]            ; valor de "X" en entero.
    mov si, offset numeroEntero1
    mov word ptr[si], ax 
    FILD numeroEntero1
    FADD                       ; desplazamiento en X

    ; Parte para manejar coordenada: "Y"
    xor ax, ax
    mov si, offset numeroEntero3
    mov ax, word ptr[si]            ; valor de "Y" en entero.
    neg ax                     ; se niega para obtener la dirección correcta de subir o bajar en el plano
    mov si, offset numeroEntero1
    mov word ptr[si], ax
    FILD numeroEntero1
    xor ax, ax
    mov ax, 320d
    mov si, offset numeroEntero1
    mov word ptr[si], ax
    FILD numeroEntero1
    FMUL                        ; total distancia en Y
    FADD                        ; desplazamiento en Y
    FISTP numeroEntero1
    
    mov si, offset numeroEntero1
    mov di, word ptr[si]
    mov dl, color               ; valor de COLOR del pixel
    mov es:[di], dl
    
    FINIT
    pop dx
    pop si
    pop di
    pop bx
    pop ax
endm
mDibujarPixelColorMejorado macro x, y, color
    push bx
    push ax
    push dx
    push cx
    FINIT
    mov bx, 159d ; nos posicionamos en el centro X: 159
    ; Parte para manejar coordenada: "X"
    mov si, offset numeroEntero1
    mov word ptr[si], bx 
    FILD numeroEntero1
    mov word ptr[si], x
    FILD numeroEntero1
    FADD
    FISTP numeroEntero2
    mov bx, 100d ; nos posicionamos en el centro Y: 100
    ; Parte para manejar coordenada: "Y"
    mov si, offset numeroEntero1
    mov word ptr[si], bx 
    FILD numeroEntero1
    mov word ptr[si], y
    FILD numeroEntero1
    FADD
    FISTP numeroEntero3

    mov si, offset numeroEntero2
    mov cx, word ptr[si]            ; Coordenada X
    mov si, offset numeroEntero3
    mov dx, word ptr[si]            ; Coordenada Y
    mov ah, 0Ch                     ; Servicio para pintar un pixel
    mov al, color                   ; Color del pixel
    int 10h             

    pop cx
    pop dx
    pop ax
    pop bx
endm

mReiniciarVariableFPU MACRO variable
    FINIT
    FLDZ
    FISTP variable
ENDM

;---------------------------------------------------------
mImprimirNumeroDecimal MACRO variable
local no_negativo, lCorrectaAproximacion
; Macro para calcular la funcion polinomica que nosotros deseemos
; Receives: variable en el FPU ( solo ella tiene que estar)
; Returns: numero decimal impreso
;---------------------------------------------------------
    
    mov si, offset signoDecimal
    mov byte ptr[si], 43d

    FINIT
    mov si, offset variable
    FLD variable
    FTST ; Comparar resultado con 0.0
    FSTSW banderaFPU
    mov si, offset banderaFPU
    mov ax, word ptr[si]
    TEST AH, 01h     ; Comprueba si el bit 0 (CONDITION) está establecido
    JZ no_negativo   ; Salta a la etiqueta no_negative si el bit 0 no está establecido
    FCHS
    mov si, offset signoDecimal
    mov byte ptr[si], 45d
    no_negativo:
    FISUB variableValorUno
    FIST parteEntera
    FIADD variableValorUno
    FLD ST(0)
    FISTP variableValorUno
    FCOM
    FSTSW banderaFPU        ; guardo las banderas del FPU en una variable
    mov si, offset banderaFPU
    mov ax, word ptr[si]
    sahf ; pasa el valor del registro AH a las banderas
    jbe lCorrectaAproximacion ; si el valor de la aproximacion es mas pequeña que el decimal
    ;FLD1
    ;FSUB ; esto es para TASM al parecer porque en MASM no da problemas la aproximación del FISTP
    lCorrectaAproximacion:
    FSUB
    FIMUL extraerDecimal
    FISTP parteDecimal
    mov si, variableValorUno
    mov word ptr[si], 1d

    mImprimirCadena signoDecimal

    mLimpiarCadenaEntero salidaNumeros ; limpio la variable por si tiene basura
    mov si, offset parteEntera
    mDoubleToString salidaNumeros, si
    mImprimirCadena salidaNumeros

    mImprimirCadena puntoDecimal

    mLimpiarCadenaEntero salidaNumeros
    mov si, offset parteDecimal
    mDoubleToString salidaNumeros, si
    mImprimirCadena salidaNumeros
ENDM

mImprimirEnteros MACRO variable
    mLimpiarCadenaEntero salidaNumeros
    mov si, offset variable
    mIntToString salidaNumeros, si
    mImprimirCadena salidaNumeros
ENDM

; **************************FIN DECLARACION DE MACROS**************************

; **************************INICIO DECLARACION DE VARIABLES DEL PROGRAMA**************************
.MODEL small ; Sirve para definir atributos del modelo de memoria
.STACK ; Crea el segmento de pila con valor por default de 1KB sino se define
.RADIX 10 ; Declara que el sistema númerico a utilizar será el hexadecimal (16), por default es decimal (10)
.DATA ; Crea el segmento de datos, aquí se declaran variables...
; recordar que el db es 'Define Byte' y define un variable de 8-bit en memoria.
; Variables para ver lo del resultado en decimal
;variables para imprimir decimales
puntoDecimal db 46d, '$'
signoDecimal db 43d, '$'
banderaFPU dw ?, '$'
variableCero dw ?, '$'
parteDecimal dw ?, '$'
extraerDecimal dw 1000d, '$'
variableValorUno dw 1d, '$'
numeroCualquiera dw 8, '$'
otroCualquiera dw 3, '$'
parteEntera dw ?
variable dw ?

;Variables para el metodo de Newton y Steffense
valorMaximoDeIteraciones dw 5d
tope13 db '$'
coeficienteTolerancia dw 5d
tope2 db '$'
baseDiez dw 10d
tope14 db '$'
gradoTolerancia dw 3d
tope3 db '$'
limiteSuperior dw 1d
tope4 db '$'
limiteInferior dw -1d
tope5 db '$'
valorYFuncion dq ?
tope8 db '$'
valorYFuncionOriginal dq ?
tope11 db '$'
valorYFuncionDerivada dq ?
tope9 db '$'
valorIteracionAnterior dq 0d
tope1 db '$'
copiaValorIteracionAnterior dq 0d
tope15 db '$'
valorErrorAbsolutoIteracion dq ?
tope12 db '$'
valorErrorAbsolutoAceptable dq ?
tope7 db '$'
valorDecimalCualquiera dq ?
tope6 db '$'
variableValorDos dw 2d
tope10 db '$'


; Variables para graficar o dibujar (como se le quiera decir)
valorY       dw ? ; Variable para almacenar el valor de la coordenada Y.
almacenador1 dw ? ; Variable para almacenar 
almacenador2 dw ? ; Variable para almacenar 
almacenador3 dw ? ; Variable para almacenar 
almacenador4 dw ? ; Variable para almacenar 
numeroEntero2 dw ?, '$'
numeroEntero3 dw ?, '$'
direccion1 dw ? ; Variable para almacenar direcciones
; Variables para la funcion integral
; array word con salto de 3
coeficiente0Integral db 2 dup(0), 24h ; Posicion 0
coeficiente1Integral db 2 dup(0), 24h ; Posicion 3
coeficiente2Integral db 2 dup(0), 24h ; Posicion 6
coeficiente3Integral db 2 dup(0), 24h ; Posicion 9
coeficiente4Integral db 2 dup(0), 24h ; Posicion 12
coeficiente5Integral db 2 dup(0), 24h ; Posicion 15
numeroEntero1 dw 0, '$'    ; almacena el menos y así.
almacenarContador db 2 dup(0)
salidaNumeros     db 6 dup('$')
cadEntrada db 5 dup(0), 24h

; Variables para la funcion derivada
; array word con salto de 3
coeficiente0Derivada db 12d, 0d, 24h ; Posicion 0
coeficiente1Derivada db 6d, 0d, 24h ; Posicion 3
coeficiente2Derivada db 3d, 0d, 24h ; Posicion 6
coeficiente3Derivada db 2 dup(0), 24h ; Posicion 9
coeficiente4Derivada db 2 dup(0), 24h ; Posicion 12
coeficiente5Derivada db 2 dup(0), 24h ; Posicion 15

; Variables para la funcion original
; array word con salto de 3
coeficiente0 db 8d, 0d, 24h ; Posicion 0
coeficiente1 db 12d, 0d, 24h ; Posicion 3
coeficiente2 db 3d, 0d, 24h ; Posicion 6
coeficiente3 db 1d, 0d, 24h ; Posicion 9
coeficiente4 db 0d, 0d, 24h ; Posicion 12
coeficiente5 db 0d, 0d, 24h ; Posicion 15

signo db 1 dup(0) ; si es 1 es un positivo, si es 0 es un negativo
gradoFuncion db 1 dup(0)
valorBaseNumerica dw 000Ah

tituloMetodoDeNewton db "////////////////////////////////// METODO DE NEWTON //////////////////////////////////", 0Ah, 24h
elCeroEncontradoEs db "El solucion es Xn = ", 24h
conUnErrorDe db " con un error de ", 24h
encabezadoIteraciones db "----------------------------------", 0Ah, 24h
iteracionTal db "Iteracion: ", 24h
valorInicial db "Valor inicial: ", 24h
errorIteracion db "Error iteracion: ", 24h
errorAbsoluto db "Error buscado: ", 24h
stringValorIteracionActual db "Valor de la iteracion actual: ", 24h
maxIteracionesString db "el maximo de iteraciones es de: ", 24h
stringLimiteSuperior db "Limite superior x = ", 24h
stringLimiteInferior db "Limite inferior x = ", 24h



suFuncionEs         db "La funcion generada es: ", 24h
parentesisAbre      db "(", 24h
parentesisCierra    db ")", 24h 
signoSuma           db "+", 24h
letraX              db "x^", 24h

preguntaCoeficiente db "Ingrese el coeficiente de x^", 24h
cierrePregunta      db ":", 24h
preguntaGrado db "Ingrese el grado de su funcion: ", 24h
errorDigitoNoValido db "Entrada no valida ", 24h

opcion1           db "Selecciono la opcion 1.", 0Ah, 24h
opcion2           db "Selecciono la opcion 2.", 0Ah, 24h
opcion3           db "Selecciono la opcion 3.", 0Ah, 24h
opcion4           db "Selecciono la opcion 4.", 0Ah, 24h
opcion5           db "Selecciono la opcion 5.", 0Ah, 24h
opcion6           db "Selecciono la opcion 6.", 0Ah, 24h
opcion7           db "Selecciono la opcion 7.", 0Ah, 24h
opcion8           db "Selecciono la opcion 8.", 0Ah, 24h
opcion9           db "Selecciono la opcion 9.", 0Ah, 24h

menu    db "///////////////// MENU /////////////////", 0Ah 
                db "(1) Ingresar Funcion.", 0Ah
                db "(2) Imprimir la funcion almacenada.", 0Ah
                db "(3) Imprimir la derivada de la funcion almacenada.", 0Ah
                db "(4) Imprimir la funcion almacenada.", 0Ah
                db "(5) Imprimir la integral de la funcion almacenada.", 0Ah
                db "(6) Graficar la funcion almacenada (original/derivada/integral).", 0Ah
                db "(7) Encontrar los ceros de la funcion por medio del metodo de Newton.", 0Ah
                db "(8) Encontrar los ceros de la funcion por medio del metodo de Steffensen.", 0Ah
                db "(9) Salir de la aplicacion,", 0Ah, 24h

subMenu    db "///////////////// SUBMENU /////////////////", 0Ah 
           db "(1) Graficar funcion original.", 0Ah
           db "(1) Graficar funcion derivada.", 0Ah
           db "(1) Graficar funcion integral.", 0Ah, 24h

presioneEnter   db "Presione Enter para continuar...", 0Ah, 24h
errorMenu1      db "Opcion incorrecta, seleccione solo valores (1,2,3,4,5,6,7,8,9).", 0Ah, 24h
saltoLinea      db 0Ah, 24h
adios           db "Hasta la proximaaa!!!!", 24h


.CODE
inicio:
    main proc
        mov dx, @DATA ;esto va siempre en el main
        mov ds, dx ;esto también va siempre en el main
        FINIT
        
        
        call pMetodoDeNewton
        mRepetirSaltoSiNoEs presioneEnter, SALIR
        SALIR:

        mov al, 16  ; retorno funcion main
        mov ah, 04Ch ; se carga en la parte alta el servicio 04Ch, devuelve el control al sistema, termina proceso
        int 21 ; Ejecutar función 04Ch, que es terminar el proceso
    main endp

    ;---------------------------------------------------------
    pMetodoDeNewton proc
    ; Procedimiento para calcular los ceros de la función original
    ; Receives: Variables con los datos (variables del método de Newton)
    ; Returns: en variable parte entera y variable parte decimal, los valores correspondientes
    ;---------------------------------------------------------
        mImprimirCadena tituloMetodoDeNewton
        mImprimirCadena saltoLinea
        ;Lo primero que hay que hacer es calcular el error absoluto Aceptable
        ; realizar parte de potencia x^n y luego dividir 1 dentro de eso
        ; Calcular valor de cT*10^-(gT)
        ; extrayendo valor de almacenar contador hacia el registro (n)
        mov di, offset gradoTolerancia
        mov cx, word ptr[di]
        ; guardando la base (10)
        FILD baseDiez
        lCicloPotencia1:
        cmp cx, 1d
        je lSalirCicloPotencia1
        cmp cx, 0d
        je lSalirPotenciaCasoCero1
            FIMUL baseDiez
        dec cx
        jmp lCicloPotencia1
        lSalirPotenciaCasoCero1:
        FINIT
        mov di, offset numeroEntero1
        mov ax, 1d
        mov word ptr[di], ax
        FILD numeroEntero1
        lSalirCicloPotencia1:
        ; solo faltaría dividir a 1/resultado para obtener el x^-n
        FIDIVR variableValorUno ; realiza 1/ST(0) = ST(0)
        FILD coeficienteTolerancia ; realiza el cT * division
        FMUL
        FST valorErrorAbsolutoAceptable ; se guarda el valor absoluto aceptable

        ; Lo siguiente a hacer es calcular el punto inicial (iteracion inicial)
        ; básicamente es calcular el punto medio de los limites inferiores y maximos
        FINIT
        FILD limiteSuperior
        FILD limiteInferior
        FADD
        FIDIV variableValorDos ; divimos (limiteSuperior + limiteInferior) / 2 -> punto medio
        FSTP valorIteracionAnterior ; valor del punto inicial

        

        mImprimirCadena stringLimiteSuperior 
        mImprimirEnteros limiteSuperior
        mImprimirCadena saltoLinea
        mImprimirCadena stringLimiteInferior
        mImprimirEnteros limiteInferior
        mImprimirCadena saltoLinea
        mImprimirCadena valorInicial
        FINIT
        FLD valorIteracionAnterior
        call pImprimirNumeroDecimal
        mImprimirCadena saltoLinea
        mImprimirCadena errorAbsoluto
        mImprimirEnteros coeficienteTolerancia
        mImprimirChar "*"
        mImprimirChar "1"
        mImprimirChar "0"
        mImprimirChar "^"
        mImprimirChar "-"
        mLimpiarCadenaEntero salidaNumeros ; limpio la variable por si tiene basura
        mov si, offset gradoTolerancia
        mDoubleToString salidaNumeros, si
        mImprimirCadena salidaNumeros
        mImprimirCadena saltoLinea
        mImprimirCadena maxIteracionesString
        mImprimirEnteros valorMaximoDeIteraciones
        
        mImprimirCadena saltoLinea
        mImprimirCadena saltoLinea

        ; guardamos el nuevo contador
        mov si, offset valorMaximoDeIteraciones
        mov cx, word ptr[si]
        ; lo siguiente sería calcular ya función P_(n) = P_(n-1) - {f[P_(n-1)] / f'[P_(n-1)]}
        lFuncionNewton:
            ; guardando registro en valorMaximoDeIteraciones
            mov si, offset valorMaximoDeIteraciones
            mov word ptr[si], cx
            
            
            ; tener en cuenta que P_(n-1) es valorIteracionAnterior
            ; Falta calcular f[P_(n-1)] / f'[P_(n-1)] 
            ; Calcular f[P_(n-1)]
            mov di, offset coeficiente0
            FINIT
            call pCalcularFuncion 
            FLD  valorYFuncion
            FSTP valorYFuncionOriginal
            ; Calcular f'[P_(n-1)]
            mov di, offset coeficiente0Derivada
            FINIT
            call pCalcularFuncion 
            FLD valorYFuncion
            FSTP valorYFuncionDerivada
            ; Calcular f[P_(n-1)] / f'[P_(n-1)] 
            FLD valorYFuncionOriginal
            FLD valorYFuncionDerivada
            FDIV ; ST(0) = division
            ; Calcular P_(n-1) - division
            FLD valorIteracionAnterior ; esto va al reves (arreglar)
            FSUBR
            FSTP valorDecimalCualquiera ; variable auxiliar
            ; Calcular el error
            FLD valorIteracionAnterior
            FLD valorDecimalCualquiera
            FSUB 
            FABS
            FSTP valorErrorAbsolutoIteracion ; Obtenemos el valor de error absoluto de esta iteración
            FLD valorDecimalCualquiera
            FSTP valorIteracionAnterior      ; Valor de dicha iteración
            ; Comparar si hay que detener las iteraciones
            ; Caso 1 se llego a un buen error absoluto
            FINIT
            FLD valorErrorAbsolutoAceptable
            FLD valorErrorAbsolutoIteracion
            FCOM
            FSTSW banderaFPU        ; guardo las banderas del FPU en una variable
            mov si, offset banderaFPU
            mov ax, word ptr[si]
            sahf ; pasa el valor del registro AH a las banderas
            jbe lTerminarNewton ; si es menor el valor de la iteracion
            ; Caso 2 se alcanzo el valor máximo de iteraciones
            
            ; mov si, offset valorMaximoDeIteraciones
            ; mov cx, word ptr[si]
            ; mImprimirCadena encabezadoIteraciones
            ; mImprimirCadena iteracionTal
            ; mImprimirValorRegistroByte cl
            ; mImprimirCadena saltoLinea

            ; mImprimirCadena stringValorIteracionActual
            ; FINIT
            ; FLD valorIteracionAnterior
            ; call pImprimirNumeroDecimal
            ; mImprimirCadena saltoLinea

            ; mImprimirCadena errorIteracion
            ; FINIT
            ; FLD valorErrorAbsolutoIteracion
            ; call pImprimirNumeroDecimal
            ; mImprimirCadena saltoLinea

            ; mImprimirCadena encabezadoIteraciones
            ; FINIT
            ; mImprimirCadena saltoLinea
            ; mRepetirSaltoSiNoEs presioneEnter, lContinuarNewtonEnter

            ; lContinuarNewtonEnter:
            mov si, offset valorMaximoDeIteraciones
            mov cx, word ptr[si]
            dec cx
            cmp cx, 0000
            jle lTerminarNewton
        jmp lFuncionNewton

        lTerminarNewton:
        ; Imprimir resultado
        mImprimirCadena elCeroEncontradoEs
        FINIT
        FLD valorIteracionAnterior
        call pImprimirNumeroDecimal
        FINIT
        FLD valorIteracionAnterior
        call pImprimirNumeroDecimal
        FINIT
        FLD valorIteracionAnterior
        call pImprimirNumeroDecimal
        FINIT
        FLD valorIteracionAnterior
        call pImprimirNumeroDecimal
        ; mImprimirCadena conUnErrorDe
        ; FINIT
        ; FLD valorErrorAbsolutoIteracion
        ; call pImprimirNumeroDecimal
        mImprimirCadena saltoLinea

        
        mRepetirSaltoSiNoEs presioneEnter, lSalirProcNewton

        lSalirProcNewton:
        ret
    pMetodoDeNewton endp

;---------------------------------------------------------
pImprimirNumeroDecimal proc
; Procedimiento para calcular la funcion polinomica que nosotros deseemos
; Receives: variable en el FPU ( solo ella tiene que estar)
; Returns: numero decimal impreso
;---------------------------------------------------------
    mReiniciarVariableFPU parteEntera
    mReiniciarVariableFPU parteDecimal
    
    mov si, offset signoDecimal
    mov byte ptr[si], 43d
    
    FTST ; Comparar resultado con 0.0
    FSTSW banderaFPU
    mov si, offset banderaFPU
    mov ax, word ptr[si]
    sahf ; pasa el valor del registro AH a las banderas
    je lCasoCeroFPU ; si es menor el valor de la iteracion
    TEST AH, 01h     ; Comprueba si el bit 0 (CONDITION) está establecido
    JZ no_negativo   ; Salta a la etiqueta no_negative si el bit 0 no está establecido
    FCHS
    mov si, offset signoDecimal
    mov byte ptr[si], 45d
    no_negativo:
    FISUB variableValorUno
    FIST parteEntera
    FIADD variableValorUno
    FLD ST(0)
    FISTP variableValorUno
    FCOM
    FSTSW banderaFPU        ; guardo las banderas del FPU en una variable
    mov si, offset banderaFPU
    mov ax, word ptr[si]
    sahf ; pasa el valor del registro AH a las banderas
    jbe lCorrectaAproximacion ; si el valor de la aproximacion es mas pequeña que el decimal
    ;FLD1
    ;FSUB
    lCorrectaAproximacion:
    FSUB
    FIMUL extraerDecimal
    FISTP parteDecimal
    mov si, variableValorUno
    mov word ptr[si], 1d
    jmp lListoImprimir
    lCasoCeroFPU:
    mReiniciarVariableFPU parteEntera
    mReiniciarVariableFPU parteDecimal

    lListoImprimir:
    mImprimirCadena signoDecimal

    mLimpiarCadenaEntero salidaNumeros ; limpio la variable por si tiene basura
    mov si, offset parteEntera
    mDoubleToString salidaNumeros, si
    mImprimirCadena salidaNumeros

    mImprimirCadena puntoDecimal

    mLimpiarCadenaEntero salidaNumeros
    mov si, offset parteDecimal
    mDoubleToString salidaNumeros, si
    mImprimirCadena salidaNumeros

    ret
pImprimirNumeroDecimal endp

    ;---------------------------------------------------------
    pCalcularFuncion proc
    ; Procedimiento para calcular la funcion polinomica que nosotros deseemos
    ; Receives: [di] direccion de la posicion 0 del array de coeficientes
    ;           "X" como la variable valorIteracionAnterior 
    ; Returns: valor de la funcion Y, en la variable (valorYFuncion)
    ;---------------------------------------------------------
        mReiniciarVariableFPU valorYFuncion
        mov si, offset almacenador1
        mov word ptr[si], di
        xor si, si
        xor di, di

        ;Calcular cada x^Cx y sumarlos, para determinar la coordenada "Y"
        mov cx, 0005
        lCalcularFuncion:
            ; guardando registro en almacenar contador
            mov si, offset almacenador3
            mov word ptr[si], cx

            ; Calculando la direccion del valor del array según el número de iteración
            mov ax, cx
            mov bx, 0003
            mul bx
            ; Extrayendo direccion de la variable parametro de memoria y enviandola [Si]
            mov di, offset almacenador1
            mov si, word ptr[di]
            add si, ax          ; Se obtiene la posicion del array acuerdo a la iteracion del ciclo 

            cmp word ptr[si], 0000 ; Si el coeficiente vale 0, saltarselo así se ahorra tiempo
            je lContinuarCalcularFuncion

            ; Calcular valor de C*x^n
            ; extrayendo valor de almacenar contador hacia el registro (n)
            mov di, offset almacenador3
            mov cx, word ptr[di]
            ; guardando la base (x)
            FLD valorIteracionAnterior

            ; realizar parte de potencia x^n
            lCicloPotencia2:
            cmp cx, 1d
            je lSalirCicloPotencia2
            cmp cx, 0d
            je lSalirPotenciaCasoCero2
                FLD valorIteracionAnterior
                FMUL
            dec cx
            jmp lCicloPotencia2
            lSalirPotenciaCasoCero2:
            FINIT
            mov di, offset numeroEntero1
            mov ax, 1d
            mov word ptr[di], ax
            FILD numeroEntero1

            lSalirCicloPotencia2:
            ; realizar multiplicación de C * [x^n]
            mov ax, word ptr[si]
            mov di, offset numeroEntero1
            mov word ptr[di], ax
            FILD numeroEntero1
            FMUL        ; ST(0) = resultado de multiplicación de C * [x^n]
            FLD valorYFuncion
            FADD
            FSTP valorYFuncion ; guardamos el resultado en el valor Y nuevamente.
            
            lContinuarCalcularFuncion:
            ; extrayendo valor de almacenar contador hacia el registro
            mov si, offset almacenador3
            mov cx, word ptr[si]

            dec cx
            cmp cx, 0000
            jl lContinuarRetornoValor
            jmp lCalcularFuncion
        
        lContinuarRetornoValor:
        ret
    pCalcularFuncion endp

    ;---------------------------------------------------------
    pDibujarGrafica PROC
    ; Todas las funciones van de X: -10 a X: +10
    ; Procedimiento para dibujar una funcion polinomica
    ; Receives: [di] direccion de la posicion 0 del array de coeficientes 
    ; Returns: Dibujo en pantalla.
    ;---------------------------------------------------------
        mov si, offset almacenador1
        mov word ptr[si], di
        xor si, si
        xor di, di
        ;Imprimir funcion en el intervalo de X: (-100, +100)
        mov cx, -10d
        lDibujarPuntoGrafica:
            FINIT
            ; guardando registro en almacenar contador
            mov si, offset almacenador2
            mov word ptr[si], cx

            ;Calcular cada x^Cx y sumarlos, para determinar la coordenada "Y"
            mov cx, 0005
            lCalcularCoordenadas:
                ; guardando registro en almacenar contador
                mov si, offset almacenador3
                mov word ptr[si], cx

                ; Calculando la direccion del valor del array según el número de iteración
                mov ax, cx
                mov bx, 0003
                mul bx
                ; Extrayendo direccion de la variable parametro de memoria y enviandola [Si]
                mov di, offset almacenador1
                mov si, word ptr[di]
                add si, ax          ; Se obtiene la posicion del array acuerdo a la iteracion del ciclo 

                cmp word ptr[si], 0000 ; Si el coeficiente vale 0, saltarselo así se ahorra tiempo
                je lContinucarCalculoCoordenadas

                ; Calcular valor de C*x^n
                ; extrayendo valor de almacenar contador hacia el registro (n)
                mov di, offset almacenador3
                mov cx, word ptr[di]
                ; guardando la base (x)
                FILD almacenador2

                ; realizar parte de potencia x^n
                lCicloPotencia:
                cmp cx, 1d
                je lSalirCicloPotencia
                cmp cx, 0d
                je lSalirPotenciaCasoCero
                    FIMUL almacenador2
                dec cx
                jmp lCicloPotencia
                lSalirPotenciaCasoCero:
                FINIT
                mov di, offset numeroEntero1
                mov ax, 1d
                mov word ptr[di], ax
                FILD numeroEntero1

                lSalirCicloPotencia:
                ; realizar multiplicación de C * [x^n]
                mov ax, word ptr[si]
                mov di, offset numeroEntero1
                mov word ptr[di], ax
                FILD numeroEntero1
                FMUL        ; ST(0) = resultado de multiplicación de C * [x^n]

                FILD valorY ; ahora quedaría así el FPU, ST(0) = valorY, ST(1) = C*[x^n]+C[x^n-1]+...C[x^0]
                FADD
                FISTP valorY ; guardamos el resultado en el valor Y nuevamente.

                lContinucarCalculoCoordenadas:
                ; extrayendo valor de almacenar contador hacia el registro
                mov si, offset almacenador3
                mov cx, word ptr[si]

                dec cx
                cmp cx, 0000
                jl lContinuarDibujarPuntoGrafica
                jmp lCalcularCoordenadas
            
            lContinuarDibujarPuntoGrafica:
            ; extrayendo valor de almacenar contador hacia el registro
            mov si, offset almacenador2
            mov cx, word ptr[si]
            ; Dibujar punto en la grafica con las coordenadas
            mov si, offset valorY
            mov ax, word ptr[si]
            ; Cx = X y Ax = Y

            ; Antes de pintar validar que las coordenadas no se salgan de la pantalla, porque sino loquea
            cmp ax, 100d
            jge lContinuarCSP1
            cmp ax, -100d
            jge lSiPintar
            lContinuarCSP1:
            jmp lContinuarConSiguientePunto
            
            lSiPintar:
            ; Si esta dentro del rango permitido si pintarlo
            mov si, offset numeroEntero2
            mov word ptr[si], cx
            mov si, offset numeroEntero3
            mov word ptr[si], ax
            mDibujarPixelColor numeroEntero2, numeroEntero3, 63h

            lContinuarConSiguientePunto:
            ; Reiniciar coordena Y
            mov si, offset valorY
            mov word ptr[si], 0000h
            inc cx
            cmp cx, 11d
            je lTerminarDibujo
            jmp lDibujarPuntoGrafica
        lTerminarDibujo:
        ret
    pDibujarGrafica ENDP

    ; ------------------- Obtiene respuesta del teclado --------------------
    TECLA PROC
        MOV AH, 10H			; Petici�n entrada del teclado al BIOS
        INT 16H				; Llama al BIOS
        RET
    TECLA ENDP

END inicio