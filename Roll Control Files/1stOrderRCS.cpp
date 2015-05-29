
/*
This program will regulate the roll of thrust based roll control system to within 5 deg/s.
The IMU used is an MPU-6050. The actuators are two solenoids releasing compressed nitrogen 
out of converging divergin parabolic nozzles at a varied duty cycle scaled thrust.  


This code was written by Brentley Wiles and Kenny Arnell for the PSAS LV3 rocket. 
*/

#include <Wire.h>        // Library to read MP6050


float rateX = 0.0;       // [deg/s]
#define kp 0.21           //  gain for duty cycle
float a = 2.0 * kp;      // (I/(r*.1s))/Ftot ====>  unit conversion equation for radian/s from duty cycle
float u = 0.0;           // controller output to solenoids in duty cycle percentage

float AcX;                //declare acclereomters and Gyros from the IMU
float AcY;
float AcZ;
float GyX;
float GyY;
float GyZ;
float Tmp;

#define onTime 200                      // cycle time in milliseconds / 5Hz actuation period
unsigned long previousMillis = 0;       // will store last time LED was updated
int interval = onTime;
boolean ledState = LOW;                 // ledState used to set the LED
#define MPU                  0x68       // I2C address of the MPU-6050
#define MPU6050_DLPF_CFG3    6          // Built in low pass filter section delay. view dflp register sheet fro more info
#define MPU6050_CONFIG       0x1A       // congfig register for MPU6050

#define CW  3         //Roll action: clockwise 
#define CCW 5         //Roll action: counter-clockwise 

void setup() {
  
    Wire.begin();
    Wire.beginTransmission(MPU);
    Wire.write(0x6B);            // PWR_MGMT_1 register
    Wire.write(0);               // set to zero (wakes up the MPU-6050)      
    Wire.endTransmission(true);
    Wire.beginTransmission(MPU);
    Wire.write(MPU6050_CONFIG);  // digital filter resgister fs 1 Khz
    Wire.write(MPU6050_DLPF_CFG3);     // set to zero (wakes up the MPU-6050)      
    Wire.endTransmission(true);
    pinMode(CW, OUTPUT);
    pinMode(CCW, OUTPUT);
    pinMode(12,OUTPUT);
    pinMode(13,OUTPUT);

    Serial.begin(9600);
    digitalWrite(CCW, LOW);
    digitalWrite(CW, LOW);
    digitalWrite(12,HIGH);              //warning light 
    delay(2000);                        // delay in start-up
    digitalWrite(12,LOW);
  
}

void loop(){
    if (millis() < 15000){              // safety timer: ony allows for 15 sec of run time
      digitalWrite(13,HIGH);            // "danger-on" light
      IMU(); //call IMU function

      
      //acvitate solenoids to roll clockwise  
      if (rateX >= 0.08) {            // +-5 deg/s for min roll rate
        blinkwd();
        digitalWrite(CW,ledState);
      }
      
      //acvitate solenoids to roll counter-clockwise  
      else if (rateX <= -0.08) {
        blinkwd();
        digitalWrite(CCW,ledState);
      }
      
      //sweetspot!! no roll action to solenoids
      else {
        digitalWrite(CW,LOW);
        digitalWrite(CCW,LOW);    
      }

      delay(1);
    }
    

    else{
      digitalWrite(CW,LOW);
      digitalWrite(CCW,LOW);
      digitalWrite(13,LOW);
    }
   
    /*
    Serial.print(" | rateX = ");
    Serial.println(rateX);
    Serial.print(" | rateX = ");
    Serial.print(rateX);
    Serial.print("   |ledstate   ");
    Serial.print(ledState);
    Serial.print("   |u   ");
    Serial.print(u);
    */
  
  
}


void blinkwd(){
    IMU();
    u = a * abs(rateX);
    unsigned long currentMillis = millis(); 
    
    if (u >= 1){
      ledState = HIGH; 
      }

    else if (abs(u) < .075 ){  
      ledState = LOW;      
    
    }
   
    
    else if ((unsigned long)(currentMillis - previousMillis) >= interval) {
      
      if (ledState) {
        interval = onTime-u*onTime;
      } 
      

      else {
        interval = u * onTime;
      }


      ledState = !(ledState);
      previousMillis = currentMillis;
    }
  

}

void IMU(){ //IMU function for MPU-6050 
    Wire.beginTransmission(MPU);
    Wire.write(0x3B);                     // starting with register 0x3B (ACCEL_XOUT_H)
    Wire.endTransmission(false);
    Wire.requestFrom(MPU,14,true);
    AcX=Wire.read()<<8|Wire.read();       // accelerometer X
    AcY=Wire.read()<<8|Wire.read(); 
    AcZ=Wire.read()<<8|Wire.read(); 
    Tmp=Wire.read()<<8|Wire.read();       
    GyX=Wire.read()<<8|Wire.read();       // Gyro Rate X
    GyY=Wire.read()<<8|Wire.read(); 
    GyZ=Wire.read()<<8|Wire.read();
    ////////////////////////////////////////////////////////////
    rateX = GyX / 7528;                   //7528 for rad or / by 131 for deg

  //  Serial.print(" | rateX = ");
  //  Serial.println(rateX);  
}
