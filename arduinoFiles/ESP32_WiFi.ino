/* 
  Blynk is a platform with iOS and Android apps to control
  ESP32, Arduino, Raspberry Pi and the likes over the Internet.
  You can easily build mobile and web interfaces for any
  projects by simply dragging and dropping widgets.
  
  Downloads, docs, tutorials: https://www.blynk.io
  Sketch generator:           https://examples.blynk.cc
  Blynk community:            https://community.blynk.cc
  Follow us:                  https://www.fb.com/blynkapp
                              https://twitter.com/blynk_app

  Blynk library is licensed under MIT license
  This example code is in the public domain.
*/

/* Comment this out to disable prints and save space */
#define BLYNK_PRINT Serial

/* Fill in information from Blynk Device Info here */
#define BLYNK_TEMPLATE_ID "TMPL62r93BeL2"
#define BLYNK_TEMPLATE_NAME "FYP2"
#define BLYNK_AUTH_TOKEN "NBFTcjxflna3kYS55nd5KLRAmcfDMUfi"

#include <WiFi.h>
#include <WiFiClient.h>
#include <Arduino.h>
#include <BlynkSimpleEsp32.h>
#include <DHT.h>

#define DHTPIN 14 // Connect Out pin to GPIO 14 in ESP32
#define DHTTYPE DHT11  
DHT dht(DHTPIN, DHTTYPE);

// Your WiFi credentials.
// Set password to "" for open networks.
char ssid[] = "9000";
char pass[] = "onlyhaikal";

BlynkTimer timer;

const int ledPin = 27;      // LED connected to GPIO pin 27
const int ledChannel = 0;   // LEDC channel 0

const int freq = 5000;      // Set your desired PWM frequency
const int resolution = 8;   // Set your desired PWM resolution

bool v1State = false;
bool v2State = false;
bool v3State = false;
bool v4State = false;
bool v5State = false;
bool v6State = false;
bool v4ActivatedByAutomation = false; // Flag to check if V4 was activated by automation

double setTemperature = 0; // Initial set temperature

// Function to handle virtual pin V1 write event
BLYNK_WRITE(V1)
{
  int pinValue = param.asInt();
  digitalWrite(26, pinValue);
  v1State = pinValue;
  Blynk.virtualWrite(V1, v1State);
}

// Function to handle virtual pin V2 write event
BLYNK_WRITE(V2)
{
  int pinValue = param.asInt();
  digitalWrite(25, pinValue);
  v2State = pinValue;
  Blynk.virtualWrite(V2, v2State);
}

// Function to handle virtual pin V3 write event
BLYNK_WRITE(V3)
{
  int pinValue = param.asInt();
  digitalWrite(33, pinValue);
  v3State = pinValue;
  Blynk.virtualWrite(V3, v3State);
}

// Function to handle virtual pin V4 write event
BLYNK_WRITE(V4)
{
  int pinValue = param.asInt();
  digitalWrite(32, pinValue);
  v4State = pinValue;
  v4ActivatedByAutomation = false; // Set to false as this is a manual action
  Blynk.virtualWrite(V4, v4State);
}

// Function to handle virtual pin V5 write event
BLYNK_WRITE(V5)
{
  int sliderValue = param.asInt();
  int dutyCycle = map(sliderValue, 0, 225, 0, 225);
  int pinValue = param.asInt();
  digitalWrite(26, pinValue);
  digitalWrite(25, pinValue);
  digitalWrite(33, pinValue);
  digitalWrite(32, pinValue);
  digitalWrite(27, pinValue);
  v5State = pinValue;

  if (pinValue == 0) {
    v1State = false;
    v2State = false;
    v3State = false;
    v4State = false;
    v6State = false;
    // Set V6 to 0 when V5 is off
    Blynk.virtualWrite(V6, 0);
    ledcWrite(ledChannel, dutyCycle);
  }
  else {
    v1State = true;
    v2State = true;
    v3State = true;
    v4State = true;
    v6State = true;
    // Set V6 to 225 when V5 is on
    Blynk.virtualWrite(V6, 225);
    ledcWrite(ledChannel, 225); 
  }

  // Update the state of V1, V2, V3, V4, V5, and V6 in the Blynk app
  Blynk.virtualWrite(V1, v1State);
  Blynk.virtualWrite(V2, v2State);
  Blynk.virtualWrite(V3, v3State);
  Blynk.virtualWrite(V4, v4State);
  Blynk.virtualWrite(V5, v5State);
}

// Function to handle virtual pin V6 write event
BLYNK_WRITE(V6)
{
  int sliderValue = param.asInt();
  //D27

  // Clamp the slider value between 0 and 255
  sliderValue = max(0, min(255, sliderValue));

  // Convert the slider value (0-255) to the duty cycle (0-225)
  int dutyCycle = map(sliderValue, 0, 255, 0, 255);

  // Set the LED brightness with PWM
  ledcWrite(ledChannel, dutyCycle);
}

// Function to handle virtual pin V8 write event
BLYNK_WRITE(V8)
{
  setTemperature = param.asDouble();
}

void sendSensor()
{
  float t = dht.readTemperature(); // or dht.readTemperature(true) for Fahrenheit

  if (isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  Blynk.virtualWrite(V7, t);
  Serial.print("Temperature: ");
  Serial.println(t);

  if (t >= setTemperature && !v4State) {
    digitalWrite(32, HIGH);
    v4State = true;
    v4ActivatedByAutomation = true; // Set to true as this is an automatic action
    Blynk.virtualWrite(V4, v4State);
  } else if (t < setTemperature && v4State && v4ActivatedByAutomation) {
    digitalWrite(32, LOW);
    v4State = false;
    v4ActivatedByAutomation = false; // Reset the flag as it's turning off
    Blynk.virtualWrite(V4, v4State);
  }
}

void setup()
{
  // Debug console
  Serial.begin(9600);

  pinMode(26, OUTPUT);
  pinMode(25, OUTPUT);
  pinMode(33, OUTPUT);
  pinMode(32, OUTPUT);

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);

  // Configure LEDC PWM channel
  ledcSetup(ledChannel, freq, resolution); // 5 kHz frequency, 8-bit resolution

  // Attach LEDC channel to the GPIO pin
  ledcAttachPin(ledPin, ledChannel);

  // Initialize the initial state of V1, V2, V3, V4, V5, V6, and V8 in the Blynk app
  Blynk.syncVirtual(V1);
  Blynk.syncVirtual(V2);
  Blynk.syncVirtual(V3);
  Blynk.syncVirtual(V4);
  Blynk.syncVirtual(V5);
  Blynk.syncVirtual(V6);
  Blynk.syncVirtual(V8);

  dht.begin();
  timer.setInterval(1000L, sendSensor);
}

void loop()
{
  Blynk.run();
  timer.run();
}