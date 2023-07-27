#import "RichflyerSdkFlutterPlugin.h"
#if __has_include(<richflyer_sdk_flutter/richflyer_sdk_flutter-Swift.h>)
#import <richflyer_sdk_flutter/richflyer_sdk_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "richflyer_sdk_flutter-Swift.h"
#endif

@implementation RichflyerSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRichflyerSdkFlutterPlugin registerWithRegistrar:registrar];
}
@end
