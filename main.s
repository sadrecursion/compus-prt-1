.data

m1_data: .space 25 # 5x5
.align 2
m1_fill:
    .word 1, 1
    .word 3, 3

s1: .string "casa"
s2: .string "dos"

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

    # Guardamos las coordenadas
    lw t1, 0(a3)
    lw t2, 4(a3)
    addi a3, a3, 8

    # Si están fuera de la matriz devolvemos 0
    bge t1, a1, fill_puzzle_false
    bge t2, a2, fill_puzzle_false

    # Calculamos la posición
    mul t3, t1, a2
    add t3, t3, t2
    add t3, t3, a0

    # Rellenamos la matriz
    sb t0, 0(t3)

    addi a4, a4, -2
    j fill_puzzle_loop

fill_puzzle_false:
    # Devolvemos 0
    li a0, 0
    jr ra

fill_puzzle_true:
    # Devolvemos 1
    li a0, 1
    jr ra

search_puzzle_return_zero:
insert_puzzle_return_zero:
    # Devolvemos 0 y restauramos la pila
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
    bge s4, s1, search_puzzle_return_zero
    bge s5, s2, search_puzzle_return_zero

    # Obtenemos la longitud de la palabra
    mv a0, s3
    jal ra, length

    # Comprobamos que la palabra cabe de manera exacta
    sub t0, s2, s5
    bne a0, t0, search_puzzle_return_zero

    # Calculamos la posición
    mul t0, s4, s2
    add t0, t0, s5

    # Avanzamos la dirección de la matriz a la posición
    add s0, s0, t0

    # Comprobamos que no hayan caracteres de relleno
    li t1, 182

search_puzzle_while_1:
    beqz a0, search_puzzle_while_1_end

    # Si la posicion actual contiene un caracter de relleno devuelve 0
    lbu t2, 0(s0)
    beq t2, t1, search_puzzle_return_zero

    addi s0, s0, 1
    addi a0, a0, -1

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

    # Si la palabra no cabe devolvemos 0
    jal ra, search_puzzle
    beqz a0, insert_puzzle_return_zero

    # Calculamos la longitud
    sub t0, s2, s5

    # Calculamos la posición
    mul t1, s4, s2
    add t1, t1, s5

    # Avanzamos la matriz a la posición
    add s0, s0, t1

insert_puzzle_loop:
    beqz t0, insert_puzzle_loop_end

    # Rellenamos la matriz
    lbu t2, 0(s3)
    sb t2, 0(s0)

    addi s0, s0, 1
    addi s3, s3, 1
    addi t0, t0, -1

    j insert_puzzle_loop

insert_puzzle_loop_end:
    # Devolvemos 1
    li a0, 1
    j insert_puzzle_restore

print_new_line:
    li a0, 10
    li a7, 11
    ecall
    jr ra

print_search_result:
    # a0 = resultado
    li a7, 1
    ecall

    li a0, 10
    li a7, 11
    ecall

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
    jal ra, print_new_line

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
    jal ra, print_new_line

    # Comprobar si caben algunas palabras
    la a0, m1_data
    li a1, 5
    li a1, 5
    la a3, s2
    li a4, 1
    li a5, 2
    jal ra, search_puzzle
    jal ra, print_search_result

    # Insertamos una palabra
    la a0, m1_data
    li a1, 5
    li a1, 5
    la a3, s2
    li a4, 1
    li a5, 2
    jal ra, insert_puzzle

    # Imprime la matriz 1
    la a0, m1_data
    li a1, 5
    li a2, 5
    jal ra, puzzle_print
    jal ra, print_new_line

exit:
    li a7, 10
    ecall
