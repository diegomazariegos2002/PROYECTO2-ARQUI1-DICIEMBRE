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

;Ambos parametros tienen signo 
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

.MODEL small ; Sirve para definir atributos del modelo de memoria
.STACK ; Crea el segmento de pila con valor por default
.RADIX 10 ; Declara que el sistema númerico a utilizar será el hexadecimal, por default es decimal (10)
.DATA ; Crea el segmento de datos, aquí se declaran variables
valorY       dw ? ; Variable para almacenar el valor de la coordenada Y.
almacenador1 dw ? ; Variable para almacenar 
almacenador2 dw ? ; Variable para almacenar 
almacenador3 dw ? ; Variable para almacenar 
almacenador4 dw ? ; Variable para almacenar 
; Variables para la funcion original
; array word con salto de 3
coeficiente0 db 10h, 00h , 24h ; Posicion 0
coeficiente1 db 05h, 00h, 24h ; Posicion 3
coeficiente2 db 02h, 00h,  24h ; Posicion 6
coeficiente3 db 2 dup(0), 24h ; Posicion 9
coeficiente4 db 2 dup(0), 24h ; Posicion 12
coeficiente5 db 2 dup(0), 24h ; Posicion 15
numeroEntero1 dw ?, '$'
numeroEntero2 dw ?, '$'
numeroEntero3 dw ?, '$'

.CODE
inicio:
    main proc
        mov dx, @DATA ;esto va siempre en el main
        mov ds, dx ;esto también va siempre en el main
        FINIT
        
        mActivarModoVideo
        mDibujarEjeX
        mDibujarEjeY
        ;mDibujarPixelColor 0001h, 0001h, 63h
        ; Comienzo de método
        ; Todas las funciones van de X: -100 a X: +100
        mov si, offset coeficiente1
        mov ax, word ptr[si]
        mov si, offset numeroEntero1
        mov word ptr[si], ax
        FILD numeroEntero1
        FIMUL numeroEntero1
        FIMUL numeroEntero1
        
        mov di, offset coeficiente0
        call pDibujarGrafica
        

        REPETIR:	

        CALL TECLA
        CMP AL,27		                ; Tecla ESC
        JE SALIR
        XOR CX, CX
        XOR DX, DX
        MOV CL, AL
        MOV DL, AH
        JMP REPETIR
        SALIR:
        mDesactivarModoVideo

        mov al, 16  ; retorno funcion main
        mov ah, 04Ch ; se carga en la parte alta el servicio 04Ch, devuelve el control al sistema, termina proceso
        int 21 ; Ejecutar función 04Ch, que es terminar el proceso
    main endp

    ;---------------------------------------------------------
    pDibujarGrafica PROC
    ;
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