#show <no-outline>: set heading(outlined: false)

#set table.cell(breakable: false)

#align(center + horizon)[
  = Estructura de Computadores <no-outline>
  == Práctica 1 <no-outline>

  #v(2em)

  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: none,
    align: left,
    [Alejandro Hita Garrido], [100581162], [grupo 80], [curso 2], [informática],
    [Hugo Vidal Martínez], [100582295], [grupo 80], [curso 2], [informática],
  )

  #v(20%)

  #outline(
    title: [Contenido],
  )
]

#pagebreak()
= `fill_puzzle`
#v(2em)

El funciónamiento se basa en un bucle que recorre los elementos del vector de
dos en dos. Esto significa que por cada iteración del bucle extraemos dos
elementos consecutivos del vector. Lo que hacemos a continuación es comprobar
que las coordenadas extraídas están dentro de la matriz. En el caso afirmativo
rellenamos esa posición de la matriz. En el caso contrario la función devuelve 0.
Finalmente, cuando el bucle acaba devolvemos 1.

```c
int fill_puzzle(char matrix[], int rows, int columns, const int vector[], int n) {
    int x;
    int y;

    while (n > 0) {
        // Guardamos las coordenadas
        x = vector[0];
        y = vector[1];

        // Si están fuera de la matriz devolvemos 0
        if (x >= rows) { return 0; }
        if (y >= columns) { return 0; }
        if (x < 0) { return 0; }
        if (y < 0) { return 0; }

        // Rellenamos la matriz
        matrix[x * columns + y] = 182;

        vector += 2;
        n -= 2;
    }

    return 1;
}
```

#pagebreak()
= `puzzle_print`
#v(2em)

La primera versión de esta función tenía como objetivo calcular la cantidad de
carácteres a imprimir para una matriz dada de dimensiones $n times m$ y
construir la cadena de texto en memoria para realizar una única llamada al
sistema al final de la función. Esto evita tener que imprimir cada símbolo de
manera individual y por lo tanto una llamada al sistema por cada uno. La
fórmula que permite calcular la cantidad de memoria necesaria es:
$("columnas" dot "filas" dot 2) + 1$.

Se multiplica por dos porque hay que contar los separadores de cada columna más
los saltos de línea y se suma uno porque es necesario añadir el byte cero al final.

```c
void puzzle_print(const char matrix[], int rows, int columns) {
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

        // Insertamos el salto de línea al final de la fila
        *buffer = '\n';
        buffer++;

        rows--;
    }

    *buffer = 0;
    printf("%s", string);
}
```

Sin embargo, cuando hemos probado a imprimir una matriz con algunos carácteres
de relleno, estos no se imprimen bien. Esto es porque el símbolo de relleno es
el 182 y como es mayor que 127 solo existe en ASCII extendido. Al imprimirlo
con la llamada al sistema `print_char` se imprime correctamente. Pero al
hacerlo con `print_string` se interpreta como `UTF-8` y al ser mayor que 127
se necesitan dos bytes para representar el símbolo.

Como no podemos cambiar el símbolo de relleno, la única solución que queda es
reservar más memoria para el texto. Sería necesario reservar memoria para una
matriz el doble de grande ya que tenemos que representar cada carácter con 2
bytes. Pero por motivos de simplicidad hemos decidido cambiar el diseño e
imprimir el texto símbolo a símbolo.

```c
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

        // Imprimimos el salto de línea al final de la fila
        printf("%c", '\n');

        rows--;
    }
}
```

#pagebreak()
= `search_puzzle`
#v(2em)

El objetivo de la función es comprobar que la palabra cabe de forma exacta y no
hay ningún carácter de relleno donde se quiera colocar la palabra. Si es así
devolverá 1. La primera comprobación se asegura de que la posición donde
insertar la palabra esté dentro de la matriz, si no es así devuelve 0.

Después comprueba que la palabra ocupe exactamente el espacio restante de la
fila desde la columna y hasta el final, si no es así devuelve 0.

El bucle comprueba que ninguna posición contenga el carácter de relleno 182,
avanzando el puntero de la matriz y reduciendo length en cada iteración.

Esta función asume que tanto `x` como `y` son valores positivos.

```c
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
        if (*matrix == 182) { return 0; }
        matrix++;
        length--;
    }

    return 1;
}
```

#pagebreak()
= `insert_puzzle`
#v(2em)

El objetivo de la función es insertar una palabra en una posición especificada
de la matriz. Si lo consigue devuelve 1, si no devuelve 0.

El primer paso consiste en comprobar si la palabra cabe mediante una llamada a
`search_puzzle`.

Una vez comprobado que la palabra cabe, se calcula la longitud que se va a
insertar y la posición correspondiente dentro de la matriz. A continuación se
avanza el puntero de la matriz a esa posición.

Finalmente, se ejecuta un bucle que, en cada iteración, sustituye el carácter
al que apunta el puntero de la matriz por el que apunta el puntero de string.
Después ambos punteros avanzan una posición y se reduce la longitud en una
unidad. El proceso se repite hasta insertar toda la palabra.

```c
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
```

#pagebreak()
= Pruebas
#v(2em)

Hemos implementado una función `init_matrix` la cual recibe la dirección de una
matriz y el número de elementos que tiene en total. Esta función sirve para
escribir un espacio en todos los elementos de la matriz. También se puede
utilizar para limpiar la matriz o dejarla vacía.

