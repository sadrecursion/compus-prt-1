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

void puzzle_print(const char matrix[], int rows, int columns) {
    int i = 0;
    int j = 0;
    int k = 0;

    while (i < rows) {
        k = i * columns;
        j = 0;

        while (j < columns) {
            printf("%c", matrix[k + j]);

            if (j != columns - 1) {
                printf(";");
            }

            j++;
        }

        printf("\n");
        i++;
    }
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
