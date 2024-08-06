import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class gauge_meters extends StatelessWidget {
  const gauge_meters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:20.0),
      child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          radial(),
          radial()
        ],
      ),
    );
  }
}

class radial extends StatefulWidget {
  const radial({
    super.key,
  });

  @override
  State<radial> createState() => _radialState();
}

class _radialState extends State<radial> {
  @override
  Widget build(BuildContext context) {
    return Container(width: 200, height: 200, child: SfRadialGauge(axes: <RadialAxis> [RadialAxis(minimum: 0, maximum: 100, showLabels: false, showTicks: false, axisLineStyle: AxisLineStyle(cornerStyle: CornerStyle.bothCurve,color: Colors.white30,thickness: 25),)],));
  }
}