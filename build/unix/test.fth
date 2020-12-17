: debug false ; 
( vars used in testing )
variable target 1 cells allot ;
variable dest 1 cells allot ;

( helper words )
: print-0-stack debug true = pe 0 = and if .S then ; 
: print-target debug if pe . target @ . cr then ;

( test words )
: test-pes pe 0 = if ." NUM PES: " pes . cr then flushemit ;
: test-pe ." PE: " pe . cr flushemit ;
: test-put pe 0 = if 111 target ! then
           pe 1 = if 999 target ! then
           print-target
           barrier
           pe 1 = if
             target target 1 0 PUT then
           barrier
           pe 0 = 999 target @ = and if ." put test passed" cr then flushemit
           print-target ;
: test-get pe 0 = if 111 target ! then
           pe 1 = if 999 target ! then
           print-target
           barrier
           pe 0 = if
             target target 1 1 GET then
           barrier
           pe 0 = 999 target @ = and if ." get test passed" cr then flushemit
           print-target ;
: test-error false = pe 0 = and if ." error test passed" cr then flushemit ;


test-pes
barrier 
print-0-stack
test-pe
print-0-stack
test-put
print-0-stack
test-get
print-0-stack
pe test-error
print-0-stack
