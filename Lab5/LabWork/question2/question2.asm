;Debouncing os switches
org 00H
ljmp main

org 01BH
ljmp timer_int1

org 100H
start_timer:
	mov TMOD,#10H
	mov IE,#88H
	clr TF1
	setb TR1
ret


main:
	mov P1,#0FH					;Set the pins as input
	mov 4FH,P1					;Prev value stored in 4FH
	acall start_timer
	
	stop: sjmp stop

org 200H
debounce:
	mov  A,P1
	cjne A,4FH,new
	sjmp term
	new:
		mov  A,P1
		cjne A,4EH,new2
		mov 4FH,4EH
		sjmp term
	new2:
		mov 4EH,P1
	term:
		;mov P1,#0FH
		mov TH1,#64H
ret



timer_int1:			
	acall debounce				;Final acceptable value at 4FH
reti

end