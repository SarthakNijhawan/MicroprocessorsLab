; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 000H
ljmp main

ORG 100H
main:
	mov r0,#80H
	mov @r0,#53H
	inc r0
	mov @r0,#61H
	inc r0
	mov @r0,#72H
	inc r0
	mov @r0,#74H
	inc r0
	mov @r0,#68H
	inc r0
	mov @r0,#61H
	inc r0
	mov @r0,#6BH
	inc r0
	mov @r0,#20H
	inc r0
	mov @r0,#4EH
	inc r0
	mov @r0,#69H
	inc r0
	mov @r0,#6AH
	inc r0
	mov @r0,#68H
	inc r0
	mov @r0,#61H
	inc r0
	mov @r0,#77H
	inc r0
	mov @r0,#61H
	inc r0
	mov @r0,#6EH
	inc r0
	mov @r0,#00H
	ljmp start
	
org 200h
start:
      mov P2,#00h
	  mov P1,#00h
	  ;initial delay for lcd power up

;here1:setb p1.0
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1


	  acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
	  mov 	a,#83h		 ;Put cursor on first row,3 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay

	  mov a,#0C0h		  ;Put cursor on second row,0 column
	  acall lcd_command
	  acall delay
	  mov   r0,#80H
	  acall lcd_sendstring_name

here: sjmp here				//stay here 

;------------------------LCD Initialisation routine----------------------------------------------------
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
         clr   a                 ;clear Accumulator for any previous data
         movc  a,@a+dptr         ;load the first character in accumulator
         jz    exit              ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   dptr              ;increment data pointer
         sjmp  LCD_sendstring    ;jump back to send the next character
exit:
         ret                     ;End of routine
		 
;-----------------------text strings sending routine-------------------------------------
lcd_sendstring_name:
         clr   a                 ;clear Accumulator for any previous data
         mov   a,@r0         	 ;load the first character in accumulator
         jz    exit2              ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   r0              ;increment data pointer
         sjmp  LCD_sendstring_name    ;jump back to send the next character
exit2:
         ret                     ;End of routine

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

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "EE337-Lab2", 00H
end

