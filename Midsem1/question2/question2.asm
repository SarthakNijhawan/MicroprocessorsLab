;GCD of two numbers
org 0h
ljmp main

gcd: ;Input at 60h and 61h and outputs the GCD at 62h
	mov A,60H
	mov B,61H
	clr C
	subb A,B
	jnc loop
	mov A,60H
	xch A,B
	loop:
		clr C
		subb A,B
		mov R0,B
		div AB
		mov A,R0
		mov R0,B
		cjne R0,#0,loop
		mov 62H,A
ret

org 100h
main:
	;mov 60h,#25
	;mov 61h,#10
	acall gcd
	here: sjmp here
end