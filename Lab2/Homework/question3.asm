; Subroutine Zero-out
org 0h
ljmp main

zeroOut:
	mov r1,50h ; N
	mov r0,51h ; Pointer
	loop:
		mov @r0,#0
		inc r0
		djnz r1, loop
ret

org 100h
main:
	mov r1,#66h
	random:
		mov @r1,#8
		inc r1
		cjne r1, #6ah, random

	mov 50h,#4
	mov 51h,#66h
	acall zeroOut
	stop: sjmp stop
end