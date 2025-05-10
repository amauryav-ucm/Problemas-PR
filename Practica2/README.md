# Practica 2: Producción de alimentos

## MiniZinc

Para resolver el problema se usan tres matrices de vars, una que dice cuánto se ha comprado en cada mes de cada aceite, una que dice cuánto se ha refinado en cada mes de cada aceite, y una que dice cuánto hay al inicio de cada mes de cada aceite en los almacenes, por lo que la primera fila contiene las cantidades iniciales, y existe una séptima fila que dice cuanto hay al inicio de julio, o lo que es lo mismo, al final de junio.

```
array[1..nM, 1..nA] of var 0..MaxR : refinado;
array[1..nM, 1..nA] of var 0..MCAP+MaxR : comprado;
array[1..nM+1, 1..nA] of var 0..MCAP : almacen;
```

### `aceite-sat.mzn`

Las restricciones de la primera versión son bastante sencillas y están explicadas en el código. Esta versión solo busca una solución que cumpla las restricciones y no optimiza nada

Usando como entrada el fichero `data.dzn` resolutor **COIN-BC** se obtuvo el siguiente resultado.

```
refinado =
[|  87,  59,  0,   0, 250
 | 159,  41,  0, 250,   0
 |   0, 200,  0, 250,   0
 | 199,   0, 49, 201,   0
 |   0, 200,  0, 250,   0
 |   0, 200,  0, 250,   0
 |];
comprado =
[|   0,   0, 0,   0,   0
 |   0,   0, 0, 451,   0
 |   0,   0, 0,   0, 200
 |   0,   0, 0,   0,   0
 |   0,   0, 0,   0,   0
 | 396, 650, 0, 700,   0
 |];
almacen =
[| 500, 500, 500, 500, 500
 | 413, 441, 500, 500, 250
 | 254, 400, 500, 701, 250
 | 254, 200, 500, 451, 450
 |  55, 200, 451, 250, 450
 |  55,   0, 451,   0, 450
 | 451, 450, 451, 450, 450
 |];
beneficio = 125890;
----------
Finished in 197msec.
```

### `aceite-opt.mzn`

La segunda versión, es igual a la primera pero busca la solución con el máximo beneficio posible. Ejecutandolo con el resolutor **COIN-BC** y la entrada `data.dzn` se obtiene el siguiente resultado.

```
refinado =
[| 200,   0, 50, 200,   0
 |   0, 200,  0,   0, 250
 | 100, 100,  0,  50, 200
 | 159,  41,  0, 250,   0
 |  41, 159,  0,   0, 250
 | 159,  41,  0, 250,   0
 |];
comprado =
[|   0,   0, 0,   0,   0
 |   0,   0, 0,   0,   0
 |   0,   0, 0,   0,   0
 |   0,   0, 0,   0,   0
 |   0,   0, 0,   0, 650
 | 609, 491, 0, 700,   0
 |];
almacen =
[| 500, 500, 500, 500, 500
 | 300, 500, 450, 300, 500
 | 300, 300, 450, 300, 250
 | 200, 200, 450, 250,  50
 |  41, 159, 450,   0,  50
 |   0,   0, 450,   0, 450
 | 450, 450, 450, 450, 450
 |];
beneficio = 132340;
_objective = 132340;
----------
==========
Finished in 191msec.
```

### `aceite-ext.mzn`

En la tercera versión se incluen las cuatro restricciones adicionales propuestas en el enunciado, extendiendo el fichero `aceite-opt.mzn`.

Para la primera, se creó un array **K** que contiene para cada mes, cuál es el mínimo de aceites distintos que se deben usar, y se añadió la restricción.

```
array[1..nM] of 0..nA : K;
constraint forall (mes in 1..nM) (count (aceite in 1..nA) (refinado[mes, aceite] > 0) >= K[mes]);
```

