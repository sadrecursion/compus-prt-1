.data

m1_data: .space 25 # 5x5

.align 2
m1_fill:
    .word 1, 1
    .word 3, 3

.text

init_matrix:
    # a0 = dirección de la matriz
    # a1 = número de elementos

    li t0, 32

init_matrix_loop:
    beqz a1, init_matrix_end

    sb t0, 0(a0)
    addi a0, a0, 1
    addi a1, a1, -1

    j init_matrix_loop

init_matrix_end:
    jr ra

puzzle_print:
    # a0 = dirección de la matriz
    # a1 = filas
    # a2 = columnas

    # t0 = número total de columnas
    # t1 = longitud del string
    # t2 = dirección del string
    # t3 = temporal genérico
    # t4 = separador de columna
    # t5 = salto de línea

    mv t0, a2

    # Calculamos la longitud
    mul t1, a1, a2
    slli t1, t1, 1
    addi t1, t1, 1

    # Reservamos espacio en la pila
    sub sp, sp, t1
    mv t2, sp

    li t4, 59
    li t5, 10

puzzle_print_row:
    beqz a1, puzzle_print_end

    # Insertamos el primer elemento de la fila
    lb t3, 0(a0)
    sb t3, 0(t2)

    addi a0, a0, 1
    addi t2, t2, 1

puzzle_print_column:
    li t3, 1
    beq a2, t3, puzzle_print_row_end

    # Insertamos el separador de columna
    sb t4, 0(t2)
    addi t2, t2, 1

    # Insertamos el siguiente elemento de la fila
    lb t3, 0(a0)
    sb t3, 0(t2)
    addi a0, a0, 1
    addi t2, t2, 1

    addi a2, a2, -1

    j puzzle_print_column

puzzle_print_row_end:
    # Restauramos el número total de columnas
    mv a2, t0

    # Insertamos el salto de línea
    sb t5, 0(t2)
    addi t2, t2, 1

    addi a1, a1, -1

    j puzzle_print_row

puzzle_print_end:
    # Insertamos el 0
    sb zero, 0(t2)

    # Imprimimos el string
    li a7, 4
    mv a0, sp
    ecall

    # Restauramos la pila
    add sp, sp, t1
    jr ra

fill_puzzle:
    # a0 = dirección de la matriz
    # a1 = filas
    # a2 = columnas
    # a3 = dirección del vector
    # a4 = número de elementos del vector

    li t0, 35

fill_puzzle_loop:
    beqz a4, fill_puzzle_true

    lw t1, 0(a3)
    lw t2, 4(a3)
    addi a3, a3, 8

    bge t1, a1, fill_puzzle_false
    bge t2, a2, fill_puzzle_false

    mul t3, t1, a2
    add t3, t3, t2
    add t3, t3, a0

    sb t0, 0(t3)

    addi a4, a4, -2
    j fill_puzzle_loop

fill_puzzle_false:
    li a0, 0
    jr ra

fill_puzzle_true:
    li a0, 1
    jr ra

main:
    # Inicializa la matriz 1
    la a0, m1_data
    la a1, 25
    jal ra, init_matrix

    # Imprime la matriz 1
    la a0, m1_data
    li a1, 5
    li a2, 5
    jal ra, puzzle_print

    # Rellenamos la matriz 1
    la a0, m1_data
    li a1, 5
    li a2, 5
    la a3, m1_fill
    li a4, 4
    jal ra, fill_puzzle

    # Imprime la matriz 1
    la a0, m1_data
    li a1, 5
    li a2, 5
    jal ra, puzzle_print

exit:
    li a7, 10
    ecall
