% Use this editor as a MiniZinc scratch book
int: maxSuc = 2;

int: len;
int: nC;
int: maxCons;

array[1..nC] of int: cons;

array[1..len] of var 1..nC: strip;

constraint sum (i in 1..len) (cons[strip[i]]) <= maxCons;

constraint forall (i in 1..len-maxSuc) (exists (j in i..i+maxSuc)(strip[j]!=strip[i]));

constraint forall (c in 1..nC, i in 1..len) (count(j in 1..i)(strip[j]=c) <= (i+1)/2);
