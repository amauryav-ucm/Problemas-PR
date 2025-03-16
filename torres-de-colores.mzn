enum Colores = { Azul,Rojo, Verde};
array[Colores] of int: disponibles;
int: n;
array[1..n] of var Colores: torre;

constraint forall (c in Colores) (count (i in 1..n) (torre[i]=c) <= disponibles[c]);

constraint forall (i in 1..n-1) (torre[i]!=Verde\/torre[i+1]!=Verde);


constraint forall (i in 1..n) (count (j in 1..i) (torre[j]=Verde)<= count (j in 1..i) (torre[j]=Azul));

constraint torre[1] = Rojo;

constraint count (i in 1..n) (torre[i]=Rojo) >= n/2;

  


