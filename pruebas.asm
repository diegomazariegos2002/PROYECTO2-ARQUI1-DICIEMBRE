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
    mov ax, 32159d ; nos posicionamos en el centro
    ; Parte para manejar coordenada: "X"
    mov si, offset numeroEntero1
    mov word ptr[si], ax 
    FILD numeroEntero1

    xor ax, ax
    mov ax, x                  ; valor de "x" en entero.
    mov si, offset numeroEntero1
    mov word ptr[si], ax 
    FILD numeroEntero1
    FADD                       ; desplazamiento en X

    ; Parte para manejar coordenada: "Y"
    xor ax, ax
    mov ax, y                  ; valor de "Y" en entero.
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
.RADIX 16 ; Declara que el sistema númerico a utilizar será el hexadecimal, por default es decimal (10)
.DATA ; Crea el segmento de datos, aquí se declaran variables
direccion1 dw ? ; Variable para almacenar direcciones
; Variables para la funcion original
; array word con salto de 3
coeficiente0 db 10h, 00h , 24h ; Posicion 0
coeficiente1 db 05h, 00h, 24h ; Posicion 3
coeficiente2 db 2 dup(0), 24h ; Posicion 6
coeficiente3 db 2 dup(0), 24h ; Posicion 9
coeficiente4 db 2 dup(0), 24h ; Posicion 12
coeficiente5 db 2 dup(0), 24h ; Posicion 15
numeroEntero1 dw ?, '$'
numeroEntero12 dw ?, '$'

.CODE
inicio:
    main proc
        mov dx, @DATA ;esto va siempre en el main
        mov ds, dx ;esto también va siempre en el main
        FINIT
        
        mActivarModoVideo
        mDibujarEjeX
        mDibujarEjeY
        mDibujarPixelColor 0001h, 0001h, 63h
        ; Todas las funciones van de X: -100 a X: +100
        mov si, offset coeficiente1
        mov ax, word ptr[si]
        mov si, offset numeroEntero1
        mov word ptr[si], ax
        FILD numeroEntero1
        FILD numeroEntero1
        FYL2X
        

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



    ; ------------------- Obtiene respuesta del teclado --------------------
    TECLA PROC
        MOV AH, 10H			; Petici�n entrada del teclado al BIOS
        INT 16H				; Llama al BIOS
        RET
    TECLA ENDP

END inicio