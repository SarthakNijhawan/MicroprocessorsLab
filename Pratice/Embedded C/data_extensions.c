#include <AT89C5131.h>

void main(void)
	{
		code unsigned char mydata[]= “Hello”;
		unsigned char z;
		
		for(z=0;z<=5;z++){
			P1 = mydata[z];
		}
	}