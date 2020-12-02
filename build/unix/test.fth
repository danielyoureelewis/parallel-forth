: debug false ; 
: PES 0 SHMEM_OP ;
: ID 1 SHMEM_OP ;
: PUT 2 SHMEM_OP ;
: GET 3 SHMEM_OP ;
: BARRIER 4 SHMEM_OP ;
: SHARED 5 SHMEM_OP ;

variable target 1 cells allot ;
variable dest 1 cells allot ;

: print-target debug if id . target @ . cr then ;
: test-pes id 0 = if ." NUM PES: " pes . cr then ;
: test-id ." ID: " id . cr ;

: test-put id 0 = if 111 target ! then
           id 1 = if 999 target ! then
           print-target
           barrier
           id 1 = if
             target target 1 0 PUT then
           barrier
           id 0 = 999 target @ = and if ." put test passed" cr then
           print-target ;

: test-get id 0 = if 111 target ! then
           id 1 = if 999 target ! then
           print-target
           barrier
           id 0 = if
             target target 1 1 GET then
           barrier
           id 0 = 999 target @ = and if ." get test passed" cr then
           print-target ;

: test-error false = id 0 = and if ." error test passed" cr then ;
: print-0-stack debug true = id 0 = and if .S then ; 

test-pes
barrier 
print-0-stack
test-id
print-0-stack
test-put
print-0-stack
test-get
print-0-stack
id test-error
print-0-stack
