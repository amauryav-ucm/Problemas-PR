int: n;
int: budget;

array[1..n] of int: cost;
array[1..n] of int: sur;

array[1..n] of var 0..1: asig;

%constraint sum (i in 1..n where asig[i] = 1) (cost[i]) <= budget;
constraint sum (i in 1..n) (asig[i] * cost[i]) <= budget;

%solve maximize sum (i in 1..n where i = 1) (sur[i]);
solve maximize sum (i in 1..n) (asig[i] * sur[i]);