;Port1 as input
org 0h
ljmp main

delay: 
	mov A,4fh ; This is D
	mov B,#20 ;	multiplies by 20 to convert into seconds
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


directly_from_port:
	loop:
		mov P1,#0FFH
		mov 4FH,#5D
		acall delay
		mov A,P1
		anl A,#0FH
		swap A
		anl P1,#0FH
		orl P1,A
		mov 4FH,#5D
		acall delay
		sjmp loop
ret

indirectly_from_port:
	
ret

org 100h
main:
	acall directly_from_port
end