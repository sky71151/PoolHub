#include <ESP8266WiFi.h>
#include <Ticker.h>
#include <AsyncMqttClient.h>
#include <ModbusRtu.h>
#include <WiFiUdp.h>
#include <NTPClient.h>

#define WIFI_SSID "Van_Baelen"
#define WIFI_PASSWORD "Rob88333"

#define MQTT_HOST "public.mqtthq.com"
#define MQTT_PORT 1883

// data array for modbus network sharing
uint16_t au16data[16] = {3, 1415, 9265, 4, 2, 7182, 28182, 8, 0, 0, 0, 0, 0, 0, 1, -1 };
Modbus slave(1,Serial,0); // this is slave @1 and RS-232 or USB-FTDI

AsyncMqttClient mqttClient;
Ticker mqttReconnectTimer;

WiFiEventHandler wifiConnectHandler;
WiFiEventHandler wifiDisconnectHandler;
Ticker wifiReconnectTimer;


// NTP time settings
const long utcOffsetInSeconds = 3600;
char daysOfTheWeek[7][12] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", utcOffsetInSeconds);

void connectToWifi() {
  //Serial.println("Connecting to Wi-Fi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
}

void onWifiConnect(const WiFiEventStationModeGotIP& event) {
  //Serial.println("Connected to Wi-Fi.");
  timeClient.begin();
  connectToMqtt();
}

void onWifiDisconnect(const WiFiEventStationModeDisconnected& event) {
  //Serial.println("Disconnected from Wi-Fi.");
  mqttReconnectTimer.detach(); // ensure we don't reconnect to MQTT while reconnecting to Wi-Fi
  wifiReconnectTimer.once(2, connectToWifi);
}

void connectToMqtt() {
  //Serial.println("Connecting to MQTT...");
  mqttClient.connect();
}

void onMqttConnect(bool sessionPresent) {
  //Serial.println("Connected to MQTT.");
  //Serial.print("Session present: ");
  //Serial.println(sessionPresent);
  mqttClient.subscribe("homesky/light", 2);
  mqttClient.subscribe("homesky/socket", 2);
  mqttClient.subscribe("homesky/temp", 2);
  
}

void onMqttDisconnect(AsyncMqttClientDisconnectReason reason) {
  //Serial.println("Disconnected from MQTT.");

  if (WiFi.isConnected()) {
    mqttReconnectTimer.once(2, connectToMqtt);
  }
}

void onMqttSubscribe(uint16_t packetId, uint8_t qos) {
  //Serial.println("Subscribe acknowledged.");
  //Serial.print("  packetId: ");
  //Serial.println(packetId);
  //Serial.print("  qos: ");
  //Serial.println(qos);
}

void onMqttUnsubscribe(uint16_t packetId) {
  //Serial.println("Unsubscribe acknowledged.");
  //Serial.print("  packetId: ");
  //Serial.println(packetId);
}

void onMqttMessage(char* topic, char* payload, AsyncMqttClientMessageProperties properties, size_t len, size_t index, size_t total) {
  //Serial.println("Publish received.");
  //Serial.println("  topic: ");
  //Serial.println(topic);
  //Serial.println(payload);
  char payloadString[len];
  memcpy(payloadString, payload, len);
  payloadString[len] = '\0'; 
  //Serial.println(payloadString);
 // Serial.print("  qos: ");
  //Serial.println(properties.qos);
  //Serial.print("  dup: ");
  //Serial.println(properties.dup);
  //Serial.print("  retain: ");
  //Serial.println(properties.retain);
 //Serial.print("  len: ");
  //Serial.println(len);
  //Serial.print("  index: ");
  //Serial.println(index);
  //Serial.print("  total: ");
  //Serial.println(total);
 
  if (String(topic) == "homesky/light")
  {
    //Serial.println(1);
    if (String(payloadString) == "on")
    {
       au16data[5] = uint16_t(1);
       //Serial.println(2);
    }else{
       au16data[5] = uint16_t(0);
       //Serial.println(3);
    }
    //Serial.println(au16data[0]);
  }else if (String(topic) == "homesky/socket") {
      if (String(payloadString) == "on")
    {
       au16data[6] = uint16_t(1);
       //Serial.println(2);
    }else{
       au16data[6] = uint16_t(0);
       //Serial.println(3);
    }
  }else if (String(topic) == "homesky/temp") {
    au16data[7] = uint16_t(atoi(payloadString));
  }

}

void onMqttPublish(uint16_t packetId) {
  //Serial.println("Publish acknowledged.");
  //Serial.print("  packetId: ");
  //Serial.println(packetId);
}

void setup() {
  Serial.begin(115200);


  wifiConnectHandler = WiFi.onStationModeGotIP(onWifiConnect);
  wifiDisconnectHandler = WiFi.onStationModeDisconnected(onWifiDisconnect);

  mqttClient.onConnect(onMqttConnect);
  mqttClient.onDisconnect(onMqttDisconnect);
  mqttClient.onSubscribe(onMqttSubscribe);
  mqttClient.onUnsubscribe(onMqttUnsubscribe);
  mqttClient.onMessage(onMqttMessage);
  mqttClient.onPublish(onMqttPublish);
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);

  connectToWifi();
  slave.start();
}

void loop() {
  timeClient.update();
  if (WiFi.isConnected())
  {
    au16data[0] = 1;
  }else
  {
    au16data[0] = 0;
  }

  if (mqttClient.connected())
  {
    au16data[1] = 1;
  }
  else{
    au16data[1] = 0;
  }

  au16data[2] = timeClient.getHours();
  au16data[3] = timeClient.getMinutes();
  au16data[4] = timeClient.getDay();
  
  slave.poll( au16data, 16 );
  
  }
