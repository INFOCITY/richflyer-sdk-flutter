import Flutter
import UIKit
import RichFlyer

@UIApplicationMain
public class RFCustomAppDelegate: FlutterAppDelegate {
    
    var serviceKey:String?
    var appgroupId:String?
    var sandbox:Bool?
    var RFlaunchOptions:Array<RFContentType> = []
    var isUniquelDialog:Bool? = false
    var prompt:Dictionary<String, String>?
    
    public override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        guard let servicekey = self.serviceKey,let appgroupId = self.appgroupId, let sandbox = self.sandbox, let isUniquelDialog = self.isUniquelDialog else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        // 管理サイトで発行されたSDK実行キーを設定
        RFApp.setServiceKey(serviceKey: servicekey,
                            appGroupId: appgroupId,
                            sandbox: sandbox)
        // //通知のDelegate設定
        RFApp.setRFNotficationDelegate(delegate: self)

        // アプリ起動時の通知オプション
        RFApp.setLaunchMode(modes: RFlaunchOptions)

        //OSに対してプッシュ通知受信の許可をリクエスト
        if !isUniquelDialog{
            RFApp.requestAuthorization(application: UIApplication.shared, applicationDelegate: self)
        } else {
            if let rfPrompt = prompt, let title = rfPrompt["title"], let message = rfPrompt["message"], let imageName = rfPrompt["imageName"] {
                RFAlertController(application: UIApplication.shared, title:title , message: message)
                    .addImage(imageName: imageName)
                    .present(completeHandler: {
                        RFApp.requestAuthorization(application: UIApplication.shared, applicationDelegate: UIApplication.shared.delegate!)
                })
            } else {
                RFApp.requestAuthorization(application: UIApplication.shared, applicationDelegate: self)
            }
        }

        return true
    }
    
    // 通知の開封オプション
    public override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if #available(iOS 10.0, *) {
            // 通知のdelegate設定
            RFApp.setRFNotficationDelegate(delegate: self)
        }
        return true
    }
}

@available(iOS 10, *)
extension RFCustomAppDelegate: RFNotificationDelegate {
    
    // アプリ起動時の通知情報取得
    public func dismissedContentDisplay(_ action : RFAction?, content: RFContent?) {
        guard let channel = SwiftRichflyerSdkFlutterPlugin.channel else {
            return
        }

        guard let action = action else {return}
        guard let content = content else {return}

         var notificationId = content.notificationId
         let actDictionaries : [String:String] = ["notificationId": "", "actionTitle":action.title, "actionType":action.type, "actionValue":action.value, "notifyAction":String(action.index)]
         let dictionaries : [String:Any] = ["action": actDictionaries, "notificationId": notificationId]

        do {
            let data = try JSONSerialization.data(withJSONObject: dictionaries, options: [])
            if let json = String(data: data, encoding: .utf8) {
                channel.invokeMethod("onRFEventLaunchAppIOS", arguments: json)
            }
        } catch {}
    }
    
    // フォアグラウンドの時にも通知を受信する設定
    public func willPresentNotification(_: UNUserNotificationCenter,
                                 willPresent _: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if let rawValue = UserDefaults.standard.value(forKey: "RICHFLYER_NOTIFICATION_OPTION") as? UInt {
            let options = UNNotificationPresentationOptions(rawValue: rawValue)
            // optionsを使用して必要な処理を行う
            RFApp.willPresentNotification(options: options, completionHandler: completionHandler)
        }
    }
    
    
    // 通知センターからプッシュ通知が開封された時
    public func didReceiveNotification(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
    parseReceivedNotification(response, retry: 0, withCompletionHandler: completionHandler)
  }
  
  private func parseReceivedNotification(_ response:UNNotificationResponse,
                                         retry:Int,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
    if (!SwiftRichflyerSdkFlutterPlugin.initialized) {
      if (retry > 5) {
        completionHandler()
        return;
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        self?.parseReceivedNotification(response, retry: retry+1, withCompletionHandler: completionHandler)
      }
      return;
    }
    
    RFApp.didReceiveNotification(response: response) { (act, extendedProperty) in
        guard let channel = SwiftRichflyerSdkFlutterPlugin.channel else {
          return
        }

        var dictionaries:[String:Any] = [:]

        var notificationId = ""
        if let value = RFApp.getLatestReceivedData()?.notificationId {
            dictionaries["notificationId"] = value
            notificationId = value
        }

        if let action = act {
          let actDictionaries = ["notificationId":notificationId, "actionTitle":action.title, "actionType":action.type, "actionValue":action.value, "notifyAction":String(action.index)]
          dictionaries["action"] = actDictionaries
        }

        dictionaries["extendedProperty"] = extendedProperty ?? ""
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionaries, options: [])
            if let json = String(data: data, encoding: .utf8) {
                channel.invokeMethod("openNotificationButtonIOS", arguments: json)
            }
        } catch {
            
        }
        
    }
    completionHandler()
  }
}
