#include "at89c5131.h"
#include "stdio.h"

/* Functions Declaration */
void ISR_serial(void);
void init_serial();
char receive_data(void);
void transmit_data(unsigned char str);
void transmit_string(char* str, int n);
void delay_ms(int delay);


void SPI_Init();
char int_to_string(int val);

sfr IE=0xA8;
sbit parity_bit = PSW^0;

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit ONULL = P1^0;
bit transmit_completed= 0;							// To check if spi data transmit is complete
bit offset_null = 0;								// Check if offset nulling is enabled
bit roundoff = 0;
unsigned int adcVal=0, avgVal=0, initVal=0, adcValue = 0, tempVal = 0;
unsigned char serial_data;
unsigned char data_save_high;
unsigned char data_save_low;
unsigned char i=0, samples_counter=0;
unsigned char voltage[3];

char* string1 = "Press Y to start sampling the data\n";
char* string2 = "To stop sampling press N\n";
char* string3 = "Temperature: ";
char received_data;

//=========================================================
				/* Main Function */
//=========================================================
/**

 * FUNCTION_INPUTS:  P1.5(MISO) serial input  
 * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
 *                   P1.4(SSbar)
                     P1.6(SCK)
 */

void main(){	
	
	SPI_Init();
	init_serial();
	
	while(1){
		transmit_string(string1, 35);					// "Press Y to start ....."
		received_data = receive_data();
		
		if(received_data == 'Y') break;
	}
	

	while(1) 
	{

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

	
		samples_counter++;
		adcValue+=adcVal;
		if(samples_counter!=10) continue;
		else{
			samples_counter=0;
			avgVal = adcValue/20;			//Average
			adcValue=0;
			voltage[0]=avgVal/100;
			voltage[0]%=10;
			voltage[1]=avgVal/10;
			voltage[1]%=10;
			voltage[2]=avgVal;
			voltage[2]%=10;
		}

		transmit_string(string3, 14);
		for(i=0; i<3; i++){
			transmit_data(int_to_string(voltage[i]));
		}
		transmit_data('\n');

		transmit_string(string2, 25);

		received_data = receive_data();
		if(received_data == 'N') break;
  }

  while(1);									// Wait forever
}


void init_serial()
{
	//Initialize serial communication and interrupts
	TMOD = 0x20;						// Timer1 in mode 2
	SCON = 0xD0;						// Serial in mode 3
	TH1 = -52;							// To ensure 1200 baud rate
	TR1 = 1;							// Initiate the timer
	TI = 0;
	RI = 0;
}


char receive_data(void)
{
	//function to receive data over RxD pin.
	char rec_data;
	unsigned int d=0;
	
	delay_ms(2000);
 	if(RI==1){
		rec_data = SBUF;
		RI=0;
		return rec_data;
	}

	return 'A';							// Arbitrarily setting the return value to 'A'

}


void transmit_data(unsigned char str)
{
	//function to transmit data over TxD pin.
	TI=0;
	ACC = str;
	TB8 = parity_bit;
	SBUF = ACC;
	while(TI==0);						// Wait till data gets trnasmitted fully
	TI=0;
}


void transmit_string(char* str, int n)
{
	//function to transmit string of size n over TxD pin.
	for(i=0; i<n; i++) transmit_data(str[i]);
}


// ========================================================================================================
									/* Previous Lab's Functions */
// ========================================================================================================
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

void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}