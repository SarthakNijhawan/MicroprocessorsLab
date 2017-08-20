;Blink LEDs at P1 using interrrupts
org 00h
ljmp main

org 0bh 		;Timer Interrupt
	cpl 90H		;P1=80H Address Location
reti

org 100h
port:
	mov IE,#82h
	mov TMOD,#01h
	mov P1,#0
	mov TH0,#0
	mov TL0,#0
	setb TR0 	;Starting the timer
ret

main:
	acall port
	stop: sjmp stop
end