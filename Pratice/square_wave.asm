; Square Wave generator
ORG 0H
LJMP MAIN

PIN EQU P1.0

SQUARE_WAVE: 					;Using timer 0 in mode 1
	MOV TMOD,#01H
	SETB PIN	
	LOOP:
		MOV TH0,50H				;Load the values in the registers
		MOV TL0,51H				
		CPL P1.0
		SETB TR0				;Start the timer
		DELAY: JNB TF0,DELAY
		CLR TF0
		CLR TR0
		SJMP LOOP
RET

ORG 100H
MAIN:
	MOV SP,#0C7H
	MOV 50H,00H 				;Using timer in full mode
	MOV	51H,00H
	ACALL SQUARE_WAVE
END