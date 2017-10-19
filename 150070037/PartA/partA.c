#include "at89c5131.h"
#include "stdio.h"

void pwm_sig(unsigned char dutyCycle);
void TimerInit();

sfr IE=0xA8;
sbit PIN=P3^0;								// Output Pin

unsigned char duty_cycle=60;
unsigned char high[2], low[2];				// initial values for the timer reg

bit high_bit=1;								// checks

// =================================== Main Function ===============================

void main(void){

	pwm_sig(duty_cycle);

	while(1);
	
}



// ============================================ First Part
void TimerInit(){
	TH0 = high[0];							//Initialised to generate a delay of 25ms
	TL0 = high[1];							//
	TMOD = 0x01; 						//Configure TMOD
	IE |= 0x82; 						//Enable interrupt
	TR0 = 0;							//Set TR0
}


void timer0_ISR (void) interrupt 1			
{
	TR0=0;
	if(high_bit==1){
		// PIN=1;
		TH0=low[0];
		TL0=low[1];
		high_bit=0;

	}
	else{
		// PIN=0;
		
		TH0=high[0];
		TL0=high[1];
		high_bit=1;
	}

	TR0=1;
	PIN=~PIN;
}

void pwm_sig(unsigned char dutyCycle){
	unsigned int high_time = 65535 - dutyCycle*10; 	// in uS
	unsigned int low_time = 65535 - (100-dutyCycle)*10; 

	high_time+=1;
	low_time+=1;

	high[1]	= high_time%256;
	high[0] = high_time>>8;
	low[1] = low_time%256;
	low[0] = low_time>>8;

	TimerInit();

	PIN=1;
	high_bit=1;
	TR0=1;					// Start Timer
}

