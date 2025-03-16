int: m;
int: n;
int: s;
int: ja;
enum Tipo;
array[1..m] of int: disp;
array[1..m] of Tipo: jtipo;
array[1..n,1..m] of int: jsat;

array[1..n,1..ja] of var 1..m: asig;
var int: tsat =  sum(k in 1..n, j in 1..ja)(jsat[k, asig[k,j]]);

constraint forall(k in 1..n, i in 1..ja-1)(asig[k,i] < asig[k,i+1]);

constraint forall(k in 1..n)(sum(j in 1..ja)(jsat[k, asig[k,j]]) >= s);

constraint forall(t in 1..m)((count(k in 1..n, j in 1..ja)(asig[k,j] = t)) <= disp[t]);

constraint forall(k in 1..n, i in 1..ja, j in i+1..ja)(jtipo[asig[k,i]] != jtipo[asig[k,j]]);

solve maximize tsat;