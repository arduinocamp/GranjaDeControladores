//MASTER
//l´neas a modificar:  #define xxxx   y añadir el n´mero del nodo
#include "QuectelM10.h"
#include <NewSoftSerial.h>

#define NODESQUANT 1

//int nodesQuant = 1;    //Cantidad de nodos asociados al maestro
char adminNum[10] = "5551234";
char nodeNums[NODESQUANT][10];
char incomingCallNum[10];
char incomingSMSNum[10];

int callingTime = 9000;
int SMSLength = 161;
char SMStext[161];
char SMSbuffer[161];

int digitalOutputPin = 8;

//**********************************************
void setup(){
  // Slaves numbers
  strcpy(nodeNums[0], "659024243");
//  strcpy(nodeNums[1], "689010427");
//  strcpy(nodeNums[1], "689010427");
//  strcpy(nodeNums[1], "689010427");
//  strcpy(nodeNums[1], "689010427");

  
  //salida digital:
  pinMode(digitalOutputPin, OUTPUT);
  digitalWrite(digitalOutputPin, LOW);
  //fin salida digital

  Serial.begin(9600);
  Serial.println("GSM master node test.");
  //Start configuration.
  if (gsm.begin()){
    Serial.println("\nstatus=READY");
  }else{
    Serial.println("\nstatus=IDLE");
  }
}
//********************************************
void loop(){
  int cont;
 /* if(NODESQUANT == 1){
    acker(0);
    delay(20000);        //10 segundos de descanso entre nodo y nodo
    nackTester(0);
  }else{*/
    for(cont = 0; cont < NODESQUANT; cont++){
      acker(cont);
      delay(20000);        //10 segundos de descanso entre nodo y nodo
      nackTester(cont);
     }
   }
   if(gsm.readSMS(SMSbuffer, SMSLength, incomingSMSNum, 20)){
     gsm.sendSMS(adminNum, SMSbuffer);
   }
//   delay(300000);       //haz el ack-nack cada 5 minutos
}
//******************************************
void acker(int node){
  digitalWrite(digitalOutputPin, HIGH);
  snprintf(SMStext,SMSLength,"Calling node %d", node);
  Serial.println(SMStext);
  gsm.call(nodeNums[node], callingTime);
  snprintf(SMStext,SMSLength,"Finished call to node %d", node);
  Serial.println(SMStext);
  digitalWrite(digitalOutputPin, LOW);
}
//******************************************
void nackTester(int node){
  int attempts;
  if(gsm.readCall(incomingCallNum, 16)){
  return;
  }else{
    for(attempts=1; attempts<3; attempts++){
      acker(node);
      delay(20000);
      if(gsm.readCall(incomingCallNum, 16)){
        return;
      }
    }
    snprintf(SMStext,SMSLength,"The node %d isn't Nacking to my acks", node);
    gsm.sendSMS(adminNum, SMStext);
    return;
  }
}//zterm
