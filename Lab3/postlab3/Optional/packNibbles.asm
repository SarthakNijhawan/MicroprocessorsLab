;
org 0h
ljmp main

delay: 				;This routine takes input from 50H location
	push psw
	mov psw,#08H
	using 1
	mov A,50H 		;This is D
	mov B,#20 		;Divides D by 2 and multiplies by 20 to convert into seconds
	mul AB 			;Now A has the total number of times delay must be called
	mov r0,A 		;Total number of iterations over 50ms stored in A
	delay1:
		mov R2,#200
		back1:
			mov R1,#0FFH
			back: djnz R1, back
		djnz R2, back1
	djnz r0, delay1
	pop psw
ret

readNibble:
	using 0
	mov 50H,#5D	
	mov R0,#0
	loop:
		mov 4EH,R0
		mov P1,#0FFH
		;acall delay
		anl P1,#0FH
		mov A,P1
		mov R0,A
		swap A
		orl P1,A
		;acall delay
		cjne R0,#0FH,loop
		
		mov A,4EH
		swap A
		mov P1,A
		;acall delay
		mov P1,#00H
		mov 50H,#1
		;acall delay
ret

packNibble:
	acall readNibble
	mov A,4EH
	swap A
	mov 4FH,A
	acall readNIbble
	mov A,4EH
	orl A,4FH
	mov 4FH,A
ret

org 100h
main:
	acall packNibble
	stop: sjmp stop
end