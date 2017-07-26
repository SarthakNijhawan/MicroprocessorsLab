org 0h
ljmp main
org 100h
		
		main : 
			setb p1.7
			acall delay
			clr p1.7
			acall delay
			sjmp main
			
			
		delay : 
			mov R1, #100
			here : djnz R1, here
			ret
			
end
				