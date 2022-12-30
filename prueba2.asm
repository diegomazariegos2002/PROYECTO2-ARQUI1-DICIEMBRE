

; **************************INICIO DECLARACION DE VARIABLES DEL PROGRAMA**************************
.MODEL small ; Sirve para definir atributos del modelo de memoria
.STACK ; Crea el segmento de pila con valor por default de 1KB sino se define
.RADIX 10 ; Declara que el sistema númerico a utilizar será el hexadecimal (16), por default es decimal (10)
.DATA ; Crea el segmento de datos, aquí se declaran variables...

; Variable del mensaje inicial
;recordar que el db es 'Define Byte' y define un variable de 8-bit en memoria.

;tablero_J1_Disparos
;variables para imprimir decimales
signoDecimal db 0d, '$'
banderaFPU dw ?, '$'
variableCero dw ?, '$'
parteDecimal dw ?, '$'
extraerDecimal dw 1000d, '$'
aproximarAbajo dw 1, '$'
numeroCualquiera dw 8, '$'
otroCualquiera dw 3, '$'
parteEntera dw ?
variable dw ?
;**************************FIN DECLARACION DE VARIABLES DEL PROGRAMA**************************

.CODE
lInicio:
    ; *** MAIN ****
    pMain proc
        mov dx, @DATA ;esto va siempre en el main, inicializar area de datos
        mov ds, dx ;esto también va siempre en el main
        FINIT
        FILD numeroCualquiera
        FILD otroCualquiera        
        FDIV
        FTST ; Comparar resultado con 0.0
        FSTSW banderaFPU
        mov si, offset banderaFPU
        mov ax, word ptr[si]
        TEST AH, 01h     ; Comprueba si el bit 0 (CONDITION) está establecido
        JZ no_negativo   ; Salta a la etiqueta no_negative si el bit 0 no está establecido
        FCHS
        mov si, offset signoDecimal
        mov byte ptr[si], 1d
        no_negativo:
        FISUB aproximarAbajo
        FIST parteEntera
        FIDIV aproximarAbajo
        FILD aproximarAbajo
        FSUB
        FIMUL extraerDecimal
        FISTP parteDecimal



        jmp lSalir ; terminar proceso si se llega aquí
    pMain endp


;*****************************PROC O ETIQUETAS GENERALES*****************************
;------------------------
; etiqueta utilizada para cerrar el programa
;------------------------
lSalir: 
    mov al, 16h  ; retorno funcion main
    mov ah, 04Ch ; se carga en la parte alta el servicio 04Ch, devuelve el control al sistema, termina proceso
    int 21h ; se ejecuta el servicio cargado en ah, ejecuta 04Ch.    
    ; Recordar que la interrupción 21h se utiliza para entradas y salidas, files, administración de memeoria y llamadas a funciones.

END lInicio
