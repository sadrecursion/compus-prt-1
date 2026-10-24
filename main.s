.data

m1_data: .space 25 # 5x5

.align 2
m1_fill:
    .word 1, 1
    .word 3, 3

s1: .string "example"

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

    # s0 = dirección de la matriz
    # s1 = contador de filas
    # s2 = contador de columnas
    # s3 = número total de columnas

    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a2

puzzle_print_row:
    beqz s1, puzzle_print_end

    # Imprimimos el primer elemento de la fila
    lbu a0, 0(s0)
    addi s0, s0, 1
    li a7, 11
    ecall

puzzle_print_column:
    li t0, 1
    ble s2, t0, puzzle_print_row_end

    # Imprimimos el separador de columna
    li a0, 59
    li a7, 11
    ecall

    # Imprimimos el siguiente elemento de la fila
    lbu a0, 0(s0)
    addi s0, s0, 1
    li a7, 11
    ecall

    addi s2, s2, -1

    j puzzle_print_column

puzzle_print_row_end:
    # Restauramos el contador de columnas
    mv s2, s3

    # Imprimimos el salto de línea
    li a0, 10
    li a7, 11
    ecall

    addi s1, s1, -1

    j puzzle_print_row

puzzle_print_end:
    # Restauramos la pila
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
    jr ra

fill_puzzle:
    # a0 = dirección de la matriz
    # a1 = filas
    # a2 = columnas
    # a3 = dirección del vector
    # a4 = número de elementos del vector

    li t0, 182

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
