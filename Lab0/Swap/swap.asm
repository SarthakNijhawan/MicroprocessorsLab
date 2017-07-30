; My first program
Org 0h ; Org command lets us define the origin reference
ljmp main
Org 100h

main:
MOV 70H,#20H ; # represents data
MOV 71H,#21H
MOV A,70H
MOV 70H,71H
MOV 71H,A
HERE: sjmp HERE
END