== `fill_puzzle`
Para probar esta función hemos elegido una matriz inicializada de dimensiones
arbitrarias. En este caso hemos seleccionado una de dimensiones $5 times 5$ pero
podría ser cualquier otra. Para cada prueba imprimimos la matriz antes y
después de llamar a la función `fill_puzzle` junto con el valor que devuelve.

No vamos a probar los casos en los que el número de elementos no es el adecuado
ya que no tenemos manera de comprobar esos datos y esperamos que siempre sean
correctos.

#table(
  columns: (auto, auto, auto, auto),
  stroke: 0.5pt + luma(150),
  table.header(
    [*Datos a introducir*], [*Descripción de la prueba*], [*Resultado esperado*], [*Resultado obtenido*]
  ),

  [
    Dos coordenadas válidas y repetidas. Por ejemplo el vector 2, 3, 2, 3.
  ],
  [
    Queremos ver si se puede escribir sobre otros carácteres de rellenos.
  ],
  [
    Nada raro, la misma coordenada se rellena dos veces y devuelve 1.
  ],
  [
    El esperado.
  ],

  [
    Una coordenada fuera del rango, por ejemplo, $(-3, 8)$.
  ],
  [
    Queremos ver lo que pasa cuando tenemos una coordenada fuera de las dimensiones
    de nuestra matriz.
  ],
  [
    Ninguna modificación a la matriz y que devuelva el número 0.
  ],
  [
    El esperado.
  ],
)

== `puzzle_print`
Nos hemos dado cuenta de que si utilizamos una palabra escrita entre comillas
hay algunos caracteres que hacen que la matriz no se imprima bien. La explicación,
que hemos encontrado es la misma que la dada en la sección `puzzle_print`.

```asm
.data
ejemplo: .string "cálculo"
```

#pagebreak()

== `search_puzzle`
Para las pruebas de esta función usaremos una matriz de dimensiones $2 times
4$.

#table(
  columns: (auto, auto, auto, auto),
  stroke: 0.5pt + luma(150),
  table.header(
    [*Datos a introducir*], [*Descripción de la prueba*], [*Resultado esperado*], [*Resultado obtenido*]
  ),

  [
    La palabra "abc" y la coordenada $(1, 1)$.
  ],
  [
    Buscar una palabra en una fila distinta de la primera, comenzando en una
    columna intermedia.
  ],
  [
    Devuelve 1 porque la palabra coincide exactamente con las columnas
    restantes de la fila.
  ],
  [
    El esperado.
  ],
  [ 
    La palabra "a" y la coordenada $(2, 0)$.
  ],
  [
    Introducir una coordenada de fila igual al número de filas.
  ],
  [
    Devuelve 0, porque la coordenada está fuera de la matriz.
  ],
  [
    El esperado.
  ],

  [
    La palabra "hola" y la coordenada $(2, 0)$.
  ],
  [
    Intentar escribir en las dos últimas columnas de la primera fila y en las
    dos primeras de la segunda.
  ],
  [
    Devuelve 0, porque la palabra no cabe en la primera fila.
  ],
  [
    El esperado.
  ],

  [
    La palabra "está" y la coordenada $(0, 0)$.
  ],
  [
    Comprobar el resultado de la función al introducir una palabra que contiene
    un carácter especial `UTF-8` como una letra con tilde o el carácter de
    relleno 182.
  ],
  [
    Devuelve 0, porque el carácter `á` se interpreta como dos bytes por lo que
    la longitud aumenta en 1 y no cabe (parece que ocupa 4 bytes pero realmente
    ocupa 5). Esta palabra habría que representarla con una codificación en la
    que el carácter especial se representa como un byte específico:
    ```asm
    string: 
      .ascii "est"
      .byte 225
      .byte 0
    ```
  ],
  [
    El esperado.
  ],
)

#pagebreak()

== `insert_puzzle`

Esta función se basa principalmente en la función `search_puzzle`, por lo que
si esta funcióna correctamente, `insert_puzzle` también lo va a hacer.


#table(
  columns: (auto, auto, auto, auto),
  stroke: 0.5pt + luma(150),
  table.header(
    [*Datos a introducir*], [*Descripción de la prueba*], [*Resultado esperado*], [*Resultado obtenido*]
  ),

  [
    La palabra "ABC" y la coordenada $(1, 1)$.
  ],
  [
    Insertar una palabra en la segunda fila y la segunda columna.
  ],
  [
    Devuelve 1 e inserta la palabra correctamente porque esta cabe en la
    posición solicitada.
  ],
  [
    `XXXX XABC`
  ],

  [
    La palabra "esá" y la coordenada $(0, 0)$.
  ],
  [
    Comprobar el resultado de la función al introducir una palabra que contiene
    un carácter especial UTF-8 como una letra con tilde o el carácter de
    relleno 182.
  ],
  [
    La palabra ocupa 4 bytes por lo que si cabe, pero el carácter especial esta
    dividido en dos bytes, por lo que la función no inserta el carácter
    especial `á` sino dos carácteres ASCII diferentes, que corresponden a cada
    byte de `á`.
  ],
  [
    `esÃ¡ XXXX`
  ],
)
