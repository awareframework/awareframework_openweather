import 'package:test/test.dart';
import 'package:awareframework_openweather/awareframework_openweather.dart';

void main(){
  test("test sensor config", (){
    var config = OpenWeatherSensorConfig();
    expect(config.debug, false);
  });
}