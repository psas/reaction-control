
/*
This Code allows for variation in duty cycle for BlinkWithoutDelay
*/

const unsigned int onTime = 1000;  // change overall PWM cycle time here!!!!
unsigned long previousMillis=0;  
int interval = onTime;
boolean LED13state = true;

void setup() {
  pinMode(13, OUTPUT);
  Serial.begin(9600);
}
 


void blinkwd(){ //controls duty cycle only 
  double val = map(analogRead(0), 0, 1023, 0, 100); 
  val = val/100;
  digitalWrite(13, LED13state);
  unsigned long currentMillis = millis(); 
  if ((unsigned long)(currentMillis - previousMillis) >= interval) {
    if (LED13state) {
      interval = onTime-val*onTime;
    } else {
      interval = val*onTime;
    }
    LED13state = !(LED13state);
    previousMillis = currentMillis;
  }
  Serial.println(val);
  
} 
 
 
 
void loop() {
  
  blinkwd();
  
}
