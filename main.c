//usr/bin/env gcc "$0" -o /tmp/main; /tmp/main; exit
#include <stdio.h>
#include <string.h>

// Se asume en todas las funciones que todos los números son positivos. Es por
// eso que se utiliza int en lugar de unsigned int.

#define FILL_CHAR '#'

int search_puzzle(const char matrix[], int rows, int columns, const char string[], int x, int y) {
    // Devolvemos 0 si las coordenadas están fuera de la matriz
    if (x >= rows || y >= columns) { return 0; }

    // Comprobamos que la palabra cabe de manera exacta
    int length = strlen(string);
    if (columns - y != length) { return 0; }

    // Comprobamos que no haya ningún símbolo de relleno por el camino
    int position = (x * columns) + y;
    matrix += position;
    while (length > 0) {
        if (*matrix == FILL_CHAR) { return 0; }
        matrix++;
        length--;
    }

    return 1;
}

int insert_puzzle(char matrix[], int rows, int columns, const char string[], int x, int y) {
    // Si la palabra no cabe devolvemos 0
    if (!search_puzzle(matrix, rows, columns, string, x, y)) { return 0; }

    // Insertamos la palabra
    int length = columns - y;
    int position = (x * columns) + y;
    matrix += position;
    while (length > 0) {
        *matrix = *string;
        matrix++;
        string++;
        length--;
    }

    return 1;
}

// HECHA
// Esta función asume que n es un número par positivo. En caso de ser impar se
// puede producir un UB en la última iteración. En caso de no poder asumir que
// n es un número válido sería necesario añadir una comprobación.
int fill_puzzle(char matrix[], int rows, int columns, const int vector[], int n) {
    int x;
    int y;

    while (n > 0) {
        // Guardamos las coordenadas
        x = vector[0];
        y = vector[1];
        vector += 2;

        // Si están fuera de la matriz devolvemos 0
        if (x >= rows) { return 0; }
        if (y >= columns) { return 0; }

        // Rellenamos la matriz
        matrix[x * columns + y] = FILL_CHAR;

        // Decrementamos el número de elementos
        n -= 2;
    }

    return 1;
}

// HECHA
void puzzle_print(const char matrix[], int rows, int columns) {
    // Guardamos el número total de columnas
    const int total_columns = columns;

    // Recorremos las filas
    while (rows > 0) {
        // Siempre imprimimos directamente el primer elemento de cada fila
        printf("%c", *matrix);
        matrix++;

        // Recorremos las columnas
        while (columns > 1) {
            // Imprimimos el separador de columna
            printf("%c", ';');

            // Imprimimos el siguiente elemento de la fila
            printf("%c", *matrix);
            matrix++;

            columns--;
        }

        // Restauramos el número de columnas
        columns = total_columns;

        // Imprimimos el salto de línea la final de la fila
        printf("%c", '\n');

        rows--;
    }
}

// HECHA
void puzzle_print_buffered(const char matrix[], int rows, int columns) {
    // Guardamos el número total de columnas
    const int total_columns = columns;

    // Calculamos la longitud necesaria para el texto que queremos imprimir y
    // reservamos ese espacio en la pila
    int capacity = (rows * columns * 2) + 1;
    char string[capacity];
    char* buffer = string;

    // Recorremos las filas
    while (rows > 0) {
        // Siempre insertamos directamente el primer elemento de cada fila
        *buffer = *matrix;
        buffer++;
        matrix++;

        // Recorremos las columnas
        while (columns > 1) {
            // Insertamos el separador de columna
            *buffer = ';';
            buffer++;

            // Insertamos el siguiente elemento de la fila
            *buffer = *matrix;
            buffer++;
            matrix++;

            columns--;
        }

        // Restauramos el número de columnas
        columns = total_columns;

        // Insertamos el salto de línea la final de la fila
        *buffer = '\n';
        buffer++;

        rows--;
    }

    *buffer = 0;
    printf("%s", string);
}

int main() {
    char matrix1[25];
    memset(matrix1, ' ', sizeof(matrix1));

    printf("\n");
    puzzle_print(matrix1, 5, 5);

    const int fill[4] = {1, 1, 3, 3};
    fill_puzzle(matrix1, 5, 5, fill, sizeof(fill));

    printf("\n");
    puzzle_print(matrix1, 5, 5);

    printf("\n%d", search_puzzle(matrix1, 5, 5, "abc", 1, 2));
    insert_puzzle(matrix1, 5, 5, "abc", 1, 2);
    printf("\n");
    puzzle_print(matrix1, 5, 5);

    return 0;
}
