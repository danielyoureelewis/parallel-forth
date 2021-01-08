: debug false ; 
( vars used in testing )
variable target 1 cells allot ;
variable dest 1 cells allot ;

( helper words )
: print-0-stack debug true = pe 0 = and if .S then ; 
: print-target debug if pe . target @ . cr then ;

( test words )
: test-pes pe 0 = if ." NUM PES: " pes . cr then
           flushemit
           barrier_all ;
: test-pe ." PE: " pe . cr flushemit ;
: test-put pe 0 = if 111 target ! then
           pe 1 = if 999 target ! then
           print-target
           barrier_all
           pe 1 = if
             target target 1 0 PUT then
           barrier_all
           pe 0 = 999 target @ = and if ." put test passed" cr then
           flushemit
           print-target ;
: test-get pe 0 = if 111 target ! then
           pe 1 = if 999 target ! then
           print-target
           barrier_all
           pe 0 = if
             target target 1 1 GET then
           barrier_all
           pe 0 = 999 target @ = and if ." get test passed" cr then
           flushemit
           print-target ;
: test-broadcast pe 0 = if 111 target ! else 999 target ! then
                 barrier_all
                 print-target
                 target target 1 0 0 0 pes broadcast
                 pe 1 = 111 target @ = and if ." broadcast test passed" cr then
                 flushemit
                 print-target ; 
                   
: test-error false = pe 0 = and if ." error test passed" cr then
             flushemit ;

variable collection pes cells allot ;  
: test-collect 1 target !
               collection target 1 0 0 pes collect
               0 pe = if
                 pes 0 do
                   collection I cells + I = invert
                   if
                     ." collect failed" cr leave
                   then
                 loop then ;

0 pe = if cr ." Testing Basics:" cr flushemit then ; 
barrier_all ; 
test-pes
print-0-stack
test-pe
print-0-stack
test-put
print-0-stack
test-get
print-0-stack
barrier_all ; 
0 pe = if cr ." Testing Collectives:" cr flushemit then ; 
barrier_all ; 
test-broadcast
print-0-stack
barrier_all ; 
test-collect
print-0-stack ;
barrier_all ; 
0 pe = if cr ." Testing Errors:" cr flushemit then ; 
barrier_all ;
pe test-error
