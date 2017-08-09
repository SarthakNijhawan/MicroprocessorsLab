; display routine for the last 4 bits 
org 0h
ljmp main

delay_with_banks:
	using 0
		push psw
	using 1
		mov psw,#08h
		
	mov A,4fh ; This is D
	mov B,#10 ; Divides D by 2 and multiplies by 20 to convert into seconds
	mul AB ; Now A has the total number of times delay must be called
	mov r0,A ; Total number of iterations over 50ms stored in A
	delay2:
		mov R2,#200
		back2:
			mov R1,#0FFH
			back3: djnz R1, back3
		djnz R2, back2
	djnz r0, delay2
		using 0
			pop psw
ret

delay: 
	using 0
		push psw
		push ar0
		push ar1
		push ar2
	
	using 1
	mov A,4fh ; This is D
	mov B,#10 ; Divides D by 2 and multiplies by 20 to convert into seconds
	mul AB ; Now A has the total number of times delay must be called
	mov r0,A ; Total number of iterations over 50ms stored in A
	delay1:
		mov R2,#200
		back1:
			mov R1,#0FFH
			back: djnz R1, back
		djnz R2, back1
	djnz r0, delay1
	using 0
			pop ar2
			pop ar1
			pop ar0
			pop psw
ret

display:
	mov r0,50h ; N
	mov r1,51h ; Ptr
	mov r2,#0fh ; To read the last 4 pins only
	
	mov 4fh,#2 ; D=2 to call the delay function
	loop:
		mov A,@r1
		anl A,r2
		mov r3,#4
		rotate:
			rr A
		djnz r3,rotate
		mov p1,A ; p1 is present at 90h and is directly addressable
		inc r1
		acall delay_with_banks
		djnz r0, loop
ret

org 100h
main:
	mov sp,#0cfh
	mov r1,#80h
	random:
		mov A,r1
		mov @r1,A
		inc r1
		cjne r1, #88h, random

	mov 50h,#8
	mov 51h,#80h
	
	lcall display
	
	mov p1,#0ffh ; Setting all the bits to 0
	
stop: sjmp stop
end