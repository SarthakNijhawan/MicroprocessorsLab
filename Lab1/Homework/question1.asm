; Adds two numbers at 50h & 60h and stores the result at 70h

org 0h
ljmp main
org 100h

main:
	mov A,50h
	add A,60h
	mov 70h,A
	here: sjmp here
END