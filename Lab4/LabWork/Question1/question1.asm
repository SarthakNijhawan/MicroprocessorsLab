; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 000H
ljmp main

ORG 100H
	;;Parameters:
	;;		50H -> N
	;; 		51H -> Starting Pointer

spaceOut:				
	mov r1,50h
	mov r0,51h
	loop_zero:
		mov @r0,#0
		inc r0
		djnz r1, loop_zero
ret



	;;Parameters:
	;;		50H -> D
	
delay_: 					;This routine takes input from 50H location
	using 0
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
	
	
	
	;;Parameters:
	;;		53H -> Nibble
	;; 		r0  -> Write Location

write_nibble: 				;Nibble in 53h and write location in r0
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
		
		
		
	;;Parameters:
	;;		50H -> N
	;; 		51H -> Read Pointer
	;; 		52H -> Write Pointer

bin2ascii:
	mov r2,50h 				;N
	mov r1,51h 				;Read pointer
	mov r0,52h 				;Write pointer	
	
	binloop:
		mov A,@r1
		anl A,#0F0H 		;higher nibble saved , rest all bits to 0
		swap A
		mov 53h,A
		acall write_nibble 	;53h as argument parameter
		inc r0
		
		mov A,#0FH
		anl A,@r1 			;Lower order bits recovered
		mov 53h,A
		acall write_nibble
		inc r0
		inc r1
	djnz r2,binloop
ret

;======================================
;			Main Function
;======================================

main:
	mov SP,#0C7H
	mov 50H,#64D			;ZeroOut the locations before displaying
	mov 51H,#80H			
	acall spaceOut
	
	mov r0,#80H				;80H -> "ABPSW="
	mov @r0,#41H
	inc r0
	mov @r0,#42H
	inc r0
	mov @r0,#50H
	inc r0
	mov @r0,#53H
	inc r0
	mov @r0,#57H
	inc r0
	mov @r0,#3DH
	
	mov r0,#90H				;90H -> "R012="
	mov @r0,#'R'
	inc r0
	mov @r0,#'0'
	inc r0
	mov @r0,#31H
	inc r0
	mov @r0,#32H
	inc r0
	mov @r0,#3DH
	
	mov r0,#0A0H			;0A0H -> "R345="
	mov @r0,#52H
	inc r0
	mov @r0,#33H
	inc r0
	mov @r0,#34H
	inc r0
	mov @r0,#35H
	inc r0
	mov @r0,#3DH
	
	mov r0,#0B0H			;0B0H -> "R67SP"
	mov @r0,#52H
	inc r0
	mov @r0,#36H
	inc r0
	mov @r0,#37H
	inc r0
	mov @r0,#53H
	inc r0
	mov @r0,#50H
	inc r0
	mov @r0,#3DH

;======================================
;	Test Data fed into the registers
;======================================
	mov r0,#00
	mov r1,#10
	mov r2,#20
	mov r3,#30
	mov r4,#40
	mov r5,#50
	mov r6,#60
	mov r7,#70
	
;==========================================
;	Copying everything to an array (#70H)
;==========================================
	mov 70H,r0
	mov 71H,r1
	mov 72H,r2
	mov 73H,r3
	mov 74H,r4
	mov 75H,r5
	mov 76H,r6
	mov 77H,r7
	mov 78H,sp
	mov 79H,A
	mov 7AH,B
	mov 7BH,psw
	
	binascii:
		mov 50H,#3				;R012
		mov 51H,#70H
		mov 52H,#95H
		acall bin2ascii
		
		mov 50H,#3				;R345
		mov 51H,#73H
		mov 52H,#0A5H
		acall bin2ascii
		
		mov 50H,#3				;R67SP
		mov 51H,#76H
		mov 52H,#0B6H
		acall bin2ascii
		
		mov 50H,#3				;ABPSW
		mov 51H,#79H
		mov 52H,#86H
		acall bin2ascii
	
	ljmp start
	
	
org 200h
start:
      mov P2,#00h
	  mov P1,#00h
	  
      acall delay				;initial delay for lcd power up
	  acall delay
	  acall lcd_init      		;initialise LCD
	  acall delay
	  acall delay
	  acall delay
	  
	  ;=====================================
	  ;				LCD display
	  ;=====================================
	  mov 	a,#80H				;Put cursor on first row,0 column
	  acall lcd_command	 		;send command to LCD
	  acall delay
	  mov   r0,#80H   			;Load DPTR with sring1 Addr
	  acall lcd_sendstring_name	;call text strings sending routine
	  acall delay

	  mov a,#0C0H		  		;Put cursor on second row,0 column
	  acall lcd_command
	  acall delay
	  mov   r0,#90H
	  acall lcd_sendstring_name
	  
	  mov 50H,#10D
	  acall delay_
	  
	  ;=====================================
	  ;				Second LCD display
	  ;=====================================
	  mov 	a,#80h		 		;Put cursor on first row,0 column
	  acall lcd_command	 		;send command to LCD
	  acall delay
	  mov   r0,#0A0H 	  		;Load DPTR with sring1 Addr
	  acall lcd_sendstring_name	;call text strings sending routine
	  acall delay

	  mov   a,#0C0h			  	;Put cursor on second row,0 column
	  acall lcd_command
	  acall delay
	  mov   r0,#0B0H
	  acall lcd_sendstring_name
	  
	  mov 50H,#10D
	  acall delay_
	  
here: sjmp here				//stay here 

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  	;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         	;Selected command register
         clr   LCD_rw         	;We are writing in instruction register
         setb  LCD_en         	;Enable H->L
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
lcd_sendstring_name:
         clr   a                 ;clear Accumulator for any previous data
         mov   a,@r0         	 ;load the first character in accumulator
         jz    exit2             ;go to exit if zero
         acall lcd_senddata      ;send first char
         inc   r0              	 ;increment data pointer
         sjmp  LCD_sendstring_name    ;jump back to send the next character
exit2:
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 
	using 1
		push psw
		mov psw,#08H
         
		mov r0,#1
loop2:	mov r1,#255
loop1:	djnz r1, loop1
		djnz r0,loop2
		 
		pop psw
ret

end