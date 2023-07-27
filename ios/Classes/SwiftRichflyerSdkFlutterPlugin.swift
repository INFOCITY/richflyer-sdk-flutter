import Flutter
import UIKit
import RichFlyer
import UserNotifications


public class SwiftRichflyerSdkFlutterPlugin: NSObject, FlutterPlugin{
    
    static var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "jp.co.infocity/richflyer", binaryMessenger: registrar.messenger())
        let instance = SwiftRichflyerSdkFlutterPlugin()
        if let channel = channel{
            registrar.addMethodCallDelegate(instance, channel: channel)
        }
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method{
            
        case "RFInitialize":
            // 初期化
            // フォアグラウンド通知の初期化
            let initOptions: UNNotificationPresentationOptions = []
            let initRawValue = initOptions.rawValue
            UserDefaults.standard.set(initRawValue, forKey: "RICHFLYER_NOTIFICATION_OPTION")
            
            guard let arguments =  call.arguments as? [String:Any],
                  let settings = arguments["settings"] as? [String:Any]
            else {
                result(FlutterError(code: "argument error", message: "argument error", details: nil))
                break
            }
            RFInitialize(settings: settings)
            
        case "registerSegments":
            // セグメントの登録
            guard let arguments =  call.arguments as? [String:Any],
                  let segments = arguments["segments"] as? [String:String]
            else {
                result(FlutterError(code: "argument error", message: "argument error", details: nil))
                break
            }
            registerSegments(segments: segments)
            
        case "getSegments":
            // セグメントの取得
            result(getSegments())
            
        case "getReceivedData":
            // 通知の受信履歴を取得する
            result(getReceivedData())
            
        case "getLatestReceivedData":
            // 最新のプッシュ通知を取得する
            result(getLatestReceivedData())
            
        case "showReceivedData":
            // 受信した通知の表示
            guard let notificationId =  call.arguments as? String else {break}
            
            showReceivedData(notificationId : notificationId)
            
        case "openNotification":
            // 通知の開封
            break

        case "resetBadgeNumber":
            RFApp.resetBadgeNumber(application: UIApplication.shared)

        case "setForegroundNotification":
            guard let options =  call.arguments as? [String:Any],
            let badge = options["badge"] as? Bool,
            let alert = options["alert"] as? Bool,
            let sound = options["sound"] as? Bool else {
                result(FlutterError(code: "argument error", message: "argument error", details: nil))
                break
            }
            var presentationOptions:UNNotificationPresentationOptions = []
            
            if badge {
                presentationOptions.insert(.badge)
            }
            if alert {
                presentationOptions.insert(.alert)
            }
            if sound {
                presentationOptions.insert(.sound)
            }
            
            let rawValue = presentationOptions.rawValue
            UserDefaults.standard.set(rawValue, forKey: "RICHFLYER_NOTIFICATION_OPTION")
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // デバイストークンを登録
    public func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        RFApp.registDevice(deviceToken: deviceToken, completion: { (result: RFResult) in
            if let channel = SwiftRichflyerSdkFlutterPlugin.channel {
                let dictionaries:[String: Any] = ["result":result.result,"message":result.message,"code":result.code]
                do {
                    let data = try JSONSerialization.data(withJSONObject: dictionaries, options: [])
                    if let json = String(data: data, encoding: .utf8) {
                        channel.invokeMethod("onCallbackResult", arguments: json)
                    }
                } catch {}
            }
        })
    }
    
    // 初期化
    private func RFInitialize(settings:[String:Any]) {
        
        let rfCustomAppDelegate = RFCustomAppDelegate()
        
        settings.forEach { (key, value) in
            switch key {
            case "RICHFLYER_SERVICE_KEY":
                rfCustomAppDelegate.serviceKey = value as? String
            case "RICHFLYER_APP_GROUP_ID":
                rfCustomAppDelegate.appgroupId = value as? String
            case "RICHFLYER_SANDBOX":
                rfCustomAppDelegate.sandbox = value as? Bool
            case "RICHFLYER_TEXT":
                guard let text = value as? Bool else {break}
                if(text){
                    rfCustomAppDelegate.RFlaunchOptions.append(.text)
                }
            case "RICHFLYER_IMAGE":
                guard let image = value as? Bool else {break}
                if(image){
                    rfCustomAppDelegate.RFlaunchOptions.append(.image)
                }
            case "RICHFLYER_GIF":
                guard let gif = value as? Bool else {break}
                if(gif){
                    rfCustomAppDelegate.RFlaunchOptions.append(.gif)
                }
            case "RICHFLYER_MOVIE":
                guard let movie = value as? Bool else {break}
                if(movie){
                    rfCustomAppDelegate.RFlaunchOptions.append(.movie)
                }
            case "RICHFLYER_UNIQUE_DIALOG":
                rfCustomAppDelegate.isUniquelDialog = true
                rfCustomAppDelegate.prompt = value as? Dictionary<String, String>
            default: break
            }
        }
        _ = rfCustomAppDelegate.application(UIApplication.shared,didFinishLaunchingWithOptions: nil)
    }
    
    // セグメントを登録する
    private func registerSegments(segments:[String:String]) {
        RFApp.registSegments(segments: segments, completion: { (result: RFResult) in
            if let channel = SwiftRichflyerSdkFlutterPlugin.channel {
                let dictionaries:[String: Any] = ["result":result.result,"message":result.message,"code":result.code]
                do {
                    let data = try JSONSerialization.data(withJSONObject: dictionaries, options: [])
                    if let json = String(data: data, encoding: .utf8) {
                        channel.invokeMethod("onCallbackResult", arguments: json)
                    }
                } catch {}
            }
        })
    }
    
    // セグメントの取得
    private func getSegments() -> [String:String]? {
        guard let savedSegments: [String:String] = RFApp.getSegments() else {return nil}
        return savedSegments
    }
    
    // 通知の受信履歴を取得する
    private func getReceivedData() -> String? {
        guard let receivedData: [RFContent] = RFApp.getReceivedData() else {return nil}
        let dictionaries = receivedData.map { $0.toDictionary() }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionaries, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    // 最新のプッシュ通知を取得する
    private func getLatestReceivedData() -> String? {
        guard let latestData = RFApp.getLatestReceivedData(),
              let dictionaries = latestData.toDictionary() else {
            return nil
        }
        return toJson(obj: dictionaries)
    }
    
    // 受信した通知の表示
    private func showReceivedData(notificationId : String) {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let rootVC = window.rootViewController else { return }

        guard let contentArray = RFApp.getReceivedData() else {return}
        
        contentArray.forEach({ content in
          if (content.notificationId != notificationId) {
            return
          }
          let display = RFContentDisplay.init(content: content)
          display.present(parent: rootVC, completeHandler:{ (action : RFAction) in

              guard let channel = SwiftRichflyerSdkFlutterPlugin.channel else {return}

              let actDictionaries:[String:Any] = ["notificationId": content.notificationId, "actionTitle":action.title, "actionType":action.type, "actionValue":action.value, "notifyAction":String(action.index)]
              let dictionaries:[String:Any] = ["action":actDictionaries,"notificationId":content.notificationId]

              do {
                  let data = try JSONSerialization.data(withJSONObject: dictionaries, options: [])
                  if let json = String(data: data, encoding: .utf8) {
                      channel.invokeMethod("onRFEventLaunchAppIOS", arguments: json)
                  }
              } catch {}

              display.dismiss()
          })
      })
    }
    
    // jsonへ変換する
    private func toJson(obj:[String:Any]) -> String?{
        guard let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)else{
            return nil
        }
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    }
    
}

extension RFContent {
    func toDictionary() -> [String:Any]?{
        var dictionary = [String:Any]()
        dictionary["actionButtonArray"] = []
        dictionary["title"] = self.title
        dictionary["message"] = self.body
        dictionary["notificationId"] = self.notificationId
        dictionary["imagePath"] = self.imagePath?.absoluteString
        if let date = self.receivedDate {
            dictionary["receivedDate"] = date.timeIntervalSince1970
        }
        switch self.type{
        case .text:
            dictionary["contentType"] = 0
        case .image:
            dictionary["contentType"] = 1
        case .gif:
            dictionary["contentType"] = 2
        case .movie:
            dictionary["contentType"] = 3
        default:
            dictionary["contentType"] = 4
        }
        if let date = self.notificationDate {
            dictionary["notificationDate"] = date.timeIntervalSince1970
        }
        dictionary.removeValue(forKey: "type")
        dictionary.removeValue(forKey: "body")
        
        return dictionary
    }
}

