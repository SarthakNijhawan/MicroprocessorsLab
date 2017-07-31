; Subtract 2 numbers

org 0h
ljmp main

addition:
	clr c
	mov A,61h
	add A,r0
	mov 64h,A
	mov A,60h
	addc A,r1
	mov 63h,A
	mov A,r1
	xrl A,60h
	mov B,A
	clr A
	addc A,#0
	jnb 0f7h, skip
	cpl A
	anl A,#1h
	skip: mov 62h,A
	
RET
	
subtraction:
	mov B,70h
	mov A,71h
	cpl A
	add A,#1
	mov r0,A
	mov A,B
	cpl A
	addc A,#0
	mov r1,A
	acall addition
RET

org 100h
main:
	mov 60h,#0ffh
	mov 61h,#0ffh
	mov 70h,#01h
	mov 71h,#0ffh
	
	acall subtraction
	
	here: sjmp here
END