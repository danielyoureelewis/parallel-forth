false constant debug ;
1000 constant warm-up ;
10000 constant iter ;

defer test-word ;

: test-lat { time elem }
           iter 0 do
             I warm-up =
             if
               wtime time ! 
             then 
             elem elem 0 1 put
             quiet
           loop
           wtime time @ - time !
           time @ iter / time ! ; 


variable elem 65 elem ! ;
variable time ;

' put is test-word
pe 0 =
if
  ." begin put test" cr
  time elem test-lat 
  time @ . cr 
then

' get is test-word
pe 0 =
if
  ." begin get test" cr
  time elem test-lat 
  time @ . cr
then ;