Para la segunda, se creo una matriz **T**, que contiene para cada mes, para cada aceite, cuál es el mínimo que se debe usar si se usa, y tenemos la restricción que dice que para cada y mes y cada aceite, o no se usa el aceite, o se usa al menos la cantidad requerida

```
array[1..nM, 1..nA] of int : T;
constraint forall (mes in 1..nM, aceite in 1..nA) (refinado[mes, aceite] = 0 \/ refinado[mes, aceite] >= T[mes, aceite]);
```

Para la tercera, se ha creado la matriz **incompatible**, que guarda, para cada aceite, con cuales de los demás es incompatible, lo que la convierte en una matriz simétrica, y con todos sus valores en a diagonal iguales a cero. Por ejemplo para decir que si usamos el aceite ANV 1 o el aceite ANV 2 en un cierto mes, entonces no podemos usar ni el VEG 2 ni el ANV3 ese mes, tenemos la siguiente matriz.

```
incompatible = [| 0, 0, 0, 0, 0
                | 0, 0, 1, 1, 0
                | 0, 1, 0, 0, 1
                | 0, 1, 0, 0, 1
                | 0, 0, 1, 1, 0
                |];
```

Y se añade la restricción, que dice que para cada mes, para cada pareja de aceites, si son incompatibles, entonces al menos uno de los dos debe no usarse (cantidad refinada igual a cero), la implicación se ha convertido en un "or".

```
array[1..nA, 1..nA] of 0..1 : incompatible;
constraint forall (mes in 1..nM) (forall (aceite1 in 1..nA, aceite2 in 1..nA) (incompatible[aceite1, aceite2] = 0 \/ refinado[mes, aceite1] = 0 \/ refinado[mes, aceite2] = 0));
```

Para la última restricción, se creó la matriz **requerido**, que guarda para cada aceite, que aceites son requeridos si se usa, esta no es necesariamente simétrica. Por ejemplo para decir que si usamos el aceite ANV 3 entonces debemos usar VEG 1 ese mes, tenemos la siguiente matriz.

```
requerido = [| 0, 0, 0, 0, 0
             | 0, 0, 0, 0, 0
             | 0, 0, 0, 0, 0
             | 0, 0, 0, 0, 0
             | 1, 0, 0, 0, 0
             |];
```

Y se añade la restricción que nos dice que para cada mes, para cada pareja de aceites _aceite1_ y _aceite2_, si _aceite1_ rquiere al _aceite2_, entonces si se usa el _aceite1_, entonces también se usa el _aceite2_. ambas implicaciones se han convertido en condiciones "or".

```
constraint forall (mes in 1..nM) (forall (aceite1 in 1..nA, aceite2 in 1..nA) (requerido[aceite1, aceite2] = 0 \/ refinado[mes, aceite1] = 0 \/ refinado[mes, aceite2] > 0));
```

Se ha dejado la versión original en el fichero `aceite.mzn`, y se ha creado una nueva versión con las extensiones en el fichero `aceite-ext.mzn`.

Ejecutando con el resolutor **COIN-BC** y la entrada `data-ext.dzn`, se obtiene el siguiente resultado.

```
refinado =
[|  11, 189,  0,   0, 250
 | 200,   0, 50, 200,   0
 |  11, 189,  0,   0, 250
 | 200,   0, 50, 200,   0
 | 160,   0,  0, 250,   0
 | 160,   0,  0, 250,   0
 |];
comprado =
[|   0,   0,  0,   0,   0
 |   0,   0,  0, 150,   0
 |   0,   0,  0,   0,   0
 |   0,   0, 50,   0,   0
 |  82,   0,  0,   0, 450
 | 610, 328,  0, 700,   0
 |];
almacen =
[| 500, 500, 500, 500, 500
 | 489, 311, 500, 500, 250
 | 289, 311, 450, 450, 250
 | 278, 122, 450, 450,   0
 |  78, 122, 450, 250,   0
 |   0, 122, 450,   0, 450
 | 450, 450, 450, 450, 450
 |];
beneficio = 126740;
_objective = 126740;
----------
==========
Finished in 2s 34msec.
```

