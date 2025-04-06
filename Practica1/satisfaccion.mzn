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

% Guardamos en un array con indices dia y trabajador cuantos turnos tiene el trabajador ese dia
array [1..D, 1..T] of var 0..3 : turnos;

% El numero de turnos para un trabajador un dia es la suma de si trabaja en cada uno de los turnos
constraint forall (d in 1..D, t in 1..T) (turnos[d,t] = asig1[d,t] + asig2[d,t] + asig3[d,t]);

% Se necesitan al menos tantos trabajadores como la suma de cuantos se necesitan cada turno
constraint assert (T >= N1 + N2 + N3, "No hay suficientes trabajadores para cubrir los turnos");

% Debe haber al menos 3 encargados porque cada turno necesita uno
constraint assert (count (r in R) (true) >= 3, "No hay suficientes engargados para cubrir el turno");

% Para cada dia, la suma de trabajadores en cada turno es el numero indicado
constraint forall (d in 1..D) (sum (t in 1..T) (asig1[d,t]) = N1);
constraint forall (d in 1..D) (sum (t in 1..T) (asig2[d,t]) = N2);
constraint forall (d in 1..D) (sum (t in 1..T) (asig3[d,t]) = N3);

% Cada trabajador trabaja a lo sumo un turno cada dia
constraint forall (d in 1..D, t in 1..T) (turnos[d,t] <= 1);

% Para cada trabajador, en cada secuencia de MaxDT + 1, hay al menos un dia que no trabaja (no trabaja mas de MaxDT dias seguidos)
constraint forall (t in 1..T, d in 1..D-MaxDT) (exists (i in d..d+MaxDT) (turnos[i,t] = 0));

% Para cada trabajador, en cada secuencia de MaxDL + 1, hay al menos un dia que trabaja (no tiene libre mas de MaxDL dias seguidos)
constraint forall (t in 1..T, d in 1..D-MaxDL) (exists (i in d..d+MaxDL) (turnos[i,t] = 1));

% Cada trabajador trabaja al menos MinDT dias
constraint forall (t in 1..T) (sum (d in 1..D) (turnos[d,t]) >= MinDT);

% Si un trabajador trabaja el turno 3 un dia, no trabaja el turno 1 el dia siguiente
constraint forall (t in 1..T, d in 1..D-1) (asig3[d,t] = 0 \/ asig1[d+1,t] = 0); 

% Si un trabajador trabaja el turno 3 dos dias seguidos, no trabaja el dia siguiente
constraint forall (t in 1..T, d in 1..D-2) ((asig3[d,t] = 0 \/ asig3[d+1,t] = 0) \/ turnos[d+2,t]=0);

% Para cada trabajador cada dia, si trabaja un turno, entonces tiene al menos A trabajadores afines trabajando ese turno
constraint forall (t in 1..T, d in 1..D) (asig1[d,t] = 0 \/ count (t2 in 1..T) (asig1[d,t2] = 1 /\ afines[t,t2]) >= A);
constraint forall (t in 1..T, d in 1..D) (asig2[d,t] = 0 \/ count (t2 in 1..T) (asig2[d,t2] = 1 /\ afines[t,t2]) >= A);
constraint forall (t in 1..T, d in 1..D) (asig3[d,t] = 0 \/ count (t2 in 1..T) (asig3[d,t2] = 1 /\ afines[t,t2]) >= A);

% Para cada turno cada dia, existe un trabajador en R que trabaja ese turno ese dia
constraint forall (d in 1..D) (exists (t in R) (asig1[d,t] = 1));
constraint forall (d in 1..D) (exists (t in R) (asig2[d,t] = 1));
constraint forall (d in 1..D) (exists (t in R) (asig3[d,t] = 1));

solve satisfy;

