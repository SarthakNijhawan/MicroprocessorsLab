;; Assembly program to read a nibble from the slider swithches and dislplay on the LEDs
org 0H
ljmp main

delay: 				;This routine takes input from 4FH location
	push psw
	mov psw,#08H
	using 1
	mov A,4FH 		;This is D
	mov B,#10 		;Divides D by 2 and multiplies by 20 to convert into seconds
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
	
loop:
	setb P1.4		;turn on all 4 LEDs (routine is ready to accept input from the user)
	setb P1.5
	setb P1.6
	setb P1.7
	mov 4FH,#10		;wait for 5 sec during which user can give input through switches
	acall delay
	anl P1,#0FH		;turn off all LEDS
	mov A,P1		;read the input from switches (nibble)
	
value_changed:
	mov 4EH,A		;show the read value on LEDs and store in 4EH
	swap A
	mov P1,A
	mov 4FH,#10		;Display for 5 sec till a new input is fed
	acall delay
	anl P1,#0FH		;clear LEDs (pin P1.7 - p1.4)
	mov A,P1		;read the input from switches
	cjne A,#0FH,loop	;if  read value != 0Fh go to loop
	
display_old:
	mov A,4EH		;otherwise display previously stored nibble from location 4EH
	swap A
	mov P1,A
	mov 4FH,#10		;wait for 5 seconds
	acall delay
	RET 			;return from the subroutine.


;; =============================================
;; 				Main Function
;; =============================================
org 100h
main:
	mov SP,#0CFH 	;Initialising the pointer
	acall readNibble
here: sjmp here
end