## SMT

Para resolver el problema con SMT se ha usado la API de **z3py**. Todas las versiones reciben como primer argumento un fichero JSON que contiene los datos de entrada y como segundo argumento opcional un fichero para escribir la salida. Si no se indica se mostrará por stdout.

### `aceite-sat.py`

La primera versión, contenida en el fichero `aceite.py` solo busca una solución que cumpla todas las restricciones iniciales. Todas las restricciones son inecuaciones lineales y arriba de cada una aparece un comentario indicando a que restricción en formato MiniZinc equivalen.

Ejecutando el script con el fichero `data.json` como entrada se obtiene la siguiente salida.

```
|COMPRAS   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |    0|    0|    0|    0|    0|
|Febrero   |    0|    0|    0|    0|    0|
|Marzo     |    0|    0|    0|    0|  400|
|Abril     |    0|  100|    0|    0|    0|
|Mayo      |    0|    0|    0|  250|    0|
|Junio     |  150|  450|    0|  650|    0|

|REFINADO  |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |    0|  200|    0|    0|  250|
|Febrero   |    0|  200|    0|  250|    0|
|Marzo     |  200|    0|   50|  200|    0|
|Abril     |    0|  200|    0|   50|  200|
|Mayo      |    0|    0|    0|  250|    0|
|Junio     |    0|    0|    0|  200|    0|

|ALMACEN   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Inicial   |  500|  500|  500|  500|  500|
|Enero     |  500|  300|  500|  500|  250|
|Febrero   |  500|  100|  500|  250|  250|
|Marzo     |  300|  100|  450|   50|  650|
|Abril     |  300|    0|  450|    0|  450|
|Mayo      |  300|    0|  450|    0|  450|
|Junio     |  450|  450|  450|  450|  450|

Beneficio: 100000
```

### `aceite-opt.py`

Esta versión intenta optimizar el número de aceites distintos usados cada mes, para ello hemos añadido una restricción suave para cada pareja mes-aceite, que dice que el aceite de ese tipo usado ese mes debe ser cero, entonces el resolutor intentará hacer que se cumplan el máximo número de ellas posibles, así minimizando la media de aceites usados cada mes.

```
for mes in range(nM):
    for aceite in range(nA):
        s.add_soft(refinado[mes][aceite] == 0)
```

Ejecutando el script con el fichero `data.json` como entrada, después de un tiempo considerable pero aceptable, se obtiene la siguiente salida, con una media de 1.67 aceites usados cada mes.

```
|COMPRAS   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |    1|    0|    0|    0|    0|
|Febrero   |    0|    0|  198|    0|    0|
|Marzo     |    0|    0|    0|    0|  277|
|Abril     |    1|    0|    0|    0|    0|
|Mayo      |    0|    0|    0|    0|  184|
|Junio     |  308|  350|    2|  700|    0|

|REFINADO  |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |    0|  200|    0|    0|  250|
|Febrero   |  160|    0|    0|  250|    0|
|Marzo     |  200|    0|  250|    0|    0|
|Abril     |    0|  200|    0|    0|  249|
|Mayo      |    0|    0|    0|  250|    0|
|Junio     |    0|    0|    0|  250|    0|

|ALMACEN   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Inicial   |  500|  500|  500|  500|  500|
|Enero     |  501|  300|  500|  500|  250|
|Febrero   |  341|  300|  698|  250|  250|
|Marzo     |  141|  300|  448|  250|  527|
|Abril     |  142|  100|  448|  250|  278|
|Mayo      |  142|  100|  448|    0|  462|
|Junio     |  450|  450|  450|  450|  462|

Beneficio: 100075
```

### `aceite-ext.py`

