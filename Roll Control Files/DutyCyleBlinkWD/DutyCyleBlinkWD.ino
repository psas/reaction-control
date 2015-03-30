
/*
This Code allows for variation in duty cycle for BlinkWithoutDelay
*/
const unsigned int onTime = 500;
unsigned long previousMillis=0;
int interval = onTime;
boolean LED13state = true;
 

void setup() {
  pinMode(13, OUTPUT);
  Serial.begin(9600);
}
 
void loop() {
  
  float val = analogRead(0);
  val = map(val, 0, 1023, 0, 100);
  float sal = val/100;
  digitalWrite(13, LED13state);
  unsigned long currentMillis = millis(); 
  if ((unsigned long)(currentMillis - previousMillis) >= interval) {
    if (LED13state) {
      interval = sal*onTime;
    } else {
      interval = onTime-sal*onTime;
    }
    LED13state = !(LED13state);
    previousMillis = currentMillis;
  }
  Serial.println(sal);
}
