/**
 SPI HOMEWORK2, LABWORK2 (SAME PROGRAM)
 */

/* @section  INCLUDES */
#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

void SPI_Init();
void LCD_Init();
// void Timer_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);
char int_to_string(int val);
void init_control();
int set();
void run();
void split_into_characters(int number, char num_of_char, unsigned char* array);

sfr IE=0xA8;
char temp;

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag
sbit ONULL = P1^0;
bit transmit_completed= 0;							// To check if spi data transmit is complete
bit offset_null = 0;								// Check if offset nulling is enabled
bit roundoff = 0;
unsigned int adcVal=0, avgVal=0, initVal=0, adcValue = 0, timerVal=0;
unsigned char serial_data;
unsigned char data_save_high;
unsigned char data_save_low;
unsigned char i=0, samples_counter=0; //, timer_count=30;
unsigned char temperature[3],time[3];

unsigned int CT, del_T=50;
unsigned int DT=35;
bit start_timer=0;
sbit PIN = P1^0;		// This is to check the mode of the Temperature Controller
sbit RELAY = P3^7;		// This pins drives the delay
sbit LED = P3^6;		// just an LED

/**

 * FUNCTION_INPUTS:  P1.5(MISO) serial input  
 * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
 *                   P1.4(SSbar)
                     P1.6(SCK)
 */
void main(void)
{
	P3 = 0X00;											// Make Port 3 output 
	P2 = 0x00;											// Make Port 2 output 
	P1 &= 0xEF;											// Make P1 Pin4-7 output
	P0 &= 0xF0;											// Make Port 0 Pins 0,1,2 output
	
	SPI_Init();
	LCD_Init();
	// Timer_Init();
	
	/* First Line */
	LCD_CmdWrite(0x81);
	sdelay(100);
	LCD_StringWrite("DT", 2);

	LCD_CmdWrite(0x87);
	sdelay(100);
	LCD_StringWrite("CT", 2);

	LCD_CmdWrite(0x8C);
	sdelay(100);
	LCD_StringWrite("Time", 4);

	/* Control Signals Initialisation */
	init_control();

	LED=1;					// Is always kept in set mode

	while(1){
		
		if(PIN==1){  /* PIN is in mode SET */
			DT=set();
			// start_timer=1;	/* To start the timer on toggle */
			
			/* Time is set to zero */
			timerVal=0;			// Initial time value
			split_into_characters(timerVal, 3, time);

			/* displaying time */	
			LCD_CmdWrite(0xCC);
			sdelay(100);

			for(i=0; i<3; i++){
				temp = int_to_string(time[i]);
				LCD_DataWrite(temp);
			}

			/* Delay in Sampling */
			delay_ms(500);
		}
		else{	/* PIN is in mode RUN */
			// if(start_timer==1){
			// 	TR0=1;	// Start timer for the first time mode is toggled from set to run
			// }
			run();
			delay_ms(1000);
		}
	}
}

int set(){	/* Reads ADC value from channel 0 */
	while(1){

		CS_BAR = 0;                 // enable ADC as slave		 
		SPDAT= 0x01;				// Write start bit to start ADC 
		while(!transmit_completed);	// wait end of transmition; TILL SPIF = 1 i.e. MSB of SPSTA
		transmit_completed = 0;    	// clear software transfert flag 
		
		SPDAT= 0x80;				// 80H written to start ADC CH0 single ended sampling,refer ADC datasheet
		while(!transmit_completed);	// wait end of transmition 
		data_save_high = serial_data & 0x03;  
		transmit_completed = 0;    	// clear software transfer flag 
				
		SPDAT= 0x00;								// 
		while(!transmit_completed);	// wait end of transmition 
		data_save_low = serial_data;
		transmit_completed = 0;    	// clear software transfer flag 
		CS_BAR = 1;                	// disable ADC as slave
		
		adcVal = (data_save_high <<8) + (data_save_low);	// Value at adc

		/* Starts Sampling */
		samples_counter++;
		adcValue+=adcVal;
		if(samples_counter!=10) continue;
		else{
			samples_counter=0;
			avgVal = adcValue/200;			//Average
			adcValue=0;

			if(avgVal < 5){
				avgVal = 0;
			}
			else if(5<avgVal && avgVal<15){
				avgVal = 20;
			}
			else if(15<avgVal && avgVal<25){
				avgVal = 20;
			}
			else if(25<avgVal && avgVal<35){
				avgVal = 30;
			}
			else if(35<avgVal && avgVal<45){
				avgVal = 40;
			}
			else{
				avgVal = 50;
			}
			avgVal+=35;	// Final Temperature Value


			/* Splits the value into character array for Tx */
			split_into_characters(avgVal, 3, &temperature);

			/* Writes on the second line below DT */
			LCD_CmdWrite(0xC0);
			sdelay(100);

			for(i=0; i<3; i++){
				temp = int_to_string(temperature[i]);
				LCD_DataWrite(temp);
			}
		}

		PIN=1;				// Ensure that PIN is set as an input pin
		return avgVal;
	}	  	
}

