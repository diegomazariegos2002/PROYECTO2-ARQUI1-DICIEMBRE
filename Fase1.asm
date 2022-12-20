; **************************INICIO DECLARACIoN DE MACROS**************************
mLeerCaracter MACRO cadena
    mov ah,01h    ; se carga en la parte alta el servicio 01h, que lee un caracter de la entrada y lo guarda en el registro al.
    int 21h       ; se ejecuta el servicio cargado en ah, ejecuta 01h.
ENDM
mImprimirCadena MACRO cadena
    mov dx, offset cadena ; offset obtiene la direccion de cadena
    mov ah, 09h        ; se carga en la parte alta el servicio 09H, el cual despliega una cadena, que es imprimir n columnas hacia adelante.
    int 21h            ; Peticion de funcion al DOS. se ejecuta el servicio cargado en ah. Ejecutar funcion 09,
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



; **************************FIN DECLARACIoN DE MACROS**************************

; **************************INICIO DECLARACION DE VARIABLES DEL PROGRAMA**************************
.MODEL small ; Sirve para definir atributos del modelo de memoria
.STACK ; Crea el segmento de pila con valor por default de 1KB sino se define
.RADIX 10 ; Declara que el sistema númerico a utilizar será el hexadecimal (16), por default es decimal (10)
.DATA ; Crea el segmento de datos, aquí se declaran variables...

;      recordar que el db es 'Define Byte' y define un variable de 8-bit en memoria.
gradoFuncion db 1 dup(0)
coeficiente1 db 1 dup(0)
coeficiente2 db 1 dup(0)
coeficiente3 db 1 dup(0)
coeficiente4 db 1 dup(0)
coeficiente5 db 1 dup(0)
coeficiente6 db 1 dup(0)
preguntaCoeficiente db "Ingrese el coeficiente: ", 24h
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

presioneEnter   db "Presione Enter para continuar...", 0Ah, 24h
errorMenu1      db "Opcion incorrecta, seleccione solo valores (1,2,3,4,5,6,7,8,9).", 0Ah, 24h
saltoLinea      db 0Ah, 24h
adios           db "Hasta la proximaaa!!!!", 24h


