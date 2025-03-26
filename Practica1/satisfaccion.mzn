int : D;
int : T;
int : N1;
int : N2;
int : N3;
int : MaxDT;
int : MaxDL;
int : MinDT;
int : A;
array [1..T,1..T] of bool : afines;
set of 1..T : R;

array [1..D, 1..T] of var 0..1 : asig1;
array [1..D, 1..T] of var 0..1 : asig2;
array [1..D, 1..T] of var 0..1 : asig3;

array [1..D, 1..T] of var 0..1 : turnos;
constraint forall (d in 1..D, t in 1..T) (turnos[d,t] = asig1[d,t] + asig2[d,t] + asig3[d,t]);

constraint assert (T >= N1 + N2 + N3, "No hay suficientes trabajadores para cubrir los turnos");
constraint assert (count (r in R) (true) >= 3, "No hay suficientes engargados para cubrir el turno");

constraint forall (d in 1..D) (sum (t in 1..T) (asig1[d,t]) = N1);
constraint forall (d in 1..D) (sum (t in 1..T) (asig2[d,t]) = N2);
constraint forall (d in 1..D) (sum (t in 1..T) (asig3[d,t]) = N3);

constraint forall (d in 1..D, t in 1..T) (turnos[d,t] <= 1);

constraint forall (t in 1..T, d in 1..D-MaxDT) (exists (i in d..d+MaxDT) (turnos[i,t] = 0));

constraint forall (t in 1..T, d in 1..D-MaxDL) (exists (i in d..d+MaxDL) (turnos[i,t] = 1));

constraint forall (t in 1..T) (sum (d in 1..D) (turnos[d,t]) >= MinDT);

constraint forall (t in 1..T, d in 1..D-1) (asig3[d,t] = 0 \/ asig1[d+1,t] = 0); 

constraint forall (t in 1..T, d in 1..D-2) (asig3[d,t] = 0 \/ asig3[d+1,t] = 0 \/ turnos[d+2,t]=0);

constraint forall (t in 1..T, d in 1..D) (asig1[d,t] = 0 \/ count (t2 in 1..T) (asig1[d,t2] = 1 /\ afines[t,t2]) >= A);
constraint forall (t in 1..T, d in 1..D) (asig2[d,t] = 0 \/ count (t2 in 1..T) (asig2[d,t2] = 1 /\ afines[t,t2]) >= A);
constraint forall (t in 1..T, d in 1..D) (asig3[d,t] = 0 \/ count (t2 in 1..T) (asig3[d,t2] = 1 /\ afines[t,t2]) >= A);

constraint forall (d in 1..D) (exists (t in R) (asig1[d,t] = 1));
constraint forall (d in 1..D) (exists (t in R) (asig2[d,t] = 1));
constraint forall (d in 1..D) (exists (t in R) (asig3[d,t] = 1));

solve satisfy;

