const int v_out = A0;
const int v_ref = A1;

unsigned int value_out;
unsigned int value_ref;

void setup() {
  pinMode(v_out, INPUT);
  pinMode(v_ref, INPUT);
  Serial.begin(9600);
}

void loop() {

  value_out = analogRead(v_out);
  value_ref = analogRead(v_ref);

  Serial.print("Value: ");
  Serial.println(value_out);
  Serial.print("Ref: ");
  Serial.println(value_ref);

  delay(2000);
  



}