En esta versión se han añadido las extensiones partiendo de `aceite-opt.py`. Se han usado las mismas matrices y vectores que se añadieron en la versión extendida de MiniZinc, por lo que ahora al JSON de entrada se le han añadido las siguientes claves, que tienen el mismo significado que en la versión de MiniZinc

```
"K": [3, 2, 3, 3, 2, 1],
"T": [
    [11, 12, 13, 11, 11],
    [13, 13, 11, 9, 11],
    [11, 14, 13, 10, 9],
    [12, 11, 12, 12, 12],
    [100, 120, 150, 110, 105],
    [90, 100, 140, 80, 135]
],
"incompatible": [
    [0, 0, 0, 0, 0],
    [0, 0, 1, 1, 0],
    [0, 1, 0, 0, 1],
    [0, 1, 0, 0, 1],
    [0, 0, 1, 1, 0]
],
"requerido": [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0]
]
```

Para la primera restricción, iteramos sobre cada mes y para contar cuantos aceites hemos usado cada mes, usamos comprensión de listas para obtener una lista de unos y ceros indicando si se ha usado, y luego calculamos su suma para comprarla con K.

```
for mes in range(nM):
    s.add(sum([If(val > 0, 1, 0) for val in refinado[mes]]) >= arrayK[mes])
```

El resto de restricciones son bucles for con condiciones "or" dentro que son traducciones directas de las restricciones implementadas en la versión de MiniZinc, y tienen arriba un comentario indicando a qué restricción corresponden.

Al ejecutar el script con el fichero `data-ext.json`, obtenemos la siguiente salida.

```
|COMPRAS   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |   10|    0|    0|    0|    0|
|Febrero   |    0|    0|    0|  205|    0|
|Marzo     |    0|    0|    0|    0|    0|
|Abril     |    0|    0|  244|    0|    0|
|Mayo      |  144|    0|    0|    0|  206|
|Junio     |  450|  157|    0|  725|    0|

|REFINADO  |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |  178|    0|   22|  228|    0|
|Febrero   |  127|    0|    0|  249|    0|
|Marzo     |   11|  189|    0|    0|  250|
|Abril     |  178|    0|   22|  228|    0|
|Mayo      |  160|    0|  250|    0|    0|
|Junio     |    0|    0|    0|  250|    0|

|ALMACEN   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Inicial   |  500|  500|  500|  500|  500|
|Enero     |  332|  500|  478|  272|  500|
|Febrero   |  205|  500|  478|  228|  500|
|Marzo     |  194|  311|  478|  228|  250|
|Abril     |   16|  311|  700|    0|  250|
|Mayo      |    0|  311|  450|    0|  456|
|Junio     |  450|  468|  450|  475|  456|

Beneficio: 100000
```

## Extensiones adicionales

En este apartado se proponen extensiones adicionales al enunciado. Se han implementado todas estas restricciones en el fichero `aceite-prp`, y los nuevos datos de entrada necesarios se han añadido en el fichero `data-prp.json`

### Máximas compras en un mes

Se podría definir un valor **MaxG**, que podría ser distinto cada mes, y que sea el maximo dinero que se puede gastar en compras durante ese mes, esto tiene sentido ya que podría existir un presupuesto mensual definido. Como ejemplo hemos añadido los siguientes valores.

```
"MaxG": [50000, 50000, 50000, 50000, 50000, 40000]
```

Y hemos codificado la restricción de la siguiente manera.

```
for mes in range(nM):
    s.add(dotProd(comprado[mes], precios[mes]) <= maxG[mes])
```

### Minimo uso de aceites durante el periodo

Se podría definir para cada aceite, un valor **MinUso**, que sea la cantidad mínima de toneladas de ese aceite que se deben refinar durante el periodo de 6 meses. Esta restricción tiene sentido ya que la empresa podría querer evitar tener un tipo de aceite demasiado tiempo sin ser refinado. Para esta restricción añadimos los siguientes valores para **MinUso**

```
"MinUso": [100, 200, 100, 100, 300]
```

