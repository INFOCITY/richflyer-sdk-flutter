import UIKit
import Flutter

import richflyer_sdk_flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  let rfCustomDelegate = RFCustomAppDelegate()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    SwiftRichflyerSdkFlutterPlugin.register(delegate: rfCustomDelegate)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
