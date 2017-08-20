org 0h
ljmp main

delay:
		push psw
		mov psw,#08H
		mov R2,#208D
		back1:
			mov R1,#0FFH
			back: djnz R1, back
		djnz R2, back1
		pop psw
ret

wave:
	mov R1,#8
	mov A,#0
	mov P1,#00H
	;acall delay
	loop:
		mov r0,A
		mov A,#4
		clr c
		subb A,r1
		mov A,r0
		jnc subn
	addn:
		add A,#50
		sjmp check
	subn:
		clr c
		subb A,#50
	check:
		mov P1,A
		acall delay
		djnz R1,loop
ret

org 100H
main:
	mov P1,#00H
	acall wave
	stop: sjmp stop
end