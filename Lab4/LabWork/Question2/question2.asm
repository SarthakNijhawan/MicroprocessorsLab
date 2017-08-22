;Display the contents stored at a memloc on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

org 00h
ljmp main

org 100h
;======================================
;			Delay Function
;======================================
delay_: 					;This routine takes input from 50H location
	push psw
	mov psw,#08H
	using 1
	mov A,50H 				;This is D
	mov B,#10 				;Divides D by 2 and multiplies by 20 to convert into seconds
	mul AB 					;Now A has the total number of times delay must be called
	mov r0,A 				;Total number of iterations over 50ms stored in A
	delay1:
		mov R2,#200
		back1:
			mov R1,#0FFH
			back: djnz R1, back
		djnz R2, back1
	djnz r0, delay1
	pop psw
ret

;======================================
;			packNibble Function
;======================================

readNibble:
	using 0
	mov 50H,#10D
	mov R0,#0
	loop:
		mov 4EH,R0
		mov P1,#0FFH
		acall delay_
		anl P1,#0FH
		mov A,P1
		mov R0,A
		swap A
		orl P1,A
		acall delay_
		cjne R0,#0FH,loop
		
		mov A,4EH
		swap A
		mov P1,A
		acall delay_
		mov P1,#00H
		mov 50H,#2
		acall delay_
ret

packNibble:
	acall readNibble
	mov A,4EH
	swap A
	mov 4FH,A
	acall readNibble
	mov A,4EH
	orl A,4FH
	mov 4FH,A
ret

;======================================
;		bin2ascii subroutine	
;======================================

write_nibble: 					;Lower nibble in 53h and write location in r0
		clr c
		subb A,#0ah
		jc digit
			add A,#41h
			mov @r0,A
		sjmp comp
		digit:
			mov A,53h
			add A,#30h
			mov @r0,A
		comp: ret

bin2ascii:
	using 1
		push psw
		mov psw,#08H
	mov r2,50h 					;N
	mov r1,51h 					;Read pointer
	mov r0,52h 					;Write pointer	
	
	binloop:
		mov A,@r1
		anl A,#0F0H 			;higher nibble saved , rest all bits to 0
		swap A
		mov 53h,A
		acall write_nibble 		;53 is reserved for its argument parameter
		inc r0
		
		mov A,#0FH
		anl A,@r1 				;Lower order bits recovered
		mov 53h,A
		acall write_nibble
		inc r0
		inc r1
	djnz r2,binloop
	pop psw
ret

;===============================================
;				Main Function
;===============================================
main:
	mov sp,#0C7H
	mov 12H,#53H
	
	mov P1,#0FH					;First configure switches as input and LED’s as output
	acall lcd_init				;initialise LCD
	acall delay
	acall delay
	acall delay

loop_main:
	
	mov   a,#80h		 		;Put cursor on first row,0 column
	acall lcd_command	 		;send command to LCD
	acall delay
	mov  dptr,#my_string    	;Load DPTR with sring1 Addr
	acall lcd_sendstring		;call text strings sending routine
	acall delay

	mov 50H,10D					;wait for 5 sec
	acall delay_
	
	acall packNibble			;Read 8 bit value using subroutine packNibbles
	
	;;;;;;;;
	mov 50H,#1					;Parsing the memloc
	mov 51H,#4FH
	mov 52H,#60H
	acall bin2ascii
	
	mov 62H,#' '
	mov r0,4FH
	mov 4FH,@r0					;Storing the value inside the location stored in 4FH
	
	mov 50H,#1					;Parsing the memloc
	mov 51H,#4FH
	mov 52H,#63H
	acall bin2ascii
	
	mov 65H,#0H
	
								;Display the value of memory address and content in Hex on LCD
	mov a,#0C5H		  		 	;Put cursor on second row,0 column
	acall lcd_command
	acall delay
	mov   r0,#60H
	acall lcd_sendstring_name	;eg: Display "12 53"  where memory location 12H contains value 53H
	
	mov 50H,#10D			 	;wait for 5 sec
	acall delay_
	
	sjmp loop_main				 ;return to loop
	
	stop: sjmp stop

;======================================
;			LCD subroutines
;======================================
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
         clr   a                  ;clear Accumulator for any previous data
         movc  a,@a+dptr          ;load the first character in accumulator
         jz    exit               ;go to exit if zero
         acall lcd_senddata       ;send first char
         inc   dptr               ;increment data pointer
         sjmp  LCD_sendstring     ;jump back to send the next character
exit:
         ret                      ;End of routine
		 
;-----------------------text strings sending routine-------------------------------------
lcd_sendstring_name:
         mov   a,@r0         	  ;load the first character in accumulator
         jz    exit2              ;go to exit if zero
         acall lcd_senddata       ;send first char
         inc   r0              	  ;increment register
         sjmp  LCD_sendstring_name    ;jump back to send the next character
exit2:
         ret                      ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 
	using 1
		push psw
		mov psw,#08H
         mov r0,#1
loop2:	 mov r1,#255
loop1:	 djnz r1, loop1
		 djnz r0,loop2
		 pop psw
		 ret

org 300h
	my_string:
		DB 'Enter memory Location',00H
end