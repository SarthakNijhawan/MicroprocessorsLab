; display routine for the last 4 bits 
org 0h
ljmp main

delay:
	mov r4,#200
    back1:
    mov r5,#0FFH
    back:
	djnz r5, back
    djnz r4, back1
ret

delay_banks:
	using 0
	push psw
	push AR0
	push AR1
	push AR2
	push AR3

	using 1
	mov r0,#200
    back2:
    mov r1,#0FFH
    back0:
	djnz r1, back0
    djnz r0, back2
	
	using 0
	pop ar3
	pop ar2
	pop ar1
	pop ar0
	pop psw
ret

display:
	mov r0,50h ; N
	mov r1,51h ; Ptr
	mov r2,#0fh ; To read the last 4 pins only
	loop:
		mov r3,#30 ; 20 iterations of the delay subroutine will give us a delay of 1s
		mov A,@r1
		inc r1
		anl A,r2
		mov 90h,A
		delay1:
			lcall delay_banks
			djnz r3, delay1
		djnz r0,loop
ret

org 100h
main:
		
	mov 50h,#4
	mov 51h,#66h
	lcall display
	mov p1,#0ffh
stop: sjmp stop
end