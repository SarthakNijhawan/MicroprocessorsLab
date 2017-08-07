; Subroutine Zero-out
org 0h
ljmp main

zeroOut:
	mov r1,50h ; N
	mov r0,51h ; Starting Pointer
	loop:
		mov @r0,#0
		inc r0
		djnz r1, loop
ret

org 100h
main:
	mov r1,#80h
	random:
		mov A,r1
		mov @r1,A
		inc r1
		cjne r1, #88h, random

	mov 50h,#8
	mov 51h,#80h
	acall zeroOut
	
	stop: sjmp stop
end