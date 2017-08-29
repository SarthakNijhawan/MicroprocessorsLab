;Toggle LED on Timer Interrupts
org 00h
ljmp main

org 0bh
ljmp isr1

org 100h
toggle_led:					;Input parameter at 4FH => Timer Count
	using 2
		push psw
		mov psw,#10H
	mov TMOD,#01H
	mov IE,#82H
	mov P1,#00H
	mov r0,4FH
	
	clr tf0
	setb tr0				;Starting the timer
	pop psw
ret


main:
	mov 4FH,#30				;At 30 the timer is close to 1 second
	acall toggle_led
	stop: sjmp stop
	
org 200h
isr1:
	using 2
		push psw
		mov psw,#10H
	djnz r0,skip
	cpl P1.7
	mov r0,4FH
	skip:
		pop psw
		reti

end