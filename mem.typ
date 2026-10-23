#show <no-outline>: set heading(outlined: false)

#align(center)[
  = Estructura de Computadores <no-outline>
  == Práctica 1 <no-outline>

  #v(2em)

  Alejandro Hita Garrido \
  Hugo Vidal Martínez
]

#pagebreak()
#outline(
  title: [Contenido],
)

#pagebreak()
= Función `fill_puzzle`
#v(2em)

Esta función asume que `n` es un número par positivo. En caso de ser impar se
accede a una dirección de memoria que se encuentra fuera del vector. En caso de
no poder asumir que `n` siempre es un número par es necesario añadir una
comprobación.

```c
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
        matrix[x * columns + y] = 182;

        // Decrementamos el número de elementos
        n -= 2;
    }

    return 1;
}
```

#pagebreak()
= Función `puzzle_print`
#v(2em)

La primera versión de esta función tenía como objetivo calcular la cantidad de
caracteres a imprimir para una matriz dada de dimensiones $n times m$ y
construir la cadena de texto en memoria para realizar una única llamada al
sistema al final de la función. Esto evita tener que imprimir cada símbolo de
manera individual y por lo tanto una llamada al sistema por cada uno. La
fórmula que permite calcular la cantidad de memoria necesaria es $("columnas"
dot "filas" dot 2) + 1$.

Sin embargo, cuando hemos probado a imprimir una matriz con algunos caracteres
de relleno, estos no se imprimen bien. Esto se debe a que el símbolo de relleno
es el 182 y solo existe en ASCII extendido. Al imprimirlo con la llamada al
sistema `print_char (11)` se imprime correctamente. Pero al hacerlo con la
llamada `print_string (4)` se interpreta como `UTF-8` y en este caso el 182 se
representa con 2 bytes.

Por motivos de simplicidad hemos decidido cambiar el diseño e imprimir el texto
símbolo a símbolo.

```c
void puzzle_print(const char matrix[], int rows, int columns) {
    // Guardamos el número total de columnas
    const int total_columns = columns;

    // Recorremos las filass
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
```

#pagebreak()
= Función `search_puzzle`
#v(2em)

```c
int search_puzzle(const char matrix[], int rows, int columns, const char string[], int x, int y) {
    // Devolvemos 0 si las coordenadas están fuera de la matriz
    if (x >= rows || y >= columns) { return 0; }
    if (y >= columns) { return 0; }

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
```

#pagebreak()
= Función `insert_puzzle`
#v(2em)

```c
int insert_puzzle(char matrix[], int rows, int columns, const char string[], int x, int y) {
    // Si la palabra no cabe devolvemos 0
    if (!search_puzzle(matrix, rows, columns, string, x, y)) { return 0; }

    // Insertamos la palabra
    int position = (x * columns) + y;
    int length = columns - y;
    while (length > 0) {
        *matrix = *string;
        matrix++;
        string++;
        length--;
    }

    return 1;
}
```
