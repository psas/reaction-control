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


int16_t		ax,           //Linear acceleration in the X direction (Raw Data)
			ay,           //Linear acceleration in the Y direction (Raw Data)
			az,           //Linear acceleration in the Z direction (Raw Data)
			gx,           //Angular Velocity about the X direction (Raw Data)
			gy,           //Angular Velocity about the Y direction (Raw Data)
			gz;           //Angular Velocity about the Z direction (Raw Data)
			//Tmp,           //Temperature reading
			//d = 0;
double
			aXg,
			aYg,
			aZg,
			gXds,
			gYds,
			gZds,
			Xgyro,
			Ygyro,
			Zgyro,
			Yacc,
			Xacc,
			Zacc,
			AngleX = 0, AngleX_shift,
			AngleY = 0, AngleY_shift,
			AngleZ = 0, AngleX_shift,
			ErrorX,
			ErrorX_m1,
			ControlX,
			ControlX_m1;

int			PWM = 0,
			A = .758, 
			DT = .1667, 
			angle = 0,
			Kp = 1,
			K1 = 19.8482,
			K2 = 18.5763;


int main (void)
{
		//USART Setup
	UBRR0H = MYUBRR >> 8;
	UBRR0L = MYUBRR;
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	stdout = &mystdout;                                          //Required for printf init

	DDRD=0b00000010;                                             //Set Output Port for USART
	
	
		// Initialize TWI/I2C
	
	mpu6050_init();

		/// Activate Output Pins
	DDRC |= (1 << 3)|(1 << 2)|(1 << 1)|(1 << 0);                 //activate a clock measurement pin for debugging

		//Port D Activat OC2B, OC0B, OC0A
	DDRD  |= (1 << PORTD3)|(1 << PORTD5)|(1 << PORTD6);          //set data direction 
	
		//Port B Activate OC1A, OC2A
	DDRB  |= (1 >> PORTB1)|(1 << PORTB3);                        //set data direction 



	PORTD |= (0 << PORTD5)|(0 << PORTD6);                        //activate pins
	PORTB |= (0 >> PORTB1)|(0 << PORTB3);                        //activate pins
 

		// Interrupt Timer to Timer 1 (16-bit resolution)

	TCCR1A |= (1 << COM1A1);                                     // OC1n clears on compare match (non-inverting PWM mode)
	TCCR1B |= (1 << WGM12);                                      // sets CTC mode to using OCR1nA as TOP of counter
	TIMSK1 |= (1 << OCIE1A);                                     // Enable CTC interrupt
	sei();                                                       // Enable global interrupts
	
	TCCR1B |=(1 << CS10)|(0 << CS11)|(1 << CS12);                // sets the prescaler on the clock frequency to 1024
	
		////  TARGET FREQUENCY CALCULATION ////////////////////
		////  Target Frequency =  F CPU/(2*Prescale*(OCR1A+1)) 
	
	OCR1A = 80;                                                  //This sets frequency of interrupt to about 6 Hz

	// PWM Timer set to Timer 0 (8-bit resolution)  ** Timer 0 and Timer 1 share the set prescale value
	
	TCCR0A |= (1 << COM0A1)|(0 << COM0A0)|(1 << COM0B1)|(0 << COM0B0)|(1 << WGM00)|(1 << WGM01);   //Setting up Fast PWM with OCR0A and OCROB as compare registers
	TCCR0B |= (0 << WGM02)|(1 << CS02)|(0 << CS01)|(0 << CS00);                                    // Defines Fast PWM and activates timer

	
  
	while(1)
	{

	}
}

ISR(TIMER1_COMPA_vect)                                      //runs an interrupt comparing timer to OCR1A
{
	PORTC ^= (1 << 0);                                    // Debug toggle switch for interupt frequency check
	
	mpu6050_getConvData(&aXg,&aYg,&aZg,&gXds,&gYds,&gZds);  //reads in accel and gyro data and apply sensitivity conversion and stores in addressed variables
	
			//printf("   %f;   %f;   %f;\n   %f;   %f;   %f;\n\n",aXg,aYg,aZg,gXds,gYds,gZds);
			//_delay_ms(150);
	
	// Integrating angular velocity to get the angle based on gryo data
	Xgyro = gXds*DT;              
	Ygyro = gYds*DT;
	Zgyro = gZds*DT;
	
				//printf("\nangle X %f;  gXds %f;  Xacc %f;\n",X,gXds,Xacc);
	
	// Finding the angle based on accel data
	Xacc = atan2f(aYg,aZg)*180/M_PI;
	Yacc = atan2f(aXg,aZg)*180/M_PI;
	Zacc = atan2f(aXg,aYg)*180/M_PI;
	
	// Complimentary Fitler Equation   ** this is important to remove drift that is a symptom of only using the gyro for angle calculations
	AngleX = A * (AngleX + Xgyro) + (1-A) * Xacc;
	AngleY = A * (AngleY + Ygyro) + (1-A) * Yacc;
	AngleZ = A * (AngleZ + Zgyro) + (1-A) * Zacc;
	
	ErrorX = AngleX; 
	//ControlX = Kp*ErrorX;
	//
	ErrorX_m1 = ErrorX;
	
	ControlX_m1 = ControlX;
	
				
	
	// Determining with solenoid to actuate and the duty cycle to use.
	if (AngleX < -165 && -179.6 < AngleX )          //The system can only control from 1.4 to 8 degrees
	{
		AngleX_shift = 1*(AngleX + 180);
		ControlX = K1*gXds*M_PI/180 + K2*AngleX_shift*M_PI/180;
		//printf(" %f; %f; %f; \n\n",ControlX, gXds, AngleX_shift);
		
		if (1 < ControlX && ControlX < 5.5 ){ 
		PWM =( 0.6/4.5*ControlX + .06667)*256; //Relationship based off experimental data of duty cycle and thrust output
		OCR0A = PWM;
		printf("%d;  right     %f;\n", PWM,ControlX);
		
		return;
		}
		else;
		{
			return;
		}
	}
	
	
		else if(165 < AngleX && AngleX < 179.6)
		{
			AngleX_shift = 180 - AngleX;
			ControlX = K1*gXds*M_PI/180 + K2*AngleX_shift*M_PI/180;
			//printf(" %f; %f; %f; \n\n",ControlX, gXds, AngleX_shift);
			if (1 < ControlX && ControlX < 5.5 ){
				PWM =( 0.6/4.5*ControlX + .06667)*256; //Relationship based off experimental data of duty cycle and thrust output
				OCR0B = PWM;
				printf("%d;  right     %f;\n", PWM,ControlX);
				
				return;
			}
			else;
			{
				return;
			}
		}
		
		
			else if((ControlX < -179.6 || ControlX > 179.6)&&(ControlX > -165 || ControlX < 165));
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