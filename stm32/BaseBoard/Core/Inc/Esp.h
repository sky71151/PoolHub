/*
 * Esp.h
 *
 *  Created on: Aug 4, 2024
 *      Author: vanba
 */

#ifndef INC_ESP_H_
#define INC_ESP_H_


typedef enum{
	disconnected = 0u,
	connected,
}WifiMqttState;

struct Time{
	char Hour;
	char Minutes;
};

struct Date{
	char Day;
	char month;
	int Year;
};


struct Outputs{
	char Relay1;
	char Relay2;
	char Relay3;
	char Relay4;
};

typedef struct Esp
{
	char WiFi;
	char Mqtt;
	char UpdateRecieved;
	struct Time Time;
	struct Date Date;
	struct Outputs Outputs;
	char D_temp;
}ESP_t;


#endif /* INC_ESP_H_ */