Y la restricción queda de la siguiente forma. Usamos comprension de listas para obtener el total refinado de cada aceite y compararlo con el valor de **MinUso**

```
for aceite in range(nA):
    s.add(addSum([refinado[mes][aceite] for mes in range(nM)]) >= minUso[aceite])
```

### Incompatibilidad de compra

Podemos añadir una restricción similar a la de aceites incompatibles en refinado, pero ahora de aceites incompatibles en compra. Esto tiene sentido ya que se podría dar por ejemplo que dos aceites vengan del mismo distribuidor y este solo pueda hacer una entrega por mes. Para esto podriamos añadir una matriz **IncCompra** que nos diga si un aceite no se puede comprar el mismo mes que otro. Ponemos como ejemplo que el VEG 1 no se pueda comprar el mismo mes que el ANV 3, que sería la siguiente matriz.

```
"IncCompra": [
    [0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0]
]
```

Y la restricción quedaría igual que la de incompatibilidades para refinar, solo con los nombres cambiados.

```
for mes in range(nM):
    for aceite1 in range(nA):
        for aceite2 in range(aceite1 + 1, nA):
            s.add(
                Or(
                    incCompra[aceite1][aceite2] == 0,
                    comprado[mes][aceite1] == 0,
                    comprado[mes][aceite2] == 0,
                )
            )
```

### Entregas conjuntas

Podemos añadir una restricción que no sea fuerte, que sean aceites que se puedan entregar de manera conjunta, entonces querremos maxmimizar el número de meses en los que compramos aceites que se puedan entregar de manera simultánea, así no hacen falta dos envíos y ayudamos al medio ambiente. Como ejemplo hemos puesto que en VEG 2 y el ANV 3 se pueden entregar simultáneamente, y creamos la matriz **EntCnj**.

```
"EntCnj": [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0]
]
```

Para la restricción, iteramos para cada mes, para cada pareja de aceites, y si estos se pueden entregar de manera conjunta, añadimos una restricción suave que nos dice que se deben comprar ambos o ninguno, le damos peso 1 y le damos el id de compraConj para que no se combine con la restricción de uso de aceites, con este fin también le añadimos un id a la restricción de uso de aceites.

```
for mes in range(nM):
    for aceite1 in range(nA):
        for aceite2 in range(nA):
            if entCnj[aceite1][aceite2] == 1:
                s.add_soft(
                    If(comprado[mes][aceite1] > 0, 1, 0)
                    == If(comprado[mes][aceite2] > 0, 1, 0),
                    1,
                    "compraConj",
                )
```

### Ejecución

Ejecutando el script `aceite-prp.py` con el fichero de datos `data-prp.json`, obtenemos la siguiente salida.

```
|COMPRAS   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |   10|    0|    0|    0|    0|
|Febrero   |    0|    1|   49|  485|    1|
|Marzo     |    0|    1|    0|   73|  448|
|Abril     |    0|  325|    0|    0|    1|
|Mayo      |  500|    0|    0|    0|    0|
|Junio     |  183|    0|    1|  292|    0|

|REFINADO  |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Enero     |  200|    0|   50|  200|    0|
|Febrero   |  200|    0|   50|  200|    0|
|Marzo     |   11|  189|    0|    0|  250|
|Abril     |   12|  188|    0|    0|  250|
|Mayo      |  160|    0|    0|  250|    0|
|Junio     |  160|    0|    0|  250|    0|

|ALMACEN   |VEG 1|VEG 2|ANV 1|ANV 2|ANV 3|
|Inicial   |  500|  500|  500|  500|  500|
|Enero     |  310|  500|  450|  300|  500|
|Febrero   |  110|  501|  449|  585|  501|
|Marzo     |   99|  313|  449|  658|  699|
|Abril     |   87|  450|  449|  658|  450|
|Mayo      |  427|  450|  449|  408|  450|
|Junio     |  450|  450|  450|  450|  450|

Beneficio: 100760
```
