.text

puzzle_print:
    ; a0 = puntero a la matriz
    ; a1 = filas
    ; a2 = columnas

    ; t0 = capacidad del buffer
    ; t1 = primera dirección del buffer
    ; t2 = contador de fila
    ; t3 = contador de columna
    ; t4 = temporal para copiar un byte
    ; t5 = separador de columna
    ; t6 = salto de línea

    ; Calculamos los caracteres a imprimir utilizando las dimensiones de la
    ; matriz. Esto se hace con la fórmula (2 * columnas * filas) + 1.
    mul t0, a1, a2
    slli t0, t0, 1 ; multiplicamos por 2
    addi t0, t0, 1 ; un byte extra para el 0

    sub sp, sp, t0 ; reservamos el buffer
    mv t1, sp      ; guardamos la primera dirección del buffer

    li t2, 0       ; contador de fila
    li t5, 59      ; separador de columna
    li t6, 10      ; salto de línea

puzzle_print_row:
    bge t2, a1, puzzle_print_end ; t2 >= a1

    li t3, 1       ; columna actual

    lb t4, 0(a0)   ; cargamos el primer byte de la fila
    sb t4, 0(t1)   ; cargamos el byte en el buffer

    addi a0, a0, 1 ; dirección de la matriz + 1
    addi t1, t1, 1 ; dirección del buffer + 1

puzzle_print_column:
    bge t3, a2, puzzle_print_row_end ; t3 >= a2

    sb t5, 0(t1)   ; cargamos el separador en el buffer
    addi t1, t1, 1 ; dirección del buffer + 1

    lb t4, 0(a0)   ; cargamos el siguiente byte de la matriz
    sb t4, 0(t1)   ; cargamos el byte en el buffer

    addi a0, a0, 1 ; dirección de la matriz + 1
    addi t1, t1, 1 ; dirección del buffer + 1
    addi t3, t3, 1 ; contador de columna + 1

    j puzzle_print_column

puzzle_print_row_end:
    sb t6, 0(t1)   ; cargamos el salto de línea en el buffer

    addi t1, t1, 1 ; dirección del buffer + 1
    addi t2, t2, 1 ; contador de fila + 1

    j puzzle_print_row

puzzle_print_end:
    sb zero, 0(t1) ; cargamos el byte 0 en el buffer

    li a7, 4       ; print string
    mv a0, sp      ; la dirección del buffer sigue estando en sp
    ecall

    ; Restauramos la pila teniendo en cuenta que la llamada anterior no debería
    ; de modificar t0.
    add sp, sp, t0
    ret
