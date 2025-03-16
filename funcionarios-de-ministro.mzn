int: N;
array[1..N,1..N] of int: time;

array[1..N,1..N] of var 0..1: asig;

constraint forall (i in 1..N) (sum (j in 1..N) (asig[i,j]) = 1 /\ sum (j in 1..N) (asig[j,i]) = 1);

%solve minimize sum(i in 1..N, j in 1..N where asig[i,j]=1) (time[i,j]);

solve minimize sum(i in 1..N, j in 1..N) (time[i,j] * asig[i,j]);
/*
include "alldifferent.mzn";

int: N;

array[1..N,1..N] of int: time;

array[1..N] of var 1..N: asig;

constraint alldifferent (i in 1..N) (asig[i]);

solve minimize sum (i in 1..N) (time[i,asig[i]);
*/