void run(){	/* Reads from Channel 1 */

	while(1){

		CS_BAR = 0;                 // enable ADC as slave		 
		SPDAT= 0x01;				// Write start bit to start ADC 
		while(!transmit_completed);	// wait end of transmition; TILL SPIF = 1 i.e. MSB of SPSTA
		transmit_completed = 0;    	// clear software transfert flag 
		
		SPDAT= 0x90;				// 80H written to start ADC CH0 single ended sampling,refer ADC datasheet
		while(!transmit_completed);	// wait end of transmition 
		data_save_high = serial_data & 0x03;  
		transmit_completed = 0;    	// clear software transfer flag 
				
		SPDAT= 0x00;								// 
		while(!transmit_completed);	// wait end of transmition 
		data_save_low = serial_data;
		transmit_completed = 0;    	// clear software transfer flag 
		CS_BAR = 1;                	// disable ADC as slave
		
		adcVal = (data_save_high <<8) + (data_save_low);	// Value at adc

		/* Starts Sampling */
		samples_counter++;
		adcValue+=adcVal;
		if(samples_counter!=10) continue;
		else{
			samples_counter=0;
			avgVal = adcValue/20;			//Average
			adcValue=0;

			split_into_characters(avgVal, 3, temperature);

			/* Writes on the second line below CT */
			LCD_CmdWrite(0xC6);
			sdelay(100);

			/* Displays the current Tempearture */
			for(i=0; i<3; i++){
				temp = int_to_string(temperature[i]);
				LCD_DataWrite(temp);
			}
		}

		CT=avgVal;

		// if( TR0 && (DT<avgVal) ){	/* Temperature reaches the DT */
			// TR0=0;			/* 
			// start_timer=0;	/* Won't allow the timer to run henceforth */
		// }
		/* Updating time */
		if( DT > CT ){	/* Till the temperature reaches DT */
			timerVal++;
			split_into_characters(timerVal, 3, time);

			LCD_CmdWrite(0xCC);
			sdelay(100);

			/* Updates the time */
			for(i=0; i<3; i++){
				temp = int_to_string(time[i]);
				LCD_DataWrite(temp);
			}
		}


		/* Regulate Temperature */
		if( (DT+del_T) < CT ){
			RELAY=0;
		}
		else if( (DT-del_T) > CT ){
			RELAY=1;
		}

		PIN=1;				// Ensure that PIN is set as an input pin
		break;
	}
}

void split_into_characters(unsigned int number, char num_of_char, unsigned char* array){
	for ( i=num_of_char-1; i>=0; i--)
	{
		/* code */
		array[i]=number%10;
		number/=10;
	}
}

void init_control(){
	/* Switching off the power supply */
	RELAY=0;

	/* Setting P1^0 as input */
	PIN=1;
}

// void Timer_Init()
// {
// 	// Set Timer0 to work in up counting 16 bit mode. Counts upto 
// 	// 65536 depending upon the calues of TH0 and TL0
// 	// The timer counts 65536 processor cycles. A processor cycle is 
// 	// 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow
    
// 	TH0 = 0x00;							//Initialize TH0
// 	TL0 = 0x00;							//Initialize TL0
// 	TMOD = 0x01; 						//Configure TMOD 
// 	// IE |= 0x82; 						//Set ET0
// 	TR0 = 0;							//Set TR0
// 	// timer_count = 30;
// }

// void timer0_ISR (void) interrupt 1			
// {
// 	//Initialize TH0
// 	//Initialize TL0
// 	//Increment Overflow 
// 	//Write averaging of 10 samples code here

	// if(timer_count==0){							// 100ms passed
	// 	// One second completed
	// 	timerVal++;
	// 	split_into_characters(timerVal, 3, time);
	// 	timerVal=0;

	// 	LCD_CmdWrite(0xCC);
	// 	sdelay(100);

	// 	/* Updates the time */
	// 	for(i=0; i<3; i++){
	// 		temp = int_to_string(time[i]);
	// 		LCD_DataWrite(temp);
	// 	}

// 		timer_count=30;
// 	}
// 	else timer_count--;
// }

/**
 * FUNCTION_PURPOSE:interrupt
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: transmit_complete is software transfert flag
 */
void it_SPI(void) interrupt 9 /* interrupt address is 0x004B, (Address -3)/8 = interrupt no.*/
{
	switch	( SPSTA )         /* read and clear spi status register */
	{
		case 0x80:	
			serial_data=SPDAT;   /* read receive data */
      		transmit_completed=1;/* set software flag */
 		break;

		case 0x10:
         /* put here for mode fault tasking */	
		break;
	
		case 0x40:
         /* put here for overrun tasking */	
		break;
	}
}

char int_to_string(int val){
	val += 0x30;
	return (char)val;
}

/**

 * FUNCTION_INPUTS:  P1.5(MISO) serial input  
 * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
 *                   P1.4(SSbar)
                     P1.6(SCK)
 */ 
void SPI_Init()
{
	CS_BAR = 1;	                  	// DISABLE ADC SLAVE SELECT-CS 
	SPCON |= 0x20;               	 	// P1.1(SSBAR) is available as standard I/O pin 
	SPCON |= 0x01;                	// Fclk Periph/4 AND Fclk Periph=12MHz ,HENCE SCK IE. BAUD RATE=3000KHz 
	SPCON |= 0x10;               	 	// Master mode 
	SPCON &= ~0x08;               	// CPOL=0; transmit mode example|| SCK is 0 at idle state
	SPCON |= 0x04;                	// CPHA=1; transmit mode example 
	IEN1 |= 0x04;                	 	// enable spi interrupt 
	EA=1;                         	// enable interrupts 
	SPCON |= 0x40;                	// run spi;ENABLE SPI INTERFACE SPEN= 1 
}



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