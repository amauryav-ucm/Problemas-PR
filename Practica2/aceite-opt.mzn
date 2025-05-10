% Use this editor as a MiniZinc scratch book
int : nM = 6;
int : nA = 5;

int : VALOR;
array[1..nA] of float : dureza;
array[1..nM, 1..nA] of int : precios;

int : MAXV;
int : MAXN;

int : MCAP;

int : CA;

float : MinD;
float : MaxD; 
int : MinB;

array[1..nA] of int : inicial;
int : PV;

% Calculamos cual es lo maximo de un tipo de aceite que se puede refinar en un mes, para acotar la matriz refinado
int : MaxR = max(MAXV, MAXN);
array[1..nM, 1..nA] of var 0..MaxR : refinado;
% Lo maximo que se puede llegar a comprar es MCAP+MaxR ya que mas de eso implicaria aceite que ni se ha refinado ni se ha almacenado
array[1..nM, 1..nA] of var 0..MCAP+MaxR : comprado;

% almacen[mes, aceite] tiene la cantidad de aceite en el almacen al inicio del mes
% almacen[mes+1, aceite] tiene la cantidad de aceite en el almacen al final del mes
array[1..nM+1, 1..nA] of var 0..MCAP : almacen;

var int : beneficio;

% RESTRICCIONES

% Ponemos la cantidad inicial de aceite en los almacenes
constraint forall (aceite in 1..nA) (almacen[1, aceite] = inicial[aceite]);

% La cantidad de aceite es la anterior mas la comprada menos la refinada
constraint forall (mes in 1..nM, aceite in 1..nA) (almacen[mes+1, aceite] = almacen[mes, aceite] + comprado[mes,aceite] - refinado[mes,aceite]);

% No se puede refinar mas de MAXV tons de aceite vegetal en ningun mes
constraint forall (mes in 1..nM) (refinado[mes, 1] + refinado[mes,2] <= MAXV);

% No se puede refinar mas de MAXN tons de aceite no vegetal en ningun mes
constraint forall (mes in 1..nM) (refinado[mes, 3] + refinado[mes,4] + refinado[mes,5] <= MAXN);

% La cantidad en los almacenes al acabar el mes 6 no debe variar en mas de PV con respecto a la inicial
constraint forall (aceite in 1..nA) (almacen[7, aceite] >= inicial[aceite]*(1-0.01*PV) /\ almacen[7, aceite] <= inicial[aceite]*(1+0.01*PV));

% El beneficio es el valor por la cantidad refinada, menos los costes de almacenamiento y el coste de compras de aceites
constraint beneficio = (sum (mes in 1..nM, aceite in 1..nA) (VALOR * refinado[mes, aceite])
                      - sum (mes in 1..nM, aceite in 1..nA) (CA * almacen[mes, aceite])
                      - sum (mes in 1..nM, aceite in 1..nA) (precios[mes, aceite] * comprado[mes, aceite])
                      );

% Para verificar que está por arriba de la dureza minima, tomamos la suma ponderada de dureza y la comparamos con la dureza total de una cantidad igual con la dureza minima
% Lo he hecho de esta manera para evitar divisiones
constraint forall (mes in 1..nM) (sum (aceite in 1..nA) (dureza[aceite] * refinado[mes, aceite]) >= sum (aceite in 1..nA) (MinD * refinado[mes, aceite]));

% Analogo para la dureza maxima 
constraint forall (mes in 1..nM) (sum (aceite in 1..nA) (dureza[aceite] * refinado[mes, aceite]) <= sum (aceite in 1..nA) (MaxD * refinado[mes, aceite])); 
                      

constraint beneficio >= MinB;

solve maximize beneficio;