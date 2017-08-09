; Subroutine memcpy
org 0h
ljmp main

compare: ; Compares 2 operands stored in r0 and r1
	clr c
	mov A,r0
	subb A,r1
ret

memcpy:
	mov r2,50h ; N
	mov r0,51h ; Read Pointer
	mov r1,52h ; Write Pointer
	acall compare 
	jc skip ; c is zero when Write Ptr < Read Ptr
	; Code
	loop1:
		mov A,@r0
		mov @r1,A
		inc r0
		inc r1
		djnz r2, loop1
	ljmp completed
	skip: ; Write Pointer > Read Pointer
	; Code
		mov A,r2
		add A,r1
		subb A,#1
		mov r1,A
		mov A,r2
		add A,r0
		subb A,#1
		mov r0,A
		loop2:
			mov A,@r0
			mov @r1,A
			dec r0
			dec r1
			djnz r2, loop2			
	completed: nop
ret

org 100h
main:
mov r1,#85h
	random:
		mov A,r1
		mov @r1,A
		inc r1
		cjne r1, #8ch, random
		
	mov 50h,#7
	mov 51h,#85h
	mov 52h,#80h
	acall memcpy
	stop: sjmp stop
end