;Finger print Scanner with all the data stored in the ROM
ORG 00h
LJMP MAIN

ORG 03H
LJMP SCAN

ORG 200H
SCAN:
	MOV R0,P1
	MOV R1,#40			;Total number of students
	MOV DPTR,#3000H
	LOOP:
		CLR A
		MOVC A,@A+DPTR
		CLR C
		SUBB A,R0
		JZ MATCH
		DJNZ R1,LOOP
		SJMP TERM
		MATCH:
			SETB P0.0
			MOV 4FH,#5D
			ACALL DELAY
			CLR P0.0
TERM:RETI

ORG 100H
DELAY:
	MOV TMOD,#01H
	SETB TR0
	HERE: JNB TF0,HERE
RET

MAIN:
	MOV IE,#81H				;Using the external interrupt 0
	SETB TCON.1				;Setting the incoming as edge triggered
	CLR P0.0
	STOP: SJMP STOP
END

