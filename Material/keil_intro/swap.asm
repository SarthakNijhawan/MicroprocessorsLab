Org 0h
ljmp main
Org 100h
main:
MOV 70H,#20H
MOV 71H,#21H

MOV A,70H
MOV 70H,71H
MOV 71H,A
 
HERE:SJMP HERE
END
