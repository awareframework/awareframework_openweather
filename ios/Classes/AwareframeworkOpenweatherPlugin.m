#import "AwareframeworkOpenweatherPlugin.h"
#import <awareframework_openweather/awareframework_openweather-Swift.h>

@implementation AwareframeworkOpenweatherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftAwareframeworkOpenWeatherPlugin registerWithRegistrar:registrar];
}
@end
