; LED blink at p1.7

org 0h
ljmp main

delay: 
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
ret

org 100h
main:
	mov p1,#0
	mov 4fh,#1 ; Setting D to some value to check it
	
	setb P1.7
	blink:
		acall delay
		cpl P1.7
	sjmp blink
end