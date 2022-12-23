.MODEL small ; Sirve para definir atributos del modelo de memoria
.STACK ; Crea el segmento de pila con valor por default
.RADIX 16 ; Declara que el sistema númerico a utilizar será el hexadecimal, por default es decimal (10)
.DATA ; Crea el segmento de datos, aquí se declaran variables
hm db "Hola mundo", 0Ah, 0Ah, 24
numeroEntero db 2 dup(0), '$'
numeroEntero2 dw ?, '$'

.CODE
inicio:
    main proc
        mov dx, @DATA ;esto va siempre en el main
        mov ds, dx ;esto también va siempre en el main
        FINIT
        
        mov dx, offset hm ; offset obtiene la direccion de hm
        mov ah, 09        ; se carga en la parte alta el servicio 09H, el cual despliega una cadena
        int 21            ; Petición de función al DOS. Ejecutar función 09, que es imprimir n columnas hacia adelante.

        mov ax, 0008h 
        mov si, offset numeroEntero
        mov word ptr[si], ax
        mov dx, word ptr[si]
        mov si, offset numeroEntero2
        mov word ptr[si], dx
        FILD numeroEntero2
        mov ax, 0003h 
        neg ax
        mov si, offset numeroEntero
        mov word ptr[si], ax
        mov dx, word ptr[si]
        mov si, offset numeroEntero2
        mov word ptr[si], dx
        FILD numeroEntero2
        FDIV
        FISTP numeroEntero2
        mov si, offset numeroEntero2
        mov bx, word ptr[si]

        mov al, 16  ; retorno funcion main
        mov ah, 04Ch ; se carga en la parte alta el servicio 04Ch, devuelve el control al sistema, termina proceso
        int 21 ; Ejecutar función 04Ch, que es terminar el proceso
    main endp
END inicio