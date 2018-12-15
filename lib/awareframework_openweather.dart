import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';


/// The OpenWeather measures the acceleration applied to the sensor
/// built-in into the device, including the force of gravity.
///
/// Your can initialize this class by the following code.
/// ```dart
/// var sensor = OpenWeatherSensor();
/// ```
///
/// If you need to initialize the sensor with configurations,
/// you can use the following code instead of the above code.
/// ```dart
/// var config =  OpenWeatherSensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
///
/// var sensor = OpenWeatherSensor.init(config);
/// ```
///
/// Each sub class of AwareSensor provides the following method for controlling
/// the sensor:
/// - `start()`
/// - `stop()`
/// - `enable()`
/// - `disable()`
/// - `sync()`
/// - `setLabel(String label)`
///
/// `Stream<OpenWeatherData>` allow us to monitor the sensor update
/// events as follows:
///
/// ```dart
/// sensor.onDataChanged.listen((data) {
///   print(data)
/// }
/// ```
///
/// In addition, this package support data visualization function on Cart Widget.
/// You can generate the Cart Widget by following code.
/// ```dart
/// var card = OpenWeatherCard(sensor: sensor);
/// ```
class OpenWeatherSensor extends AwareSensor {
  static const MethodChannel _openWeatherMethod = const MethodChannel('awareframework_openweather/method');
  // static const EventChannel  _openWeatherStream  = const EventChannel('awareframework_openweather/event');

  static const EventChannel _onDataChangedStream = const EventChannel('awareframework_openweather/event_on_data_changed');
  StreamController<OpenWeatherData> onDataChangedStreamController = StreamController<OpenWeatherData>();

  OpenWeatherData weatherData = OpenWeatherData();

  /// Init OpenWeather Sensor without a configuration file
  ///
  /// ```dart
  /// var sensor = OpenWeatherSensor.init(null);
  /// ```
  OpenWeatherSensor():this.init(null);

  /// Init OpenWeather Sensor with OpenWeatherSensorConfig
  ///
  /// ```dart
  /// var config =  OpenWeatherSensorConfig();
  /// config
  ///   ..debug = true
  ///   ..frequency = 100;
  ///
  /// var sensor = OpenWeatherSensor.init(config);
  /// ```
  OpenWeatherSensor.init(OpenWeatherSensorConfig config) : super(config){
    super.setMethodChannel(_openWeatherMethod);
  }

  /// An event channel for monitoring sensor events.
  ///
  /// `Stream<OpenWeatherData>` allow us to monitor the sensor update
  /// events as follows:
  ///
  /// ```dart
  /// sensor.onDataChanged.listen((data) {
  ///   print(data)
  /// }
  ///
  Stream<OpenWeatherData> get onDataChanged{
    onDataChangedStreamController.close();
    onDataChangedStreamController = StreamController<OpenWeatherData>();
    return onDataChangedStreamController.stream;
  }

  @override
  Future<Null> start() {
    super.getBroadcastStream(_onDataChangedStream, "on_data_changed").map(
            (dynamic event) => OpenWeatherData.from(Map<String,dynamic>.from(event))
    ).listen((event){
      this.weatherData = event;
      if(!onDataChangedStreamController.isClosed){
        onDataChangedStreamController.add(event);
      }
    });
    return super.start();
  }

  @override
  Future<Null> stop() {
    super.cancelBroadcastStream("on_data_changed");
    return super.stop();
  }

}

/// A configuration class of OpenWeatherSensor
///
/// You can initialize the class by following code.
///
/// ```dart
/// var config =  OpenWeatherSensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
/// ```
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


/// A data model of OpenWeatherSensor
///
/// This class converts sensor data that is Map<String,dynamic> format, to a
/// sensor data object.
///
class OpenWeatherData extends AwareData {

  Map<String,dynamic> source;

  String city = "";
  double temperature = 0.0;
  double temperatureMax = 0.0;
  double temperatureMin = 0.0;
  String unit = "";
  double humidity = 0.0;
  double pressure = 0.0;

  double windSpeed = 0.0;
  double windDegrees = 0.0;

  double cloudiness = 0.0;
  int    weatherIconId = 0;
  String weatherDescription = "";
  double rain = 0.0;
  double snow = 0.0;
  int sunrise = 0;
  int sunset  = 0;

  OpenWeatherData():this.from(null);
  OpenWeatherData.from(Map<String,dynamic> data):super.from(data){
    if(data!=null){
      city = data["city"] ?? "";
      temperature = data["temperature"] ?? 0.0;
      temperatureMax = data["temperatureMax"] ?? 0.0;
      temperatureMin = data["temperatureMin"] ?? 0.0;
      unit = data["unit"] ?? "";
      humidity = data["humidity"]  ?? 0.0;
      pressure = data["pressure"]  ?? 0.0;
      windSpeed = data["windSpeed"]  ?? 0.0;
      windDegrees = data["windDegrees"]  ?? 0.0;
      cloudiness = data["cloudiness"] ?? 0.0;
      weatherIconId = data["weatherIconId"] ?? 0;
      weatherDescription = data["weatherDescription"] ?? "";
      rain = data["rain"] ?? 0.0;
      snow = data["snow"] ?? 0.0;
      sunrise = data["sunrise"] ?? 0;
      sunset = data["sunset"] ?? 0;

      source = data;
    }
    print(data);
  }

  @override
  String toString() {
    if(source!=null){
      return source.toString();
    }
    return super.toString();
  }
}


///
/// A Card Widget of OpenWeather Sensor
///
/// You can generate a Cart Widget by following code.
/// ```dart
/// var card = OpenWeatherCard(sensor: sensor);
/// `
class OpenWeatherCard extends StatefulWidget {
  OpenWeatherCard({Key key, @required this.sensor }) : super(key: key);

  final OpenWeatherSensor sensor;

  @override
  OpenWeatherCardState createState() => new OpenWeatherCardState();
}

///
/// A Card State of OpenWeather Sensor
///
class OpenWeatherCardState extends State<OpenWeatherCard> {

  String weatherData = "";

  @override
  void initState() {

    super.initState();

    if(mounted){
      setState((){
        updateContent(widget.sensor.weatherData);
      });
    }

    // set observer
    widget.sensor.onDataChanged.listen((event) {
      if(event!=null){
        if(mounted){
          setState((){
            updateContent(event);
          });
        }else{
          updateContent(event);
        }
      }

    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }

  void updateContent(OpenWeatherData data){
    DateTime.fromMicrosecondsSinceEpoch(data.timestamp);
    weatherData = data.toString();
  }

  @override
  Widget build(BuildContext context) {
    return new AwareCard(
      contentWidget: SizedBox(
          width: MediaQuery.of(context).size.width*0.8,
          child: new Text(weatherData),
        ),
      title: "Open Weather",
      sensor: widget.sensor
    );
  }
}
