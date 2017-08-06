; LED blink at p1.7

org 0h
ljmp main

delay: ; delay function basically takes 50ms in one call
	mov R2,#200
    back1:
    mov R1,#0FFH
    back:
	djnz R1, back
    djnz R2, back1
ret

org 100h
main:
	mov p1,#0
	mov 4fh,#5
	mov A,4fh ; This is D
	mov B,#2
	div AB
	mov B,#20
	mul AB ; Now A has the total number of times delay must be called
	setb P1.7
	blink:
		mov r0,A
		delay1:
			acall delay
			djnz r0, delay1
		cpl P1.7
		ljmp blink
	
end