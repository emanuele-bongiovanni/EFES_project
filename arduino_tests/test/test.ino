
const int trigger_pin = 5;
const int echo_pin = 4;
const int button_pin = 2;


unsigned int duration = 0;
int distance;
bool status;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(trigger_pin, OUTPUT);
  pinMode(echo_pin, INPUT);
  pinMode(button_pin, INPUT);
}

void loop() {


    digitalWrite(trigger_pin, LOW);
    duration = 0;
    delayMicroseconds(10);
    status = LOW;
    status = digitalRead(button_pin);
    

  if (status == HIGH) {
    digitalWrite(trigger_pin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigger_pin, LOW);


    duration = pulseIn(echo_pin, HIGH);
    //Serial.println(duration);
    distance = duration*0.034/2;
    Serial.println(distance);
    delay(2000);
  }
    

  
}
 