; LED blink at p1.7

org 0h
ljmp main

delay: 
	mov A,4fh 				; This is D
	mov B,#10 				; Divides by 2 and multiplies by 20 to convert into seconds
	mul AB 					; Now A has the total number of times delay must be called
	mov r0,A 				; Total number of iterations over 50ms stored in A
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
	clr p1.7
	mov 4fh,#10D
	blink:
		acall delay
		cpl p1.7
		sjmp blink
end