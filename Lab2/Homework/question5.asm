; bin2ascii subroutine
org 0h
ljmp main

write_lower_nibble: ; Lower nibble in 53h and write location in r0
	using 0
		clr c
		subb A,#0ah
		jc digit
			add A,#61h
			mov @r0,A
		sjmp comp
		digit:
			mov A,53h
			add A,#30h
			mov @r0,A
		comp: nop
ret

bin2ascii:
	mov r2,50h ; N
	mov r1,51h ; Read pointer
	mov r0,52h ; Write pointer
	mov r3,#0f0h ; Starts the loop by extracting the lower 4-bits
	
	loop:
		mov A,@r1
		anl A,r3 ; higher nibble saved , rest all bits to 0
		mov r4,#4
		rot: ; upper nibble is now in the lower half
			rr A
		djnz r4, rot
		mov 53h,A
		acall write_lower_nibble ; 53 is reserved for its argument parameter
		inc r0
		
		mov A,r3
		cpl A
		anl A,@r1 ; Lower order bits recovered
		mov 53h,A
		acall write_lower_nibble
		inc r0
		
		inc r1
	djnz r2,loop
ret

org 100h
main:
	mov r1,#80h
	random:
		mov A,r1
		mov @r1,A
		inc r1
		cjne r1, #90h, random
		mov 50h,#16
		mov 51h,#80h
		mov 52h,#90h
		acall bin2ascii
stop: sjmp stop
end