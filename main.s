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

search_puzzle_return_zero:
insert_puzzle_return_zero:
    # Devuelve 0 y restaura la pila
    li a0, 0

search_puzzle_restore:
insert_puzzle_restore:
	# Restaura la pila
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

    jr ra

search_puzzle:
    # a0 = dirección de la matriz
    # a1 = filas
    # a2 = columnas
    # a3 = string
    # a4 = coordenada x
    # a5 = coordenada y

    # s0 = dirección de la matriz
    # s1 = filas
    # s2 = columnas
    # s3 = string
    # s4 = coordenada x
    # s5 = coordenada y
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5

    # Devuelve 0 si las coordenadas están fuera de la matriz
    bge s4, s1, search_puzzle_return_zero    # x >= rows
    bge s5, s2, search_puzzle_return_zero    # y >= columns

    # Comprobamos que la palabra cabe de manera exacta
    # length = strlen(string) -> t0
    mv a0, s3
    jal ra, strlen
    mv t0, a0

    # if (columns - y != length) {return 0}
    sub t1, s2, s5
    bne t0, t1, insert_puzzle_return_zero

    # position = x * columns + y -> t1
    mul t1, s4, s2   # position = x * columns
    add t1, t1, s5   # position = position + y

    # Avanzamos la dirección de la matriz a la posición
    add s0, s0, t1

    # Comprobamos que desde la posición quepa la palabra y no haya caracteres de relleno
    li t1, 0
    li t2, 182

search_puzzle_while_1:
    ble t0, t1, search_puzzle_while_1_end
    lbu t3, 0(s0)    # Si la posicion actual contiene un caracter de relleno devuelve 0
    beq t3, t2, search_puzzle_return_zero

    addi s0, s0, 1   # matrix++
    addi t0, t0, -1  # length--

    j search_puzzle_while_1

search_puzzle_while_1_end:
    # Devuelve 1 y restaura la pila
    li a0, 1

	j search_puzzle_restore

insert_puzzle:
    # a0 = dirección de la matriz
    # a1 = filas
    # a2 = columnas
    # a3 = string
    # a4 = coordenada x
    # a5 = coordenada y

    # s0 = dirección de la matriz
    # s1 = filas
    # s2 = columnas
    # s3 = string
    # s4 = coordenada x
    # s5 = coordenada y
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5

    # Si la palabra no cabe se devuelve 0
    jal ra, search_puzzle     # Los parametros vienen en orden

    # if (!search_puzzle) {return 0}
    li t0, 0
    beq a0, t0, insert_puzzle_return_zero

    # length = columns - y -> t0
    sub t0, s2, s5

    # position = x * columns + y -> t1
    mul t1, s4, s2   # position = x * columns
    add t1, t1, s5   # position = position + y
    # Avanzamos matrix a la posición
    add s0, s0, t1

    # while (length > 0)
    li t2, 0

insert_puzzle_while_1:
    ble t0, t2, insert_puzzle_while_1_end
    # Añadimos el byte del string correspondiente a la matriz
    lbu t3, 0(s3)
    sb t3, 0(s0)

    addi s0, s0, 1   # matrix++
    addi s3, s3, 1   # string++
    addi t0, t0, -1  # length--

    j insert_puzzle_while_1

insert_puzzle_while_1_end:

    # Devuelve 1
    li a0, 1
    
	j insert_puzzle_restore

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
