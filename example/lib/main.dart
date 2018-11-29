import 'package:flutter/material.dart';

import 'package:awareframework_openweather/awareframework_openweather.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  OpenWeatherSensor sensor;
  OpenWeatherSensorConfig config;

  @override
  void initState() {
    super.initState();

    config = OpenWeatherSensorConfig()
      ..debug    = true
      ..interval = 1
      ..apiKey   = "54e5dee2e6a2479e0cc963cf20f233cc";

    sensor = new OpenWeatherSensor(config);

    sensor.start();

  }

  @override
  Widget build(BuildContext context) {


    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin Example App'),
          ),
          body: new OpenWeatherCard(sensor: sensor,)
      ),
    );
  }
}
