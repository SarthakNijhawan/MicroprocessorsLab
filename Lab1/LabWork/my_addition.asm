; Adds 2 16-bits numbers in 2's complement form

org 0h;
ljmp main

addition:
	mov A,61h
	add A,71h
	mov 64h,A
	mov A,60h
	addc A,70h
	mov 63h,A
	mov A,60h
	xrl A,70h
	mov B,A
	clr A
	addc A,#0
	jnb 0f7h, skip
	cpl A
	anl A,#1h
	skip: mov 62h,A
	
RET
	
org 100h
main:
	mov 60h,#0ffh
	mov 61h,#0ffh
	mov 70h,#0ffh
	mov 71h,#0ffh
	
	acall addition
	
	here: sjmp here
END