#include "QuectelM10.h"
#include <NewSoftSerial.h>

void setup(){
  Serial.begin(9600);
  Serial.println("GSM master node test.");
  //Start configuration.
  if (gsm.begin()){
    Serial.println("\nstatus=READY");
  }else{
    Serial.println("\nstatus=IDLE");
  }
}

void loop(){
  gsm.call("690630635", 10000);
  while(1);
};
  
  
  //strcpy(dest, orig)
