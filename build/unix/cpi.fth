: fsquare ( f_x -- f_x^2 )
  2.0 f** ;

: f ( f_x -- f_y )
  4.0 fswap
  fsquare 1.0 f+ f/ ; 

: 2fdup
  fover fover ;

fvariable sum
0.0 sum f!

: integrate
  fswap fover f- dup s>f f/
  fdup 2.0 f/ frot f+ \ midpt rule
  fswap
  0 do
    2fdup
    I s>f f* f+ f sum f@ f+ sum f!
  loop
  sum f@ f* sum f! ;

3.141592653589793238462643 fconstant PI ;
100 constant INTERVALS_PER_THREAD ;
fvariable work pes cells allot
variable pSync pes cells allot

: approx-pi
  
  INTERVALS_PER_THREAD
  \ end
  pe 1 + s>f pes s>f f/
  \ start
  pe s>f pes s>f f/
  integrate
  sum sum 1 0 0 pes work pSync fsum-reduction ;


: print-sum
  sum f@ pe 0 = if f. then ;

        
approx-pi
print-sum