.CODE
lInicio:
    ; *** MAIN ****
    pMain proc
        mov dx, @DATA   ; esto va siempre en el main, inicializar area de datos
        mov ds, dx      ; esto también va siempre en el main
        FINIT
        call pImprimirMensajeInicial

        jmp lSalir ; terminar proceso si se llega aquí
    pMain endp

    ;*****************************PROC O ETIQUETAS ESPECIFICOS DE LA APP*****************************
    ;---------------------------------------------------------
    pImprimirMensajeInicial proc
    ;
    ; Procedimiento para imprimir el texto inicial
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        lPrint1:    ; imprimir mensaje inicial
            mLimpiarPantalla
            mImprimirCadena menu
            mov ah,01h    ; se carga en la parte alta el servicio 01h, que lee un caracter de la entrada y lo guarda en el registro al.
            int 21h       ; se ejecuta el servicio cargado en ah, ejecuta 01h.
            cmp al, 49    ; Compara si el valor en el registro al es un '3'. al = 0dh, entonces ZF = 1, de lo contrario ZF = 0.
            je  lOpcion1    ; je -> if ZF = 1 then jump. Cerrar programa
            cmp al, 50    
            je  lOpcion2    
            cmp al, 51    
            je  lOpcion3
            cmp al, 52    
            je  lOpcion4
            cmp al, 53    
            je  lOpcion5
            cmp al, 54    
            je  lOpcion6
            cmp al, 55    
            je  lOpcion7
            cmp al, 56    
            je  lOpcion8
            cmp al, 57    
            je  lOpcion9
            jmp lOpcionIncorrecta1
        lOpcion1:
            call pOpcion1
            jmp lPrint1
        lOpcion2:
            call pOpcion2
            jmp lPrint1
        lOpcion3:
            call pOpcion3
            jmp lPrint1
        lOpcion4:
            call pOpcion4
            jmp lPrint1
        lOpcion5:
            call pOpcion5
            jmp lPrint1
        lOpcion6:
            call pOpcion6
            jmp lPrint1
        lOpcion7:
            call pOpcion7
            jmp lPrint1
        lOpcion8:
            call pOpcion8
            jmp lPrint1
        lOpcion9:
            call pOpcion9
            jmp lPrint1
        lOpcionIncorrecta1:
        mImprimirCadena errorDigitoNoValido
        mRepetirSaltoSiNoEs presioneEnter, lPrint1
        ret          ; retorna la direccion la llamada al procedimiento donde se llamo, y la asigna al registro ip, para seguir ejecutando instrucciones después de su llamada.
    pImprimirMensajeInicial endp

    ;---------------------------------------------------------
    pOpcion1 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        xor ax, ax
        mLimpiarPantalla
        mImprimirCadena opcion1
        mImprimirCadena preguntaGrado
        mLeerCaracter gradoFuncion ; guarda el caracter en 'AL'
        cmp al, 48
        jb lPrintError1 ; si al es más pequeño que 48
        cmp al, 53
        jg lPrintError1 ; si al es más grande que 53

        guardarGrado:
            sub al, 48
            mov gradoFuncion, al ; se guarda el valor del grado
            xor ah, ah
            xor cx, cx
            mov cx, ax
            ; Pedir coeficientes y guardarlos
            lciclo1:
                mImprimirCadena adios
                mImprimirCadena saltoLinea
            cmp cx, 0000
            LOOPNE lciclo1

        lPrintError1:
            mImprimirCadena saltoLinea
            mImprimirCadena errorDigitoNoValido
            mImprimirCadena saltoLinea
            mRepetirSaltoSiNoEs presioneEnter, lPrint1

        lAceptarEntrada:
            mRepetirSaltoSiNoEs presioneEnter, lSalirOpcion1
        lSalirOpcion1:
        ret
    pOpcion1 endp

    ;---------------------------------------------------------
    pOpcion2 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mLimpiarPantalla
        mImprimirCadena opcion2
        mRepetirSaltoSiNoEs presioneEnter, lSalirOpcion2
        lSalirOpcion2:
        ret
    pOpcion2 endp

    ;---------------------------------------------------------
    pOpcion3 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mLimpiarPantalla
        mImprimirCadena opcion3
        mRepetirSaltoSiNoEs presioneEnter, lSalirOpcion3
        lSalirOpcion3:
        ret
    pOpcion3 endp

    ;---------------------------------------------------------
    pOpcion4 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mImprimirCadena opcion4
        ret
    pOpcion4 endp

    ;---------------------------------------------------------
    pOpcion5 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mImprimirCadena opcion5
        ret
    pOpcion5 endp

    ;---------------------------------------------------------
    pOpcion6 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mImprimirCadena opcion6
        ret
    pOpcion6 endp

    ;---------------------------------------------------------
    pOpcion7 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mImprimirCadena opcion7
        ret
    pOpcion7 endp

    ;---------------------------------------------------------
    pOpcion8 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mImprimirCadena opcion8
        ret
    pOpcion8 endp

    ;---------------------------------------------------------
    pOpcion9 proc
    ;
    ; Procedimiento para la opcion 1
    ; Receives: --- 
    ; Returns: ---
    ;---------------------------------------------------------
        mLimpiarPantalla
        mImprimirCadena opcion9
        mRepetirSaltoSiNoEs presioneEnter, lSalir
        ret
    pOpcion9 endp

;------------------------
; etiqueta utilizada para cerrar el programa
;------------------------
lSalir: 
    ; Cuando se termina el programa siempre hay que mandar esto o .exit que es lo mismo
    mImprimirCadena adios
    mov al, 16h  ; retorno funcion main
    mov ah, 04Ch ; se carga en la parte alta el servicio 04Ch, devuelve el control al sistema, termina proceso
    int 21h ; se ejecuta el servicio cargado en ah, ejecuta 04Ch.    
    ; Recordar que la interrupcion 21h se utiliza para entradas y salidas, files, administracion de memoria y llamadas a funciones.

END lInicio
