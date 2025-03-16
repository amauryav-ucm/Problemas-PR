/*
int: MAX_MOVES = 11;

var 1..MAX_MOVES: moves;

array[1..2, 0..MAX_MOVES] of var 0..3: mis;
array[1..2, 0..MAX_MOVES] of var 0..3: can;
array[1..MAX_MOVES] of var 0..2: move_mis;
array[1..MAX_MOVES] of var 0..2: move_can;

constraint mis[1,0] = 3;
constraint can[1,0] = 3;
constraint mis[2,0] = 0;
constraint can[2,0] = 0;

constraint forall (i in 0..MAX_MOVES) (mis[1,i]>=can[1,i] \/ mis[1,i]=0\/ can[1,i]=0);
constraint forall (i in 0..MAX_MOVES) (mis[2,i]>=can[2,i] \/ mis[2,i]=0\/ can[2,i]=0);

constraint forall (i in 1..MAX_MOVES) (move_mis[i]+move_can[i]<=2);
constraint forall (i in 1..moves) (move_mis[i]+move_can[i]>=1);

constraint forall (i in 1..MAX_MOVES where i mod 2 = 1) (mis[2,i] = mis[2,i-1] + move_mis[i] /\ 
                                                         mis[1,i] = mis[1,i-1] - move_mis[i]);
constraint forall (i in 1..MAX_MOVES where i mod 2 = 0) (mis[1,i] = mis[1,i-1] + move_mis[i] /\ 
                                                         mis[2,i] = mis[2,i-1] - move_mis[i]);
                                                         
                                                         
constraint forall (i in 1..MAX_MOVES where i mod 2 = 1) (can[2,i] = can[2,i-1] + move_can[i] /\ 
                                                         can[1,i] = can[1,i-1] - move_can[i]);
constraint forall (i in 1..MAX_MOVES where i mod 2 = 0) (can[1,i] = can[1,i-1] + move_can[i] /\ 
                                                         can[2,i] = can[2,i-1] - move_can[i]);
                                                         
constraint mis[2,moves]=3 /\ can [2,moves] = 3;

%constraint moves = 11;

solve minimize moves;
*/


int: MAX_MOVES = 20;

var 1..MAX_MOVES: nMoves;

enum Sides = {ini,fin};

type State = record(0..3: mis, 0..3: can);
type Move = record(0..2: mis, 0..2: can, Sides: from, Sides: to);

array[0..MAX_MOVES, Sides] of var State: states;
array[1..MAX_MOVES] of var Move: moves;

constraint states[0, ini] = (mis: 3, can: 3);
constraint states[0, fin] = (mis: 0, can: 0);
constraint moves[1].from = ini;

constraint forall (i in 0..MAX_MOVES, s in Sides) (states[i, s].mis>=states[i, s].can \/ states[i, s].mis = 0);

constraint forall (i in 1..nMoves) (moves[i].mis + moves[i].can <= 2 /\ moves[i].mis + moves[i].can >= 1);

constraint forall (i in 1..MAX_MOVES) (states[i, moves[i].to].mis = states[i - 1, moves[i].to].mis + moves[i].mis /\
                                    states[i, moves[i].to].can = states[i - 1, moves[i].to].can + moves[i].can);                                    
                                    
constraint forall (i in 1..MAX_MOVES) (states[i, moves[i].from].mis = states[i - 1, moves[i].from].mis - moves[i].mis /\
                                    states[i, moves[i].from].can = states[i - 1, moves[i].from].can - moves[i].can);

constraint forall (i in 1..MAX_MOVES) (moves[i].from != moves[i].to);
constraint forall (i in 2..MAX_MOVES) (moves[i].from = moves[i-1].to);

                                                         
constraint states[nMoves, fin].mis = 3 /\ states[nMoves, fin].can = 3;

output ["\(moves[i].mis) misioneros y \(moves[i].can) canibales\n" | i in 1..MAX_MOVES];


solve minimize nMoves;









