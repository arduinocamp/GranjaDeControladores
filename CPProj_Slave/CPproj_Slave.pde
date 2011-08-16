//SLAVE
#include "QuectelM10.h"
#include <NewSoftSerial.h>

//FALTA: RECEPCION Y REENVIO DEL MENSAJE POR EL MASTER

int nodeNum = 0;
float MAXtemp = 70;
char masterNum[] = "659772443";
int delayAfterCall = 5000;

int SMSLength = 161;
char SMStext[161];
char incomingCallNum[16];
int firstBrightness;
int analogSensorPin = 5;
int digitalSensorPin = 12;
int digitalOutputPin = 8;
int callingTime = 15000;

void setup(){
  //Entrada digital:
  pinMode(digitalSensorPin, INPUT);
  digitalWrite(digitalSensorPin, HIGH);
  //fin digital
  //salida digital:
  pinMode(digitalOutputPin, OUTPUT);
  digitalWrite(digitalOutputPin, LOW);
  //fin salida digital
  Serial.begin(9600);
  firstBrightness = analogRead(analogSensorPin);
  snprintf(SMStext, SMSLength, "The first brightness measured is: %d", firstBrightness);
  Serial.println(SMStext);
  snprintf(SMStext,SMSLength,"GSM node %d setup", nodeNum);
  Serial.println(SMStext);
  //Start configuration.
  if (gsm.begin()){
    Serial.println("\nstatus=READY");
  }else{
    Serial.println("\nstatus=IDLE");
  }
}
//******************************************
void loop(){
  int digitalSensorState;
//  int brightness=analogRead(analogSensorPin);
  digitalSensorState = digitalRead(digitalSensorPin);
  if(digitalSensorState == 0){
    sendSMSfunc();          //un valor que no pueda ser enviado desde analogRead
  }

/*  if(analogRead(analogSensorPin) <= (brightness*0.6)){;    //Falta meter ecuación línea temp
    sendSMSfunc(brightness);
  }*/
  if(gsm.readCall(incomingCallNum, 16)){
    nacker();
  }
  
  
  //NOT IMPLEMENTED YET:
/*  if(gsm.readSMS(smsbuffer, 160, n, 20){
    Serial.println(n);
    Serial.println(smsbuffer);
  }*/
};

//******************************************
void sendSMSfunc(){
  Serial.println("has entrado en sendSMSfunction");
  if(digitalRead(digitalSensorPin)==0){
    Serial.println("has entrado en mandar SMS por alerta digital");
    snprintf(SMStext, SMSLength, "ALERT! In the node %d digital alarm just rised!", nodeNum);
    gsm.sendSMS(masterNum, SMStext);
    return;
  }
  if(analogRead(analogSensorPin) <= firstBrightness*0.3){
      Serial.println("has entrado en la zona ALERTA POR ANALOG SIGNAL");
    snprintf(SMStext,SMSLength,"Overbright alert in node %d! Bright = %d", nodeNum, analogRead(analogSensorPin));
    gsm.sendSMS(masterNum, SMStext);
    while((analogRead(analogSensorPin) < analogRead(analogSensorPin)*0.2)){}    //-50 da un margen para los picos
    snprintf(SMStext,SMSLength,"Brightness is OK again in node %d", nodeNum);
    gsm.sendSMS(masterNum, SMStext);
    return;
  }
}
//******************************************
void nacker(void){
  digitalWrite(digitalOutputPin, HIGH);
  gsm.call(masterNum, callingTime);
  digitalWrite(digitalOutputPin, LOW);
  delay(delayAfterCall);
  Serial.println("\nJust NACKED the ack");
};
//******************************************
/*void remoteSetting(void){
}*/
