int IN1 = 2;
int IN2 = 3;



void setup() {

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
}

void loop() {

  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);

}
