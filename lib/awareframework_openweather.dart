import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';

/// init sensor
class OpenWeatherSensor extends AwareSensorCore {
  static const MethodChannel _openWeatherMethod = const MethodChannel('awareframework_openweather/method');
  static const EventChannel  _openWeatherStream  = const EventChannel('awareframework_openweather/event');

  OpenWeatherSensor(OpenWeatherSensorConfig config):this.convenience(config);
  OpenWeatherSensor.convenience(config) : super(config){
    super.setMethodChannel(_openWeatherMethod);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> get onDataChanged{
    return super.getBroadcastStream(_openWeatherStream, "on_data_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }

  @override
  void cancelAllEventChannels() {
    super.cancelBroadcastStream("on_data_changed");
  }
}

class OpenWeatherSensorConfig extends AwareSensorConfig {
  OpenWeatherSensorConfig();

  int interval  = 15; // 15min
  String apiKey = "YOUR_API_KEY";

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map["interval"] = interval;
    map["apiKey"] = apiKey;
    if (apiKey == "YOUR_API_KEY") {
      print("[Error][Open Weather Plugin]Please use your API key for Open Weather API");
    }
    return map;
  }
}

/// Make an AwareWidget
class OpenWeatherCard extends StatefulWidget {
  OpenWeatherCard({Key key, @required this.sensor }) : super(key: key);

  final OpenWeatherSensor sensor;

  String data = "";

  @override
  OpenWeatherCardState createState() => new OpenWeatherCardState();
}


class OpenWeatherCardState extends State<OpenWeatherCard> {

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          widget.data = event.toString();
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }


  @override
  Widget build(BuildContext context) {
    return new AwareCard(
      contentWidget: SizedBox(
          width: MediaQuery.of(context).size.width*0.8,
          child: new Text(widget.data),
        ),
      title: "Open Weather",
      sensor: widget.sensor
    );
  }

  @override
  void dispose() {
    widget.sensor.cancelAllEventChannels();
    super.dispose();
  }

}
