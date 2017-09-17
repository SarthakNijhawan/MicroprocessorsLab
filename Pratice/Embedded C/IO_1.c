// Takes an input and displays on the LEDs
// Author: Sarthak Nijhawan

#include <AT89C5131.h>

unsigned char mybyte;

void main(void){
	P1 = 0x0F;								// Setting the lower nibble of P1 as an input port
	
	while(1){
	
		mybyte = P1;
		mybyte = mybyte & 0x0F;					// Extracting the lower nibble
		mybyte << 4;							// Shifting lower nibbles to upper nibbles
		P1 = P1 | mybyte;		
		P1 = P1 | 0x0F;
	}
}