#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

void meas_volt();
void INT0_Init();
void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);

sfr IE=0xA8;
unsigned int port_input=0;
unsigned char temp[3];
char i=0;
bit flag=0;

sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag

sbit CS_BAR = P3^7;
sbit RD_BAR = P3^6;
sbit WR_BAR = P3^5;
sbit arbit = P3^4;

void main(void){
	// P3 = 0X00;											// Make Port 3 output 
	P2 = 0x00;											// Make Port 2 output 
	P1 = 0xFF;											// P1 Input port

	LCD_Init();
	// P1 = 0xFF;							// Input port

	while(1){
		meas_volt();

		if(flag == 1){
			port_input = port_input*50;
			port_input /= 255;

			/* Updates the desired temperature */
			temp[0]=port_input/10;
			temp[0]%=10;
			temp[1]=port_input;
			temp[1]%=10;

			LCD_CmdWrite(0xC0);
			sdelay(100);

			for(i=0; i<2; i++){
				LCD_DataWrite(temp[i]+'0');
			}

			flag=0;
		}

		// P1=0xFF;
		delay_ms(100);
	}
}


void INT0_ISR (void) interrupt 0	
{
	// sdelay(10);

	// CS_BAR=0;
	// sdelay(100);
	TCON &= 0xFD;

	sdelay(1);

	RD_BAR=0;
	sdelay(10);

	RD_BAR=1;
	sdelay(1);

	port_input=P1;	// READ INPUT
	flag=1;

	arbit=~arbit;
}

void INT0_Init(){
	CS_BAR = 0;
	RD_BAR = 1;
	WR_BAR = 1;
	IE |= 0x81; 						// Enable interrupt
	IT0=1;								// falling edge
}

void meas_volt(){
	INT0_Init();
	sdelay(1);

	CS_BAR = 0;                 // enable ADC as slave		 
	
	sdelay(2);
	WR_BAR = 0;

	sdelay(2);
	WR_BAR = 1;

}

// -------------------------------------------- LCD Functions 

/**
 * FUNCTION_PURPOSE:LCD Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Init()
{
  sdelay(100);
  LCD_CmdWrite(0x38);   		// LCD 2lines, 5*7 matrix
  LCD_CmdWrite(0x0C);			// Display ON cursor ON  Blinking off
  LCD_CmdWrite(0x01);			// Clear the LCD
  LCD_CmdWrite(0x80);			// Cursor to First line First Position
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: cmd- command to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_CmdWrite(char cmd)
{
  LCD_Ready();
  LCD_data=cmd;     			// Send the command to LCD
  LCD_rs=0;         	 		// Select the Command Register by pulling LCD_rs LOW
  LCD_rw=0;          			// Select the Write Operation  by pulling RW LOW
  LCD_en=1;          			// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: dat- data to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_DataWrite( char dat)
{
	LCD_Ready();
  	LCD_data=dat;	   				// Send the data to LCD
  	LCD_rs=1;	   					// Select the Data Register by pulling LCD_rs HIGH
  	LCD_rw=0;    	     			// Select the Write Operation by pulling RW LOW
  	LCD_en=1;	   					// Send a High-to-Low Pusle at Enable Pin
  	sdelay(5);
  	LCD_en=0;
	sdelay(5);
}

/**
 * FUNCTION_PURPOSE: Write a string on the LCD Screen
 * FUNCTION_INPUTS: 1. str - pointer to the string to be written, 
										2. length - length of the array
 * FUNCTION_OUTPUTS: none
 */
void LCD_StringWrite( char * str, unsigned char length)
{
    while(length>0)
    {
        LCD_DataWrite(*str);
        str++;
        length--;
    }
}

/**
 * FUNCTION_PURPOSE: To check if the LCD is ready to communicate
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Ready()
{
	LCD_data = 0xFF;
	LCD_rs = 0;
	LCD_rw = 1;
	LCD_en = 0;
	sdelay(5);
	LCD_en = 1;
	while(LCD_busy == 1)
	{
		LCD_en = 0;
		LCD_en = 1;
	}
	LCD_en = 0;
}

/**
 * FUNCTION_PURPOSE: A delay of 15us for a 24 MHz crystal
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
}

/**
 * FUNCTION_PURPOSE: A delay of around 1000us for a 24MHz crystel
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}