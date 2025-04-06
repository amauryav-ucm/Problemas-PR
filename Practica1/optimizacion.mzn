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

% 1. Cada turno tiene el número de trabajadores (“N1”, “N2” o “N3”) que le corresponde.
constraint forall (d in 1..D) (sum (t in 1..T) (asig1[d,t]) = N1);
constraint forall (d in 1..D) (sum (t in 1..T) (asig2[d,t]) = N2);
constraint forall (d in 1..D) (sum (t in 1..T) (asig3[d,t]) = N3);

% 2. Un trabajador solo puede estar en un turno cada día.
constraint forall (t in 1..T, d in 1..D) (turnos[d,t] <= 1);

% 3. Dado un número “MaxDT”, garantizar que nadie trabaja “MaxDT” días consecutivos.
% Para cada trabajador, en cada secuencia de MaxDT + 1, hay al menos un dia que no trabaja 
constraint forall (t in 1..T, d in 1..D-MaxDT) (exists (i in d..d+MaxDT) (turnos[i,t] = 0));

% 4. Dado un número “MaxDL”, garantizar que nadie tiene “MaxDL” días libres consecutivos.
% Para cada trabajador, en cada secuencia de MaxDL + 1, hay al menos un dia que trabaja 
constraint forall (t in 1..T, d in 1..D-MaxDL) (exists (i in d..d+MaxDL) (turnos[i,t] = 1));

% 5. Dado un número “MinDT”, garantizar que todos trabajan como mínimo “MinDT” en los “D” días
% Cada trabajador trabaja al menos MinDT dias
constraint forall (t in 1..T) (sum (d in 1..D) (turnos[d,t]) >= MinDT);

% 6. Si un trabajador hace el último turno de un día entonces no puede tener el primero del día siguiente
% Si un trabajador trabaja el turno 3 un dia, no trabaja el turno 1 el dia siguiente
constraint forall (t in 1..T, d in 1..D-1) (asig3[d,t] = 1 -> asig1[d+1,t] = 0); 

% 7. Si un trabajador hace el último turno dos días seguidos entonces tiene que librar el día siguiente.
% Si un trabajador trabaja el turno 3 dos dias seguidos, no trabaja el dia siguiente
constraint forall (t in 1..T, d in 1..D-2) ((asig3[d,t] = 1 /\ asig3[d+1,t] = 1) -> turnos[d+2,t] = 0);

% 8. Dada una serie de parejas de trabajadores afines, que se indicarán con una matriz 1..T x 1..T de Booleanos “afines”, y un número “A”, cada trabajador de un turno tiene que estar con al menos A trabajadores afines en ese turno.
% Para cada trabajador cada dia, si trabaja un turno, entonces tiene al menos A trabajadores afines trabajando ese turno
constraint forall (t in 1..T, d in 1..D) (asig1[d,t] = 1 -> count (t2 in 1..T) (asig1[d,t2] = 1 /\ afines[t,t2]) >= A);
constraint forall (t in 1..T, d in 1..D) (asig2[d,t] = 1 -> count (t2 in 1..T) (asig2[d,t2] = 1 /\ afines[t,t2]) >= A);
constraint forall (t in 1..T, d in 1..D) (asig3[d,t] = 1 -> count (t2 in 1..T) (asig3[d,t2] = 1 /\ afines[t,t2]) >= A);

% 9. Sea “R” el conjunto de trabajadores (que se obtendrá como un set of números de trabajador) que tienen la categoría de encargados. En cada turno debe haber al menos un responsable.
% Para cada turno cada dia, existe un trabajador en R que trabaja ese turno ese dia
constraint forall (d in 1..D) (exists (t in R) (asig1[d,t] = 1));
constraint forall (d in 1..D) (exists (t in R) (asig2[d,t] = 1));
constraint forall (d in 1..D) (exists (t in R) (asig3[d,t] = 1));

