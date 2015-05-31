/*
 * PWM_Inverted_Pendulum.c
 *
 * Created: 5/22/2015 4:27:00 PM
 *  Author: Robert Schweizer
  
 This program is being built to control the Pitch and Yaw dynamics of an rocket via an inverted pendulum simulation 
  
 */ 


#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>
// Math functions
#include <math.h>
#include <stdlib.h>
#include <util/twi.h>



#define F_CPU 1000000UL // 1 MHz CPU Clock Frequency
#include <util/delay.h>

#include "mpu6050.h"

#define sbi(var, mask) ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask) ((var) &= (uint8_t)~(1 << mask))

volatile uint8_t buffer[14];

#define MPU6050_AXGAIN 16384.0
#define MPU6050_AYGAIN 16384.0
#define MPU6050_AZGAIN 16384.0

#define MPU6050_GXGAIN 131.0
#define MPU6050_GYGAIN 131.0
#define MPU6050_GZGAIN 131.0


// USART definitions
#define FOSC F_CPU  // CPU Clock Frequency must be set correctly for the USART to work
#define BAUD 4800
#define MYUBRR FOSC/16/BAUD-1

// USART declarations
static int    uart_putchar(char c, FILE *stream);
unsigned char uart_getchar(void);
static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);


int16_t		ax,           //Linear acceleration in the X direction
			ay,           //Linear acceleration in the Y direction
			az,           //Linear acceleration in the Z direction
			gx,          //Angular Velocity about the X direction
			gy,           //Angular Velocity about the Y direction
			gz,           //Angular Velocity about the Z direction
			Tmp,           //Temperature reading
			d = 0;
double
			aXg,
			aYg,
			aZg,
			gXds,
			gYds,
			gZds,
			X,
			Y,
			Z,
			Yacc,
			Xacc,
			Zacc,
			AngleX = 0, AngleX_shift,
			AngleY = 0, AngleY_shift,
			AngleZ = 0, AngleX_shift;

int PWM = 0,A = .98, DT = .1, angle = 0;


int main (void)
{
	//USART Setup
	UBRR0H = MYUBRR >> 8;
	UBRR0L = MYUBRR;
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	stdout = &mystdout; //Required for printf init

	DDRD=0b10000010; //Set Output Port for USART
	
	
	// Initialize TWI
	
	mpu6050_init();

/// Activate Output Pins
DDRC |= (1 << 3)|(1 << 2)|(1 << 1)|(1 << 0);  //activate a clock measurement pin for debugging

//Port D Activat OC2B, OC0B, OC0A
DDRD  |= (1 << PORTD3)|(1 << PORTD5)|(1 << PORTD6); //set data direction 
//Port B Activate OC1A, OC2A
DDRB  |= (1 >> PORTB1)|(1 << PORTB3);  //set data direction 

PORTD |= (1 << PORTD5)|(1 << PORTD6); //activate pins
PORTB |= (1 >> PORTB1)|(1 << PORTB3);  //activate pins
 

// Interrupt Timer to Timer 1 (16-bit resolution)

TCCR1A |= (1 << COM1A1);                       //sets Timer 1 to CTC mode using OCR1A as TOP of counter
TCCR1B |= (1 << WGM12);                        // 
TIMSK1 |= (1 << OCIE1A);                       // Enable CTC interrupt
sei();                                         // Enable global interrupts
OCR1A = 55;                                   //This sets frequency of interrupt  
TCCR1B |=(1 << CS10)|(0 << CS11)|(1 << CS12);  // sets the prescaler on the clock frequency to 1024
////  TARGET FREQUENCY CALCULATION ////////////////////
////  Target Frequency =  F CPU/(2*Prescale*OCR1A) - 1
////  For OCR1A = 100,  Target Frequency = 4.88 Hz

// PWM Timer set to Timer 0 (8-bit resolution)  ** Timer 0 and Timer 1 share the set prescale value

TCCR0A |= (1 << COM0A1)|(0 << COM0A0)|(1 << COM0B1)|(0 << COM0B0)|(1 << WGM00)|(0 << WGM01);//Setting up Fast PWM with OCR0A and OCROB as compare registers
TCCR0B |= (0 << WGM02)|(1 << CS02)|(0 << CS01)|(0 << CS00);  // Defines Fast PWM and activates timer

//OCR0A = 0;                               // Sets value to compare give a 4.8 Hz PWM cycle


	while(1)
	{
	//printf("tcnt0 %d; \n", TCNT0);
	}
}

ISR(TIMER1_COMPA_vect)  //runs an interupt comparing timer to OCR1A
{
	
	PORTC ^= (1 << 0);// Debug toggle switch for interupt frequency check
	
	mpu6050_getConvData(&aXg,&aYg,&aZg,&gXds,&gYds,&gZds);  //reads in accel and gyro data and apply sensitivity conversion and stores in addressed variables
	
	
	//printf("   %f;   %f;   %f;\n   %f;   %f;   %f;\n\n",aXg,aYg,aZg,gXds,gYds,gZds);
	//_delay_ms(150);
	
	X = gXds*DT/2+X*DT/2-Xacc;
	Y = gYds*DT/2+Y*DT/2-Yacc;
	Z = gZds*DT/2+Z*DT/2-Zacc;
	
	Xacc = atan2f(aYg,aZg)*180/M_PI;
	Yacc = atan2f(aXg,aZg)*180/M_PI;
	Zacc = atan2f(aXg,aYg)*180/M_PI;
	AngleX = A * (AngleX + X) + (1-A) * Xacc;
	AngleY = A * (AngleY + Y) + (1-A) * Yacc;
	AngleZ = A * (AngleZ + Z) + (1-A) * Zacc;

	//printf(" %f;  %f;  %f;\n\n", AngleX,AngleY,AngleZ);
	
	if (AngleX < -171 && -178.3 < AngleX )
	{
		AngleX_shift = AngleX + 180;
		PWM =( 0.6/7.3*AngleX_shift + .06027397)*256; //Relationship based off experimental data of duty cycle and thrust output
		OCR0A = PWM;
		printf("%d;  right     %f;\n", PWM,AngleX_shift);
		
		return;
	}
	
	
		else if(171 < AngleX && AngleX < 178.3)
		{
			AngleX_shift = 180 - AngleX;
			PWM =( 0.6/7.3*AngleX_shift + .06027397)*256; //Relationship based off experimental data of duty cycle and thrust output
			OCR0B = PWM;
			printf("%d;   left     %f;\n", PWM,AngleX_shift);
			
		
			return;
		}
		
		
			else if((AngleX < -178.3 || AngleX > 178.3)&&(AngleX > -171 || AngleX < 171));
			{
				//printf("working??\n");
				OCR0A = 0;
				OCR0B = 0;
				return;
			}
}

// USART Functions

static int uart_putchar(char c, FILE *stream)
{
	if (c == '\n') uart_putchar('\r', stream);
	
	loop_until_bit_is_set(UCSR0A, UDRE0);
	UDR0 = c;
	
	return 0;
}

unsigned char uart_getchar(void)
{
	while( !(UCSR0A & (1<<RXC0)) );
	return(UDR0);
}