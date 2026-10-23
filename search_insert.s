.text

search_puzzle_return_zero:
	# Devuelve 0 y restaura la pila
	li a0, 0
	j search_puzzle_restore

search_puzzle:
    addi sp, sp, -28
	sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

	# matrix -> s0
	# rows -> s1
	# columns -> s2
	# string -> s3
	# x -> s4
	# y -> s5
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

	# Avanzamos matrix a la posición
	add s0, s0, t1

	# Comprobamos que desde la posicion quepa la palabra y no haya caracteres de relleno
	li t1, 0
	li t2, 182       # Caracter de relleno

search_puzzle_while_1:
	ble t0, t1, search_puzzle_while_1_end
	lbu t3, 0(s0)    # Si la posicion actual contiene un caracter de relleno devuelve 0
	beq t3, t2, search_puzzle_return_zero

	addi s0, s0, 1   # matrix++
	addi t0, t0, -1  # length--

	j search_puzzle_while_1
search_puzzle_while_1_end:

	li a0, 1   # Devuelve 1

	# Restauramos la pila
search_puzzle_restore:
	lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

	jr ra


insert_puzzle_return_zero:
	# Devuelve 0 y restaura la pila
	li a0, 0
	j insert_puzzle_restore 

insert_puzzle:
    addi sp, sp, -28
	sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
	# matrix -> s0
	# rows -> s1
	# columns -> s2
	# string -> s3
	# x -> s4
	# y -> s5
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
	
	# Restauramos la pila
insert_puzzle_restore:
	lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

	jr ra
