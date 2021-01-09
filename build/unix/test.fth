: debug false ; 
( vars used in testing )
variable target 1 cells allot ;
variable dest 1 cells allot ;

( helper words )
: print-0-stack debug true = pe 0 = and if .S then ; 

: print-target debug if pe . target @ . cr then ;

( test words )
: test-pes pe 0 = if
             ." Testing with " pes .
             ." pes."  cr
           then
           flushemit
           barrier-all ;

: test-pe ." PE: " pe . ." present!" cr flushemit ;

: test-put pe 0 = if
             111 target !
           then
           pe 1 = if
             999 target !
           then
           print-target
           barrier-all
           pe 1 = if
             target target 1 0 PUT
           then
           barrier-all
           pe 0 = 999 target @ = invert and if
             ." put test failed" cr
           then
           flushemit
           print-target ;

: test-get pe 0 = if
             111 target !
           then
           pe 1 = if
             999 target !
           then
           print-target
           barrier-all
           pe 0 = if
             target target 1 1 GET
           then
           barrier-all
           pe 0 = 999 target @ = invert and if
             ." get test failed" cr
           then
           flushemit
           print-target ;

: test-broadcast pe 0 = if
                   111 target !
                 else
                   999 target !
                 then
                 barrier-all
                 print-target
                 target target 1 0 0 0 pes broadcast
                 pe 1 = 111 target @ = invert and if
                   ." broadcast test failed" cr
                 then
                 flushemit
                 print-target ; 
                   
: test-error false = invert pe 0 = and if
               ." error test passed" cr
             then
             flushemit ;

variable collection pes cells allot ;  
: test-collect pe target !
               collection target 1 0 0 pes collect
               pes 0 do
                 collection I cells + @ I = invert if
                   pe ." collect failed" cr leave
                 then
               loop ;

variable work 2 cells allot ;
: test-and-reduction 1 target !
                     target target 1 0 0 pes work and-reduction
                     1 target @ = invert if ." and reduction failed" then
                     pe target ! 
                     target target 1 0 0 pes work and-reduction
                     0 target @ = invert if ." and reduction failed" then ;

: test-max-reduction pe target ! 
                     target target 1 0 0 pes work max-reduction
                     pes 1 - target @ = invert if ." max reduction failed" then ;

: test-min-reduction pe target ! 
                     target target 1 0 0 pes work min-reduction
                     0 target @ = invert if ." min reduction failed" then ;

: test-sum-reduction 1 target ! 
                     target target 1 0 0 pes work sum-reduction
                     pes target @ = invert if ." sum reduction failed" cr then ;

: test-prod-reduction pes target ! 
                     target target 1 0 0 pes work prod-reduction
                     pes pes * target @ = invert if ." prod reduction failed" cr then ;

: test-or-reduction pe 0 = if 10000000 target ! else 1 target ! then  
                     target target 1 0 0 pes work or-reduction
                     10000001 target @ = invert if ." or reduction failed" cr then ;

: test-xor-reduction pe 0 = if 10000001 target ! else 1 target ! then  
                     target target 1 0 0 pes work xor-reduction
                     10000000 target @ = invert if ." xor reduction failed" cr then ;

0 pe = if cr ." Testing Basics:" cr flushemit then ; 
barrier-all ; 
test-pes
print-0-stack
test-pe
print-0-stack
test-put
print-0-stack
test-get
print-0-stack
barrier-all ; 
0 pe = if cr ." Testing Collectives:" cr flushemit then ; 
barrier-all ; 
test-broadcast
print-0-stack
barrier-all ; 
test-collect
print-0-stack ;
barrier-all ; 
test-and-reduction 
test-max-reduction
test-min-reduction
test-prod-reduction
test-or-reduction
test-xor-reduction
0 pe = if cr ." Testing Errors:" cr flushemit then ; 
barrier-all ;
pe test-error
