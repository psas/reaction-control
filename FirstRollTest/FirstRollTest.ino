
// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin 13 as an output.
  pinMode(3, OUTPUT);
  digitalWrite(3, LOW);
  delay(10000);
  digitalWrite(3, HIGH);
  delay(100);
}

// the loop function runs over and over again forever
void loop() {
            // wait for a second
  digitalWrite(3, LOW);    // turn the LED off by making the voltage LOW
             // wait for a second
}
