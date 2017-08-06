; bin2ascii subroutine
org 0h
ljmp main

write_lower_nibble: ; Lower nibble in 53h and write location in r0
	using 0
		clr c
		subb A,#0ah
		jc digit
			add A,r4
			mov @r0,A
		sjmp comp
		digit:
			mov A,53h
			add A,r3
			mov @r0,A
		comp: nop
ret

bin2ascii:
	mov r2,50h ; N
	mov r1,51h ; Read pointer
	mov r0,52h ; Write pointer
	
	mov r3,#30h ; Offset for 0
	mov r4,#61h ; Offset for a
	
	mov r5,#0f0h ; Starts the loop by extracting the lower 4-bits
	
	loop:
		mov A,@r1
		anl A,r5 ; higher nibble saved , rest all bits to 0
		mov r6,#4
		rot: ; upper nibble is now in the lower half
			rr A
		djnz r6, rot
		mov 53h,A
		acall write_lower_nibble ; 53 is reserved for its argument parameter
		inc r0
		
		mov A,r5
		cpl A
		anl A,@r1 ; Lower order bits recovered
		mov 53h,A
		acall write_lower_nibble
		inc r0
		
	djnz r2,loop
ret

org 100h
main:
	mov r1,#80h
	random:
		mov @r1,#0feh
		inc r1
		cjne r1, #88h, random
		mov 50h,#8
		mov 51h,#80h
		mov 52h,#90h
		acall bin2ascii
stop: sjmp stop
end