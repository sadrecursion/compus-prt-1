//usr/bin/env gcc "$0" -o /tmp/main; /tmp/main; exit
#include <stdio.h>
#include <string.h>

// Se asume en todas las funciones que todos los números son positivos. Es por
// eso que se utiliza int en lugar de unsigned int.

#define FILL_CHAR '#'

bool search_puzzle(const char matrix[], int rows, int columns, const char string[], int x, int y) {
    if (x >= rows || y >= columns) { return false; }

    int length = strlen(string);
    if (columns - y < length) { return false; }

    int i = 0;
    int j = x * columns;
    while (i < columns) {
        if (matrix[j + y + i] == FILL_CHAR) { return false; }
        i++;
    }

    return true;
}

bool insert_puzzle(char matrix[], int rows, int columns, const char string[], int x, int y) {
    if (!search_puzzle(matrix, rows, columns, string, x, y)) { return false; }

    int i = 0;
    int j = x * columns;
    int length = columns - y;
    while (i < length) {
        matrix[j + y + i] = string[i];
        i++;
    }

    return true;
}

// Esta función asume que n es un número par positivo. En caso de ser impar se
// puede producir un UB en la última iteración. En caso de no poder asumir que
// n es un número válido sería necesario añadir una comprobación.
bool fill_puzzle(char matrix[], int rows, int columns, const int vector[], int n) {
    int i = 0;
    while (i < n) {
        int x = vector[i++];
        int y = vector[i++];
        if (x >= rows || y >= columns) { return false; }
        matrix[x * columns + y] = FILL_CHAR;
    }

    return true;
}

// HECHA
void puzzle_print(const char matrix[], int rows, int columns) {
    int row = 0;
    int column = 1;
    int matrix_index = 0;
    int buffer_index = 0;

    int buffer_size = (rows * columns * 2) + 1;
    char buffer[buffer_size];

    while (row < rows) {
        column = 1;
        buffer[buffer_index++] = matrix[matrix_index];
        while (column < columns) {
            buffer[buffer_index++] = ';';
            buffer[buffer_index++] = matrix[matrix_index + column];
            column++;
        }

        buffer[buffer_index++] = '\n';
        matrix_index += columns;
        row++;
    }

    buffer[buffer_index] = 0;
    printf("%s", buffer);
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
