
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
float rateXrad = 0.0;     // [rad/s]
float rateXave = 0.0;     // [deg/s]
float outputX = 0.0;     // [LSB] (100% voltage to motor is 255LSB)

float accelY = 0.0;
float angleY = 0.0;      // [deg]
float rateY = 0.0;       // [deg/s]
float outputY = 0.0;     // [LSB] (100% voltage to motor is 255LSB)

float rateZ = 0.0;       // [deg/s]

#define num  6      // for smoother
int reader[num];         // for smoother
int Index = 0;           // for smoother
float total = 0.0;         // for smoother
float ave = 0.0;           // ave the rate for smoother
float rateD = 0.00;      // desired roll rate
#define kp .25;            // proportional gain for duty cycle
float a = 2.0 * kp;        // (I/(r*.1s))/Ftot equation to dc from radian error
float u = 0.0;
float aveRad = 0.0;


const int MPU=0x68;  // I2C address of the MPU-6050
float AcX;
float AcY;
float AcZ;
float GyX;
float GyY;
float GyZ;
float Tmp;
float d = 0;

#define onTime 200
unsigned long previousMillis = 0;        // will store last time LED was updated
int interval = onTime;
boolean ledState = HIGH;                 // ledState used to set the LED
//const long interval = 100;             // interval at which to blink (milliseconds)
#define MPU6050_DLPF_CFG3     6          //Built in low pass filter section delay 4.9ms
#define MPU6050_CONFIG       0x1A        //congfig register for MPU6050

#define cw  5
#define ccw  3

void setup() {
  
  Wire.begin();
  Wire.beginTransmission(MPU);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)      
  Wire.endTransmission(true);
  Wire.beginTransmission(MPU);
  Wire.write(MPU6050_CONFIG);  // digital filter resgister fs 1 Khz
  Wire.write(MPU6050_DLPF_CFG3);     // set to zero (wakes up the MPU-6050)      
  Wire.endTransmission(true);
  pinMode(cw, OUTPUT);
  pinMode(ccw, OUTPUT);
  pinMode(A0, INPUT);
  Serial.begin(9600);
  digitalWrite(ccw, LOW);
  digitalWrite(cw, LOW);
  for (int i = 0; i < num; i++)
    reader[i] = 0;
  //delay(5000);
  
}

void loop(){
  //if (millis() < 15000){

      IMU(); //call IMU function
      
      if (aveRad >= 0.175) {
        blinkwd();
        digitalWrite(cw,ledState);
      }
      
      //acvitate solenoids to roll counter-clockwise  
      else if (aveRad <= -0.175) {
        blinkwd();
        digitalWrite(ccw,ledState);
      }
      
      //sweetspot!! no roll action to solenoids
      else {
        digitalWrite(cw,LOW);
        digitalWrite(ccw,LOW);    
      }


 
//      delay(1);
  //}
 /* 
 else{
    digitalWrite(cw,LOW);
    digitalWrite(ccw,LOW);
  }
  */
  
  Serial.print(" | rateXaveRad = ");
  Serial.println(aveRad);
  Serial.print(" | rateX = ");
  Serial.print(rateX);
  Serial.print("   |ledstate   ");
  Serial.print(ledState);
  Serial.print("   |u   ");
  Serial.print(u);
  
  
  
}


void blinkwd(){
  IMU();
  u = a*abs(aveRad);
  unsigned long currentMillis = millis(); 
  
  if (u >= 1){
    ledState = HIGH; 
  }
  
  else if (abs(u) < .1 ){  
    ledState = LOW;      
  
  }
 
  
  else if ((unsigned long)(currentMillis - previousMillis) >= interval) {
    
    if (ledState) {
      interval = onTime-u*onTime;
    } 
    
    else {
      interval = u*onTime;
    }
    ledState = !(ledState);
    previousMillis = currentMillis;
  }
  

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
  rateX = GyX / 131;//7528 for rad or / by 131 for deg
//  Serial.print(" | rateX = ");
//  Serial.println(rateX);
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
  total = total - reader[Index];
  reader[Index] = rateX;
  total = total + reader[Index];
  Index = Index + 1; 
  if (Index >= num)
    Index = 0;
    
  ave = total /num;
  
  aveRad = ave/57.3;
//  Serial.print(" | rateXaveRad = ");
//  Serial.println(aveRad);  
}

void case1(){
  if ( abs(u) <= 0.175 )
  {
    digitalWrite(cw,LOW);
    digitalWrite(ccw,LOW);
  }

  else if ( u >= 1 )
  {
    u = 1;
  }

}

void case2(){
 if (aveRad >= 0.175) { 
    blinkwd();
    digitalWrite(cw,ledState);
  }
  //acvitate solenoids to roll counter-clockwise  
  else if (aveRad <= -0.175) {
    blinkwd();
    digitalWrite(ccw,ledState);
  }
 //sweetspot!! no roll action to solenoids
  
  else {
    digitalWrite(cw,LOW);
    digitalWrite(ccw,LOW);    
  }

}

void case3(){
    digitalWrite(cw,LOW);
    digitalWrite(ccw,LOW);
}