/*
% ---------------- 1 ----------------
% Si un trabajador trabaja seguido dos mañanas, dos tardes y una noche, tiene libre los dos dias siguientes
constraint forall (t in 1..T, d in 1..D-6) ((asig1[d,t] = 1 /\ asig1[d+1,t] = 1 /\ asig2[d+2,t] = 1 /\ asig2[d+3,t] = 1 /\ asig3[d+4,t] = 1) -> (turnos[d+5,t]=0 /\ turnos[d+6,t]=0));
% Contamos cuantos trabajadores han trabajado turnos anti estres
var int : antiEstres = count (t in 1..T, d in 1..D-4) (asig1[d,t] = 1 /\ asig1[d+1,t] = 1 /\ asig2[d+2,t] = 1 /\ asig2[d+3,t] = 1 /\ asig3[d+4,t] = 1);
% Maximizamos el numero de turnos rotatorios que se han trabajado
solve maximize antiEstres;

*/
/*
% ---------------- 2 ----------------
% Comentar linea 35 y 43
% Para cada trabajador se guardan los dias que ha solicitado doblar turnos
array[1..D, 1..T] of 0..1 : turnosDobles;
% Se ha modificado el constraint de la linea 35 para tener esto en cuenta
constraint forall (t in 1..T, d in 1..D) (turnosDobles[d,t] = 0 -> turnos[d,t] <= 1);
% Ahora un trabajador trabaja a lo sumo dos turnos
constraint forall (t in 1..T, d in 1..D) (turnos[d,t] <= 2);
% Forzamos que si trabaja dos turnos, estos sean consecutivos, que es lo mismo que decir que uno de ellos es el de la tarde
constraint forall (t in 1..T, d in 1..D) (turnos[d,t] = 2 -> asig2[d,t] = 1);
% Si se dobla el turno, el dia siguiente se libra
constraint forall (t in 1..T, d in 1..D-1) (turnos[d,t] = 2 -> turnos[d+1,t] = 0);
% Para no contar este dia libre en los maximos dias libres seguidos, el unico caso en que pertenece a una secuencia de dias libres, es cuando es el primero de ellos, ya que el dia anterior nunca es libre porque es el de turnos dobles, entonces añadimos la posibilidad de que exista una secuencia de mas de MaxDL, si el primero es despues de un turno doble
constraint forall (t in 1..T, d in 1..D-MaxDL) (exists (i in d..d+MaxDL) (turnos[i,t] = 1) \/ (d > 1 /\ turnos[d-1,t] = 2));
% La version anterior de la verificacion de MinDT ya funciona porque cuenta el numero de turnos trabajados, por lo que el turno doble sumaria dos a la cuenta de turnos trabajados
% Tratamos de maximizar el numero de solicitudes de turnos dobles que se conceden
solve maximize count (d in 1..D, t in 1..T) (turnos[d,t] = 2);
*/
/*
% ---------------- 3 ----------------
% Comentar la linea 43
% Este array guarda cuales son los dias que los trabajdores han solicitado no trabajar
array[1..D,1..T] of 0..1 : solicitudDiaLibre;
% Puede haber mas de MaxDL dias libres seguidos si uno de ellos es uno que el trabajador ha solicitado
constraint forall (t in 1..T, d in 1..D-MaxDL) (exists (i in d..d+MaxDL) (turnos[i,t] = 1 \/ solicitudDiaLibre[i,t] = 1));
% Minimizamos el incumplimiento de solicitudes
% solve minimize count (t in 1..T, d in 1..D) (solicitudDiaLibre[d,t] = 1 /\ turnos[d,t] > 0);
% Luego de encontrar el minimo numero de incumpliemntos lo podemos restringir aqui
constraint count (t in 1..T, d in 1..D) (solicitudDiaLibre[d,t] = 1 /\ turnos[d,t] > 0) <= 35;
% Para despues tratar de distribuirlo entre todos los trabajadores, para ello minimizamos el numero de incumplimientos de el trabajador que mas incumplimientos tiene
solve minimize max (t in 1..T) (count (d in 1..D) (solicitudDiaLibre[d,t] = 1 /\ turnos[d,t] > 0));
*/

% ---------------- 4 ----------------
% En este array se guarda para cada dia, para cada trabajador, que turno no quiere, el 1, 2 o 3, o 0 si no tiene preferencia
array[1..D,1..T] of 0..3 : turnoDesfavorecido;
% En estas variables guardamos cuantas solicitude incumplimos para cada turno
var int : incumplimientos1 = count (d in 1..D, t in 1..T) (turnoDesfavorecido[d,t] = 1 /\ asig1[d,t] = 1);
var int : incumplimientos2 = count (d in 1..D, t in 1..T) (turnoDesfavorecido[d,t] = 2 /\ asig2[d,t] = 1);
var int : incumplimientos3 = count (d in 1..D, t in 1..T) (turnoDesfavorecido[d,t] = 3 /\ asig3[d,t] = 1);
% Minimizamos los incumplimientos
%solve minimize incumplimientos1 + incumplimientos2 + incumplimientos3;
% Cuando encontremos el numero minimo de incumplimientos posible lo podemos restringir aqui
constraint incumplimientos1 + incumplimientos2 + incumplimientos3 <= 8;
% Para luego intentar repartirlos entre todos los trabajadores
solve minimize max (t in 1..T) (count (d in 1..D) (turnoDesfavorecido[d,t] = 1 /\ asig1[d,t] = 1) +  count (d in 1..D) (turnoDesfavorecido[d,t] = 2 /\ asig2[d,t] = 1) + count (d in 1..D) (turnoDesfavorecido[d,t] = 3 /\ asig3[d,t] = 1));
