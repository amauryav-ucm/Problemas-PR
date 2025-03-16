% Use this editor as a MiniZinc scratch book
int: X;
int: Y;
int: N;
array[1..N] of int: dim_x;
array[1..N] of int: dim_y;
array[1..X,1..Y] of var 1..N: surface;
array[1..N] of var 1..X: tl_x;
array[1..N] of var 1..Y: tl_y;
/*
constraint forall(box in 1..N)(
  forall(x in tl_x[box]..tl_x[box]+dim_x[box]-1,
         y in tl_y[box]..tl_y[box]+dim_y[box]-1)(
         surface[x,y]=box));
*/
constraint forall(box in 1..N)(
  count(x in 1..X, y in 1..Y)(surface[x,y]=N) = dim_x[N]*dim_y[N]);
  
array[1..N] of var 0..1: rot;
constraint forall(box in 1..N)(
  forall(x in tl_x[box]..tl_x[box]+(rot[box]*dim_x[box]+(1-rot[box])*dim_y[box])-1,
         y in tl_y[box]..tl_y[box]+(rot[box]*dim_y[box]+(1-rot[box])*dim_x[box])-1)(
         surface[x,y]=box));

output ["\(tl_x[i]-1) \(tl_y[i]-1) \(rot[i])\n" | i in 1..N];
