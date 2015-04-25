
#include <Wire.h>

#define A_GAIN 0.932    // [deg/LSB]
#define G_GAIN 1.466    // [deg/s/LSB]

#define DT 0.002         // [s/loop] loop period
#define A 0.98         // complementary filter constant

#define KP 1.8          // proportional controller gain [LSB/deg/loop]
#define KD 0.4          // derivative controller gain [LSB/deg/loop]
#define KI 0.5          // Integral controller gain

float accel = 0.0;
float angle = 0.0;      // [deg]
float rate = 0.0;       // [deg/s]
float output = 0.0;     // [LSB] (100% voltage to motor is 255LSB)

float accelX = 0.0;
float angleX = 0.0;      // [deg]
float rateX = 0.0;       // [deg/s]
float outputX = 0.0;     // [LSB] (100% voltage to motor is 255LSB)

float accelY = 0.0;
float angleY = 0.0;      // [deg]
float rateY = 0.0;       // [deg/s]
float outputY = 0.0;     // [LSB] (100% voltage to motor is 255LSB)

float rateZ = 0.0;       // [deg/s]

float rateD = 0.00;       // desired roll rate
float kp = 2.50;         //proportional gain for duty cycle


const int MPU=0x68;  // I2C address of the MPU-6050
float AcX;
float AcY;
float AcZ;
float GyX;
float GyY;
float GyZ;
float Tmp;
float d = 0;

const unsigned int onTime = 200;
unsigned long previousMillis = 0;        // will store last time LED was updated
int interval = onTime;
boolean ledState = HIGH;             // ledState used to set the LED
//const long interval = 100;           // interval at which to blink (milliseconds)

void setup() {
  Wire.begin();
  Wire.beginTransmission(MPU);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
  pinMode(10, OUTPUT);
  pinMode(13, OUTPUT);
  pinMode(A0, INPUT);
  Serial.begin(9600);
}


void IMU(){ //IMU function for MPU-6050 
  Wire.beginTransmission(MPU);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU,14,true);
  AcX=Wire.read()<<8|Wire.read();
  AcY=Wire.read()<<8|Wire.read(); 
  AcZ=Wire.read()<<8|Wire.read(); 
  Tmp=Wire.read()<<8|Wire.read(); 
  GyX=Wire.read()<<8|Wire.read(); 
  GyY=Wire.read()<<8|Wire.read(); 
  GyZ=Wire.read()<<8|Wire.read();
  ////////////////////////////////////////////////////////////
  //output for Pitch tilt
  rateX = GyX / 131;  
  Serial.print(" | rateX = ");
  Serial.println(rateX);
/*
  //set accell rate
  accelY = AcY / 16384;
  Serial.print(" | accY = ");
  Serial.print(accelY);
  //determine the angle
  angleX = A * (angle + rate * DT) + (1 - A) * accel;  
  Serial.print(" | angX = ");
  Serial.print(angleX);
  //set the scalar reaction 
  outputX = (angle * KP + rate * KD) ;
  Serial.print(" | outX = ");
  Serial.print(outputX);
  ////////////////////////////////////////////////////////////
  //output for Yaw tilt
 
  rateY = GyY / 131;  
  Serial.print(" | rateY = ");
  Serial.print(rateY);
 
  //set accell rate
  accelX = AcX / 16384;
  Serial.print(" | accX = ");
  Serial.print(accelX);
  //determine the angle
  angleY = A * (angle + rate * DT) + (1 - A) * accel;  
  Serial.print(" | angY = ");
  Serial.print(angleY);
  //set the scalar reaction 
  outputY = (angle * KP + rate * KD) ;
  Serial.print(" | outY = ");
  Serial.print(outputY);
  ////////////////////////////////////////////////////////////
  //output for roll rate
  rateZ = GyZ / 131;  
  Serial.print(" | rateZ = ");
  Serial.println(rateZ);
  */
   
}

void blink() //function for blink without  delay using preset interval for PWM
{ 
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;   
    if (ledState == LOW){
      ledState = HIGH;
  
    }
    else{
      ledState = LOW;
  }
  }
}

void blinkwd()
{
  IMU();
  float err = rateD - rateX;
  float u = map(kp*abs(err), 0, 50, 0.2, 1.00);
    
  //float rate = abs(u)/100;
  unsigned long currentMillis = millis(); 
  if (u >= 1){
    ledState = HIGH; 
  }
  else if ((unsigned long)(currentMillis - previousMillis) >= interval) {
    if (ledState) {
      interval = onTime-u*onTime;
    } else {
      interval = u*onTime;
    }
    ledState = !(ledState);
    previousMillis = currentMillis;
  }

  
  
  
  
  Serial.print("   |ledstate   ");
  Serial.print(ledState);
  Serial.print("   |err   ");
  Serial.print(err);
  Serial.print("   |u   ");
  Serial.println(u);

}


void loop() {
  
  IMU(); //call IMU function

  //float val = map(analogRead(A0), 0, 1023, -100, 100);
  if (rateX >= 10) { 
    blinkwd();
    digitalWrite(10,ledState);
  }
  //acvitate solenoids to roll counter-clockwise  
  else if (rateX <= -10) {
    blinkwd();
    digitalWrite(13,ledState);
  }
 //sweetspot!! no roll action to solenoids
  else {
    digitalWrite(10,LOW);
    digitalWrite(13,LOW);    
  }
  //Serial.print("   |ledstate   ");
  //Serial.print(ledState);
  delay(1);

}


