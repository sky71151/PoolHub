import 'package:flutter/material.dart';
import 'package:pool_controller/mqtt.dart';
import 'Gauges.dart';
import 'Buttons.dart';
import 'TempSlider.dart';
import 'package:provider/provider.dart';


bool firstMessageReceived = false;
bool debug = true;

void main() {
  runApp( ChangeNotifierProvider(
      create: (context) => MQTTService(),
      child: MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MQTT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'PoolHouse'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  
  String lightStatus = 'off';
  String socketStatus = 'off';

  @override
  void initState() {
    super.initState();
    final mqttClient = Provider.of<MQTTService>(context, listen: false);
    mqttClient.connect();
    
    //connect();
    
  }

  void dispose() {
    super.dispose();
  }

  /*Future<void> connect() async {
    client = MqttServerClient.withPort('public.mqtthq.com', 'skyw86', 1883);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('robertosld')
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

    // Define the callback function
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      debugPrint('Received message: $pt from topic: ${c[0].topic}>');
      firstMessageReceived = true;
      if (c[0].topic == 'homesky/light') {
        // Update the status of the light
        setState(() {
          lightStatus = pt;
          debugPrint('Light status: $lightStatus');
        });
      } else if (c[0].topic == 'homesky/socket') {
        // Update the status of the socket
        setState(() {
          socketStatus = pt;
          debugPrint('Socket status: $socketStatus');
        });
      }
    });
  }*/

  // Callback functions for MQTT events
  /*void onDisconnected() {
    debugPrint('Disconnected');
  }

  void onConnected() {
    debugPrint('Connected');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed topic: $topic');
  }*/



  void onLightButtonPressed() {
    // Set the status of the light (e.g., 'on' or 'off')
    final mqttService = Provider.of<MQTTService>(context, listen: false);
    setState(() {
      if (mqttService.lightStatus == 'on') {
        mqttService.lightStatus= 'off';
      } else {
        mqttService.lightStatus = 'on';
      }
    });

    mqttService.changeStatus('homesky/light', mqttService.lightStatus);
  }

  void onSocketButtonPressed() {
    // Set the status of the socket (e.g., 'on' or 'off')
    final mqttService = Provider.of<MQTTService>(context, listen: false);
    setState(() {
      if (mqttService.socketStatus == 'off') {
        mqttService.socketStatus = 'on';
      } else {
       mqttService.socketStatus = 'off';
      }
    });
    mqttService.changeStatus('homesky/socket', mqttService.lightStatus);
  }

  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MQTTService>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff283149),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              mqttService.connected()
                  ? Icons.cloud_done // Icon when connected
                  : Icons.cloud_off, // Icon when disconnected
              color: Colors.white,
            ),
            onPressed: () {
              // Handle the button press here
            },
          ),
        ],
      ),
      //body: client.connectionStatus?.state == MqttConnectionState.connected && firstMessageReceived == false ? ScreenConnected() : ScreenDisconnected() ,
      body: (mqttService.connected() &&
              mqttService.firstMessageReceived == true)
          ? ScreenDomotica()
          : ScreenDisconnected(),
    );
  }

  Center ScreenConnected() {
    final mqttService = Provider.of<MQTTService>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: onLightButtonPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (mqttService.lightStatus == 'on') return Colors.blue;
                  return Colors.red;
                },
              ),
            ),
            child: const Text('Control the light'),
          ),
          ElevatedButton(
            onPressed: onSocketButtonPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (mqttService.socketStatus == 'on') return Colors.blue;
                  return Colors.red;
                },
              ),
            ),
            child: const Text('Control the socket'),
          ),
        ],
      ),
    );
  }

  Center ScreenDisconnected() {
    final mqttService = Provider.of<MQTTService>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
                mqttService.connected() == false
                    ? 'Connecting to the server...'
                    : 'Connected to the server, retrieving data...'),
          ),
        ],
      ),
    );
  }

  ScreenDomotica() {
    final mqttService = Provider.of<MQTTService>(context);
    return Container(
      color: const Color(0xff283142),
      child: Column(
        children: <Widget>[
          gauge_meters(),
          MyWidget(),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                Button_Light(
                  status: mqttService.lightStatus,
                  changeStatus: mqttService.changeStatus,
                  topic: 'homesky/light',
                  iconToDisplay: Icons.settings,
                  name: 'Pump',
                ),
                Button_Light(
                  status: mqttService.socketStatus,
                  changeStatus: mqttService.changeStatus,
                  topic: 'homesky/socket',
                  iconToDisplay: Icons.power,
                  name: 'Socket',
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button_Light(
                  status: mqttService.lightStatus,
                  changeStatus: mqttService.changeStatus,
                  topic: 'homesky/light',
                  iconToDisplay: Icons.lightbulb,
                  name: 'Light',
                ),
                Button_Light(
                  status: mqttService.socketStatus,
                  changeStatus: mqttService.changeStatus,
                  topic: 'homesky/socket',
                  iconToDisplay: Icons.water,
                  name: 'Cover',
                )
              ],
            ),
          ),
            Text('Socket status: ${mqttService.socketStatus}'),
            Text('Socket status: ${mqttService.lightStatus}'),
        ],
      ),

    );
  }

  void debugPrint(String message) {
    if (debug) {
      // ignore: avoid_print
      print(message);
    }
  }
}


