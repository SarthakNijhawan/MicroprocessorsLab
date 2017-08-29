;Display the contents stored at a memloc on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

org 00h
ljmp main

org 0BH
ljmp timer_int0

org 1BH
ljmp timer_int1

org 100H
init_clock:
	mov 70H,#31H
	mov 71H,#32H
	mov 72H,#':'
	mov 73H,#35H
	mov 74H,#39H
	mov 75H,#':'
	mov 76H,#33H
	mov 77H,#30H
	mov 78H,#' '
	mov 79H,#' '
	mov 7AH,#' '
	mov 7BH,#' '
ret

start_timers:
	mov r7,#30D
	mov TMOD,#11H
	mov TCON,#00H
	mov IE,#8AH
	setb PT1					;Setting higher priority to timer1 than timer0
	clr TF0
	clr TF1
	setb TR0
	setb TR1
ret

main:
	mov SP,#0C7H
	
	mov P1,#0FH					;First configure switches as input and LED’s as output
	acall lcd_init				;initialise LCD
	acall delay
	acall delay
	acall delay
	
	acall init_clock
	acall start_timers
	
loop_main:
	mov   a,#80H		 		;Put cursor on first row,0 column
	acall lcd_command	 		;send command to LCD
	acall delay
	mov   dptr,#my_string    	;Load DPTR with sring1 Addr
	acall lcd_sendstring		;call text strings sending routine
	acall delay
								;Display the value of memory address and content in Hex on LCD
	mov   a,#0C4H		  		 	;Put cursor on second row,0 column
	acall lcd_command
	acall delay
	mov   r0,#70H
	acall lcd_sendstring_name	;eg: Display "12 53"  where memory location 12H contains value 53H
	
	sjmp loop_main				;return to loop
	
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
	
org 300H
update_mm_sec:
	push psw
	push acc
	
	clr A
	cjne @r0,#39H,skip_
	mov @r0,#30H
	dec r0
	cjne @r0,#35H,skip_
	mov @r0,#30H
	mov A,#10H
	sjmp terminate
	skip_:
		inc @r0
	terminate:

	pop acc
	pop psw
ret

update_hh:
	dec r0
	cjne @r0,#31H,single_dig
	inc r0
	cjne @r0,#32H,skip_hh
	mov @r0,#31H
	dec r0
	mov @r0,#30H
	sjmp terminate_
	single_dig:
		inc r0
		cjne @r0,#39H,skip_hh
		mov @r0,#30H
		dec r0
		mov @r0,#31H
		sjmp terminate_hh
	skip_hh:
		inc @r0
	terminate_hh:
ret

update_time:
	mov r0,#77H
	acall update_mm_sec
	jz terminate_
	mov r0,#74H
	acall update_mm_sec
	jz terminate_
	mov r0,#71H
	acall update_hh
	
	terminate_:
ret

;-------------------------------------Timer0 Interrupt------------------------------------
timer_int0:
	clock_setup:
		mov A,4FH				;Current State from 4FH
		jnb 0E0H,skip
		xrl A,4EH
		mov B,A
			jnb 0F1H,min
			mov r0,#77H
			acall update_mm_sec
		min:
			jnb 0F2H,hh
			mov r0,#74H
			acall update_mm_sec
		hh:
			jnb 0F3H,clock_setup
			mov r0,#71H
			acall update_hh
	sjmp clock_setup
	skip:
		djnz r7,term_int
		acall update_time
		mov r7,#30
	term_int:
		reti

;-----------------------------------------Timer1 Interrupt---------------------------------

timer_int1:						;Current stable value at 4FH and prev stable value at 4EH
	push psw
	push acc
	
	mov  A,P1					;Taking the input from port 1
	anl  A,#0FH
	cjne A,4FH,new				;First check from the current acceptable value
	mov 4EH,4FH					;Prev state is same as current
	sjmp term
	new:
		cjne A,4DH,new2			;If already occured then 4FH = 4EH
		mov  4EH,4FH			;4EH now stores the previous stable state
		mov  4FH,4DH			;4FH, current state changes
		sjmp term
	new2:
		mov 4DH,A				;If occurs for the first time
		mov 4EH,4FH
	term:
		mov P1,#0FH				;Setting the port for input again
		mov TH1,#64H
		
	pop acc
	pop psw
reti

org 400H
	my_string:
		DB '      Time        ',00H
end