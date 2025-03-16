int: n;
int: t1;
int: t2;

array[1..n] of int: dur;
array[1..n] of int: sat;

enum asig = {viaje1, viaje2, unasig};

array[1..n] of var asig: sol;

constraint sum (i in 1..n where sol[i] = viaje1) (dur[i]) = t1;
constraint sum (i in 1..n where sol[i] = viaje2) (dur[i]) = t2;

solve maximize sum (i in 1..n where sol[i] != unasig) (sat[i]);