import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:provider/provider.dart';
import 'mqtt.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MQTTService>(context, listen: false);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TemperaturePage()),
        );
      },
      child: Container(
        // Your widget code here
        height: 200,
        width: 200,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff363E50), Color(0xff2E3648)]),
            //color: Color(0xff333D4D),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: Color(0xff222939),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: Offset(-8, 20))
            ]),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Container(
                height: 105,
                width: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Center(
                  child: Text('${mqttService.temp} C',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                'Water Temperature',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TemperaturePage extends StatefulWidget {
  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MQTTService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SleekCircularSlider(
              appearance: CircularSliderAppearance(
                size: 200,
                startAngle: 130,
                angleRange: 280,
                customWidths: CustomSliderWidths(progressBarWidth: 15),
                customColors: CustomSliderColors(
                  progressBarColor: Colors.orange,
                  trackColor: Colors.black,
                ),
              ),
              min: 10,
              max: 30,
              initialValue: double.parse(mqttService.temp),
              onChange: (double value) {
                setState(() {
                  mqttService.temp = value.round().toString();
                  mqttService.changeStatus('homesky/temp', mqttService.temp);
                });
              },
              innerWidget: (double value) {
                return Align(
                  alignment: Alignment(0.0, 0.2),
                  child: Text(
                    '${mqttService.temp} C',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                    Container(
                      width: 150, height: 40,
                      child: ElevatedButton(
                          onPressed: () {
                            debugPrint("on");
                          },
                          child: Text('On')),
                    ),
                //Expanded(child: SizedBox(width: 5)),
                
                    Container(
                      width: 150, height: 40,
                      child: ElevatedButton(
                          onPressed: () {
                            debugPrint("save");
                          },
                          child: Text('Save')),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
