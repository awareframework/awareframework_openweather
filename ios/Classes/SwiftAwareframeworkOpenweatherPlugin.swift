import Flutter
import UIKit
import SwiftyJSON
import com_awareframework_ios_sensor_openweather
import com_awareframework_ios_sensor_core
import awareframework_core

public class SwiftAwareframeworkOpenWeatherPlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler, OpenWeatherObserver{

    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        if self.sensor == nil {
            if let config = call.arguments as? Dictionary<String,Any>{
                self.openWeatherSensor = OpenWeatherSensor.init(OpenWeatherSensor.Config(config))
            }else{
                self.openWeatherSensor = OpenWeatherSensor.init(OpenWeatherSensor.Config())
            }
            self.openWeatherSensor?.CONFIG.sensorObserver = self
            return self.openWeatherSensor
        }else{
            return nil
        }
    }

    var openWeatherSensor:OpenWeatherSensor?

    public override init() {
        super.init()
        super.initializationCallEventHandler = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        // add own channel
        super.setChannels(with: registrar,
                          instance: SwiftAwareframeworkOpenWeatherPlugin(),
                          methodChannelName: "awareframework_openweather/method",
                          eventChannelName: "awareframework_openweather/event")

    }

    public func onDataChanged(data: OpenWeatherData) {
        for handler in self.streamHandlers {
            if handler.eventName == "on_data_changed" {
                handler.eventSink(data.toDictionary())
            }
        }
    }
}
