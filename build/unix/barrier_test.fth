1000 constant iter ; 

pe 0 = 
if
  ." begin barrier test" cr
then

barrier-all
wtime 
iter 0 do
  barrier-all
loop

wtime swap - iter /  

pe 0 = 
if
  . cr
then
