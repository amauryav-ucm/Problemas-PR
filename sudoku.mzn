% Use this editor as a MiniZinc scratch book
array [1..9,1..9] of 0..9 : init;
array [1..9,1..9] of var 1..9 : sud;
array [1..9] of string : sep;
array [1..3, 1..2] of -2..2 : disp;
array [1..9] of 1..9 : checkto;

disp = [|
-1,-2|
 1, 2|
-1, 1|];

checkto = [ 3, 3, 3, 6, 6, 6, 9, 9, 9];

sep = [" "," "," "," "," "," "," "," ","\n"];

init=[|
0, 0, 0, 0, 2, 8, 0, 7, 0|
0, 0, 0, 3, 0, 0, 0, 0, 8|
0, 0, 8, 0, 0, 1, 0, 0, 4|
0, 4, 0, 0, 0, 0, 7, 0, 6|
0, 8, 0, 7, 5, 6, 0, 4, 0|
5, 0, 7, 0, 0, 0, 0, 1, 0|
9, 0, 0, 8, 0, 0, 6, 0, 0|
8, 0, 0, 0, 0, 9, 0, 0, 0|
0, 2, 0, 5, 4, 0, 0, 0, 0|];

constraint forall (i,j in 1..9) (init[i,j] == 0 \/ init[i,j] == sud[i,j]);
constraint forall (i,j in 1..9, k in j+1..9)(sud[i,j]!=sud[i,k] /\ sud[j,i]!=sud[k,i]);
constraint forall (i,j in 1..6, k in disp[i mod 3 + 1,1..2], l in j+1..checkto[j])(sud[i,j]!=sud[k + i,l]);

solve satisfy;

output [show_int(0,sud[i,j]) ++ sep[j] | i,j in 1..9];

