;Toggle LED on Timer Interrupts
org 00h
ljmp main

org 0bh
ljmp isr1

org 100h
toggle_led:					;Input parameter at 4FH => Timer Count 
	mov TMOD,#01H
	mov IE,#82H
	mov P1,#00H
	mov r0,4FH
	
	clr tf0
	setb tr0				;Starting the timer
	
ret


main:
	mov 4FH,#15				;At 15 the timer is close to 1 second
	acall toggle_led
	stop: sjmp stop
	
org 200h
isr1:
	djnz r0,skip
	cpl P1.7
	mov r0,4FH
	skip:
		reti

end