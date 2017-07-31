; Sort 5 numbers stored in contiguous location

org 0h
ljmp main
	
Sort:
	sjmp start
	swap_:
		mov A,@r0
		xch A,@r1
		xch A,@r0
		RET
		
start:
mov r0,#60h
mov r1,#70h
mov r2,#5

copy: ; Copy all the numbers to the new locations
	mov A,@r0
	mov @r1,A
	inc r1
	inc r0
	djnz r2, copy

	mov r2,#4
	
main_loop:
	mov r0,#70h
	mov r1,#71h
	
	inner_loop:
		mov A,@r0
		clr c
		subb A,@r1
		jc skip
		acall swap_
		
		skip:
			inc r0
			inc r1
			cjne r0, #74h, inner_loop
		djnz r2, main_loop
RET

org 100h
main:
	mov 60h,#12
	mov 61h,#3
	mov 62h,#10	
	mov 63h,#8
	mov 64h,#7
	
	acall sort ; Calls sort subroutine

stop: sjmp stop
END