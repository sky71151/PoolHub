import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MQTTService extends ChangeNotifier {
  late MqttServerClient client;

  //pool parameters
  
  String _lightStatus = 'off';
  String _socketStatus = 'off';
  bool _firstMessageReceived = false;
  String _temp = '26';
  

  String get lightStatus => _lightStatus;
  String get socketStatus => _socketStatus;
  bool get firstMessageReceived => _firstMessageReceived;
  String get temp => _temp;

  set lightStatus(String value) {
    _lightStatus = value;

    notifyListeners();
  }

  set socketStatus(String value) {
    _socketStatus = value;
    notifyListeners();
  }

  set firstMessageReceived(bool value) {
    _firstMessageReceived = value;
    notifyListeners();
  }

  set temp(String value) {
    _temp = value;
    notifyListeners();
  }

  Future<void> connect() async {
    client = MqttServerClient.withPort('public.mqtthq.com', 'skyw8617', 1883);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('roberto')
        .startClean() // Non persistent session for testing
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      await client.connect();
    }
    // Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('Client connected');
    } else {
      debugPrint(
          'ERROR: MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      await client.connect();
    }
    // Subscribe to the topics
    client.subscribe('homesky/light', MqttQos.atLeastOnce);
    client.subscribe('homesky/socket', MqttQos.atLeastOnce);
    client.subscribe('homesky/temp', MqttQos.atLeastOnce);

    // Define the callback function
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      debugPrint('Received message: $pt from topic: ${c[0].topic}>');
      firstMessageReceived = true;


      if (c[0].topic == 'homesky/light') {
        // Update the status of the light

        lightStatus = pt;
        debugPrint('Light status: $lightStatus');

      } else if (c[0].topic == 'homesky/socket') {
        // Update the status of the socket

        socketStatus = pt;
        debugPrint('Socket status: $socketStatus');
      }else if (c[0].topic == 'homesky/temp') {
        // Update the status of the socket

        temp = pt;
        debugPrint('Socket status: $temp');
      }
    });
  }

  void onDisconnected() {
    debugPrint('Disconnected');
  }

  void onConnected() {
    debugPrint('Connected');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed topic: $topic');
  }

  void changeStatus(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
        retain: true);
    debugPrint("save");
  }

  bool connected() {
    return client.connectionStatus!.state == MqttConnectionState.connected;
  }

  void subscribe() {

    // Subscribe to the parameters topics
    client.subscribe('client/parameters/ph', MqttQos.atLeastOnce);
    client.subscribe('client/parameters/orp', MqttQos.atLeastOnce);
    client.subscribe('client/parameters/pump', MqttQos.atLeastOnce);
    client.subscribe('client/parameters/temp', MqttQos.atLeastOnce);

    //subscribe to the user lever topics
    client.subscribe('client/userlevel/temp', MqttQos.atLeastOnce);
    client.subscribe('client/userlevel/filtration', MqttQos.atLeastOnce);
    client.subscribe('client/userlevel/light', MqttQos.atLeastOnce);
    client.subscribe('client/userlevel/cover', MqttQos.atLeastOnce);
    client.subscribe('client/userlevel/desinfection', MqttQos.atLeastOnce);

  }
/*
  void updateParameters(String payload) {

     final message = jsonDecode(payload);

  if (message.containsKey('temp')) {
    temp = double.parse(message['temp'].toString());
  }
  if (message.containsKey('filtration')) {
    filtration = message['filtration'].toString() == 'true';
  }
  if (message.containsKey('light')) {
    light = message['light'].toString() == 'true';
  }
  if (message.containsKey('cover')) {
    cover = message['cover'].toString() == 'true';
  }
  if (message.containsKey('desinfection')) {
    desinfection = message['desinfection'].toString() == 'true';
  }

  notifyListeners(); // Notify listeners to update the UI


  }*/

  
}
