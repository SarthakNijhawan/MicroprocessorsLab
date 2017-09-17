#include "at89c5131.h"

sbit LED = P1^7;						// Alias for 7th pin on port1
sbit LED_parity = P1^6;					// Alias for 6th pin on port1
sbit parity = PSW^0;					// Parity bit
sfr IE = 0xA8;

void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}

// Template for homework on UART
void ISR_Serial(void) interrupt 4
{
	//ISR for serial interrupt
	TI = 0;
	LED = ~LED;							// Toggle the LED
	delay_ms(1000);
	ACC = 'A';							// To set the parity bit accordingly
	TB8 = parity;
	LED_parity = parity;
	SBUF = ACC;
	
}

void init_serial()
{
	//Initialize serial communication and interrupts

	TMOD = 0x20;						// Timer1 in mode 2
	IE = 0x90;							// Setting up the serial interrupts
	SCON = 0xC0;						// REN = 0, to ensure only trnasmission takes place, serial in mode 3
	TH1 = -52;							// To ensure 1200 baud rate
	TR1 = 1;							// Initiate the timer

}

void main()
{
	init_serial();
	P1 = 0;
	LED = 1;							// Switching on the LED
	
	ACC = 'A';
	TB8 = parity;
	LED_parity = parity;
	SBUF = ACC;

	while(1);
}