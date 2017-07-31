; Stores the partial sum into contiguous memory locations starting from 50h

org 0h
ljmp main
org 100h

main:
	mov 50h,#10 ; Say, we calculate partial sum of 10 numbers and store them contiguously in memory
	mov r0,#50h ; Used for accessing memloc indirectly
	mov r1,#00h ; Gets incremented and added to the total after each iteration 
	clr A
	loop:
		xch A,r1
		inc r1
		add A,r1
		inc r0
		mov @r0,A
		xch A,r1 ; Exchange the value of the registers for comparison in Accumulator
		cjne A, 50h, loop
	stop: sjmp stop
END