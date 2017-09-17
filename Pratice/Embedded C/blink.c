// This program flashes the P1.4 RED LED on the Pt-51 target board at interval of 1 sec   

#include <AT89C5131.h> 						// All SFR declarations for AT89C5131

sbit LED=P1^7; 								// assigning label to P1^7 as "LED"

void delayms(unsigned int ms_sec);

void main (void){
	P1=0x07F;								// port pin P1.3 as output
	LED=0;									// Initialise LED to 0;
	while(1){
		LED=~LED;
		delayms(1000);						// Calls delay
	}
}

void delayms(unsigned int ms_sec){
	unsigned int i,j;

	for (i = 0; i < ms_sec; ++i)
	{
		for (j = 0; j < 355; ++j);			//This loop runs 355 times which approximately gives 1ms delay with 24MHz system clock.
	}
}