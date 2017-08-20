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

zeroOut:
	mov r1,50h ; N
	mov r0,51h ; Pointer
	loop:
		mov @r0,#0
		inc r0
		djnz r1, loop
ret

display:
	mov r0,50h ; N
	mov r1,51h ; Ptr
	mov r2,#0fh ; To read the last 4 pins only
	disploop:
		mov r3,4fh ; 20 iterations of the delay subroutine will give us a delay of 1s
		mov A,@r1
		inc r1
		anl A,r2
		swap A
		mov P1,A
		delay1:
			;lcall delay
			djnz r3, delay1
		djnz r0,disploop
ret

write_lower_nibble: ; Lower nibble in 53h and write location in r0
	using 0
		clr c
		subb A,#0ah
		jc digit
			add A,r4
			mov @r0,A
		sjmp comp
		digit:
			mov A,53h
			add A,r3
			mov @r0,A
		comp: nop
ret

bin2ascii:
	mov r2,50h ; N
	mov r1,51h ; Read pointer
	mov r0,52h ; Write pointer
	
	mov r3,#30h ; Offset for 0
	mov r4,#41h ; Offset for A
	
	mov r5,#0f0h ; Starts the loop by extracting the lower 4-bits
	
	loopb2a:
		mov A,@r1
		anl A,r5 ; higher nibble saved , rest all bits to 0
		mov r6,#4
		rot: ; upper nibble is now in the lower half
			rr A
		djnz r6, rot
		mov 53h,A
		acall write_lower_nibble ; 53 is reserved for its argument parameter
		inc r0
		
		mov A,r5
		cpl A
		anl A,@r1 ; Lower order bits recovered
		mov 53h,A
		acall write_lower_nibble
		inc r0
		inc r1
	djnz r2,loopb2a
ret


compare: ; Compares 2 operands stored in r0 and r1
	clr c
	mov A,r0
	subb A,r1
ret

memcpy:
	mov r2,50h ; N
	mov r0,51h ; Read Pointer
	mov r1,52h ; Write Pointer
	acall compare 
	jc skip ; c is zero when Write Ptr < Read Ptr
	; Code
	loop1:
		mov A,@r0
		mov @r1,A
		inc r0
		inc r1
		djnz r2, loop1
	ljmp completed
	skip: ; Write Pointer > Read Pointer
	; Code
		mov A,r2
		add A,r1
		subb A,#1
		mov r1,A
		mov A,r2
		add A,r0
		subb A,#1
		mov r0,A
		loop2:
			mov A,@r0
			mov @r1,A
			dec r0
			dec r1
			djnz r2, loop2			
	completed: nop
ret

;;;; Main Program

ORG 100H
MAIN:
mov r1,#0a7h
mov r2,#8

write:
	mov A,r1
	mov @r1,A
	inc r1
djnz r2, write

MOV SP,#0CFH;-----------------------Initialize STACK POINTER
MOV 50H,#8;------------------------No of memory locations of Array A
MOV 51H,#80h;------------------------Array A start location
LCALL zeroOut;----------------------Clear memory

MOV 50H,#8;------------------------No of memory locations of Array B
MOV 51H,#88h;------------------------Array B start location
LCALL zeroOut;----------------------Clear memory

MOV 50H,#8;------------------------No of memory locations of source array
MOV 51H,#0a7h;------------------------Source array start location
MOV 52H,#80h;------------------------Destination array(A) start location
LCALL bin2ascii;--------------------Write at memory location

MOV 50H,#16;------------------------No of elements of Array A to be copied in Array B
MOV 51H,#80h;------------------------Array A start location
MOV 52H,#88h;------------------------Array B start location
LCALL memcpy;-----------------------Copy block of memory to other location

MOV 50H,#8;------------------------No of memory locations of Array B
MOV 51H,#88h;------------------------Array B start location
MOV 4FH,#5;------------------------User defined delay value
LCALL display;----------------------Display the last four bits of elements on LEDs

here:SJMP here;---------------------WHILE loop(Infinite Loop)
END