; bin2ascii subroutine
org 0h
ljmp main

bin2ascii:
	mov r2,50h ; N
	mov r1,51h ; Read pointer
	mov r0,52h ; Write pointer
	mov r3,#0f0h ; Starts the loop by extracting the lower 4-bits
	mov r4,#30h ; Upper Nible of ascii numbers
	
	loop:
		mov A,@r1
		anl A,r3 ; Upper 4-bits are extracted and lower bits are set to 0
		mov r5,#4
		rotate:
			rr A
		djnz r5,rotate
		xrl A,r4 ; Lower bits are set to 0110
		mov @r0,A 
		inc r0
		mov A,r3
		cpl A
		anl A,@r1 ; Lower 4-bits and rest to 0
		xrl A,r4
		mov @r0,A
		inc r0
		inc r1
	djnz r2,loop
	
	
ret

org 100h
main:
	mov r1,#66h
	random:
		mov @r1,#0feh
		inc r1
		cjne r1, #6ah, random
		mov 50h,#4
		mov 51h,#66h
		mov 52h,#70h
		acall bin2ascii
stop: sjmp stop
end