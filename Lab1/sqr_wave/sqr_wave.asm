; Generates a square wave
org 0h
ljmp main

org 100h	
main: 
	setb p1.7 ; setting the 7th bit of port 1 
	acall delay ; absolute call 
	clr p1.7 
	acall delay
	sjmp main

delay: 
	mov R1,#100 ; default decimal
	here: 
		djnz R1, here ; decrement and jump if not zero 
ret

end